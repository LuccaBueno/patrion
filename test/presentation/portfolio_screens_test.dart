import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:go_router/go_router.dart';
import 'package:patrion/application/settings/appearance_service.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/presentation/widgets/common.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  /// Carteira com caixa, ação com preço e CDB com saldo informado, com o
  /// controle de caixa ligado (M-03; o comportamento da 1.0.0).
  Future<void> seed() async {
    await f.preferences.setTrackCash(true);
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
    await app.run(
      // Janela alta: a lista do Painel constrói todos os cartões.
      size: const Size(1280, 2600),
      () async {
        expect(find.text('Painel'), findsWidgets);
        // Caixa 10.000 − 3.005 − 2.000; mercado 3.500 + 2.100.
        expect(find.text(r'R$ 10.595,00'), findsOneWidget);
        await app.pumpUntil(
          find.descendant(
            of: find.byKey(const Key('stat-applied')),
            matching: find.text(r'R$ 5.005,00'),
          ),
        );
        // Sem números repetidos na Visão geral (M-11): o custo das posições
        // (igual ao aplicado aqui), o caixa e o não realizado ficam no (i)
        // do patrimônio.
        expect(find.text(r'R$ 5.005,00'), findsOneWidget);
        final equityInfo = tester
            .widget<InfoIcon>(find.byKey(const Key('stat-equity-info')))
            .message;
        expect(equityInfo, contains(r'caixa (R$ 4.995,00)'));
        expect(equityInfo, contains(r'(valor investido): R$ 5.005,00'));
        expect(equityInfo, contains(r'+R$ 595,00 (+11,89% sobre o custo'));
        // Ganho total (sem vendas nem proventos): 5.600 − 5.005.
        expect(
          find.descendant(
            of: find.byKey(const Key('stat-gain')),
            matching: find.textContaining(r'+R$ 595,00 (+11,89%)'),
          ),
          findsOneWidget,
        );
        // TIR: −5.005 em 10/01 e +5.600 em 31/05/2024; menos de um ano, então
        // mostra o retorno do período.
        expect(find.text('+11,89% no período'), findsOneWidget);
        expect(
          find.textContaining('de 10/01/2024 a 31/05/2024'),
          findsOneWidget,
        );
        // Distribuição: uma rosca, com o seletor por classe.
        await app.tap(find.byKey(const Key('dist-Classe')));
        expect(find.text('Por classe'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('distribution')),
            matching: find.text('Ações BR'),
          ),
          findsOneWidget,
        );
        expect(
          tester
              .widget<InfoIcon>(find.byKey(const Key('stat-equity-info')))
              .message,
          contains('saldos até 31/05/2024'),
        );
      },
    );
  });

  testWidgets('valores grandes nos cards do dashboard não quebram linha', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await f.preferences.setTrackCash(true);
      await f.add(
        f.draft(
          OperationType.deposit,
          '2024-01-02',
          asset: null,
          gross: '123456789012.34',
        ),
      );
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '1000000', price: '30'),
      );
      await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2024, 5, 31),
        price: dec('35.5'),
      );
    });
    final app = AppHarness(tester, f.t);
    // Janela de 960 px de largura, alta para construir todos os cartões.
    await app.run(size: const Size(960, 4200), () async {
      // O patrimônio não tem rótulo dentro da chave; nos outros, o primeiro
      // parágrafo depois do rótulo é o valor.
      for (final (key, index) in [
        ('stat-equity', 0),
        ('stat-gain', 1),
        ('stat-applied', 1),
        ('stat-realized', 1),
        ('stat-mwr', 1),
      ]) {
        final card = find.byKey(Key(key));
        expect(card, findsOneWidget, reason: key);
        final paragraphs = tester.renderObjectList<RenderParagraph>(
          find.descendant(of: card, matching: find.byType(RichText)),
        );
        final value = paragraphs.elementAt(index);
        final lineHeight = value.getFullHeightForCaret(
          const TextPosition(offset: 0),
        );
        expect(value.size.height, lessThan(lineHeight * 1.5), reason: key);
        expect(value.didExceedMaxLines, isFalse, reason: key);
      }
      // O caixa fica no (i) do patrimônio (M-11).
      expect(
        tester
            .widget<InfoIcon>(find.byKey(const Key('stat-equity-info')))
            .message,
        contains(r'R$ 123.426.789.012,34'),
      );
    });
  });

  testWidgets('detalhe do ativo mostra o desempenho com a metodologia', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira/ativo/${f.petr}', () async {
      // O desempenho (TIR) fica na aba "Dados do ativo" (M-07).
      await app.tap(find.byKey(const Key('tab-data')));
      final card = find.byKey(const Key('asset-performance'));
      expect(card, findsOneWidget);
      // −3.005 em 10/01 e +3.500 em 31/05/2024.
      expect(
        find.descendant(of: card, matching: find.text(r'+R$ 495,00')),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: card, matching: find.text('+16,47% no período')),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: card,
          matching: find.textContaining('de 10/01/2024 a 31/05/2024'),
        ),
        findsOneWidget,
      );
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
      expect(find.byKey(const Key('holding-PETR4')), findsOneWidget);
      // Valor da posição, cotação e valorização; o preço médio continua
      // visível.
      expect(find.text('indisponível'), findsNWidgets(3));
      expect(find.text(r'R$ 30,00'), findsOneWidget);
    });
  });

  testWidgets('preço atual ao lado do preço médio, na carteira e em destaque '
      'no detalhe do ativo', (tester) async {
    await tester.runAsync(() async {
      await f.add(
        f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
      );
      await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2024, 5, 31),
        price: dec('31.84'),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      expect(find.text(r'R$ 30,00'), findsOneWidget);
      final current = find.byKey(const Key('current-price'));
      expect(tester.widget<Text>(current).data, r'R$ 31,84');
      final tip = tester.widget<Tooltip>(
        find.ancestor(of: current, matching: find.byType(Tooltip)).first,
      );
      expect(tip.message, 'Preço informado em 31/05/2024');

      // Detalhes abre a página do ativo: a cotação em destaque num cartão.
      await app.tap(find.byKey(const Key('details-PETR4')));
      expect(
        tester.widget<Text>(find.byKey(const Key('card-price'))).data,
        r'R$ 31,84',
      );
      expect(find.text('informado · 31/05/2024'), findsOneWidget);
    });
  });

  testWidgets('dashboard sem preço avisa que o patrimônio é parcial', (
    tester,
  ) async {
    await tester.runAsync(() => f.preferences.setTrackCash(true));
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
      await app.tap(find.byKey(const Key('asset-more')));
      await app.tap(find.byKey(const Key('inform-price')));
      await app.type(find.byKey(const Key('val-date')), '31/05/2024');
      await app.type(find.byKey(const Key('val-value')), '35,50');
      await app.tap(find.text('Salvar'));

      expect(
        tester
            .widget<SelectableText>(find.byKey(const Key('header-value')))
            .data,
        r'R$ 3.550,00',
      );
      await app.tap(find.byKey(const Key('tab-data')));
      expect(find.text(r'R$ 35,50 em 31/05/2024'), findsOneWidget);
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
          '/fontes',
        ]) {
          GoRouter.of(tester.element(find.byType(NavigationRail))).go(location);
          await app.settle();
          expect(tester.takeException(), isNull, reason: location);
        }
      });
    });
  }

  testWidgets('sem controle de caixa (padrão): patrimônio = posições, sem '
      'card de caixa nem aviso; ligar em Configurações traz o caixa de volta '
      '(M-03)', (tester) async {
    await tester.runAsync(() async {
      await f.add(
        f.draft(OperationType.buy, '2026-10-20', qty: '120', price: '31.08'),
      );
      await f.valuations.setUnitPrice(
        assetId: f.petr,
        refDate: LocalDate(2026, 10, 20),
        price: dec('31.08'),
      );
    });
    final app = AppHarness(tester, f.t);
    // O caixa fica no (i) do patrimônio (M-11).
    String equityInfo() => tester
        .widget<InfoIcon>(find.byKey(const Key('stat-equity-info')))
        .message;
    await app.run(size: const Size(1280, 2600), () async {
      expect(equityInfo(), isNot(contains('caixa')));
      expect(find.textContaining('Caixa negativo'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-equity')),
          matching: find.text(r'R$ 3.729,60'),
        ),
        findsOneWidget,
      );

      await app.tap(find.text('Configurações').first);
      await app.tap(find.byKey(const Key('track-cash')));
      await app.tap(find.text('Painel').first);
      expect(equityInfo(), contains('caixa'));
      expect(find.textContaining('Caixa negativo'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-equity')),
          matching: find.text(r'R$ 0,00'),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('ativo recém-cadastrado, sem operações, mostra a cotação '
      'guardada na página do ativo', (tester) async {
    late String id;
    await tester.runAsync(() async {
      id = await f.registry.createAsset(
        const Asset(
          id: '',
          symbol: 'TAEE11',
          market: Market.b3,
          assetClass: AssetClass.stockBr,
          name: 'Taesa',
          currency: 'BRL',
          country: 'BR',
          priceSource: PriceSource.market,
        ),
      );
      await MarketRepository(f.t.db).saveQuote(
        MarketQuote(
          symbol: 'TAEE11',
          market: 'B3',
          price: dec('44.90'),
          currency: 'BRL',
          refAt: DateTime.utc(2026, 10, 22, 18),
          source: 'brapi',
          dataType: MarketDataType.intraday,
          collectedAt: '2026-10-22T18:01:00.000Z',
        ),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira/ativo/$id', () async {
      expect(
        tester.widget<Text>(find.byKey(const Key('card-price'))).data,
        r'R$ 44,90',
      );
      await app.tap(find.byKey(const Key('tab-data')));
      expect(
        find.descendant(
          of: find.byKey(const Key('asset-market')),
          matching: find.text(r'R$ 44,90'),
        ),
        findsOneWidget,
      );
    });
  });
}
