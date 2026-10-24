import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Carteira como lista principal (M-05) e a página do ativo (M-07).
void main() {
  late PortfolioFixture f;
  final ids = <String, String>{};

  setUp(() async {
    f = await PortfolioFixture.open();
    ids.clear();
  });
  tearDown(() => f.t.close());

  Future<String> asset(String symbol, {bool market = false}) =>
      f.registry.createAsset(
        Asset(
          id: '',
          symbol: symbol,
          market: Market.b3,
          assetClass: AssetClass.stockBr,
          name: 'Empresa $symbol',
          currency: 'BRL',
          country: 'BR',
          priceSource: market ? PriceSource.market : PriceSource.manual,
        ),
      );

  /// Cinco ativos: quatro com preço informado e BBAS3 com cotação da brapi
  /// de hoje e fechamentos da B3 (variação do dia e gráfico).
  Future<void> seed() async {
    f.t.wall.now = DateTime(2026, 10, 22, 15);
    ids['BBAS3'] = await asset('BBAS3', market: true);
    for (final s in ['VALE3', 'ITSA4', 'WEGE3']) {
      ids[s] = await asset(s);
    }
    ids['PETR4'] = f.petr;
    Future<void> buy(String s, String qty, String price) => f.add(
      f.draft(
        OperationType.buy,
        '2026-01-05',
        asset: ids[s],
        qty: qty,
        price: price,
      ),
    );
    await buy('BBAS3', '100', '25'); // 100 × 23,92 = 2.392
    await buy('PETR4', '10', '30'); // 10 × 40 = 400
    await buy('VALE3', '50', '60'); // 50 × 70 = 3.500
    await buy('ITSA4', '200', '10'); // 200 × 9 = 1.800
    await buy('WEGE3', '20', '40'); // sem preço: ordenado pelo aplicado, 800
    for (final (s, p) in [('PETR4', '40'), ('VALE3', '70'), ('ITSA4', '9')]) {
      await f.valuations.setUnitPrice(
        assetId: ids[s]!,
        refDate: LocalDate(2026, 10, 21),
        price: dec(p),
      );
    }
    final repo = MarketRepository(f.t.db);
    await repo.saveQuote(
      MarketQuote(
        symbol: 'BBAS3',
        market: 'B3',
        price: dec('23.92'),
        currency: 'BRL',
        refAt: DateTime.utc(2026, 10, 22, 17),
        source: 'brapi',
        dataType: MarketDataType.intraday,
        collectedAt: '2026-10-22T17:01:00.000Z',
      ),
    );
    await repo.savePrices([
      for (final (date, close) in [
        ('2026-09-30', '22.50'),
        ('2026-10-20', '23.80'),
        ('2026-10-21', '24.10'),
      ])
        PriceBar(
          symbol: 'BBAS3',
          market: 'B3',
          refDate: LocalDate.parse(date),
          close: dec(close),
          currency: 'BRL',
          source: 'b3_cotahist',
          dataType: MarketDataType.close,
          collectedAt: '2026-10-22T12:00:00.000Z',
        ),
    ]);
  }

  List<String> order(WidgetTester tester) {
    final rows =
        find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith('holding-') &&
                  !(w.key! as ValueKey<String>).value.contains('value') &&
                  !(w.key! as ValueKey<String>).value.contains('apprec'),
            )
            .evaluate()
            .toList()
          ..sort(
            (a, b) => tester
                .getTopLeft(find.byWidget(a.widget))
                .dy
                .compareTo(tester.getTopLeft(find.byWidget(b.widget)).dy),
          );
    return [
      for (final e in rows)
        (e.widget.key! as ValueKey<String>).value.substring(8),
    ];
  }

  testWidgets('ordem pelo valor da posição; valorização (cotação − PM) ÷ PM; '
      'a página do ativo em tela cheia mostra lucro, total aplicado, variação '
      'do dia e o gráfico só do mercado (M-07)', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      expect(order(tester), ['VALE3', 'BBAS3', 'ITSA4', 'WEGE3', 'PETR4']);
      // WEGE3 sem preço: valor, cotação e valorização indisponíveis.
      final wege = find.byKey(const Key('holding-WEGE3'));
      expect(
        find.descendant(of: wege, matching: find.text('indisponível')),
        findsNWidgets(3),
      );
      final bbas = find.byKey(const Key('holding-BBAS3'));
      expect(
        find.descendant(of: bbas, matching: find.text('100 cotas')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bbas, matching: find.text(r'R$ 2.392,00')),
        findsOneWidget,
      );
      // (23,92 − 25) ÷ 25 = −4,32%.
      expect(
        find.descendant(of: bbas, matching: find.text('-4,32%')),
        findsOneWidget,
      );

      // O clique na linha abre a página em tela cheia (sem painel lateral).
      await app.tap(find.byKey(const Key('holding-BBAS3')));
      final page = find.byKey(const Key('asset-page'));
      expect(page, findsOneWidget);
      expect(find.byKey(const Key('holding-BBAS3')), findsNothing);
      Finder inPage(String text) =>
          find.descendant(of: page, matching: find.textContaining(text));
      expect(
        tester
            .widget<SelectableText>(find.byKey(const Key('header-value')))
            .data,
        r'R$ 2.392,00',
      );
      // Lucro no cabeçalho (e no cartão do não realizado: não houve venda).
      expect(
        find.descendant(
          of: find.byKey(const Key('header-profit')),
          matching: find.text(r'-R$ 108,00 (-4,32%)'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('card-Total aplicado')),
          matching: find.text(r'R$ 2.500,00'),
        ),
        findsOneWidget,
      );
      // 100 × (23,92 − 24,10) = −18; −0,75%.
      expect(inPage(r'-R$ 18,00 (-0,75%)'), findsOneWidget);
      // 2.392 ÷ (2.392 + 400 + 3.500 + 1.800).
      expect(inPage('29,56%'), findsOneWidget);
      expect(inPage('Corretora Exemplo'), findsWidgets);

      // Gráfico: só os fechamentos, nada da carteira (sem linha do PM).
      final chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.data.extraLinesData.horizontalLines, isEmpty);
      expect(chart.data.lineBarsData, hasLength(1));
      expect(chart.data.lineBarsData.single.spots.map((s) => s.y), [
        22.5,
        23.8,
        24.1,
      ]);
      // Histórico desde 30/09: 1A desabilitado com o motivo; vale 1M.
      final periods = tester.widget<SegmentedButton<Object>>(
        find.byKey(const Key('market-periods')),
      );
      final year = periods.segments.firstWhere(
        (s) => (s.label! as Text).data == '1A',
      );
      expect(year.enabled, isFalse);
      expect(year.tooltip, 'Histórico disponível desde 09/2026');
      // 24,10 ÷ 22,50 − 1.
      expect(inPage('+7,11%'), findsOneWidget);
      expect(inPage('em 1 mês'), findsOneWidget);
      expect(inPage('Máx. R\$ 24,10 (21/10/2026)'), findsOneWidget);

      // Tooltip com o mouse (desenhado no canvas): data, cotação e variação
      // desde o início do período; o toque do mouse é atendido.
      final touch = chart.data.lineTouchData;
      expect(touch.enabled, isTrue);
      final bar = chart.data.lineBarsData.single;
      final items = touch.touchTooltipData.getTooltipItems([
        LineBarSpot(bar, 0, bar.spots.last),
      ]);
      expect(
        items.single!.text,
        '21/10/2026\nR\$ 24,10\n+7,11% desde 30/09/2026',
      );
      final box = tester.getRect(find.byType(LineChart));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: box.center);
      await gesture.moveTo(Offset(box.right - 4, box.center.dy));
      await app.settle();
      await gesture.removePointer();

      // Preço ajustado (sem proventos guardados, a série não muda).
      await app.tap(find.byKey(const Key('adjusted-switch')));
      expect(inPage('Cotação ajustada por proventos'), findsOneWidget);

      // Voltar: a Carteira está como antes.
      await app.tap(find.byKey(const Key('asset-back')));
      expect(order(tester), ['VALE3', 'BBAS3', 'ITSA4', 'WEGE3', 'PETR4']);

      // PETR4 usa preço informado: sem gráfico de mercado, com o motivo.
      await app.tap(find.byKey(const Key('details-PETR4')));
      expect(find.byType(LineChart), findsNothing);
      expect(
        find.textContaining('usa preço ou saldo informado por você'),
        findsOneWidget,
      );
    });
  });

  testWidgets('"Comprar" pela página do ativo registra e a Carteira se '
      'reordena; vender tudo leva o ativo ao fim', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      await app.tap(find.byKey(const Key('details-PETR4')));
      await app.tap(find.byKey(const Key('asset-buy')));
      await app.type(find.byKey(const Key('trade-quantity')), '200');
      await app.type(find.byKey(const Key('trade-price')), '40');
      await app.tap(find.text('Salvar'));
      // 210 × 40 = 8.400, na própria página.
      expect(
        tester
            .widget<SelectableText>(find.byKey(const Key('header-value')))
            .data,
        r'R$ 8.400,00',
      );
      await app.tap(find.byKey(const Key('asset-back')));
      expect(order(tester).first, 'PETR4');

      await app.tap(find.byKey(const Key('details-VALE3')));
      await app.tap(find.byKey(const Key('asset-sell')));
      expect(find.textContaining('Disponível: 50'), findsOneWidget);
      await app.type(find.byKey(const Key('trade-quantity')), '50');
      await app.type(find.byKey(const Key('trade-price')), '72');
      await app.tap(find.text('Salvar'));
      await app.tap(find.byKey(const Key('asset-back')));
      expect(order(tester).last, 'VALE3');
      final vale = find.byKey(const Key('holding-VALE3'));
      expect(
        find.descendant(of: vale, matching: find.text('sem cotas')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(of: vale, matching: find.byType(Opacity)).first,
            )
            .opacity,
        lessThan(1),
      );
    });
  });

  testWidgets('voltar da página do ativo mantém a busca da Carteira', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      await app.type(find.byType(TextField).first, 'bb');
      await app.settle();
      expect(order(tester), ['BBAS3']);
      await app.tap(find.byKey(const Key('holding-BBAS3')));
      expect(find.byKey(const Key('asset-page')), findsOneWidget);
      await app.tap(find.byKey(const Key('asset-back')));
      expect(order(tester), ['BBAS3']);
      // O campo de busca continua com o texto digitado.
      expect(find.text('bb'), findsOneWidget);
    });
  });

  testWidgets('Painel (M-04): destaques, distribuição, aportes, proventos e '
      'maiores altas e baixas, com valores que batem com a Carteira', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await seed();
      await f.add(
        f.draft(
          OperationType.dividend,
          '2026-09-15',
          asset: ids['ITSA4'],
          gross: '25',
        ),
      );
      await f.add(
        f.draft(
          OperationType.buy,
          '2026-10-10',
          asset: ids['ITSA4'],
          qty: '10',
          price: '9',
          fees: '1',
        ),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(() async {
      Finder inKey(String key, String text) => find.descendant(
        of: find.byKey(Key(key)),
        matching: find.textContaining(text),
      );
      final list = find
          .descendant(
            of: find.byKey(const Key('dashboard-list')),
            matching: find.byType(Scrollable),
          )
          .first;
      Future<void> show(String key) => tester.scrollUntilVisible(
        find.byKey(Key(key)).hitTestable(),
        200,
        scrollable: list,
      );
      // Patrimônio = soma dos valores da Carteira com preço:
      // 2.392 + 400 + 3.500 + 210 × 9 = 8.182 (o WEGE3 sem preço fica fora).
      expect(inKey('stat-equity', r'R$ 8.182,00'), findsOneWidget);
      expect(
        inKey('stat-equity', 'Parcial: 1 posição sem preço'),
        findsOneWidget,
      );
      // Variação do dia: só o BBAS3 tem cotação e fechamento anterior.
      expect(
        inKey('stat-day', r'-R$ 18,00 (-0,75%) · parcial'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Tooltip>(
              find.ancestor(
                of: find.byKey(const Key('stat-day')),
                matching: find.byType(Tooltip),
              ),
            )
            .message,
        contains('parcial: 4 ativos sem a variação'),
      );
      // Aplicado dos ativos com preço (o WEGE3 fica fora, como no
      // patrimônio): 2.500 + 300 + 3.000 + 2.000 + 91; ganho total (M-12) =
      // 8.182 − 7.891 + 25 de proventos do ITSA4.
      await app.pumpUntil(inKey('stat-applied', r'R$ 7.891,00'));
      expect(inKey('stat-gain', r'+R$ 316,00'), findsOneWidget);
      expect(inKey('stat-gain', 'parcial'), findsOneWidget);
      // Distribuição por ativo com os mesmos valores da Carteira; o seletor
      // troca para setor.
      await show('distribution');
      expect(
        find.descendant(
          of: find.byKey(const Key('distribution')),
          matching: find.text('VALE3'),
        ),
        findsOneWidget,
      );
      expect(inKey('distribution', r'R$ 3.500,00'), findsOneWidget);
      expect(inKey('distribution', r'R$ 2.392,00'), findsOneWidget);
      expect(inKey('distribution', 'VALE3 é 42,78% do patrimônio'), findsOne);
      await show('dist-Setor');
      await app.tap(find.byKey(const Key('dist-Setor')));
      expect(
        find.descendant(
          of: find.byKey(const Key('distribution')),
          matching: find.text('Sem setor informado'),
        ),
        findsOneWidget,
      );
      await show('dash-contributions');
      // Aportes: no mês, a compra de 10/10 (91); no ano, as cinco compras
      // de janeiro (2.500 + 300 + 3.000 + 2.000 + 800) + 91.
      expect(inKey('dash-contributions', r'No mês R$ 91,00'), findsOneWidget);
      expect(
        inKey('dash-contributions', r'no ano R$ 8.691,00'),
        findsOneWidget,
      );
      expect(
        inKey('dash-income', r'Você recebeu R$ 25,00 de proventos'),
        findsOneWidget,
      );
      await show('dash-movers');
      // Maiores altas e baixas: BBAS3 caiu 0,75% no dia; no mês, subiu
      // contra o fechamento de 30/09.
      expect(inKey('dash-movers', 'BBAS3'), findsOneWidget);
      expect(inKey('dash-movers', '-0,75%'), findsOneWidget);
      await tester.tap(find.text('Mês'));
      await app.settle();
      expect(
        inKey('dash-movers', 'contra o fechamento de 30/09/2026'),
        findsOneWidget,
      );
    });
  });
}
