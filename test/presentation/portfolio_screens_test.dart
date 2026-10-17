import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:go_router/go_router.dart';
import 'package:patrion/application/settings/appearance_service.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  /// Carteira com caixa, ação com preço e CDB com saldo informado.
  Future<void> seed() async {
    await f.add(
      f.draft(OperationType.deposit, '2024-01-02', asset: null, gross: '10000'),
    );
    await f.add(
      f.draft(
        OperationType.buy,
        '2024-01-10',
        qty: '100',
        price: '30',
        fees: '5',
      ),
    );
    await f.add(
      f.draft(
        OperationType.contribution,
        '2024-01-10',
        asset: f.cdb,
        gross: '2000',
      ),
    );
    await f.valuations.setUnitPrice(
      assetId: f.petr,
      refDate: LocalDate(2024, 5, 31),
      price: dec('35'),
    );
    await f.valuations.setBalance(
      assetId: f.cdb,
      accountId: f.account,
      refDate: LocalDate(2024, 5, 31),
      balance: dec('2100'),
    );
  }

  testWidgets('dashboard mostra totais, resultado e alocação', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(() async {
      expect(find.text('Início'), findsWidgets);
      // Caixa 10.000 − 3.005 − 2.000; mercado 3.500 + 2.100.
      expect(find.text(r'R$ 10.595,00'), findsOneWidget);
      expect(find.text(r'R$ 5.005,00'), findsOneWidget);
      expect(find.text(r'R$ 5.600,00'), findsOneWidget);
      expect(find.text(r'R$ 4.995,00'), findsWidgets);
      expect(find.text(r'+R$ 595,00 (+11,89%)'), findsOneWidget);
      expect(find.text('Alocação por classe'), findsOneWidget);
      expect(find.text('Ações BR'), findsOneWidget);
      expect(find.textContaining('informados até 31/05/2024'), findsOneWidget);
    });
  });

  testWidgets('sem preço, a carteira mostra "indisponível"', (tester) async {
    await tester.runAsync(
      () => f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      ),
    );
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text('indisponível'), findsOneWidget);
      expect(find.text(r'R$ 30,00'), findsOneWidget); // preço médio
    });
  });

  testWidgets('dashboard sem preço avisa que o patrimônio é parcial', (
    tester,
  ) async {
    await tester.runAsync(
      () => f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      ),
    );
    final app = AppHarness(tester, f.t);
    await app.run(() async {
      expect(
        find.textContaining('Parcial: 1 posição sem preço'),
        findsOneWidget,
      );
      expect(find.textContaining('Caixa negativo'), findsOneWidget);
    });
  });

  testWidgets('cria uma compra pelo formulário e ela aparece na lista', (
    tester,
  ) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/operacoes', () async {
      await app.tap(find.byKey(const Key('new-operation')));
      expect(find.byType(AlertDialog), findsOneWidget);

      await app.choose(
        find.byKey(const Key('op-account')),
        'Corretora Exemplo · Principal',
      );
      await app.choose(
        find.byKey(const Key('op-asset')),
        'PETR4 — Petrobras PN',
      );
      await app.type(find.byKey(const Key('op-date')), '10/01/2024');
      await app.type(find.byKey(const Key('op-quantity')), '100');
      await app.type(find.byKey(const Key('op-price')), '30,00');
      await app.type(find.byKey(const Key('op-fees')), '5');
      await app.tap(find.text('Salvar'));

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('10/01/2024'), findsOneWidget);
      expect(find.text(r'R$ 3.000,00'), findsOneWidget);
      expect(find.text(r'R$ 5,00'), findsOneWidget);

      final ops = await tester.runAsync(f.repos.operations.all);
      expect(ops!.single.quantity, dec('100'));
      expect(ops.single.fees, dec('5'));
    });
  });

  testWidgets('formulário mostra os erros de preenchimento', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/operacoes', () async {
      await app.tap(find.byKey(const Key('new-operation')));
      await app.tap(find.text('Salvar'));
      expect(find.text('Obrigatório'), findsWidgets);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  testWidgets('duplicata pede confirmação', (tester) async {
    await tester.runAsync(
      () => f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      ),
    );
    final app = AppHarness(tester, f.t);
    await app.run(location: '/operacoes', () async {
      await app.tap(find.byKey(const Key('new-operation')));
      await app.choose(
        find.byKey(const Key('op-account')),
        'Corretora Exemplo · Principal',
      );
      await app.choose(
        find.byKey(const Key('op-asset')),
        'PETR4 — Petrobras PN',
      );
      await app.type(find.byKey(const Key('op-date')), '10/01/2024');
      await app.type(find.byKey(const Key('op-quantity')), '100');
      await app.type(find.byKey(const Key('op-price')), '30');
      await app.tap(find.text('Salvar'));

      expect(find.text('Possível duplicata'), findsOneWidget);
      await app.tap(find.text('Gravar mesmo assim'));
      final ops = await tester.runAsync(f.repos.operations.all);
      expect(ops, hasLength(2));
    });
  });

  testWidgets('informa o preço no detalhe do ativo', (tester) async {
    await tester.runAsync(
      () => f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      ),
    );
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira/ativo/${f.petr}', () async {
      expect(find.text('PETR4'), findsWidgets);
      await app.tap(find.byKey(const Key('inform-price')));
      await app.type(find.byKey(const Key('val-date')), '31/05/2024');
      await app.type(find.byKey(const Key('val-value')), '35,50');
      await app.tap(find.text('Salvar'));

      expect(find.text(r'R$ 35,50 em 31/05/2024'), findsOneWidget);
      expect(find.text(r'R$ 3.550,00 (31/05/2024)'), findsOneWidget);
    });
  });

  testWidgets('cria uma instituição em Cadastros', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/cadastros', () async {
      await app.tap(find.text('Nova instituição'));
      await app.type(find.byKey(const Key('institution-name')), 'Banco Novo');
      await app.tap(find.text('Salvar'));
      expect(find.text('Banco Novo'), findsOneWidget);
      expect(find.text('Corretora Exemplo'), findsOneWidget);

      // Nome repetido: o erro aparece e o diálogo continua aberto.
      await app.tap(find.text('Nova instituição'));
      await app.type(find.byKey(const Key('institution-name')), 'banco novo');
      await app.tap(find.text('Salvar'));
      expect(
        find.text('Já existe uma instituição com esse nome.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('aba de ativos lista os cadastrados', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/cadastros', () async {
      await app.tap(find.text('Ativos'));
      expect(find.text('PETR4'), findsOneWidget);
      expect(find.text('CDB-EXEMPLO-2026'), findsOneWidget);
      expect(find.text('01/12/2026'), findsOneWidget);
    });
  });

  for (final dark in [false, true]) {
    testWidgets('todas as telas abrem sem erro em janela estreita '
        '(${dark ? 'escuro' : 'claro'})', (tester) async {
      await tester.runAsync(seed);
      if (dark) {
        await tester.runAsync(
          () =>
              DeviceSettingsRepository(f.t.db)
                  .put(AppearanceService.themeKey, '"dark"'),
        );
      }
      final app = AppHarness(tester, f.t);
      await app.run(size: const Size(960, 640), () async {
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, dark ? ThemeMode.dark : ThemeMode.system);
        for (final location in [
          '/',
          '/carteira',
          '/carteira/ativo/${f.cdb}',
          '/carteira/ativo/${f.petr}',
          '/operacoes',
          '/cadastros',
        ]) {
          GoRouter.of(tester.element(find.byType(NavigationRail))).go(location);
          await app.settle();
          expect(tester.takeException(), isNull, reason: location);
        }
      });
    });
  }
}
