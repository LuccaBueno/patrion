import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/settings/appearance_service.dart';
import '../core/config/app_info.dart';
import 'format/formatters.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'services/open_requests.dart';
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
  OpenRequests? _requests;

  @override
  void initState() {
    super.initState();
    _requests = ref.read(openRequestsProvider)?..addListener(_onOpenRequest);
  }

  /// Um `.invsave` aberto pelo Explorador leva à Sincronização, que o
  /// importa (DECISIONS D-39).
  void _onOpenRequest() {
    if (_requests?.hasPending ?? false) _router.go(Routes.sync);
  }

  @override
  void dispose() {
    _requests?.removeListener(_onOpenRequest);
    _router.dispose();
    super.dispose();
  }

  /// Aplica o olho (M-11): troca o formato do dinheiro e redesenha todas as
  /// telas abertas, sem perder o estado delas (aba, período, rolagem).
  void _applyHideValues(bool hide) {
    if (Fmt.hideMoney == hide) return;
    Fmt.hideMoney = hide;
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    if (mounted) (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) {
    // Na abertura, oculto até ler a preferência (nunca mostra um valor que
    // devia estar oculto); depois, a cada mudança.
    Fmt.hideMoney = ref.read(hideValuesProvider).value ?? true;
    ref.listen(
      hideValuesProvider,
      (_, next) => _applyHideValues(next.value ?? false),
    );
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
