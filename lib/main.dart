import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'core/config/app_info.dart';
import 'core/config/app_paths.dart';
import 'core/config/launch_options.dart';
import 'infrastructure/logging/rotating_file_log.dart';
import 'infrastructure/security/windows_hello.dart';
import 'infrastructure/system/app_paths_resolver.dart';
import 'infrastructure/system/single_instance.dart';
import 'infrastructure/system/window_setup.dart';
import 'presentation/screens/startup_error_app.dart';
import 'presentation/services/open_requests.dart';
import 'presentation/session/app_session.dart';
import 'presentation/session/session_host.dart';

final _log = Logger('main');

/// Ponto de entrada: monta pastas e logs e abre a sessão do banco (backup
/// antes de migrar, banco e identidade do dispositivo). Com o bloqueio
/// ativo, mostra antes a tela de desbloqueio.
///
/// Se o app já estiver aberto com a mesma pasta de dados, entrega os
/// arquivos recebidos (o `.invsave` do duplo clique) à janela aberta e
/// termina sem mostrar janela (DECISIONS D-39).
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppPaths? paths;
  try {
    final options = LaunchOptions.parse(args);
    paths = await const AppPathsResolver().resolve(options);
    final gate = await InstanceGate.acquire(paths.instanceDir);
    if (gate == null) {
      await InstanceGate.forward(paths.instanceDir, options.files);
      exit(0);
    }
    await setupMainWindow();
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
    // Só o nome do arquivo vai para o log, nunca o conteúdo.
    void logFiles(Iterable<String> files, String origin) {
      for (final f in files) {
        _log.info('Arquivo recebido para abrir ($origin): ${p.basename(f)}');
      }
    }

    final openRequests = OpenRequests()..addAll(options.files);
    logFiles(options.files, 'linha de comando');
    gate.requests.listen((files) {
      _log.info('Outra instância pediu a janela');
      logFiles(files, 'outra instância');
      openRequests.addAll(files);
      unawaited(bringMainWindowToFront());
    });

    final manager = SessionManager(
      paths: paths,
      hello: WindowsHelloAuthenticator(),
      helloVault: DpapiHelloKeyVault(paths.dataDir),
    );
    // Sem bloqueio, abre o banco; com bloqueio, a tela de desbloqueio abre
    // primeiro e o banco só depois da senha (SPEC §3).
    await manager.start();
    runApp(
      SessionHost(
        manager: manager,
        logsDir: paths.logsDir,
        openRequests: openRequests,
      ),
    );
  } catch (error, stack) {
    _log.severe('Falha na inicialização', error, stack);
    await setupMainWindow();
    runApp(StartupErrorApp(message: '$error', logsDir: paths?.logsDir));
  }
}
