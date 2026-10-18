import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../../application/backup/backup_service.dart';
import '../../application/security/security_ports.dart';
import '../../core/config/app_info.dart';
import '../../core/config/app_paths.dart';
import '../../core/crypto/crypto_box.dart';
import '../../core/crypto/database_key.dart';
import '../../core/errors/app_error.dart';
import '../../core/time/instant_format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/backup_registry_repository.dart';
import '../../data/sync/device_identity_store.dart';
import '../../data/sync/sync_context.dart';
import '../../data/sync/sync_tables_gateway.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../domain/security/key_file.dart';
import '../../domain/security/recovery_key.dart';
import '../../infrastructure/backup/database_file_inspector.dart';
import '../../infrastructure/backup/local_backup_file_system.dart';
import '../../infrastructure/backup/pre_migration_backup.dart';
import '../../infrastructure/security/database_encryption.dart';
import '../../infrastructure/security/key_file_store.dart';
import '../providers.dart';

final _log = Logger('sessao');

/// Banco aberto e o que depende dele. Existe enquanto o banco está aberto;
/// restaurar um backup, bloquear o app e ativar ou desativar o bloqueio
/// fecham a sessão e abrem outra (DECISIONS D-24, itens 5 e 6).
class AppSession {
  const AppSession({
    required this.paths,
    required this.db,
    required this.identity,
    required this.sync,
    this.key,
    this.keys,
  });

  final AppPaths paths;
  final AppDatabase db;
  final DeviceIdentity identity;
  final SyncContext sync;

  /// Chave do banco criptografado (nula sem o bloqueio).
  final DatabaseKey? key;

  /// Arquivo de chaves do bloqueio (nulo sem o bloqueio).
  final KeyFile? keys;

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
    key: key,
    keys: keys,
  );
}

/// O que sobrevive à troca do banco numa restauração: a identidade deste PC
/// (com o último HLC) e a lista de backups conhecidos.
class SessionCarryOver {
  const SessionCarryOver({required this.identity, required this.backups});

  final DeviceIdentity identity;
  final List<DevBackupRow> backups;
}

/// Abre o banco na ordem "desbloqueio ([key]) → backup antes de migrar →
/// banco → identidade".
///
/// Lança o erro original se algo falhar; o banco aberto é fechado.
Future<AppSession> openSession(
  AppPaths paths, {
  SessionCarryOver? carry,
  Clock wallClock = const Clock(),
  DatabaseKey? key,
  KeyFile? keys,
}) async {
  // Sem backup válido, o banco não é aberto e a migração não acontece.
  final preMigration =
      PreMigrationBackup(
        backupsDir: paths.backupsDir,
        appVersion: AppInfo.version,
      ).run(
        databaseFile: paths.databaseFile,
        targetVersion: AppDatabase.latestSchemaVersion,
        key: key,
        keys: keys,
      );
  final db = AppDatabase.open(paths.databaseFile, key: key);
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
      key: key,
      keys: keys,
    );
    if (preMigration != null) {
      await session.backupService().registerExisting(
        preMigration,
        BackupReason.preMigration,
      );
    }
    _log.info(
      'Banco aberto (schema ${db.schemaVersion}'
      '${key == null ? '' : ', criptografado'})',
    );
    return session;
  } catch (_) {
    await db.close();
    rethrow;
  }
}

/// Em que estado está a sessão.
enum SessionPhase {
  /// Banco aberto: o app funciona.
  ready,

  /// Bloqueio ativo e banco fechado: tela de desbloqueio.
  locked,

  /// Trocando o banco (restauração, ativação ou desativação do bloqueio).
  busy,

  /// Não há como abrir o banco (por exemplo, criptografado sem o arquivo de
  /// chaves). A tela mostra [SessionManager.notice].
  failed,
}

/// Abre uma sessão; o padrão é [openSession]. Os testes trocam para simular
/// falhas na reabertura.
typedef SessionOpener = Future<AppSession> Function(
  AppPaths paths, {
  SessionCarryOver? carry,
  Clock wallClock,
  DatabaseKey? key,
  KeyFile? keys,
});

/// Controla a sessão: abre o banco, bloqueia e desbloqueia (SPEC §3), troca
/// o banco numa restauração. A interface observa e se reconstrói do zero a
/// cada sessão nova.
class SessionManager extends ChangeNotifier implements SessionController {
  /// Com [session], começa com essa sessão já aberta (testes); sem ela,
  /// [start] decide como abrir.
  SessionManager({
    required this.paths,
    required this._hello,
    required this._helloVault,
    AppSession? session,
    Clock wallClock = const Clock(),
    Future<void> Function()? beforeClose,
    SessionOpener opener = openSession,
    this.kdfPolicy = KdfPolicy.standard,
  }) : _clock = wallClock,
       _beforeClose = beforeClose ?? _endOfFrame,
       _open = opener,
       _keyStore = KeyFileStore(paths.dataDir),
       _session = session,
       _keys = session?.keys,
       _phase = session == null ? SessionPhase.busy : SessionPhase.ready;

  static Future<void> _endOfFrame() => WidgetsBinding.instance.endOfFrame;

  final AppPaths paths;
  final KdfPolicy kdfPolicy;
  final Future<void> Function() _beforeClose;
  final SessionOpener _open;
  final HelloAuthenticator _hello;
  final HelloKeyVault _helloVault;
  final KeyFileStore _keyStore;
  final Clock _clock;

  AppSession? _session;
  KeyFile? _keys;
  SessionPhase _phase;
  int _generation = 0;
  String? _notice;
  String _busyMessage = 'Abrindo…';
  String _noticeRoute = '/configuracoes';
  String? _pendingRecoveryKey;

  /// Sessão aberta. Só existe na fase [SessionPhase.ready].
  AppSession get session => _session!;
  SessionPhase get phase => _phase;

  /// Muda a cada sessão nova (chave da árvore de widgets).
  int get generation => _generation;

  /// Aviso para mostrar na sessão nova (resultado da restauração ou da
  /// troca do bloqueio), ou o motivo da fase [SessionPhase.failed].
  String? get notice => _notice;

  String get busyMessage => _busyMessage;

  /// Tela onde o [notice] aparece.
  String get noticeRoute => _noticeRoute;

  @override
  bool get lockEnabled => _keys != null;

  @override
  bool get helloEnabled => _keys?.windowsHello ?? false;

  /// Arquivo de chaves (para a tela de desbloqueio).
  KeyFile? get keys => _keys;

  @override
  String? takePendingRecoveryKey() {
    final code = _pendingRecoveryKey;
    _pendingRecoveryKey = null;
    return code;
  }

  String get _now => formatInstant(_clock.now());

  // -- Abrir, bloquear e desbloquear ------------------------------------------

  /// Decide como abrir: sem bloqueio, abre o banco; com bloqueio, vai para a
  /// tela de desbloqueio. Corrige uma ativação ou desativação interrompida.
  Future<void> start() async {
    final db = paths.databaseFile;
    if (DatabaseEncryption.hasPrevious(db)) {
      // Interrompido depois da troca: o banco convertido já está no lugar e
      // o arquivo de chaves combina com ele (ver [enableLock]).
      _log.warning('Conversão do banco interrompida; conferindo');
    }
    final plaintext = DatabaseFileInspector.isPlaintext(db);
    final keys = _keyStore.read();
    if (plaintext) {
      if (keys != null) {
        // Ativação interrompida antes da troca, ou desativação interrompida
        // depois dela: o banco está aberto, então as chaves não valem.
        final aside = _keyStore.setAside();
        _helloVault.delete();
        _log.warning('Arquivo de chaves sem banco criptografado: $aside');
      }
      DatabaseEncryption.discardPrevious(db);
      _keys = null;
      await _openAndPublish();
      return;
    }
    if (keys == null) {
      _phase = SessionPhase.failed;
      _notice =
          'O banco de dados está criptografado, mas o arquivo de chaves '
          '(${KeyFileStore.fileName}) não está na pasta de dados '
          '${paths.dataDir}. Sem ele, o banco não pode ser aberto. Se houver '
          'um backup criptografado, copie o arquivo .keys.json que fica ao '
          'lado dele para a pasta de dados com o nome ${KeyFileStore.fileName} '
          'e abra o Patrion de novo (docs/BACKUP.md).';
      notifyListeners();
      return;
    }
    _keys = keys;
    _phase = SessionPhase.locked;
    notifyListeners();
  }

  /// Desbloqueia com a senha. Lança [DataError] se ela estiver errada.
  Future<void> unlockWithPassword(String password) async {
    final keys = _requireKeys();
    final DatabaseKey key;
    try {
      key = await keys.unlockWithPassword(password);
    } on WrongSecretError {
      _log.info('Senha incorreta no desbloqueio');
      throw const DataError('Senha incorreta.');
    }
    await _openUnlocked(key);
  }

  /// Desbloqueia com a chave de recuperação e define [newPassword] como a
  /// nova senha (SPEC §3).
  Future<void> unlockWithRecoveryKey(String code, String newPassword) async {
    final problem = PasswordPolicy.check(newPassword);
    if (problem != null) throw DataError(problem);
    final keys = _requireKeys();
    final DatabaseKey key;
    try {
      key = await keys.unlockWithRecoveryKey(code);
    } on WrongSecretError {
      _log.info('Chave de recuperação incorreta');
      throw const DataError('Chave de recuperação incorreta.');
    }
    final updated = await keys.withPassword(
      key,
      newPassword,
      now: _now,
      policy: kdfPolicy,
    );
    _keyStore.write(updated);
    _keys = updated;
    _log.info('Senha redefinida pela chave de recuperação');
    await _openUnlocked(key, notice: 'Senha redefinida.');
  }

  /// Desbloqueia pelo Windows Hello. Lança [DataError] se não der.
  Future<void> unlockWithHello() async {
    final keys = _requireKeys();
    if (!keys.windowsHello || !_helloVault.exists) {
      throw const DataError('O Windows Hello não está ativado neste PC.');
    }
    if (!await _hello.verify('Desbloquear o Patrion')) {
      throw const DataError('O Windows Hello não confirmou.');
    }
    final key = _helloVault.load(keys.keyId);
    if (key == null) {
      throw const DataError(
        'A chave do Windows Hello não pode ser lida. Use a senha e ative o '
        'Windows Hello de novo nas Configurações.',
      );
    }
    await _openUnlocked(key);
  }

  @override
  Future<bool> helloAvailable() => _hello.isAvailable();

  /// Fecha o banco, zera a chave e volta à tela de desbloqueio (botão
  /// "Bloquear agora" e bloqueio por inatividade).
  @override
  Future<void> lockNow() async {
    if (_phase != SessionPhase.ready || _keys == null) return;
    final session = _session!;
    _phase = SessionPhase.locked;
    _session = null;
    _notice = null;
    notifyListeners();
    // A interface desmonta as telas (e cancela as consultas) antes de o
    // banco fechar; os provedores da sessão são descartados com ela.
    await _beforeClose();
    await session.db.close();
    session.key?.destroy();
    _log.info('App bloqueado');
  }

  KeyFile _requireKeys() {
    final keys = _keys;
    if (keys == null || _phase != SessionPhase.locked) {
      throw StateError('O app não está bloqueado');
    }
    return keys;
  }

  Future<void> _openUnlocked(DatabaseKey key, {String? notice}) async {
    try {
      await _openAndPublish(key: key, notice: notice);
    } catch (_) {
      key.destroy();
      _phase = SessionPhase.locked;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _openAndPublish({DatabaseKey? key, String? notice}) async {
    _noticeRoute = '/configuracoes';
    _session = await _open(paths, wallClock: _clock, key: key, keys: _keys);
    _notice = notice;
    _generation++;
    _phase = SessionPhase.ready;
    _log.info('Sessão aberta');
    notifyListeners();
  }

  // -- Ativar e desativar o bloqueio ------------------------------------------

  /// Ativa o bloqueio (SPEC §3): gera as chaves, faz um backup do banco
  /// aberto, converte o banco para criptografado, confere e reabre. Se algo
  /// falhar, volta ao banco aberto e lança o erro. Com [encryptBackups],
  /// criptografa também os backups antigos da pasta de backups.
  ///
  /// Devolve a chave de recuperação, para mostrar uma única vez.
  @override
  Future<String> enableLock(
    String password, {
    bool encryptBackups = true,
  }) async {
    final problem = PasswordPolicy.check(password);
    if (problem != null) throw DataError(problem);
    if (_keys != null) throw const DataError('O bloqueio já está ativo.');
    final current = _requireReady();

    final created = await KeyFile.create(
      password: password,
      now: _now,
      policy: kdfPolicy,
    );
    await current
        .backupService(wallClock: _clock)
        .createAutomatic(BackupReason.preLock);
    final db = paths.databaseFile;
    await _closeForChange(current, 'Criptografando o banco de dados…');
    try {
      // Primeiro as chaves, depois a troca: se o app parar entre os dois, o
      // banco ainda está aberto e as chaves são postas de lado ao abrir.
      _keyStore.write(created.file);
      DatabaseEncryption.convert(databaseFile: db, to: created.key);
      _keys = created.file;
      await _openAndPublish(
        key: created.key,
        notice: 'Bloqueio ativado. O banco de dados agora é criptografado.',
      );
      DatabaseEncryption.discardPrevious(db);
    } catch (error, stack) {
      _log.severe('Ativação do bloqueio falhou; voltando', error, stack);
      DatabaseEncryption.restorePrevious(db);
      _keyStore.delete();
      _keys = null;
      created.key.destroy();
      await _openAndPublish(
        notice:
            'Não foi possível ativar o bloqueio. Os dados continuam como '
            'estavam, sem criptografia.',
      );
      throw DataError(
        'Não foi possível ativar o bloqueio. Os dados não foram alterados.',
        cause: error,
      );
    }
    _log.info('Bloqueio ativado');
    if (encryptBackups) {
      final result = await session
          .backupService(wallClock: _clock)
          .encryptExisting();
      if (result.outside.isNotEmpty) {
        _notice =
            '${_notice!} ${result.outside.length} '
            '${result.outside.length == 1 ? 'backup fora da pasta de backups continua' : 'backups fora da pasta de backups continuam'} '
            'sem criptografia.';
        notifyListeners();
      }
    }
    _pendingRecoveryKey = created.recoveryKey;
    return created.recoveryKey;
  }

  /// Desativa o bloqueio (SPEC §3): confere a senha, faz um backup
  /// (criptografado), converte o banco para aberto, apaga as chaves e
  /// reabre. Backups criptografados continuam criptografados.
  @override
  Future<void> disableLock(String password) async {
    final keys = _keys;
    if (keys == null) throw const DataError('O bloqueio não está ativo.');
    final current = _requireReady();
    final key = await _checkPassword(keys, password);
    if (!key.sameAs(current.key)) {
      throw const DataError('As chaves não correspondem ao banco aberto.');
    }
    await current
        .backupService(wallClock: _clock)
        .createAutomatic(BackupReason.preUnlock);
    final db = paths.databaseFile;
    await _closeForChange(current, 'Removendo a criptografia do banco…');
    try {
      // Primeiro a troca, depois as chaves: se o app parar entre os dois, o
      // banco já está aberto e as chaves são postas de lado ao abrir.
      DatabaseEncryption.convert(databaseFile: db, from: key);
      _keys = null;
      await _openAndPublish(
        notice:
            'Bloqueio desativado. O banco de dados não é mais criptografado; '
            'os backups criptografados continuam pedindo a senha.',
      );
      _keyStore.delete();
      _helloVault.delete();
      DatabaseEncryption.discardPrevious(db);
    } catch (error, stack) {
      _log.severe('Desativação do bloqueio falhou; voltando', error, stack);
      DatabaseEncryption.restorePrevious(db);
      _keys = keys;
      await _openAndPublish(
        key: key,
        notice: 'Não foi possível desativar o bloqueio. Nada mudou.',
      );
      throw DataError(
        'Não foi possível desativar o bloqueio. Nada mudou.',
        cause: error,
      );
    } finally {
      current.key?.destroy();
    }
    _log.info('Bloqueio desativado');
  }

  @override
  Future<void> changePassword(String current, String next) async {
    final problem = PasswordPolicy.check(next);
    if (problem != null) throw DataError(problem);
    final keys = _keys;
    if (keys == null) throw const DataError('O bloqueio não está ativo.');
    final session = _requireReady();
    (await _checkPassword(keys, current)).destroy();
    final updated = await keys.withPassword(
      session.key!,
      next,
      now: _now,
      policy: kdfPolicy,
    );
    _keyStore.write(updated);
    _keys = updated;
    _log.info('Senha trocada');
    notifyListeners();
  }

  @override
  Future<String> newRecoveryKey(String password) async {
    final keys = _keys;
    if (keys == null) throw const DataError('O bloqueio não está ativo.');
    final session = _requireReady();
    (await _checkPassword(keys, password)).destroy();
    final (updated, code) = await keys.withNewRecoveryKey(
      session.key!,
      now: _now,
      policy: kdfPolicy,
    );
    _keyStore.write(updated);
    _keys = updated;
    _log.info('Nova chave de recuperação gerada');
    notifyListeners();
    return code;
  }

  @override
  Future<void> setHello(bool enabled) async {
    final keys = _keys;
    if (keys == null) throw const DataError('O bloqueio não está ativo.');
    final session = _requireReady();
    if (enabled) {
      if (!await _hello.isAvailable()) {
        throw const DataError(
          'O Windows Hello não está configurado neste computador.',
        );
      }
      if (!await _hello.verify('Ativar o desbloqueio do Patrion')) {
        throw const DataError('O Windows Hello não confirmou.');
      }
      _helloVault.store(session.key!, keys.keyId);
    } else {
      _helloVault.delete();
    }
    final updated = keys.withWindowsHello(enabled, now: _now);
    _keyStore.write(updated);
    _keys = updated;
    _log.info('Windows Hello ${enabled ? 'ativado' : 'desativado'}');
    notifyListeners();
  }

  Future<DatabaseKey> _checkPassword(KeyFile keys, String password) async {
    try {
      return await keys.unlockWithPassword(password);
    } on WrongSecretError {
      throw const DataError('Senha incorreta.');
    }
  }

  AppSession _requireReady() {
    if (_phase != SessionPhase.ready || _session == null) {
      throw StateError('Sem sessão aberta');
    }
    return _session!;
  }

  Future<void> _closeForChange(AppSession current, String message) async {
    _busyMessage = message;
    _phase = SessionPhase.busy;
    _session = null;
    notifyListeners();
    // Deixa a interface desmontar as telas (e cancelar as consultas) antes
    // de fechar o banco.
    await _beforeClose();
    await current.db.close();
  }

  // -- Restaurar --------------------------------------------------------------

  /// Restaura o backup [path] (SPEC §11):
  ///
  /// 1. confere o arquivo (integridade, schema, SHA-256), abrindo-o com a
  ///    chave atual ou, se for de outra chave, com a derivada de
  ///    [backupSecret];
  /// 2. faz um backup automático do estado atual;
  /// 3. fecha o banco, troca o arquivo (deixando-o com a criptografia atual)
  ///    e abre de novo (migrando, se o backup for de um schema antigo),
  ///    mantendo a identidade deste PC;
  /// 4. se a abertura falhar, volta o arquivo do passo 2.
  ///
  /// Lança [DataError] se o arquivo for recusado no passo 1 ou se o backup
  /// do passo 2 falhar, e `BackupLockedError` se faltar [backupSecret];
  /// nesses casos nada muda.
  @override
  Future<void> restore(String path, {String? backupSecret}) async {
    final current = _requireReady();
    final backups = current.backupService(wallClock: _clock);
    final backupKey = backupSecret == null
        ? null
        : await backups.unlockBackup(path, backupSecret);
    final candidate = backups.checkRestore(path, backupKey: backupKey);
    final safety = await backups.createAutomatic(BackupReason.preRestore);
    final carry = SessionCarryOver(
      identity: DeviceIdentity(
        deviceId: current.identity.deviceId,
        deviceName: current.identity.deviceName,
        lastHlc: current.sync.lastHlc,
      ),
      backups: await BackupRegistryRepository(current.db).all(),
    );
    final key = current.key;

    await _closeForChange(current, 'Restaurando o backup…');
    const files = LocalBackupFileSystem();
    try {
      files.replaceDatabase(
        backup: candidate.path,
        databaseFile: paths.databaseFile,
        backupKey: candidate.key,
        databaseKey: key,
      );
      _session = await _open(
        paths,
        carry: carry,
        wallClock: _clock,
        key: key,
        keys: _keys,
      );
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
        backupKey: key,
        databaseKey: key,
      );
      _session = await _open(
        paths,
        carry: carry,
        wallClock: _clock,
        key: key,
        keys: _keys,
      );
      _notice =
          'A restauração falhou e os dados voltaram ao estado anterior. '
          '${error is AppError ? error.message : ''}';
    } finally {
      if (!identical(backupKey, key)) backupKey?.destroy();
    }
    _noticeRoute = '/backup';
    _generation++;
    _phase = SessionPhase.ready;
    notifyListeners();
  }
}
