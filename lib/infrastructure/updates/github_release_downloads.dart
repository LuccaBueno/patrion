import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../application/updates/update_installer.dart';
import '../../core/config/app_info.dart';

/// Baixa os arquivos de uma Release por HTTPS, seguindo só redirecionamentos
/// para o GitHub (DECISIONS D-62). O que garante o arquivo é a assinatura;
/// isto só evita baixar de outro lugar por engano.
class GitHubReleaseDownloads implements UpdateDownloads {
  GitHubReleaseDownloads({
    Dio? dio,
    String appVersion = AppInfo.version,
    this.stallTimeout = const Duration(seconds: 60),
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 60),
             ),
           ),
       _userAgent = '${AppInfo.name}/$appVersion';

  static const maxRedirects = 5;

  /// Somas e assinatura são arquivos pequenos.
  static const maxSmallFile = 1024 * 1024;

  /// O instalador tem dezenas de megabytes; isto é só um teto de segurança.
  static const maxInstaller = 500 * 1024 * 1024;

  final Dio _dio;
  final String _userAgent;

  /// Tempo máximo sem receber nenhum byte durante o download.
  final Duration stallTimeout;

  static bool isAllowed(Uri uri) =>
      uri.scheme == 'https' &&
      (uri.host == 'github.com' || uri.host.endsWith('.githubusercontent.com'));

  @override
  Future<Uint8List?> fetch(Uri uri) async {
    final response = await _open(uri, null);
    if (response == null) return null;
    final bytes = BytesBuilder(copy: false);
    await _read(
      response,
      maxSmallFile,
      null,
      (chunk) async => bytes.add(chunk),
    );
    return bytes.takeBytes();
  }

  @override
  Future<void> download(
    Uri uri,
    String target, {
    void Function(int received, int? total)? onProgress,
    UpdateCancel? cancel,
  }) async {
    final token = CancelToken();
    cancel?.onCancel = token.cancel;
    final response = await _open(uri, token);
    if (response == null) {
      throw const UpdateFailure(
        UpdateFailureKind.unavailable,
        'O instalador não foi encontrado na Release.',
      );
    }
    final sink = File(target).openWrite();
    try {
      await _read(response, maxInstaller, onProgress, (chunk) async {
        if (cancel?.cancelled ?? false) throw _cancelled;
        sink.add(chunk);
      });
    } finally {
      await sink.close();
    }
  }

  /// Resposta com o corpo por ler; nulo em 404.
  Future<ResponseBody?> _open(Uri first, CancelToken? token) async {
    var uri = first;
    for (var hop = 0; hop <= maxRedirects; hop++) {
      if (!isAllowed(uri)) {
        throw UpdateFailure(
          UpdateFailureKind.unavailable,
          'Endereço de download recusado: ${uri.host}.',
        );
      }
      final Response<ResponseBody> response;
      try {
        response = await _dio.getUri<ResponseBody>(
          uri,
          cancelToken: token,
          options: Options(
            responseType: ResponseType.stream,
            followRedirects: false,
            validateStatus: (_) => true,
            headers: {'User-Agent': _userAgent},
          ),
        );
      } on DioException catch (e) {
        throw _failure(e);
      }
      final status = response.statusCode ?? 0;
      final body = response.data!;
      if (status >= 300 && status < 400) {
        final location = response.headers.value('location');
        await _discard(body);
        if (location == null) break;
        uri = uri.resolve(location);
        continue;
      }
      if (status == 200) return body;
      await _discard(body);
      if (status == 404) return null;
      throw UpdateFailure(
        UpdateFailureKind.unavailable,
        'O GitHub respondeu com o erro HTTP $status.',
      );
    }
    throw const UpdateFailure(
      UpdateFailureKind.unavailable,
      'Redirecionamentos demais no download.',
    );
  }

  Future<void> _discard(ResponseBody body) => body.stream.listen(null).cancel();

  Future<void> _read(
    ResponseBody body,
    int limit,
    void Function(int received, int? total)? onProgress,
    Future<void> Function(Uint8List chunk) onChunk,
  ) async {
    final length = body.headers['content-length']?.firstOrNull;
    final total = length == null ? null : int.tryParse(length);
    var received = 0;
    try {
      await for (final chunk in body.stream.timeout(stallTimeout)) {
        received += chunk.length;
        if (received > limit) {
          throw const UpdateFailure(
            UpdateFailureKind.unavailable,
            'O arquivo é maior que o esperado.',
          );
        }
        await onChunk(chunk);
        onProgress?.call(received, total);
      }
    } on UpdateFailure {
      rethrow;
    } on DioException catch (e) {
      throw _failure(e);
    } on Exception {
      // Conexão caiu ou parou no meio (socket, HTTP, tempo esgotado).
      throw _interrupted;
    }
    if (total != null && received != total) throw _interrupted;
  }

  static const _cancelled = UpdateFailure(
    UpdateFailureKind.cancelled,
    'Download cancelado.',
  );

  static const _interrupted = UpdateFailure(
    UpdateFailureKind.interrupted,
    'O download foi interrompido. Sua versão continua funcionando; tente de '
    'novo.',
  );

  UpdateFailure _failure(DioException e) {
    if (e.type == DioExceptionType.cancel) return _cancelled;
    final offline =
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.error is SocketException;
    return offline
        ? const UpdateFailure(
            UpdateFailureKind.offline,
            'Sem conexão com a internet. Sua versão continua funcionando.',
          )
        : _interrupted;
  }
}
