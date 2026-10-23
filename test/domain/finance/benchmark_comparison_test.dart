import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/benchmark.dart';
import 'package:patrion/domain/finance/benchmark_comparison.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/wealth_history.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);

String pct(Decimal? v) => v == null
    ? 'null'
    : DecimalMath.roundHalfUp(v * Decimal.fromInt(100)).toString();

IndicatorPoint ip(IndicatorSeries s, String date, String value) =>
    IndicatorPoint(
      series: s,
      refDate: day(date),
      value: d(value),
      source: 'teste',
      collectedAt: '2026-10-23T00:00:00.000Z',
    );

IndexLevels levels(IndicatorSeries s, Map<String, String> m) =>
    IndexLevels(s, [for (final e in m.entries) (day(e.key), d(e.value))]);

WealthPoint pt(String date, String value, {String flow = '0'}) => WealthPoint(
  date: day(date),
  value: d(value),
  invested: Decimal.zero,
  flow: d(flow),
  income: Decimal.zero,
  buys: Decimal.zero,
  sells: Decimal.zero,
);

void main() {
  final carteira = WealthSeries(
    points: [
      pt('2024-01-02', '1000', flow: '1000'),
      pt('2024-07-01', '1100'),
      pt('2025-01-02', '1200'),
    ],
    entries: const {},
    excluded: const {},
  );

  group('IndexLevels', () {
    test('pela unidade: taxa diária, variação mensal e pontos', () {
      final selic = IndexLevels.of(IndicatorSeries.selic, [
        ip(IndicatorSeries.selic, '2025-01-02', '1'),
        ip(IndicatorSeries.selic, '2025-01-03', '1'),
      ])!;
      expect(selic.series, IndicatorSeries.selic);
      expect(selic.levels.last.$2, d('1.0201'));
      final igpm = IndexLevels.of(IndicatorSeries.igpm, [
        ip(IndicatorSeries.igpm, '2025-01-01', '-1'),
      ])!;
      expect(igpm.levelOn(day('2025-01-31')), d('0.99'));
      final ifix = IndexLevels.of(IndicatorSeries.ifix, [
        ip(IndicatorSeries.ifix, '2025-01-02', '3117.34'),
      ])!;
      expect(ifix.levels.single.$2, d('3117.34'));
      expect(
        IndexLevels.of(IndicatorSeries.selicTarget, [
          ip(IndicatorSeries.selicTarget, '2025-01-02', '15'),
        ]),
        isNull,
      );
    });

    test('em reais pela PTAX do dia (a última até a data)', () {
      final btc = levels(IndicatorSeries.btcUsd, {
        '2024-01-01': '100',
        '2024-01-02': '100',
        '2025-01-04': '110',
      });
      final brl = btc.inBrl([
        (day('2024-01-02'), d('5')),
        (day('2025-01-03'), d('5.5')),
      ]);
      // Antes da primeira PTAX, fica de fora; no sábado, vale a de sexta.
      expect(brl.levels.map((e) => e.$1), [
        day('2024-01-02'),
        day('2025-01-04'),
      ]);
      expect(brl.levels.last.$2, d('605'));
    });

    test('base 100 no início do período', () {
      final n = IndexLevels.normalize(
        [(day('2024-01-01'), d('50')), (day('2024-01-03'), d('55'))],
        day('2024-01-02'),
        day('2024-01-05'),
      );
      expect(n, [(day('2024-01-02'), d('100')), (day('2024-01-03'), d('110'))]);
      expect(
        IndexLevels.normalize(
          [(day('2024-01-03'), d('55'))],
          day('2024-01-02'),
          day('2024-01-05'),
        ),
        isEmpty,
        reason: 'sem dado até o início',
      );
    });
  });

  group('BenchmarkComparison', () {
    test('mesmo intervalo da carteira, diferença em pontos e ao ano', () {
      final c = BenchmarkComparison.compute(
        BenchmarkIndex.ibovespa,
        levels: levels(IndicatorSeries.ibovespa, {
          '2024-01-02': '100',
          '2025-01-02': '110',
        }),
        series: carteira,
        from: day('2024-01-02'),
        to: day('2025-01-02'),
      )!;
      expect(pct(c.value), '10');
      expect(pct(c.portfolio), '20');
      expect(pct(c.difference), '10');
      expect(c.annual, isNull, reason: '366 dias: não anualiza');
      expect(c.original, isNull);
    });

    test('índice que para antes do fim: a carteira até a mesma data', () {
      final c = BenchmarkComparison.compute(
        BenchmarkIndex.ipca,
        levels: levels(IndicatorSeries.ipca, {
          '2024-01-02': '1',
          '2024-07-01': '1.02',
        }),
        series: carteira,
        from: day('2024-01-02'),
        to: day('2025-01-02'),
      )!;
      expect(c.to, day('2024-07-01'));
      expect(pct(c.value), '2');
      expect(pct(c.portfolio), '10');
    });

    test('em dólar: em reais pela PTAX e o retorno em dólar ao lado', () {
      // US$ 100 → 110 e câmbio 5,00 → 5,50: 21% em reais (CASOS §7).
      final c = BenchmarkComparison.compute(
        BenchmarkIndex.btc,
        levels: levels(IndicatorSeries.btcUsd, {
          '2024-01-02': '100',
          '2025-01-02': '110',
        }),
        usdToBrl: [(day('2024-01-02'), d('5')), (day('2025-01-02'), d('5.5'))],
        series: carteira,
        from: day('2024-01-02'),
        to: day('2025-01-02'),
      )!;
      expect(pct(c.value), '21');
      expect(pct(c.original), '10');
    });

    test('índice que começa depois do início: indisponível', () {
      expect(
        BenchmarkComparison.compute(
          BenchmarkIndex.ifix,
          levels: levels(IndicatorSeries.ifix, {'2024-03-01': '3000'}),
          series: carteira,
          from: day('2024-01-02'),
          to: day('2025-01-02'),
        ),
        isNull,
      );
    });

    test('ao ano em mais de um ano', () {
      final c = BenchmarkComparison.compute(
        BenchmarkIndex.cdi,
        levels: levels(IndicatorSeries.cdi, {
          '2023-01-02': '1',
          '2025-01-02': '1.21',
        }),
        series: carteira,
        from: day('2023-01-02'),
        to: day('2025-01-02'),
      )!;
      // 731 dias: 1,21^(365/731) − 1.
      expect(pct(c.annual), '9.99');
    });
  });
}
