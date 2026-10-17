import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import '../../core/config/app_info.dart';

/// Configura a janela principal (só desktop).
Future<void> setupMainWindow() async {
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
