import 'dart:async';
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

/// Roda [action] antes de a janela fechar (instalar ao fechar, M-14).
Future<void> runBeforeWindowCloses(Future<void> Function() action) async {
  windowManager.addListener(_BeforeClose(action));
  await windowManager.setPreventClose(true);
}

class _BeforeClose with WindowListener {
  _BeforeClose(this._action);

  final Future<void> Function() _action;
  var _closing = false;

  @override
  void onWindowClose() {
    if (_closing) return;
    _closing = true;
    unawaited(_action().whenComplete(windowManager.destroy));
  }
}

/// Traz a janela para a frente (outra instância pediu para abrir um arquivo).
Future<void> bringMainWindowToFront() async {
  if (await windowManager.isMinimized()) await windowManager.restore();
  await windowManager.show();
  await windowManager.focus();
}
