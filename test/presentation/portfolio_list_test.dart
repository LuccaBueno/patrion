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

/// Carteira como lista principal, com o painel de detalhes (M-05).
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
      'painel com lucro, total aplicado, variação do dia e gráfico com a '
      'linha do PM', (tester) async {
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

      await app.tap(find.byKey(const Key('details-BBAS3')));
      final panel = find.byKey(const Key('asset-panel'));
      expect(panel, findsOneWidget);
      Finder inPanel(String text) =>
          find.descendant(of: panel, matching: find.textContaining(text));
      expect(
        find.descendant(of: panel, matching: find.text(r'-R$ 108,00')),
        findsOneWidget,
      ); // lucro
      expect(inPanel(r'R$ 2.500,00'), findsOneWidget); // total aplicado
      // 100 × (23,92 − 24,10) = −18; −0,75%.
      expect(inPanel(r'-R$ 18,00 (-0,75%)'), findsOneWidget);
      expect(inPanel('Desde o fechamento de 21/10/2026'), findsOneWidget);
      // 2.392 ÷ (2.392 + 400 + 3.500 + 1.800).
      expect(inPanel('29,56%'), findsOneWidget);
      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final avg = chart.data.extraLinesData.horizontalLines.single;
      expect(avg.y, 25);
      expect(chart.data.lineBarsData.single.spots.last.y, 23.92);

      // Fechar e abrir o PETR4 (sem histórico): gráfico indisponível.
      await app.tap(find.byKey(const Key('asset-panel-close')));
      await app.tap(find.byKey(const Key('details-PETR4')));
      expect(find.byKey(const Key('price-chart-unavailable')), findsOneWidget);
      expect(
        find.text('Nenhum histórico de cotações guardado para este ativo.'),
        findsOneWidget,
      );
      expect(find.byType(LineChart), findsNothing);
    });
  });

  testWidgets('"Comprar" pelo painel registra sem sair da Carteira e a lista '
      'se reordena; vender tudo leva o ativo ao fim', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      await app.tap(find.byKey(const Key('details-PETR4')));
      // Sem ensureVisible: ele rolaria o painel até o botão.
      await tester.tap(find.byKey(const Key('panel-buy')));
      await app.settle();
      await app.type(find.byKey(const Key('trade-quantity')), '200');
      await app.type(find.byKey(const Key('trade-price')), '40');
      await app.tap(find.text('Salvar'));
      // 210 × 40 = 8.400: PETR4 passa a ser o maior.
      expect(find.byKey(const Key('asset-panel')), findsOneWidget);
      expect(order(tester).first, 'PETR4');

      await app.tap(find.byKey(const Key('asset-panel-close')));
      await app.tap(find.byKey(const Key('details-VALE3')));
      await tester.tap(find.byKey(const Key('panel-sell')));
      await app.settle();
      expect(find.textContaining('Disponível: 50'), findsOneWidget);
      await app.type(find.byKey(const Key('trade-quantity')), '50');
      await app.type(find.byKey(const Key('trade-price')), '72');
      await app.tap(find.text('Salvar'));
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
}
