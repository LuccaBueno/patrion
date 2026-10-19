import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../core/time/instant_format.dart';
import '../../data/repositories/device_settings_repository.dart';

/// Uma versão publicada (SPEC §19, verificador de atualizações).
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.tag,
    required this.name,
    required this.notes,
    required this.page,
    required this.prerelease,
    this.publishedAt,
  });

  factory ReleaseInfo.fromJson(Map<String, Object?> json) => ReleaseInfo(
    version: Version.parse(json['version']! as String),
    tag: json['tag']! as String,
    name: json['name'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    page: Uri.parse(json['page']! as String),
    prerelease: json['prerelease'] as bool? ?? false,
    publishedAt: switch (json['publishedAt']) {
      final String s => parseInstant(s),
      _ => null,
    },
  );

  final Version version;
  final String tag;
  final String name;

  /// Notas da versão, como publicadas (Markdown).
  final String notes;

  /// Página da versão, com os arquivos para baixar.
  final Uri page;
  final bool prerelease;
  final DateTime? publishedAt;

  Map<String, Object?> toJson() => {
    'version': version.toString(),
    'tag': tag,
    'name': name,
    'notes': notes,
    'page': page.toString(),
    'prerelease': prerelease,
    if (publishedAt != null) 'publishedAt': formatInstant(publishedAt!),
  };
}

/// Fonte das versões publicadas (as Releases do GitHub, na infraestrutura).
abstract interface class ReleaseFeed {
  /// A maior versão publicada; nulo se não houver nenhuma. Rascunhos nunca
  /// entram; pré-lançamentos só com [includePrerelease].
  Future<ReleaseInfo?> latest({required bool includePrerelease});
}

/// Falha ao consultar as versões.
class UpdateCheckFailure implements Exception {
  const UpdateCheckFailure(this.message, {this.offline = false});

  final String message;
  final bool offline;

  @override
  String toString() => message;
}

/// O que o app sabe sobre atualizações, para a interface.
class UpdateSnapshot {
  const UpdateSnapshot({
    required this.current,
    this.automatic = true,
    this.includePrerelease = false,
    this.checkedAt,
    this.latest,
    this.skipped,
  });

  final Version current;

  /// Verificar sozinho ao abrir (no máximo uma vez por dia).
  final bool automatic;

  /// Considerar versões de teste (`-beta`, `-rc`).
  final bool includePrerelease;

  /// Última consulta bem-sucedida.
  final DateTime? checkedAt;

  /// Maior versão encontrada na última consulta.
  final ReleaseInfo? latest;

  /// Versão que o usuário pediu para ignorar.
  final Version? skipped;

  /// Há uma versão mais nova que a instalada (ignorada ou não).
  ReleaseInfo? get newer {
    final l = latest;
    if (l == null || l.version <= current) return null;
    if (l.prerelease && !includePrerelease) return null;
    return l;
  }

  /// Há uma versão mais nova que o usuário não ignorou: o Início avisa.
  ReleaseInfo? get available {
    final n = newer;
    return n == null || n.version == skipped ? null : n;
  }
}

/// Verificador de atualizações (SPEC §19).
///
/// - Consulta a última Release estável e compara pelo SemVer; ignora
///   pré-lançamentos, a não ser que o usuário peça.
/// - Automático: no máximo uma vez a cada [automaticInterval]. Manual: no
///   máximo uma vez a cada [manualInterval]. A API do GitHub sem token
///   permite 60 consultas por hora.
/// - Nunca bloqueia o uso: sem internet, a consulta automática falha em
///   silêncio e tenta de novo na próxima abertura.
/// - O estado fica em `dev_settings` (só deste PC; não vai no save).
class UpdateChecker {
  UpdateChecker({
    required this._settings,
    required this._feed,
    required this._current,
    this._clock = const Clock(),
  });

  static const stateKey = 'updates.state';
  static const automaticInterval = Duration(hours: 24);
  static const manualInterval = Duration(minutes: 1);

  final DeviceSettingsRepository _settings;
  final ReleaseFeed _feed;
  final Version _current;
  final Clock _clock;

  /// Última tentativa nesta execução do app (com ou sem sucesso).
  DateTime? _lastAttempt;

  Stream<UpdateSnapshot> watch() => _settings.watch(stateKey).map(_decode);

  Future<UpdateSnapshot> snapshot() async =>
      _decode(await _settings.get(stateKey));

  /// Consulta automática ao abrir o app. Não faz nada se estiver desligada
  /// ou se a última consulta for recente. Nunca lança.
  Future<UpdateSnapshot> checkIfDue() async {
    final state = await snapshot();
    if (!state.automatic) return state;
    final now = _clock.now();
    final last = state.checkedAt;
    if (last != null && now.difference(last) < automaticInterval) {
      return state;
    }
    if (_lastAttempt != null &&
        now.difference(_lastAttempt!) < automaticInterval) {
      return state;
    }
    try {
      return await _check(state);
    } on UpdateCheckFailure {
      return state;
    }
  }

  /// Consulta pedida pelo usuário. Lança [UpdateCheckFailure].
  Future<UpdateSnapshot> checkNow() async {
    final state = await snapshot();
    final last = _lastAttempt;
    if (last != null && _clock.now().difference(last) < manualInterval) {
      return state;
    }
    return _check(state);
  }

  Future<UpdateSnapshot> _check(UpdateSnapshot state) async {
    _lastAttempt = _clock.now();
    final latest = await _feed.latest(
      includePrerelease: state.includePrerelease,
    );
    final next = UpdateSnapshot(
      current: _current,
      automatic: state.automatic,
      includePrerelease: state.includePrerelease,
      checkedAt: _clock.now(),
      latest: latest,
      skipped: state.skipped,
    );
    await _save(next);
    return next;
  }

  Future<void> skip(Version? version) async {
    final s = await snapshot();
    await _save(
      UpdateSnapshot(
        current: _current,
        automatic: s.automatic,
        includePrerelease: s.includePrerelease,
        checkedAt: s.checkedAt,
        latest: s.latest,
        skipped: version,
      ),
    );
  }

  Future<void> setAutomatic(bool value) async {
    final s = await snapshot();
    await _save(
      UpdateSnapshot(
        current: _current,
        automatic: value,
        includePrerelease: s.includePrerelease,
        checkedAt: s.checkedAt,
        latest: s.latest,
        skipped: s.skipped,
      ),
    );
  }

  /// Trocar a opção invalida a última consulta (o resultado muda).
  Future<void> setIncludePrerelease(bool value) async {
    final s = await snapshot();
    _lastAttempt = null;
    await _save(
      UpdateSnapshot(
        current: _current,
        automatic: s.automatic,
        includePrerelease: value,
        skipped: s.skipped,
      ),
    );
  }

  Future<void> _save(UpdateSnapshot s) => _settings.put(
    stateKey,
    jsonEncode({
      'automatic': s.automatic,
      'includePrerelease': s.includePrerelease,
      if (s.checkedAt != null) 'checkedAt': formatInstant(s.checkedAt!),
      if (s.latest != null) 'latest': s.latest!.toJson(),
      if (s.skipped != null) 'skipped': s.skipped.toString(),
    }),
  );

  UpdateSnapshot _decode(String? json) {
    if (json == null) return UpdateSnapshot(current: _current);
    try {
      final m = jsonDecode(json) as Map<String, Object?>;
      return UpdateSnapshot(
        current: _current,
        automatic: m['automatic'] as bool? ?? true,
        includePrerelease: m['includePrerelease'] as bool? ?? false,
        checkedAt: switch (m['checkedAt']) {
          final String s => parseInstant(s),
          _ => null,
        },
        latest: switch (m['latest']) {
          final Map<String, Object?> r => ReleaseInfo.fromJson(r),
          _ => null,
        },
        skipped: switch (m['skipped']) {
          final String s => Version.parse(s),
          _ => null,
        },
      );
    } on Object {
      // Estado ilegível (versão antiga do app, arquivo mexido): recomeça.
      return UpdateSnapshot(current: _current);
    }
  }
}
