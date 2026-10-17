import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_info.dart';
import '../app.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'app_session.dart';

/// Raiz da interface: monta o app sobre a sessão aberta e o remonta do zero
/// quando a sessão troca (restauração de backup; bloqueio na F5B).
class SessionHost extends StatelessWidget {
  const SessionHost({required this.manager, super.key});

  final SessionManager manager;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        if (manager.phase == SessionPhase.restoring) {
          return const _RestoringApp();
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
            sessionNoticeProvider.overrideWithValue(notice),
          ],
          child: PatrionApp(initialLocation: notice == null ? '/' : '/backup'),
        );
      },
    );
  }
}

class _RestoringApp extends StatelessWidget {
  const _RestoringApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Restaurando o backup…'),
            ],
          ),
        ),
      ),
    );
  }
}
