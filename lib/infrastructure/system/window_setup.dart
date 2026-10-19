import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import '../../core/config/app_info.dart';

var _windowReady = false;

/// Configura a janela principal (só desktop). Chamadas repetidas não fazem
/// nada.
Future<void> setupMainWindow() async {
  if (_windowReady) return;
  _windowReady = true;
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    title: AppInfo.name,
    minimumSize: Size(960, 640),
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// Traz a janela para a frente (outra instância pediu para abrir um arquivo).
Future<void> bringMainWindowToFront() async {
  if (await windowManager.isMinimized()) await windowManager.restore();
  await windowManager.show();
  await windowManager.focus();
}
