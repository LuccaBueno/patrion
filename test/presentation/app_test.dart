import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/config/app_info.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/presentation/app.dart';
import 'package:patrion/presentation/providers.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDb t;

  setUp(() async {
    t = await TestDb.open();
  });

  tearDown(() => t.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironment(
              paths: const AppPaths(
                dataDir: r'C:\dados',
                cacheDir: r'C:\cache',
              ),
              deviceId: t.identity.deviceId,
              deviceName: t.identity.deviceName,
              appVersion: AppInfo.version,
            ),
          ),
          databaseProvider.overrideWithValue(t.db),
          syncContextProvider.overrideWithValue(t.sync),
        ],
        child: const PatrionApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Desmonta o app e deixa o Drift encerrar os streams de consulta (ele
  // usa um timer para isso) antes do fim do teste.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  // As consultas do Drift rodam fora do relógio falso do teste.
  Future<void> settleDb(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  // Monta o app, roda [body] e sempre desmonta, mesmo se uma verificação
  // falhar (sem isso o fechamento do banco trava a execução dos testes).
  Future<void> withApp(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    await pumpApp(tester);
    try {
      await body();
    } finally {
      await unmount(tester);
    }
  }

  testWidgets('abre na tela inicial com navegação lateral', (tester) async {
    await withApp(tester, () async {
      expect(find.text('PATRION'), findsWidgets);
      expect(find.text(AppInfo.subtitle), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Nenhum investimento registrado'), findsOneWidget);
    });
  });

  testWidgets('navega para Configurações e mostra as pastas', (tester) async {
    await withApp(tester, () async {
      await tester.tap(find.text('Configurações').first);
      await tester.pumpAndSettle();

      expect(find.text('Dados deste computador'), findsOneWidget);
      expect(find.text(r'C:\dados'), findsOneWidget);
      expect(find.text(t.identity.deviceId), findsOneWidget);
    });
  });

  testWidgets('trocar o tema grava a preferência e aplica', (tester) async {
    await withApp(tester, () async {
      await tester.tap(find.text('Configurações').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Escuro'));
      await settleDb(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      final stored = await tester.runAsync(
        () => t.db.select(t.db.devSettings).getSingle(),
      );
      expect(stored!.valueJson, '"dark"');
    });
  });
}
