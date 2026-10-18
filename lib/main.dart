import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'core/config/app_info.dart';
import 'core/config/app_paths.dart';
import 'core/config/launch_options.dart';
import 'infrastructure/logging/rotating_file_log.dart';
import 'infrastructure/security/windows_hello.dart';
import 'infrastructure/system/app_paths_resolver.dart';
import 'infrastructure/system/window_setup.dart';
import 'presentation/screens/startup_error_app.dart';
import 'presentation/session/app_session.dart';
import 'presentation/session/session_host.dart';

final _log = Logger('main');

/// Ponto de entrada: monta pastas e logs e abre a sessão do banco (backup
/// antes de migrar, banco e identidade do dispositivo). Com o bloqueio
/// ativo, mostra antes a tela de desbloqueio.
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

    final manager = SessionManager(
      paths: paths,
      hello: WindowsHelloAuthenticator(),
      helloVault: DpapiHelloKeyVault(paths.dataDir),
    );
    // Sem bloqueio, abre o banco; com bloqueio, a tela de desbloqueio abre
    // primeiro e o banco só depois da senha (SPEC §3).
    await manager.start();
    runApp(SessionHost(manager: manager, logsDir: paths.logsDir));
  } catch (error, stack) {
    _log.severe('Falha na inicialização', error, stack);
    runApp(StartupErrorApp(message: '$error', logsDir: paths?.logsDir));
  }
}
