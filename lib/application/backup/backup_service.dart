import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../core/crypto/crypto_box.dart';
import '../../core/crypto/database_key.dart';
import '../../core/errors/app_error.dart';
import '../../core/ids/id_generator.dart';
import '../../core/time/instant_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/backup_registry_repository.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../domain/security/key_file.dart';
import 'backup_ports.dart';

final _log = Logger('backup');

/// Backup registrado, com a indicação de o arquivo ainda existir.
class BackupEntry {
  const BackupEntry({required this.row, required this.fileExists});

  final DevBackupRow row;
  final bool fileExists;

  BackupReason? get reason => BackupReason.fromCode(row.reason);

  bool get encrypted => row.encryption != BackupMetadata.encryptionNone;
}

/// Backup conferido e pronto para restaurar.
class RestoreCandidate {
  const RestoreCandidate({
    required this.path,
    required this.info,
    this.metadata,
    this.key,
  });

  final String path;
  final BackupFileInfo info;

  /// Metadados do arquivo `.json` ao lado, se existirem.
  final BackupMetadata? metadata;

  /// Chave que abre o backup (nula se ele não é criptografado).
  final DatabaseKey? key;
}

/// O backup é criptografado com uma chave diferente da atual (de antes de o
/// bloqueio ser desativado e ativado de novo): para restaurá-lo é preciso a
/// senha ou a chave de recuperação daquela época.
class BackupLockedError implements Exception {
  const BackupLockedError(this.path);

  final String path;

  @override
  String toString() => 'BackupLockedError';
}

/// Resultado de [BackupService.encryptExisting].
class EncryptExistingResult {
  const EncryptExistingResult({required this.encrypted, required this.outside});

  /// Backups da pasta de backups que foram criptografados.
  final int encrypted;

  /// Backups sem criptografia fora da pasta de backups (escolhidas pelo
  /// usuário), que ficaram como estavam.
  final List<String> outside;
}

/// Backups do banco deste PC (SPEC §11).
///
/// Backup é a cópia integral do banco, para recuperação: restaurar substitui
/// tudo. É diferente do save, que mescla dados entre PCs.
///
/// - Cópia consistente com `VACUUM INTO` pela conexão aberta, verificada
///   (`integrity_check` e versão) antes de ser registrada. Com o bloqueio
///   ativo (F5B), a cópia sai criptografada com a chave do banco e leva ao
///   lado uma cópia do arquivo de chaves.
/// - Data, motivo, schema e versão do app no nome; metadados com SHA-256 e
///   criptografia num `.json` ao lado e em `dev_backups`.
/// - Retenção: os [keepAutomatic] mais recentes de cada motivo automático;
///   backups manuais nunca são apagados pelo app.
class BackupService {
  BackupService({
    required this._registry,
    required this._files,
    required this.backupsDir,
    required this.appVersion,
    required this.deviceId,
    required this.deviceName,
    this.keepAutomatic = 10,
    Clock wallClock = const Clock(),
    this._ids = const IdGenerator(),
    this._key,
    this._keys,
  }) : _clock = wallClock;

  final BackupRegistryRepository _registry;
  final BackupFileSystem _files;
  final Clock _clock;
  final IdGenerator _ids;
  final String backupsDir;
  final String appVersion;
  final String deviceId;
  final String deviceName;
  final int keepAutomatic;

  /// Chave do banco aberto (nula sem o bloqueio).
  final DatabaseKey? _key;
  final KeyFile? _keys;

  /// Backup manual em [directory] (padrão: a pasta de backups).
  Future<DevBackupRow> createManual({String? directory}) =>
      _create(BackupReason.manual, directory ?? backupsDir);

  /// Backup automático (antes de importar, restaurar, ativar ou desativar o
  /// bloqueio) na pasta de backups.
  Future<DevBackupRow> createAutomatic(BackupReason reason) {
    assert(reason.isAutomatic);
    return _create(reason, backupsDir);
  }

  Future<DevBackupRow> _create(BackupReason reason, String directory) async {
    final at = _clock.now();
    final schema = _registry.schemaVersion;
    final path = _files.newBackupPath(
      directory: directory,
      reason: reason,
      at: at,
      schemaVersion: schema,
      appVersion: appVersion,
    );
    final DevBackupRow row;
    try {
      await _registry.vacuumInto(path);
      final info = _files.inspect(path, key: _key);
      if (!info.integrityOk) {
        throw DataError('integrity_check: ${info.integrity}');
      }
      if (info.schemaVersion != schema) {
        throw DataError('schema ${info.schemaVersion} na cópia');
      }
      if (_key != null && _files.isPlaintext(path)) {
        throw const DataError('cópia sem criptografia');
      }
      final metadata = _metadataFor(
        createdAt: formatInstant(at),
        reason: reason,
        info: info,
        encrypted: _key != null,
      );
      _files.writeMetadata(path, metadata);
      if (_key != null && _keys != null) _files.writeKeyFile(path, _keys);
      row = _rowFor(path, metadata);
      await _registry.add(row);
    } catch (error) {
      _deleteQuietly(path);
      _log.severe('Backup (${reason.code}) falhou', error);
      throw DataError(
        'Não foi possível fazer o backup. Nada foi alterado.',
        cause: error,
      );
    }
    _log.info('Backup (${reason.code}) criado');
    if (reason.isAutomatic) {
      final removed = _files.applyRetention(
        directory: directory,
        reason: reason,
        keep: keepAutomatic,
      );
      await _registry.removePaths(removed);
    }
    return row;
  }

  BackupMetadata _metadataFor({
    required String createdAt,
    required BackupReason reason,
    required BackupFileInfo info,
    required bool encrypted,
  }) => BackupMetadata(
    createdAt: createdAt,
    reason: reason,
    schemaVersion: info.schemaVersion,
    appVersion: appVersion,
    deviceId: deviceId,
    deviceName: deviceName,
    size: info.size,
    sha256: info.sha256,
    encryption: encrypted
        ? BackupMetadata.encryptionSqlcipher
        : BackupMetadata.encryptionNone,
    keyId: encrypted ? _keys?.keyId : null,
  );

  /// Registra em `dev_backups` um backup feito com o banco fechado (antes de
  /// uma migração). Usa os metadados do `.json` ao lado, se houver.
  Future<void> registerExisting(String path, BackupReason reason) async {
    if (await _registry.byPath(path) != null) return;
    final encrypted = !_files.isPlaintext(path);
    final info = _files.inspect(path, key: encrypted ? _key : null);
    final metadata =
        _files.readMetadata(path) ??
        _metadataFor(
          createdAt: formatInstant(_clock.now()),
          reason: reason,
          info: info,
          encrypted: encrypted,
        );
    await _registry.add(_rowFor(path, metadata));
    if (reason.isAutomatic) {
      // A retenção dos arquivos foi feita por quem criou o backup; aqui só
      // esquecemos os que não existem mais.
      final gone = [
        for (final r in await _registry.all())
          if (r.reason == reason.code && !_files.exists(r.path)) r.path,
      ];
      await _registry.removePaths(gone);
    }
  }

  Stream<List<BackupEntry>> watch() => _registry.watchAll().map(
    (rows) => [
      for (final r in rows)
        BackupEntry(row: r, fileExists: _files.exists(r.path)),
    ],
  );

  /// Confere [path] antes de restaurar: banco legível e íntegro, schema que
  /// esta versão abre, identidade do Patrion e, se houver metadados, SHA-256
  /// igual ao do momento do backup.
  ///
  /// Backup criptografado com a chave atual abre com ela. Com outra chave
  /// (o bloqueio foi desativado e ativado de novo depois dele), lança
  /// [BackupLockedError] se [backupKey] não vier: a chave sai de
  /// [unlockBackup] com a senha da época.
  RestoreCandidate checkRestore(String path, {DatabaseKey? backupKey}) {
    if (!_files.exists(path)) {
      throw const DataError('O arquivo de backup não existe mais.');
    }
    final metadata = _files.readMetadata(path);
    final plaintext = _files.isPlaintext(path);
    if (metadata != null && metadata.encrypted == plaintext) {
      throw const DataError(
        'Os metadados do backup não conferem com o arquivo (criptografia '
        'diferente). Ele não será restaurado.',
      );
    }
    DatabaseKey? key;
    if (!plaintext) {
      final sameKey =
          _key != null &&
          (metadata?.keyId == null || metadata!.keyId == _keys?.keyId);
      key = backupKey ?? (sameKey ? _key : null);
      if (key == null) {
        if (_files.readKeyFile(path) == null) {
          throw const DataError(
            'O arquivo não é um banco do Patrion, ou é um backup '
            'criptografado sem o arquivo de chaves (.keys.json) ao lado.',
          );
        }
        throw BackupLockedError(path);
      }
    }
    final info = _files.inspect(path, key: key);
    if (!info.integrityOk) {
      throw const DataError(
        'O backup não passou na verificação de integridade e não pode ser '
        'restaurado.',
      );
    }
    if (info.schemaVersion > _registry.schemaVersion) {
      throw DataError(
        'O backup é de uma versão mais nova do Patrion (schema '
        '${info.schemaVersion}). Atualize o aplicativo para restaurá-lo.',
      );
    }
    if (info.schemaVersion < 1 || info.deviceId == null) {
      throw const DataError('O arquivo não é um backup do Patrion.');
    }
    if (metadata != null && metadata.sha256 != info.sha256) {
      throw const DataError(
        'O arquivo de backup foi alterado depois de criado (SHA-256 '
        'diferente). Ele não será restaurado.',
      );
    }
    return RestoreCandidate(
      path: path,
      info: info,
      metadata: metadata,
      key: key,
    );
  }

  /// Chave de um backup criptografado com outra chave, a partir da senha ou
  /// da chave de recuperação da época (cópia do arquivo de chaves ao lado
  /// dele). Lança [DataError] se não der.
  Future<DatabaseKey> unlockBackup(String path, String secret) async {
    final keys = _files.readKeyFile(path);
    if (keys == null) {
      throw DataError(
        'O backup é criptografado, mas o arquivo de chaves dele '
        '(${p.basename(path)} → .keys.json) não está ao lado. Sem ele, o '
        'backup não pode ser aberto.',
      );
    }
    try {
      return await keys.unlockWithPassword(secret);
    } on WrongSecretError {
      try {
        return await keys.unlockWithRecoveryKey(secret);
      } on WrongSecretError {
        throw const DataError(
          'Senha ou chave de recuperação incorreta para este backup.',
        );
      }
    }
  }

  /// Criptografa, com a chave atual, os backups sem criptografia da pasta de
  /// backups (feitos antes de ativar o bloqueio). Backups em outras pastas
  /// ficam como estão e são listados no resultado.
  Future<EncryptExistingResult> encryptExisting() async {
    final key = _key;
    if (key == null) {
      throw StateError('O bloqueio não está ativo');
    }
    var encrypted = 0;
    final outside = <String>[];
    for (final row in await _registry.all()) {
      if (row.encryption != BackupMetadata.encryptionNone ||
          !_files.exists(row.path)) {
        continue;
      }
      if (!p.isWithin(backupsDir, row.path)) {
        outside.add(row.path);
        continue;
      }
      try {
        _files.encryptInPlace(row.path, key);
        final info = _files.inspect(row.path, key: key);
        final old = _files.readMetadata(row.path);
        final metadata = BackupMetadata(
          createdAt: old?.createdAt ?? row.at,
          reason: old?.reason ?? BackupReason.fromCode(row.reason)!,
          schemaVersion: info.schemaVersion,
          appVersion: old?.appVersion ?? row.appVersion,
          deviceId: old?.deviceId ?? info.deviceId,
          deviceName: old?.deviceName ?? info.deviceName,
          size: info.size,
          sha256: info.sha256,
          encryption: BackupMetadata.encryptionSqlcipher,
          keyId: _keys?.keyId,
        );
        _files.writeMetadata(row.path, metadata);
        if (_keys != null) _files.writeKeyFile(row.path, _keys);
        await _registry.add(
          row.copyWith(
            size: metadata.size,
            sha256: metadata.sha256,
            encryption: metadata.encryption,
          ),
        );
        encrypted++;
      } on Object catch (error) {
        _log.warning('Não consegui criptografar um backup antigo', error);
      }
    }
    _log.info('Backups antigos criptografados: $encrypted');
    return EncryptExistingResult(encrypted: encrypted, outside: outside);
  }

  DevBackupRow _rowFor(String path, BackupMetadata m) => DevBackupRow(
    id: _ids.newId(),
    path: path,
    at: m.createdAt,
    reason: m.reason.code,
    schemaVersion: m.schemaVersion,
    appVersion: m.appVersion,
    size: m.size,
    sha256: m.sha256,
    encryption: m.encryption,
  );

  void _deleteQuietly(String path) {
    try {
      _files.delete(path);
    } on Object {
      // O erro original é o que importa.
    }
  }
}
