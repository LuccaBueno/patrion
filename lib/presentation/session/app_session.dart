import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../../application/backup/backup_service.dart';
import '../../core/config/app_info.dart';
import '../../core/config/app_paths.dart';
import '../../core/errors/app_error.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/backup_registry_repository.dart';
import '../../data/sync/device_identity_store.dart';
import '../../data/sync/sync_context.dart';
import '../../data/sync/sync_tables_gateway.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../infrastructure/backup/local_backup_file_system.dart';
import '../../infrastructure/backup/pre_migration_backup.dart';
import '../providers.dart';

final _log = Logger('sessao');

/// Banco aberto e o que depende dele. Existe enquanto o banco está aberto;
/// restaurar um backup (e, na F5B, bloquear o app) fecha a sessão e abre
/// outra (DECISIONS D-24, itens 5 e 6).
class AppSession {
  const AppSession({
    required this.paths,
    required this.db,
    required this.identity,
    required this.sync,
  });

  final AppPaths paths;
  final AppDatabase db;
  final DeviceIdentity identity;
  final SyncContext sync;

  BackupService backupService({
    Clock wallClock = const Clock(),
    int keepAutomatic = 10,
  }) => BackupService(
    registry: BackupRegistryRepository(db),
    files: const LocalBackupFileSystem(),
    backupsDir: paths.backupsDir,
    appVersion: AppInfo.version,
    deviceId: identity.deviceId,
    deviceName: identity.deviceName,
    wallClock: wallClock,
    keepAutomatic: keepAutomatic,
  );
}

/// O que sobrevive à troca do banco numa restauração: a identidade deste PC
/// (com o último HLC) e a lista de backups conhecidos.
class SessionCarryOver {
  const SessionCarryOver({required this.identity, required this.backups});

  final DeviceIdentity identity;
  final List<DevBackupRow> backups;
}

/// Abre o banco na ordem "backup antes de migrar → banco → identidade" (a
/// F5B acrescenta o desbloqueio antes do backup).
///
/// Lança o erro original se algo falhar; o banco aberto é fechado.
Future<AppSession> openSession(
  AppPaths paths, {
  SessionCarryOver? carry,
  Clock wallClock = const Clock(),
}) async {
  // Sem backup válido, o banco não é aberto e a migração não acontece.
  final preMigration =
      PreMigrationBackup(
        backupsDir: paths.backupsDir,
        appVersion: AppInfo.version,
      ).run(
        databaseFile: paths.databaseFile,
        targetVersion: AppDatabase.latestSchemaVersion,
      );
  final db = AppDatabase.open(paths.databaseFile);
  try {
    final store = DeviceIdentityStore(db);
    final DeviceIdentity identity;
    if (carry == null) {
      identity = await store.loadOrCreate(
        deviceName: Platform.localHostname,
        now: wallClock.now(),
      );
    } else {
      identity = await store.adopt(
        carry.identity,
        now: wallClock.now(),
        atLeast: await SyncTablesGateway.maxHlcOf(db),
      );
      await BackupRegistryRepository(db).addAll(carry.backups);
    }
    final session = AppSession(
      paths: paths,
      db: db,
      identity: identity,
      sync: SyncContext(identity: identity, store: store, wallClock: wallClock),
    );
    if (preMigration != null) {
      await session.backupService().registerExisting(
        preMigration,
        BackupReason.preMigration,
      );
    }
    _log.info('Banco aberto (schema ${db.schemaVersion})');
    return session;
  } catch (_) {
    await db.close();
    rethrow;
  }
}

enum SessionPhase { ready, restoring }

/// Controla a sessão aberta: a interface observa e se reconstrói quando a
/// sessão troca.
class SessionManager extends ChangeNotifier implements SessionController {
  SessionManager(
    this._session, {
    Clock wallClock = const Clock(),
    Future<void> Function()? beforeClose,
  }) : _clock = wallClock,
       _beforeClose = beforeClose ?? _endOfFrame;

  static Future<void> _endOfFrame() => WidgetsBinding.instance.endOfFrame;

  final Future<void> Function() _beforeClose;

  AppSession _session;
  final Clock _clock;
  SessionPhase _phase = SessionPhase.ready;
  int _generation = 0;
  String? _notice;

  AppSession get session => _session;
  SessionPhase get phase => _phase;

  /// Muda a cada sessão nova (chave da árvore de widgets).
  int get generation => _generation;

  /// Aviso para mostrar na sessão nova (resultado da restauração).
  String? get notice => _notice;

  /// Restaura o backup [path] (SPEC §11):
  ///
  /// 1. confere o arquivo (integridade, schema, SHA-256);
  /// 2. faz um backup automático do estado atual;
  /// 3. fecha o banco, troca o arquivo e abre de novo (migrando, se o backup
  ///    for de um schema antigo), mantendo a identidade deste PC;
  /// 4. se a abertura falhar, volta o arquivo do passo 2.
  ///
  /// Lança [DataError] se o arquivo for recusado no passo 1 ou se o backup
  /// do passo 2 falhar; nesses casos nada muda.
  @override
  Future<void> restore(String path) async {
    final backups = _session.backupService(wallClock: _clock);
    final candidate = backups.checkRestore(path);
    final safety = await backups.createAutomatic(BackupReason.preRestore);
    final carry = SessionCarryOver(
      identity: DeviceIdentity(
        deviceId: _session.identity.deviceId,
        deviceName: _session.identity.deviceName,
        lastHlc: _session.sync.lastHlc,
      ),
      backups: await BackupRegistryRepository(_session.db).all(),
    );
    final paths = _session.paths;

    _phase = SessionPhase.restoring;
    notifyListeners();
    // Deixa a interface desmontar as telas (e cancelar as consultas) antes
    // de fechar o banco.
    await _beforeClose();
    await _session.db.close();

    const files = LocalBackupFileSystem();
    try {
      files.replaceDatabase(
        backup: candidate.path,
        databaseFile: paths.databaseFile,
      );
      _session = await openSession(paths, carry: carry, wallClock: _clock);
      _notice =
          'Backup restaurado. O estado anterior foi guardado em '
          '${safety.path}.';
      _log.info('Backup restaurado');
    } catch (error, stack) {
      _log.severe(
        'Restauração falhou; voltando ao estado anterior',
        error,
        stack,
      );
      files.replaceDatabase(
        backup: safety.path,
        databaseFile: paths.databaseFile,
      );
      _session = await openSession(paths, carry: carry, wallClock: _clock);
      _notice =
          'A restauração falhou e os dados voltaram ao estado anterior. '
          '${error is AppError ? error.message : ''}';
    }
    _generation++;
    _phase = SessionPhase.ready;
    notifyListeners();
  }
}
