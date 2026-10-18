import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/backup/backup_service.dart';
import '../application/portfolio/operation_service.dart';
import '../application/portfolio/portfolio_query.dart';
import '../application/portfolio/registry_service.dart';
import '../application/portfolio/valuation_service.dart';
import '../application/settings/appearance_service.dart';
import '../application/settings/lock_preferences.dart';
import '../application/sync/save_service.dart';
import '../core/config/app_paths.dart';
import '../core/crypto/database_key.dart';
import '../data/db/app_database.dart';
import '../data/repositories/backup_registry_repository.dart';
import '../data/repositories/device_settings_repository.dart';
import '../data/repositories/portfolio_repositories.dart';
import '../data/repositories/shared_settings_repository.dart';
import '../data/repositories/sync_peers_repository.dart';
import '../data/sync/sync_context.dart';
import '../data/sync/sync_tables_gateway.dart';
import '../domain/security/key_file.dart';
import '../infrastructure/backup/local_backup_file_system.dart';
import 'services/file_dialogs.dart';

/// Ambiente montado na inicialização (`main.dart`). Os provedores abaixo são
/// sobrescritos no `ProviderScope` raiz; nos testes, com um banco em memória.
class AppEnvironment {
  const AppEnvironment({
    required this.paths,
    required this.deviceId,
    required this.deviceName,
    required this.appVersion,
  });

  final AppPaths paths;
  final String deviceId;
  final String deviceName;
  final String appVersion;
}

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final syncContextProvider = Provider<SyncContext>(
  (ref) => throw UnimplementedError('Sobrescrito na inicialização'),
);

final deviceSettingsRepositoryProvider = Provider<DeviceSettingsRepository>(
  (ref) => DeviceSettingsRepository(ref.watch(databaseProvider)),
);

final sharedSettingsRepositoryProvider = Provider<SharedSettingsRepository>(
  (ref) => SharedSettingsRepository(
    ref.watch(databaseProvider),
    ref.watch(syncContextProvider),
  ),
);

final appearanceServiceProvider = Provider<AppearanceService>(
  (ref) => AppearanceService(ref.watch(deviceSettingsRepositoryProvider)),
);

final themePreferenceProvider = StreamProvider<ThemePreference>(
  (ref) => ref.watch(appearanceServiceProvider).watchTheme(),
);

// -- Carteira real (F3) -------------------------------------------------------

final portfolioRepositoriesProvider = Provider<PortfolioRepositories>(
  (ref) => PortfolioRepositories(
    ref.watch(databaseProvider),
    ref.watch(syncContextProvider),
  ),
);

final registryServiceProvider = Provider<RegistryService>(
  (ref) => RegistryService(ref.watch(portfolioRepositoriesProvider)),
);

final operationServiceProvider = Provider<OperationService>(
  (ref) => OperationService(ref.watch(portfolioRepositoriesProvider)),
);

final valuationServiceProvider = Provider<ValuationService>(
  (ref) => ValuationService(ref.watch(portfolioRepositoriesProvider)),
);

final portfolioQueryProvider = Provider<PortfolioQuery>(
  (ref) => PortfolioQuery(ref.watch(portfolioRepositoriesProvider)),
);

/// Retrato da carteira real, recalculado a cada alteração.
final portfolioSnapshotProvider = StreamProvider<PortfolioSnapshot>(
  (ref) => ref.watch(portfolioQueryProvider).watch(),
);

// -- Sessão, backup e save (F5) ----------------------------------------------

/// Troca da sessão do banco: restauração de backup e bloqueio do app (F5B).
/// Nulo nos testes que não montam a sessão.
abstract interface class SessionController implements Listenable {
  /// Restaura o backup [path]. Para um backup criptografado com outra chave,
  /// lança `BackupLockedError` sem [backupSecret] (senha ou chave de
  /// recuperação da época do backup).
  Future<void> restore(String path, {String? backupSecret});

  /// O bloqueio (banco criptografado com senha) está ativo neste PC.
  bool get lockEnabled;

  /// O desbloqueio pelo Windows Hello está ativo.
  bool get helloEnabled;

  Future<bool> helloAvailable();

  /// Criptografa o banco com uma senha nova e devolve a chave de
  /// recuperação (mostrada uma única vez).
  Future<String> enableLock(String password, {bool encryptBackups = true});

  /// A chave de recuperação da última ativação, ainda não mostrada; a tela
  /// a mostra uma vez (a sessão troca na ativação e a tela é remontada).
  String? takePendingRecoveryKey();

  /// Volta ao banco sem criptografia. Pede a senha atual.
  Future<void> disableLock(String password);

  Future<void> changePassword(String current, String next);

  /// Nova chave de recuperação (a anterior deixa de valer).
  Future<String> newRecoveryKey(String password);

  Future<void> setHello(bool enabled);

  /// Fecha o banco e volta à tela de desbloqueio.
  Future<void> lockNow();
}

final sessionControllerProvider = Provider<SessionController?>((ref) => null);

/// Aviso deixado pela troca de sessão (resultado da restauração).
final sessionNoticeProvider = Provider<String?>((ref) => null);

/// Diálogos de arquivo do Windows (sobrescritos nos testes).
final fileDialogsProvider = Provider<FileDialogs>(
  (ref) => const PlatformFileDialogs(),
);

final backupServiceProvider = Provider<BackupService>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  final security = ref.watch(sessionSecurityProvider);
  return BackupService(
    registry: BackupRegistryRepository(ref.watch(databaseProvider)),
    files: const LocalBackupFileSystem(),
    backupsDir: env.paths.backupsDir,
    appVersion: env.appVersion,
    deviceId: env.deviceId,
    deviceName: env.deviceName,
    key: security.key,
    keys: security.keys,
  );
});

final backupsProvider = StreamProvider<List<BackupEntry>>(
  (ref) => ref.watch(backupServiceProvider).watch(),
);

final syncPeersRepositoryProvider = Provider<SyncPeersRepository>(
  (ref) => SyncPeersRepository(ref.watch(databaseProvider)),
);

final saveServiceProvider = Provider<SaveService>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  return SaveService(
    tables: SyncTablesGateway(
      ref.watch(databaseProvider),
      ref.watch(syncContextProvider),
    ),
    peers: ref.watch(syncPeersRepositoryProvider),
    sync: ref.watch(syncContextProvider),
    backups: ref.watch(backupServiceProvider),
    appVersion: env.appVersion,
    deviceName: env.deviceName,
    portfolio: ref.watch(portfolioQueryProvider),
  );
});

final syncPeersProvider = StreamProvider<List<DevSyncPeerRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchPeers(),
);

final syncHistoryProvider = StreamProvider<List<DevSyncHistoryRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchHistory(),
);

// -- Bloqueio (F5B) -----------------------------------------------------------

final lockPreferencesProvider = Provider<LockPreferences>(
  (ref) => LockPreferences(ref.watch(deviceSettingsRepositoryProvider)),
);

/// Minutos sem uso até bloquear (0 = nunca).
final idleMinutesProvider = StreamProvider<int>(
  (ref) => ref.watch(lockPreferencesProvider).watchIdleMinutes(),
);

/// Chave do banco aberto e arquivo de chaves atual, para os backups saírem
/// criptografados com o bloqueio ativo.
class SessionSecurity {
  const SessionSecurity({this.key, this.keys});

  final DatabaseKey? key;

  /// Atualizado quando a senha muda (a sessão continua a mesma).
  final KeyFile? keys;
}

final sessionSecurityProvider = Provider<SessionSecurity>(
  (ref) => const SessionSecurity(),
);

/// Aviso deixado por uma troca do bloqueio (ativar, desativar, recuperar),
/// mostrado nas Configurações.
final lockNoticeProvider = Provider<String?>((ref) => null);
