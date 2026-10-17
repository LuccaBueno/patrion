import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'core/config/app_info.dart';
import 'core/config/app_paths.dart';
import 'core/config/launch_options.dart';
import 'infrastructure/logging/rotating_file_log.dart';
import 'infrastructure/system/app_paths_resolver.dart';
import 'infrastructure/system/window_setup.dart';
import 'presentation/screens/startup_error_app.dart';
import 'presentation/session/app_session.dart';
import 'presentation/session/session_host.dart';

final _log = Logger('main');

/// Ponto de entrada: monta pastas e logs, abre a sessão do banco (backup
/// antes de migrar, banco e identidade do dispositivo) e entrega tudo à
/// interface.
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

    final session = await openSession(paths);
    runApp(SessionHost(manager: SessionManager(session)));
  } catch (error, stack) {
    _log.severe('Falha na inicialização', error, stack);
    runApp(StartupErrorApp(message: '$error', logsDir: paths?.logsDir));
  }
}
