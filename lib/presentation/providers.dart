import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/backup/backup_service.dart';
import '../application/portfolio/operation_service.dart';
import '../application/portfolio/portfolio_query.dart';
import '../application/portfolio/registry_service.dart';
import '../application/portfolio/valuation_service.dart';
import '../application/settings/appearance_service.dart';
import '../application/sync/save_service.dart';
import '../core/config/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/repositories/backup_registry_repository.dart';
import '../data/repositories/device_settings_repository.dart';
import '../data/repositories/portfolio_repositories.dart';
import '../data/repositories/shared_settings_repository.dart';
import '../data/repositories/sync_peers_repository.dart';
import '../data/sync/sync_context.dart';
import '../data/sync/sync_tables_gateway.dart';
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

/// Troca da sessão do banco (restauração de backup). Nulo nos testes que não
/// montam a sessão.
abstract interface class SessionController {
  Future<void> restore(String path);
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
  return BackupService(
    registry: BackupRegistryRepository(ref.watch(databaseProvider)),
    files: const LocalBackupFileSystem(),
    backupsDir: env.paths.backupsDir,
    appVersion: env.appVersion,
    deviceId: env.deviceId,
    deviceName: env.deviceName,
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
  );
});

final syncPeersProvider = StreamProvider<List<DevSyncPeerRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchPeers(),
);

final syncHistoryProvider = StreamProvider<List<DevSyncHistoryRow>>(
  (ref) => ref.watch(syncPeersRepositoryProvider).watchHistory(),
);
