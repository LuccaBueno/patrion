import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'core/config/app_info.dart';
import 'core/config/app_paths.dart';
import 'core/config/launch_options.dart';
import 'data/db/app_database.dart';
import 'data/sync/device_identity_store.dart';
import 'data/sync/sync_context.dart';
import 'infrastructure/backup/pre_migration_backup.dart';
import 'infrastructure/logging/rotating_file_log.dart';
import 'infrastructure/system/app_paths_resolver.dart';
import 'infrastructure/system/window_setup.dart';
import 'presentation/app.dart';
import 'presentation/providers.dart';
import 'presentation/screens/startup_error_app.dart';

final _log = Logger('main');

/// Ponto de entrada: monta pastas, logs, banco e identidade do dispositivo
/// e entrega tudo à interface pelos provedores do Riverpod.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupMainWindow();

  AppPaths? paths;
  try {
    paths = await const AppPathsResolver().resolve(LaunchOptions.parse(args));
    setupLogging(logsDir: paths.logsDir);
    FlutterError.onError = (details) {
      _log.severe('Erro do Flutter', details.exception, details.stack);
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _log.severe('Erro não tratado', error, stack);
      return true;
    };
    _log.info('Iniciando ${AppInfo.name} ${AppInfo.version}');

    // Sem backup válido, o banco não é aberto e a migração não acontece.
    PreMigrationBackup(
      backupsDir: paths.backupsDir,
      appVersion: AppInfo.version,
    ).run(
      databaseFile: paths.databaseFile,
      targetVersion: AppDatabase.latestSchemaVersion,
    );
    final db = AppDatabase.open(paths.databaseFile);
    final identityStore = DeviceIdentityStore(db);
    final identity = await identityStore.loadOrCreate(
      deviceName: Platform.localHostname,
      now: clock.now(),
    );
    final sync = SyncContext(identity: identity, store: identityStore);
    _log.info('Banco aberto (schema ${db.schemaVersion})');

    runApp(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironment(
              paths: paths,
              deviceId: identity.deviceId,
              deviceName: identity.deviceName,
              appVersion: AppInfo.version,
            ),
          ),
          databaseProvider.overrideWithValue(db),
          syncContextProvider.overrideWithValue(sync),
        ],
        child: const PatrionApp(),
      ),
    );
  } catch (error, stack) {
    _log.severe('Falha na inicialização', error, stack);
    runApp(StartupErrorApp(message: '$error', logsDir: paths?.logsDir));
  }
}
