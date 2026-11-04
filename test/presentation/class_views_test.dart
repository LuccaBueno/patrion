import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Visões por classe na Carteira (F8, parte 5).
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  Decimal d(String v) => Decimal.parse(v);
  const at = '2026-10-17T12:00:00.000Z';

  PriceBar bar(String symbol, String market, LocalDate day, String close) =>
      PriceBar(
        symbol: symbol,
        market: market,
        refDate: day,
        close: d(close),
        currency: market == 'B3' ? 'BRL' : 'USD',
        source: 'teste',
        dataType: MarketDataType.close,
        collectedAt: at,
        volume: d('2000000'),
      );

  Future<void> seed() async {
    final repo = MarketRepository(f.t.db);
    final cal = BusinessCalendar.brazil;
    // FII: 10 cotas a R$ 160; cotação de R$ 165; VP/cota de R$ 150;
    // rendimento de R$ 1,10 por mês.
    final hglg = await f.registry.createAsset(
      const Asset(
        id: '',
        symbol: 'HGLG11',
        market: Market.b3,
        assetClass: AssetClass.fii,
        name: 'CGHG Logística',
        currency: 'BRL',
        country: 'BR',
        isin: 'BRHGLGCTF004',
        segment: 'Logística',
        priceSource: PriceSource.market,
      ),
    );
    await f.add(
      f.draft(
        OperationType.buy,
        '2026-01-10',
        asset: hglg,
        qty: '10',
        price: '160',
      ),
    );
    final bars = <PriceBar>[];
    final cdi = <IndicatorPoint>[];
    for (
      var x = LocalDate(2026, 8, 1);
      !x.isAfter(LocalDate(2026, 10, 16));
      x = x.addDays(1)
    ) {
      if (!cal.isBusinessDay(x)) continue;
      bars.add(bar('HGLG11', 'B3', x, '165'));
      cdi.add(
        IndicatorPoint(
          series: IndicatorSeries.cdi,
          refDate: x,
          value: d('0.05'),
          source: 'bcb_sgs',
          collectedAt: at,
        ),
      );
    }
    bars.add(bar('AAPL', 'NASDAQ', LocalDate(2026, 10, 16), '110'));
    await repo.savePrices(bars);
    await repo.saveIndicators(cdi);
    await repo.replaceEvents('HGLG11', 'B3', 'b3_events', [
      for (var m = 0; m < 12; m++)
        CorporateEvent(
          symbol: 'HGLG11',
          market: 'B3',
          kind: CorporateEventKind.fiiIncome,
          exDate: LocalDate(2025, 11, 17).addMonths(m),
          comDate: LocalDate(2025, 11, 14).addMonths(m),
          paymentDate: LocalDate(2025, 11, 28).addMonths(m),
          amount: d('1.1'),
          source: 'b3_events',
          seq: 0,
          status: CorporateEventStatus.paid,
          collectedAt: at,
        ),
    ]);
    await repo.saveFundReports([
      FundReport(
        cnpj: '11728688000147',
        refDate: LocalDate(2026, 8, 1),
        kind: FundReportKind.fiiMonthly,
        source: 'cvm',
        collectedAt: at,
        quota: d('150'),
        isin: 'BRHGLGCTF004',
      ),
    ]);
    // CDB de 110% do CDI: R$ 1.000 em 01/09/2026.
    await f.add(
      f.draft(
        OperationType.contribution,
        '2026-09-01',
        asset: f.cdb,
        gross: '1000',
      ),
    );
    // Internacional: 10 × US$ 100 com câmbio de 5,00; hoje US$ 110 e 5,50.
    final aapl = await f.registry.createAsset(
      const Asset(
        id: '',
        symbol: 'AAPL',
        market: Market.nasdaq,
        assetClass: AssetClass.stockIntl,
        name: 'Apple',
        currency: 'USD',
        country: 'US',
        priceSource: PriceSource.market,
      ),
    );
    await f.add(
      OperationDraft(
        accountId: f.account,
        assetId: aapl,
        type: OperationType.buy,
        tradeDate: LocalDate(2026, 2, 2),
        currency: 'USD',
        quantity: d('10'),
        unitPrice: d('100'),
        fxRate: d('5'),
      ),
    );
    await repo.saveFx([
      FxRate(
        base: 'USD',
        quote: 'BRL',
        refDate: LocalDate(2026, 10, 16),
        kind: FxKind.ptaxClose,
        source: 'bcb_ptax',
        collectedAt: at,
        ask: d('5.5'),
      ),
    ]);
  }

  String cell(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets('FIIs, renda fixa e internacional, cada um na sua visão', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/carteira',
      size: const Size(1280, 1600),
      () async {
        await app.pumpUntil(find.byKey(const Key('class-views')));
        expect(find.byKey(const Key('view-crypto')), findsNothing);

        await app.tap(find.byKey(const Key('view-fii')));
        await app.pumpUntil(find.byKey(const Key('fii-table')));
        // P/VP = 165 ÷ 150; DY = 12 × 1,10 ÷ 165.
        expect(cell(tester, 'fii-HGLG11-3'), '1,10');
        expect(cell(tester, 'fii-HGLG11-4'), '8,00%');
        expect(cell(tester, 'fii-HGLG11-2'), contains('08/2026'));
        expect(cell(tester, 'fii-HGLG11-5'), r'R$ 2.000.000,00');
        expect(cell(tester, 'fii-HGLG11-6'), 'Logística');
        // Estimado: R$ 1,10 × 10 cotas.
        expect(cell(tester, 'fii-income-HGLG11-5'), r'R$ 11,00');
        expect(
          find.textContaining('Vacância e emissões: indisponíveis'),
          findsOneWidget,
        );

        await app.tap(find.byKey(const Key('view-fixedIncome')));
        await app.pumpUntil(find.byKey(const Key('fixed-Pós-fixados')));
        expect(cell(tester, 'fixed-CDB-EXEMPLO-2026-1'), '110% do CDI');
        expect(
          cell(tester, 'fixed-CDB-EXEMPLO-2026-5'),
          contains('(até 19/10/2026)'),
        );
        expect(cell(tester, 'fixed-CDB-EXEMPLO-2026-5'), startsWith(r'R$ 1.0'));

        await app.tap(find.byKey(const Key('view-international')));
        await app.pumpUntil(find.byKey(const Key('intl-table')));
        expect(cell(tester, 'intl-AAPL-5'), r'R$ 6.050,00');
        expect(cell(tester, 'intl-AAPL-6'), '+10,00%');
        expect(cell(tester, 'intl-AAPL-7'), '+10,00%');
        expect(cell(tester, 'intl-AAPL-8'), '+21,00%');
      },
    );
  });
}
