import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/config/app_info.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/presentation/app.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:patrion/presentation/router/app_router.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('navega para Configurações e mostra as pastas em Sobre', (
    tester,
  ) async {
    await withApp(tester, () async {
      await tester.tap(find.text('Configurações').first);
      await tester.pumpAndSettle();
      expect(find.text('Geral'), findsWidgets);
      await tester.tap(find.byKey(const Key('settings-sobre')));
      await tester.pumpAndSettle();

      expect(find.text('Dados deste computador'), findsOneWidget);
      expect(find.text(r'C:\dados'), findsOneWidget);
      expect(find.text(t.identity.deviceId), findsOneWidget);
    });
  });

  testWidgets('menu: uso diário em cima; Sincronizar e Configurações no '
      'rodapé; todas as seções das Configurações abrem', (tester) async {
    await withApp(tester, () async {
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(
        [for (final d in rail.destinations) (d.label as Text).data],
        // Cadastros saiu do menu (M-06): está em Configurações.
        ['Painel', 'Carteira', 'Operações'],
      );
      final sync = tester.getCenter(find.byKey(const Key('nav-Sincronizar')));
      final settings = tester.getCenter(
        find.byKey(const Key('nav-Configurações')),
      );
      final operations = tester.getCenter(find.text('Operações'));
      expect(sync.dy, greaterThan(operations.dy + 100), reason: 'no rodapé');
      expect(settings.dy, greaterThan(sync.dy), reason: 'sempre por último');

      // Exportar o save: dois cliques a partir de qualquer tela.
      await tester.tap(find.byKey(const Key('nav-Sincronizar')));
      await tester.pumpAndSettle();
      expect(find.text('Salvar arquivo de save'), findsOneWidget);
      expect(find.text('Importar save…'), findsOneWidget);

      for (final (key, text) in [
        ('settings-geral', 'Tema'),
        ('settings-corretoras', 'Instituições e contas'),
        ('settings-seguranca', 'Bloqueio do app'),
        ('settings-fontes', 'Atualizar agora'),
        ('settings-backup', 'Fazer backup agora'),
        ('settings-sincronizacao', 'Histórico'),
        ('settings-sobre', 'Licenças de terceiros'),
      ]) {
        await tester.tap(find.byKey(Key(key)));
        await settleDb(tester);
        expect(find.textContaining(text), findsWidgets, reason: key);
      }
    });
  });

  testWidgets('endereços antigos levam à seção das Configurações', (
    tester,
  ) async {
    await withApp(tester, () async {
      final router = GoRouter.of(tester.element(find.byType(NavigationRail)));
      for (final (old, now) in [
        ('/fontes', Routes.dataSources),
        ('/backup', Routes.backup),
        ('/sincronizacao', Routes.sync),
        ('/cadastros', Routes.registry),
      ]) {
        router.go(old);
        await settleDb(tester);
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          now,
          reason: old,
        );
      }
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
