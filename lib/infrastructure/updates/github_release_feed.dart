import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../application/updates/update_checker.dart';
import '../../core/config/app_info.dart';

/// Versões publicadas nas Releases do GitHub (DECISIONS D-07 e D-40).
///
/// O repositório é público: a consulta não usa token. A requisição leva só o
/// nome do app e a versão no `User-Agent`; nada da carteira.
class GitHubReleaseFeed implements ReleaseFeed {
  GitHubReleaseFeed({
    Dio? dio,
    this.repository = AppInfo.releasesRepository,
    String appVersion = AppInfo.version,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 15),
             ),
           ),
       _userAgent = '${AppInfo.name}/$appVersion';

  final Dio _dio;
  final String repository;
  final String _userAgent;

  String get _api => 'https://api.github.com/repos/$repository/releases';

  @override
  Future<ReleaseInfo?> latest({required bool includePrerelease}) async {
    if (!includePrerelease) {
      // O GitHub já exclui rascunhos e pré-lançamentos de `/latest`.
      final json = await _get('$_api/latest');
      if (json == null) return null;
      return _parse(json as Map<String, Object?>);
    }
    final json = await _get('$_api?per_page=30');
    ReleaseInfo? best;
    for (final item in (json as List?) ?? const []) {
      final release = item as Map<String, Object?>;
      if (release['draft'] == true) continue;
      final info = _parse(release);
      if (info == null) continue;
      if (best == null || info.version > best.version) best = info;
    }
    return best;
  }

  /// Corpo JSON; nulo em 404 (nenhuma Release publicada).
  Future<Object?> _get(String url) async {
    try {
      final response = await _dio.get<Object?>(
        url,
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'User-Agent': _userAgent,
          },
          validateStatus: (_) => true,
        ),
      );
      final status = response.statusCode ?? 0;
      if (status == 404) return null;
      if (status == 403 || status == 429) {
        throw const UpdateCheckFailure(
          'O GitHub limitou as consultas deste computador. Tente de novo '
          'mais tarde.',
        );
      }
      if (status != 200) {
        throw UpdateCheckFailure('O GitHub respondeu com o erro HTTP $status.');
      }
      return response.data;
    } on DioException catch (e) {
      final offline =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException;
      throw UpdateCheckFailure(
        offline
            ? 'Sem conexão com a internet.'
            : 'Não foi possível consultar o GitHub (${e.type.name}).',
        offline: offline,
      );
    }
  }

  ReleaseInfo? _parse(Map<String, Object?> json) {
    final tag = json['tag_name'];
    if (tag is! String) return null;
    final Version version;
    try {
      version = Version.parse(tag.startsWith('v') ? tag.substring(1) : tag);
    } on FormatException {
      return null; // tag fora do padrão vX.Y.Z
    }
    return ReleaseInfo(
      version: version,
      tag: tag,
      name: json['name'] as String? ?? tag,
      notes: json['body'] as String? ?? '',
      page: _safePage(json['html_url'], tag),
      prerelease: json['prerelease'] == true || version.isPreRelease,
      publishedAt: switch (json['published_at']) {
        final String s => DateTime.tryParse(s)?.toUtc(),
        _ => null,
      },
    );
  }

  /// Só abre páginas do próprio repositório no GitHub.
  Uri _safePage(Object? url, String tag) {
    final fallback = Uri.parse(
      'https://github.com/$repository/releases/tag/$tag',
    );
    if (url is! String) return fallback;
    final uri = Uri.tryParse(url);
    final ok =
        uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'github.com' &&
        uri.path.startsWith('/$repository/');
    return ok ? uri : fallback;
  }
}
