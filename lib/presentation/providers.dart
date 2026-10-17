import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portfolio/operation_service.dart';
import '../application/portfolio/portfolio_query.dart';
import '../application/portfolio/registry_service.dart';
import '../application/portfolio/valuation_service.dart';
import '../application/settings/appearance_service.dart';
import '../core/config/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/repositories/device_settings_repository.dart';
import '../data/repositories/portfolio_repositories.dart';
import '../data/repositories/shared_settings_repository.dart';
import '../data/sync/sync_context.dart';

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
