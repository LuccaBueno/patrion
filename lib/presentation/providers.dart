import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/settings/appearance_service.dart';
import '../core/config/app_paths.dart';
import '../data/db/app_database.dart';
import '../data/repositories/device_settings_repository.dart';
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
