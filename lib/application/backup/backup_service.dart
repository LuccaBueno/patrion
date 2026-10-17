import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import '../../core/errors/app_error.dart';
import '../../core/ids/id_generator.dart';
import '../../core/time/instant_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/backup_registry_repository.dart';
import '../../domain/backup/backup_metadata.dart';
import 'backup_ports.dart';

final _log = Logger('backup');

/// Backup registrado, com a indicação de o arquivo ainda existir.
class BackupEntry {
  const BackupEntry({required this.row, required this.fileExists});

  final DevBackupRow row;
  final bool fileExists;

  BackupReason? get reason => BackupReason.fromCode(row.reason);
}

/// Backup conferido e pronto para restaurar.
class RestoreCandidate {
  const RestoreCandidate({
    required this.path,
    required this.info,
    this.metadata,
  });

  final String path;
  final BackupFileInfo info;

  /// Metadados do arquivo `.json` ao lado, se existirem.
  final BackupMetadata? metadata;
}

/// Backups do banco deste PC (SPEC §11).
///
/// Backup é a cópia integral do banco, para recuperação: restaurar substitui
/// tudo. É diferente do save, que mescla dados entre PCs.
///
/// - Cópia consistente com `VACUUM INTO` pela conexão aberta, verificada
///   (`integrity_check` e versão) antes de ser registrada.
/// - Data, motivo, schema e versão do app no nome; metadados com SHA-256 e
///   campo de criptografia num `.json` ao lado e em `dev_backups`.
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

  /// Backup manual em [directory] (padrão: a pasta de backups).
  Future<DevBackupRow> createManual({String? directory}) =>
      _create(BackupReason.manual, directory ?? backupsDir);

  /// Backup automático (antes de importar ou restaurar) na pasta de backups.
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
      final info = _files.inspect(path);
      if (!info.integrityOk) {
        throw DataError('integrity_check: ${info.integrity}');
      }
      if (info.schemaVersion != schema) {
        throw DataError('schema ${info.schemaVersion} na cópia');
      }
      final metadata = BackupMetadata(
        createdAt: formatInstant(at),
        reason: reason,
        schemaVersion: schema,
        appVersion: appVersion,
        deviceId: deviceId,
        deviceName: deviceName,
        size: info.size,
        sha256: info.sha256,
      );
      _files.writeMetadata(path, metadata);
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

  /// Registra em `dev_backups` um backup feito com o banco fechado (antes de
  /// uma migração). Usa os metadados do `.json` ao lado, se houver.
  Future<void> registerExisting(String path, BackupReason reason) async {
    if (await _registry.byPath(path) != null) return;
    final info = _files.inspect(path);
    final metadata =
        _files.readMetadata(path) ??
        BackupMetadata(
          createdAt: formatInstant(_clock.now()),
          reason: reason,
          schemaVersion: info.schemaVersion,
          appVersion: appVersion,
          deviceId: info.deviceId,
          deviceName: info.deviceName,
          size: info.size,
          sha256: info.sha256,
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
  /// esta versão abre, identidade do Patrion, sem criptografia (F5B) e, se
  /// houver metadados, SHA-256 igual ao do momento do backup.
  RestoreCandidate checkRestore(String path) {
    if (!_files.exists(path)) {
      throw const DataError('O arquivo de backup não existe mais.');
    }
    final info = _files.inspect(path);
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
    final metadata = _files.readMetadata(path);
    if (metadata != null) {
      if (metadata.encryption != BackupMetadata.encryptionNone) {
        throw const DataError(
          'Este backup é criptografado, o que esta versão do Patrion ainda '
          'não abre.',
        );
      }
      if (metadata.sha256 != info.sha256) {
        throw const DataError(
          'O arquivo de backup foi alterado depois de criado (SHA-256 '
          'diferente). Ele não será restaurado.',
        );
      }
    }
    return RestoreCandidate(path: path, info: info, metadata: metadata);
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
