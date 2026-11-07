import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import '../../core/time/instant_format.dart';
import '../../data/repositories/device_settings_repository.dart';
import 'update_checker.dart';

/// Por que uma atualização não foi adiante.
enum UpdateFailureKind {
  offline,
  interrupted,
  cancelled,
  unavailable,
  notSigned,
  badSignature,
  badHash,
  install,
}

/// Falha na atualização: a versão instalada continua funcionando.
class UpdateFailure implements Exception {
  const UpdateFailure(this.kind, this.message);

  final UpdateFailureKind kind;
  final String message;

  @override
  String toString() => message;
}

/// Pedido de cancelamento de um download.
class UpdateCancel {
  bool cancelled = false;

  /// Definido por quem baixa, para interromper a conexão.
  void Function()? onCancel;

  void cancel() {
    cancelled = true;
    onCancel?.call();
  }
}

/// Download dos arquivos da Release (GitHub, na infraestrutura).
abstract interface class UpdateDownloads {
  /// Arquivo pequeno; nulo se não existir. Lança [UpdateFailure].
  Future<Uint8List?> fetch(Uri uri);

  /// Grava em [target]. Lança [UpdateFailure].
  Future<void> download(
    Uri uri,
    String target, {
    void Function(int received, int? total)? onProgress,
    UpdateCancel? cancel,
  });
}

/// Confere a assinatura de [message] (conteúdo do `.minisig`).
typedef SignatureCheck = Future<bool> Function(
  List<int> message,
  String signatureFile,
);

/// Inicia o instalador sem esperar por ele.
typedef InstallerStart = Future<void> Function(
  String installer,
  List<String> arguments,
);

/// Instalador baixado e conferido, pronto para rodar.
class PreparedUpdate {
  const PreparedUpdate({
    required this.release,
    required this.installer,
    required this.sha256,
  });

  final ReleaseInfo release;
  final String installer;

  /// Soma assinada, em hexadecimal.
  final String sha256;
}

/// O que aconteceu com a atualização pedida antes da última abertura.
class UpdateOutcome {
  const UpdateOutcome({
    required this.updated,
    required this.from,
    required this.to,
    this.notes = '',
    this.log,
  });

  final bool updated;
  final Version from;
  final Version to;
  final String notes;

  /// Log do instalador (mostrado quando a atualização não aconteceu).
  final String? log;
}

/// Atualização pelo próprio app (M-14; SPEC §19; DECISIONS D-62).
///
/// 1. [prepare] baixa `SHA256SUMS.txt` e a assinatura, confere a assinatura
///    com a chave pública embutida, exige a linha do instalador desta versão,
///    baixa o instalador e confere o SHA-256. Se algo falhar, apaga o arquivo.
/// 2. [install] confere o arquivo de novo, faz o backup, grava o pedido e
///    inicia o instalador, que espera o app fechar.
/// 3. Na abertura seguinte, [takeOutcome] diz se a versão mudou.
class UpdateInstaller {
  UpdateInstaller({
    required this._downloads,
    required this._checkSignature,
    required this._settings,
    required this._current,
    required this._startInstaller,
    required this._backup,
    required this.repository,
    required this.cacheDir,
    required this.logsDir,
    required this.relaunchArguments,
    this._clock = const Clock(),
  });

  static const pendingKey = 'updates.pending';
  static const sumsFile = 'SHA256SUMS.txt';
  static const signatureFile = 'SHA256SUMS.txt.minisig';

  final UpdateDownloads _downloads;
  final SignatureCheck _checkSignature;
  final DeviceSettingsRepository _settings;
  final Version _current;
  final InstallerStart _startInstaller;
  final Future<void> Function() _backup;
  final Clock _clock;

  /// Repositório no formato `dono/nome`: o único lugar de onde baixa.
  final String repository;
  final String cacheDir;
  final String logsDir;

  /// Parâmetros do instalador para reabrir este app (`/RELAUNCH=…`).
  final List<String> relaunchArguments;

  String get _updatesDir => p.join(cacheDir, 'updates');

  static String installerName(Version version) =>
      'Patrion-$version-instalador.exe';

  Uri _asset(ReleaseInfo release, String name) => Uri.parse(
    'https://github.com/$repository/releases/download/${release.tag}/$name',
  );

  Future<PreparedUpdate> prepare(
    ReleaseInfo release, {
    void Function(int received, int? total)? onProgress,
    UpdateCancel? cancel,
  }) async {
    if (release.version <= _current || release.tag != 'v${release.version}') {
      throw const UpdateFailure(
        UpdateFailureKind.unavailable,
        'Esta versão não é mais nova que a instalada.',
      );
    }
    final name = installerName(release.version);
    final expected = await _signedHash(release, name);

    final dir = Directory(_updatesDir);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final partial = p.join(dir.path, '$name.part');
    try {
      await _downloads.download(
        _asset(release, name),
        partial,
        onProgress: onProgress,
        cancel: cancel,
      );
      if (await _hashOf(partial) != expected) {
        throw const UpdateFailure(
          UpdateFailureKind.badHash,
          'O instalador baixado não confere com a soma assinada e foi '
          'apagado. Nada foi instalado.',
        );
      }
      final installer = File(partial).renameSync(p.join(dir.path, name));
      return PreparedUpdate(
        release: release,
        installer: installer.path,
        sha256: expected,
      );
    } on Object {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      rethrow;
    }
  }

  /// Soma do instalador, depois de conferir a assinatura do arquivo de somas.
  Future<String> _signedHash(ReleaseInfo release, String name) async {
    final sums = await _downloads.fetch(_asset(release, sumsFile));
    final signature = await _downloads.fetch(_asset(release, signatureFile));
    if (sums == null || signature == null) {
      throw const UpdateFailure(
        UpdateFailureKind.notSigned,
        'Esta versão não tem assinatura. Baixe pela página da Release.',
      );
    }
    final String signatureText;
    final String sumsText;
    try {
      signatureText = utf8.decode(signature);
      sumsText = utf8.decode(sums);
    } on FormatException {
      throw _badSignature;
    }
    if (!await _checkSignature(sums, signatureText)) throw _badSignature;
    final hash = _hashLine(sumsText, name);
    if (hash == null) {
      // Assinado, mas de outra versão: não serve para esta.
      throw const UpdateFailure(
        UpdateFailureKind.badSignature,
        'O arquivo assinado não é desta versão. Nada foi instalado.',
      );
    }
    return hash;
  }

  static const _badSignature = UpdateFailure(
    UpdateFailureKind.badSignature,
    'A assinatura desta versão é inválida. Nada foi baixado nem instalado.',
  );

  static String? _hashLine(String sums, String name) {
    final line = RegExp(r'^([0-9a-f]{64}) [ *](.+)$');
    for (final raw in const LineSplitter().convert(sums)) {
      final m = line.firstMatch(raw.trim());
      if (m != null && m.group(2) == name) return m.group(1);
    }
    return null;
  }

  static Future<String> _hashOf(String path) async =>
      (await sha256.bind(File(path).openRead()).first).toString();

  /// Faz o backup e inicia o instalador. Com [relaunch], o instalador reabre
  /// o app no fim, tenha instalado ou não. Depois disto, o app precisa
  /// fechar. Lança [UpdateFailure] com o app ainda inteiro.
  Future<void> install(PreparedUpdate update, {bool relaunch = true}) async {
    final file = File(update.installer);
    if (!file.existsSync() || await _hashOf(file.path) != update.sha256) {
      throw const UpdateFailure(
        UpdateFailureKind.badHash,
        'O instalador mudou depois do download. Nada foi instalado.',
      );
    }
    try {
      await _backup();
    } on Object {
      throw const UpdateFailure(
        UpdateFailureKind.install,
        'Não foi possível fazer o backup antes de atualizar. Nada foi '
        'instalado.',
      );
    }
    final version = update.release.version;
    final log = p.join(logsDir, 'atualizacao-$version.log');
    await _settings.put(
      pendingKey,
      jsonEncode({
        'from': _current.toString(),
        'to': version.toString(),
        'log': log,
        'at': formatInstant(_clock.now()),
      }),
    );
    try {
      await _startInstaller(file.path, [
        '/SILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
        '/WAITAPP',
        '/LOG=$log',
        if (relaunch) ...relaunchArguments,
      ]);
    } on Object {
      await _settings.put(pendingKey, 'null');
      throw const UpdateFailure(
        UpdateFailureKind.install,
        'Não foi possível iniciar o instalador. Sua versão continua '
        'funcionando.',
      );
    }
  }

  /// Resultado do pedido anterior, uma única vez. As notas vêm de [snapshot].
  Future<UpdateOutcome?> takeOutcome(UpdateSnapshot snapshot) async {
    final json = await _settings.get(pendingKey);
    if (json == null || json == 'null') return null;
    await _settings.put(pendingKey, 'null');
    final dir = Directory(_updatesDir);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    try {
      final m = jsonDecode(json) as Map<String, Object?>;
      final to = Version.parse(m['to']! as String);
      final latest = snapshot.latest;
      return UpdateOutcome(
        updated: _current == to,
        from: Version.parse(m['from']! as String),
        to: to,
        notes: latest != null && latest.version == to ? latest.notes : '',
        log: m['log'] as String?,
      );
    } on Object {
      return null; // pedido ilegível: não há o que mostrar
    }
  }
}
