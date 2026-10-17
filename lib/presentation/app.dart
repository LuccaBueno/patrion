import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/settings/appearance_service.dart';
import '../core/config/app_info.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PatrionApp extends ConsumerStatefulWidget {
  const PatrionApp({super.key, this.initialLocation = '/'});

  final String initialLocation;

  @override
  ConsumerState<PatrionApp> createState() => _PatrionAppState();
}

class _PatrionAppState extends ConsumerState<PatrionApp> {
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preference =
        ref.watch(themePreferenceProvider).value ?? ThemePreference.system;
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (preference) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      },
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router,
    );
  }
}
