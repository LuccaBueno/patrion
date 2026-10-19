import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/market/market_indicators.dart';
import 'package:patrion/domain/market/market_price.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/portfolio/portfolio_summary.dart';
import 'package:patrion/domain/portfolio/portfolio_valuation.dart';

Decimal d(String s) => Decimal.parse(s);

/// Regras dos preços de mercado (`docs/FORMULAS.md` §2.1 a §2.3).
void main() {
  MarketPrice price(
    String date, {
    String value = '10',
    DateTime? at,
    String currency = 'BRL',
    MarketDataType type = MarketDataType.close,
  }) => MarketPrice(
    assetId: 'a1',
    price: d(value),
    currency: currency,
    refDate: LocalDate.parse(date),
    refAt: at,
    source: 'teste',
    dataType: type,
    collectedAt: '2026-10-17T12:00:00.000Z',
  );

  group('escolha do preço', () {
    test('vale a data mais recente; na mesma data, o instante mais novo', () {
      final close = price('2026-10-15', value: '10');
      final quote = price(
        '2026-10-16',
        value: '11',
        at: DateTime.utc(2026, 10, 16, 15),
        type: MarketDataType.intraday,
      );
      final later = price(
        '2026-10-16',
        value: '12',
        at: DateTime.utc(2026, 10, 16, 18),
        type: MarketDataType.intraday,
      );
      expect(MarketPricing.best([close, quote, later])!.price, d('12'));
      expect(MarketPricing.best([later, close])!.price, d('12'));
      expect(MarketPricing.best([]), isNull);
    });

    test('fechamento do COTAHIST por lote vira preço unitário', () {
      PriceBar bar(String factor) => PriceBar(
        symbol: 'X',
        market: 'B3',
        refDate: LocalDate(2026, 10, 16),
        close: d('1250'),
        currency: 'BRL',
        source: 'b3_cotahist',
        dataType: MarketDataType.close,
        collectedAt: '2026-10-17T12:00:00.000Z',
        quoteFactor: d(factor),
      );
      expect(MarketPricing.unitClose(bar('1')), d('1250'));
      expect(MarketPricing.unitClose(bar('1000')), d('1.25'));
    });

    test('desatualizado: antes do último pregão (cripto: antes de ontem)', () {
      // Segunda, 19/10/2026: o último pregão completo é sexta, 16/10.
      final monday = LocalDate(2026, 10, 19);
      expect(MarketPricing.isStale(price('2026-10-16'), monday), isFalse);
      expect(MarketPricing.isStale(price('2026-10-15'), monday), isTrue);
      expect(
        MarketPricing.isStale(price('2026-10-17'), monday, market: 'CRYPTO'),
        isTrue,
      );
      expect(
        MarketPricing.isStale(price('2026-10-18'), monday, market: 'CRYPTO'),
        isFalse,
      );
    });

    test('classes sem cotação automática ficam com preço informado', () {
      expect(
        MarketPricing.defaultSource(AssetClass.stockBr),
        PriceSource.market,
      );
      expect(
        MarketPricing.defaultSource(AssetClass.fixedIncome),
        PriceSource.manual,
      );
      expect(MarketPricing.defaultSource(AssetClass.cash), PriceSource.manual);
    });
  });

  group('Tesouro', () {
    const asset = Asset(
      id: 'a1',
      symbol: 'IPCA+2035',
      market: Market.tesouro,
      assetClass: AssetClass.treasury,
      name: 'Tesouro IPCA+ 2035',
      currency: 'BRL',
      country: 'BR',
      priceSource: PriceSource.market,
    );
    final terms = FixedIncomeTerms(
      assetId: 'a1',
      product: FixedIncomeProduct.tesouroIpca,
      indexer: Indexer.ipca,
      rate: d('6'),
      dayCount: DayCount.bus252,
      issueDate: LocalDate(2024, 1, 2),
      maturityDate: LocalDate(2035, 5, 15),
      liquidity: Liquidity.daily,
      taxRegime: TaxRegime.regressiveIr,
    );
    TreasuryPrice t(String title, LocalDate maturity, String pu) =>
        TreasuryPrice(
          title: title,
          maturity: maturity,
          refDate: LocalDate(2026, 10, 16),
          sellPu: d(pu),
          source: 'tesouro',
          collectedAt: '2026-10-17T12:00:00.000Z',
        );

    test('título e vencimento iguais dão o PU de resgate, com a data', () {
      final p = MarketPricing.treasuryPrice(asset, terms, [
        t('Tesouro IPCA+', LocalDate(2035, 5, 15), '2100.50'),
        t('Tesouro IPCA+ com Juros Semestrais', LocalDate(2035, 5, 15), '9'),
        t('Tesouro IPCA+', LocalDate(2045, 5, 15), '8'),
      ])!;
      expect(p.price, d('2100.50'));
      expect(p.refDate, LocalDate(2026, 10, 16));
      expect(p.source, 'tesouro');
    });

    test('sem correspondência única, não há preço (nada é inventado)', () {
      expect(
        MarketPricing.treasuryPrice(asset, terms, [
          t('Tesouro IPCA+', LocalDate(2045, 5, 15), '8'),
        ]),
        isNull,
      );
    });
  });

  group('indicadores', () {
    test('CDI diário anualizado na base 252', () {
      // 0,055131% ao dia → (1,00055131)^252 − 1 ≈ 14,90% a.a.
      final annual = MarketIndicators.annualizeDaily(d('0.055131'));
      expect((annual * d('100')).round(scale: 2), d('14.90'));
    });

    IndicatorPoint ipca(int y, int m, String v) => IndicatorPoint(
      series: IndicatorSeries.ipca,
      refDate: LocalDate(y, m, 1),
      value: d(v),
      source: 'bcb_sgs',
      collectedAt: '2026-10-17T12:00:00.000Z',
    );

    test('IPCA em 12 meses: produto dos fatores mensais', () {
      final months = [
        for (var i = 0; i < 12; i++)
          ipca(i < 3 ? 2025 : 2026, i < 3 ? 10 + i : i - 2, '0.5'),
      ];
      final r = MarketIndicators.accumulated12m(months)!;
      // 1,005^12 − 1 = 0,06167781186...
      expect(r.value.round(scale: 10), d('0.0616778119'));
      expect(r.from, LocalDate(2025, 10, 1));
      expect(r.to, LocalDate(2026, 9, 1));
    });

    test('IPCA em 12 meses com um mês faltando fica indisponível', () {
      final months = [
        for (var m = 1; m <= 12; m++)
          if (m != 6) ipca(2026, m, '0.4'),
      ];
      expect(MarketIndicators.accumulated12m(months), isNull);
    });
  });

  group('patrimônio em reais', () {
    CurrencySummary summary(String c, String market, {int unpriced = 0}) =>
        CurrencySummary(
          currency: c,
          invested: d(market),
          marketValue: d(market),
          pricedCost: d(market),
          unpricedCount: unpriced,
          unpricedCost: Decimal.zero,
          cash: d('10'),
          realizedPnl: Decimal.zero,
          incomeGross: Decimal.zero,
          incomeNet: Decimal.zero,
        );
    FxRate usd(String ask) => FxRate(
      base: 'USD',
      quote: 'BRL',
      refDate: LocalDate(2026, 10, 16),
      kind: FxKind.ptaxClose,
      bid: d('5.40'),
      ask: d(ask),
      source: 'bcb_ptax',
      collectedAt: '2026-10-17T12:00:00.000Z',
    );

    test('soma cada moeda × PTAX de venda, com o câmbio usado', () {
      final c = ConsolidatedEquity.build(
        {'BRL': summary('BRL', '1000'), 'USD': summary('USD', '90')},
        {'USD': usd('5.4321')},
      )!;
      // 1010 + 100 × 5,4321 = 1553,21
      expect(c.equity, d('1553.21'));
      expect(c.rates.keys, ['USD']);
      expect(c.oldestRate, LocalDate(2026, 10, 16));
      expect(c.partial, isFalse);
    });

    test('sem o câmbio de uma moeda, o total fica indisponível', () {
      expect(
        ConsolidatedEquity.build(
          {'BRL': summary('BRL', '1000'), 'EUR': summary('EUR', '90')},
          {'USD': usd('5.4321')},
        ),
        isNull,
      );
    });

    test('posição sem preço deixa o total parcial', () {
      final c = ConsolidatedEquity.build({
        'BRL': summary('BRL', '1000', unpriced: 1),
      }, const {})!;
      expect(c.partial, isTrue);
    });
  });

  group('avaliação com preço de mercado', () {
    const market = Asset(
      id: 'a1',
      symbol: 'PETR4',
      market: Market.b3,
      assetClass: AssetClass.stockBr,
      name: 'Petrobras',
      currency: 'BRL',
      country: 'BR',
      priceSource: PriceSource.market,
    );
    const manualAsset = Asset(
      id: 'a1',
      symbol: 'PETR4',
      market: Market.b3,
      assetClass: AssetClass.stockBr,
      name: 'Petrobras',
      currency: 'BRL',
      country: 'BR',
    );
    final state = PortfolioState(
      positions: [
        Position(
          accountId: 'c1',
          assetId: 'a1',
          currency: 'BRL',
          quantity: d('100'),
          totalCost: d('3000'),
          realizedPnl: Decimal.zero,
          incomeGross: Decimal.zero,
          incomeNet: Decimal.zero,
          lastOperationDate: LocalDate(2026, 1, 5),
        ),
      ],
      cash: const {},
      issues: const [],
    );
    ManualValuation manual(String date, String value) => ManualValuation(
      id: 'v1',
      assetId: 'a1',
      refDate: LocalDate.parse(date),
      kind: ValuationKind.unitPrice,
      value: d(value),
      currency: 'BRL',
    );
    ValuedPosition value(
      Asset asset,
      List<ManualValuation> valuations,
      MarketPrice? mp,
    ) => PortfolioValuator.value(
      state: state,
      valuations: valuations,
      assets: {'a1': asset},
      asOf: LocalDate(2026, 10, 17),
      marketPrices: {'a1': ?mp},
    ).single;

    test('cotação mais recente que o preço informado vence', () {
      final v = value(market, [
        manual('2026-10-01', '30'),
      ], price('2026-10-16', value: '35.5'));
      expect(v.marketValue, d('3550'));
      expect(v.marketPrice!.source, 'teste');
      expect(v.valuationDate, LocalDate(2026, 10, 16));
    });

    test('na mesma data, vale o informado pelo usuário', () {
      final v = value(market, [
        manual('2026-10-16', '30'),
      ], price('2026-10-16', value: '35.5'));
      expect(v.marketValue, d('3000'));
      expect(v.marketPrice, isNull);
    });

    test('ativo com preço informado ignora a cotação', () {
      final v = value(manualAsset, [], price('2026-10-16', value: '35.5'));
      expect(v.marketValue, isNull);
    });

    test('cotação em outra moeda é ignorada (sem conversão)', () {
      final v = value(
        market,
        [],
        price('2026-10-16', value: '7', currency: 'USD'),
      );
      expect(v.marketValue, isNull);
    });
  });
}
