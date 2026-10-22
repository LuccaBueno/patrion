import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_info.dart';
import '../app.dart';
import '../providers.dart';
import '../screens/security/unlock_screen.dart';
import '../screens/startup_error_app.dart';
import '../screens/updates/update_widgets.dart';
import '../services/market_refresh.dart';
import '../services/open_requests.dart';
import '../theme/app_theme.dart';
import 'app_session.dart';
import 'inactivity_guard.dart';
import '../router/app_router.dart';

/// Raiz da interface: monta o app sobre a sessão aberta e o remonta do zero
/// quando a sessão troca (restauração de backup, bloqueio e desbloqueio).
/// Bloqueado, só existe a tela de desbloqueio: as telas e os provedores da
/// sessão anterior são descartados.
class SessionHost extends StatelessWidget {
  const SessionHost({
    required this.manager,
    this.logsDir,
    this.openRequests,
    super.key,
  });

  final SessionManager manager;
  final String? logsDir;

  /// Arquivos recebidos para abrir; esperam o desbloqueio, se houver.
  final OpenRequests? openRequests;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        switch (manager.phase) {
          case SessionPhase.busy:
            return _BusyApp(message: manager.busyMessage);
          case SessionPhase.locked:
            return UnlockApp(manager: manager);
          case SessionPhase.failed:
            return StartupErrorApp(
              message: manager.notice ?? 'Erro desconhecido.',
              logsDir: logsDir,
            );
          case SessionPhase.ready:
            break;
        }
        final session = manager.session;
        final notice = manager.notice;
        return ProviderScope(
          key: ValueKey(manager.generation),
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment(
                paths: session.paths,
                deviceId: session.identity.deviceId,
                deviceName: session.identity.deviceName,
                appVersion: AppInfo.version,
              ),
            ),
            databaseProvider.overrideWithValue(session.db),
            syncContextProvider.overrideWithValue(session.sync),
            sessionControllerProvider.overrideWithValue(manager),
            openRequestsProvider.overrideWithValue(openRequests),
            sessionNoticeProvider.overrideWithValue(
              manager.noticeRoute == Routes.backup ? notice : null,
            ),
            lockNoticeProvider.overrideWithValue(
              manager.noticeRoute == Routes.backup ? null : notice,
            ),
            sessionSecurityProvider.overrideWithValue(
              SessionSecurity(key: session.key, keys: manager.keys),
            ),
          ],
          child: InactivityGuard(
            enabled: manager.lockEnabled,
            onIdle: manager.lockNow,
            child: MarketAutoRefresh(
              child: UpdateAutoCheck(
                child: PatrionApp(
                  initialLocation: notice != null
                      ? manager.noticeRoute
                      : (openRequests?.hasPending ?? false)
                      ? Routes.sync
                      : '/',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BusyApp extends StatelessWidget {
  const _BusyApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
