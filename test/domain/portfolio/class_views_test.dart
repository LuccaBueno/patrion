import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/benchmark.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/class_views.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);
Decimal r(Decimal v, [int scale = 4]) =>
    DecimalMath.roundHalfUp(v, scale: scale);

FixedIncomeTerms terms(
  Indexer indexer,
  String rate, {
  String? spread,
  DayCount dayCount = DayCount.bus252,
}) => FixedIncomeTerms(
  assetId: 'cdb',
  product: FixedIncomeProduct.cdb,
  indexer: indexer,
  rate: d(rate),
  spread: spread == null ? null : d(spread),
  dayCount: dayCount,
  issueDate: day('2025-01-02'),
  maturityDate: day('2030-01-02'),
  liquidity: Liquidity.atMaturity,
  taxRegime: TaxRegime.regressiveIr,
);

void main() {
  group('FII', () {
    test('P/VP, DY de 12 meses, rendimentos por mês e volume médio', () {
      final events = [
        for (var m = 0; m < 15; m++)
          CorporateEvent(
            symbol: 'HGLG11',
            market: 'B3',
            kind: CorporateEventKind.fiiIncome,
            exDate: day('2025-08-18').addMonths(m),
            comDate: day('2025-08-15').addMonths(m),
            paymentDate: day('2025-08-29').addMonths(m),
            amount: d('0.8'),
            source: 'b3_events',
            seq: 0,
            status: CorporateEventStatus.paid,
            collectedAt: '',
          ),
      ];
      final f = FiiMetrics.compute(
        assetId: 'hglg',
        today: day('2026-10-23'),
        price: d('100'),
        report: FundReport(
          cnpj: '1',
          refDate: day('2026-08-01'),
          kind: FundReportKind.fiiMonthly,
          source: 'cvm',
          collectedAt: '',
          quota: d('95'),
        ),
        events: events,
        bars: [
          for (var i = 0; i < 40; i++)
            PriceBar(
              symbol: 'HGLG11',
              market: 'B3',
              refDate: day('2026-08-01').addDays(i),
              close: d('100'),
              currency: 'BRL',
              source: 'b3_cotahist',
              dataType: MarketDataType.close,
              collectedAt: '',
              volume: Decimal.fromInt(i < 10 ? 1 : 1000),
            ),
        ],
      );
      expect(r(f.pvp!), d('1.0526'));
      // Datas-com de 15/11/2025 a 15/10/2026: 12 × 0,80.
      expect(f.income12m, d('9.6'));
      expect(r(f.dy12m!), d('0.096'));
      expect(f.monthly.where((m) => m.$2 != null), hasLength(12));
      expect(f.avgVolume, d('1000'), reason: 'os últimos 30 pregões');
      expect(f.navMonth, day('2026-08-01'));
    });

    test('sem informe nem proventos: indisponível', () {
      final f = FiiMetrics.compute(
        assetId: 'x',
        today: day('2026-10-23'),
        price: d('10'),
      );
      expect(f.pvp, isNull);
      expect(f.dy12m, isNull);
      expect(f.avgVolume, isNull);
    });
  });

  group('renda fixa', () {
    final flows = [(day('2025-01-02'), d('1000'))];

    test('prefixado de 12% a.a. em dias corridos por um ano', () {
      final v = FixedIncomeView.compute(
        assetId: 'cdb',
        terms: terms(Indexer.pre, '12', dayCount: DayCount.act365),
        flows: flows,
        today: day('2026-01-02'),
        daily: const {},
        monthly: const {},
      );
      expect(v.projected, d('1120'));
      expect(r(v.annualReturn!), d('0.12'));
    });

    test('110% do CDI: cada dia útil publicado; para no último publicado', () {
      final cal = BusinessCalendar.brazil;
      final points = <IndicatorPoint>[];
      for (
        var x = day('2025-01-02');
        x.isBefore(day('2025-02-03'));
        x = x.addDays(1)
      ) {
        if (!cal.isBusinessDay(x)) continue;
        points.add(
          IndicatorPoint(
            series: IndicatorSeries.cdi,
            refDate: x,
            value: d('0.05'),
            source: 'bcb_sgs',
            collectedAt: '',
          ),
        );
      }
      final v = FixedIncomeView.compute(
        assetId: 'cdb',
        terms: terms(Indexer.cdi, '110'),
        flows: flows,
        today: day('2025-02-10'),
        daily: {IndicatorSeries.cdi: points},
        monthly: const {},
      );
      final n = points.length;
      expect(
        v.projected,
        DecimalMath.roundHalfUp(
          d('1000') * DecimalMath.pow(d('1.00055'), Decimal.fromInt(n)),
        ),
      );
      expect(v.projectedUntil, day('2025-02-03'));
    });

    test('IPCA + 6%: índice até o último mês e a taxa até hoje', () {
      final ipca = IndexLevels(IndicatorSeries.ipca, [
        (day('2025-01-01'), d('1')),
        (day('2025-01-02'), d('1')),
        (day('2025-12-31'), d('1.05')),
      ]);
      final v = FixedIncomeView.compute(
        assetId: 'cdb',
        terms: terms(Indexer.ipca, '100', spread: '6'),
        flows: flows,
        today: day('2026-01-02'),
        daily: const {},
        monthly: {IndicatorSeries.ipca: ipca},
      );
      final du = BusinessCalendar.brazil.businessDaysBetween(
        day('2025-01-02'),
        day('2026-01-02'),
      );
      final real = DecimalMath.pow(
        d('1.06'),
        DecimalMath.divide(Decimal.fromInt(du), Decimal.fromInt(252)),
      );
      expect(v.projected, DecimalMath.roundHalfUp(d('1050') * real));
      expect(v.projectedUntil, day('2025-12-31'));
    });

    test('sem condições ou sem CDI: indisponível com o motivo', () {
      expect(
        FixedIncomeView.compute(
          assetId: 'cdb',
          terms: null,
          flows: flows,
          today: day('2026-01-02'),
          daily: const {},
          monthly: const {},
        ).missing,
        'condições do título',
      );
      expect(
        FixedIncomeView.compute(
          assetId: 'cdb',
          terms: terms(Indexer.cdi, '100'),
          flows: flows,
          today: day('2026-01-02'),
          daily: const {},
          monthly: const {},
        ).missing,
        'CDI',
      );
    });

    test('% do CDI: TIR do título ÷ TIR dos mesmos fluxos no CDI', () {
      final cdi = IndexLevels(IndicatorSeries.cdi, [
        (day('2025-01-02'), d('1')),
        (day('2026-01-02'), d('1.1')),
      ]);
      final v = FixedIncomeView.compute(
        assetId: 'cdb',
        terms: terms(Indexer.pre, '12', dayCount: DayCount.act365),
        flows: flows,
        today: day('2026-01-02'),
        daily: const {},
        monthly: const {},
        cdiLevels: cdi,
      );
      expect(r(v.cdiAnnual!), d('0.1'));
      expect(r(v.ofCdi!), d('1.2'));
    });
  });

  test('internacional: retorno em dólar, câmbio e reais (CASOS §7)', () {
    final f = ForeignReturn.compute(
      costOriginal: d('1000'),
      valueOriginal: d('1100'),
      buys: [(d('600'), d('5')), (d('400'), d('5'))],
      fxNow: d('5.5'),
    )!;
    expect(f.split.assetReturn, d('0.1'));
    expect(f.split.fxReturn, d('0.1'));
    expect(f.split.totalReturn, d('0.21'));
    expect(f.costBrl, d('5000'));
    expect(f.valueBrl, d('6050'));
    expect(
      ForeignReturn.compute(
        costOriginal: d('1000'),
        valueOriginal: d('1100'),
        buys: const [],
        fxNow: d('5.5'),
      ),
      isNull,
    );
  });
}
