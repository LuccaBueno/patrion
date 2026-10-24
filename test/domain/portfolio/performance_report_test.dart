import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/benchmark.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/performance_report.dart';
import 'package:patrion/domain/portfolio/wealth_history.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);

WealthPoint pt(String date, String value, {String flow = '0'}) => WealthPoint(
  date: day(date),
  value: d(value),
  invested: Decimal.zero,
  flow: d(flow),
  income: Decimal.zero,
  buys: Decimal.zero,
  sells: Decimal.zero,
);

WealthSeries series(List<WealthPoint> points) =>
    WealthSeries(points: points, entries: const {}, excluded: const {});

String pct(Decimal? v) => v == null
    ? 'null'
    : DecimalMath.roundHalfUp(v * Decimal.fromInt(100)).toString();

IndexLevels levels(IndicatorSeries s, Map<String, String> m) =>
    IndexLevels(s, [for (final e in m.entries) (day(e.key), d(e.value))]);

void main() {
  // 1.000 aplicados em 31/12/2024, +10% em jan, fev e dez de 2025 e em jan
  // de 2026, sem novos aportes.
  final s = series([
    pt('2024-12-31', '1000', flow: '1000'),
    pt('2025-01-31', '1100'),
    pt('2025-02-28', '1210'),
    pt('2025-12-31', '1331'),
    pt('2026-01-30', '1464.1'),
  ]);

  group('ReturnTable', () {
    test('mês a mês, total do ano, acumulado e CDI do ano', () {
      final cdi = levels(IndicatorSeries.cdi, {
        '2024-12-31': '1',
        '2025-12-31': '1.1',
        '2026-01-30': '1.111',
      });
      final rows = ReturnTable.build(s, cdi: cdi);
      expect(rows.map((r) => r.year), [2025, 2026]);
      final y25 = rows.first;
      expect(pct(y25.months[0]), '10');
      expect(pct(y25.months[1]), '10');
      expect(y25.months.sublist(2, 11), everyElement(isNull));
      expect(pct(y25.months[11]), '10');
      expect(pct(y25.total), '33.1');
      expect(pct(y25.accumulated), '33.1');
      expect(pct(y25.cdi), '10');
      expect(pct(y25.ofCdi), '331');
      expect(y25.partial, isFalse);

      final y26 = rows.last;
      expect(pct(y26.months[0]), '10');
      expect(pct(y26.total), '10');
      expect(pct(y26.accumulated), '46.41');
      expect(pct(y26.cdi), '1');
      expect(y26.partial, isTrue);
    });

    test('sem CDI ou com um ponto só', () {
      expect(ReturnTable.build(s).first.cdi, isNull);
      expect(ReturnTable.build(s).first.ofCdi, isNull);
      expect(ReturnTable.build(series([pt('2025-01-02', '10')])), isEmpty);
    });

    test('ano completo que termina no último pregão (29/12) não é parcial', () {
      final rows = ReturnTable.build(
        series([
          pt('2022-12-30', '1000', flow: '1000'),
          pt('2023-12-29', '1100'),
          pt('2024-01-02', '1111'),
        ]),
      );
      expect(rows.first.year, 2023);
      expect(rows.first.partial, isFalse);
      expect(rows.last.partial, isTrue);
    });

    test('primeiro ano parcial: começa na primeira compra', () {
      final rows = ReturnTable.build(
        series([
          pt('2025-03-10', '1000', flow: '1000'),
          pt('2025-03-31', '1050'),
          pt('2025-12-31', '1155'),
        ]),
      );
      expect(rows.single.partial, isTrue);
      expect(pct(rows.single.months[2]), '5');
      expect(pct(rows.single.total), '15.5');
    });
  });

  group('PeriodPerformance', () {
    test('TWR, CDI, IPCA até o último mês publicado e retorno real', () {
      final p = PeriodPerformance.compute(
        s,
        from: day('2025-01-31'),
        to: day('2025-12-31'),
        cdi: levels(IndicatorSeries.cdi, {
          '2025-01-31': '1',
          '2025-12-31': '1.11',
        }),
        ipca: levels(IndicatorSeries.ipca, {
          '2025-01-31': '1',
          '2025-06-30': '1.05',
        }),
      )!;
      expect(p.from, day('2025-01-31'));
      expect(pct(p.twr), '21');
      expect(pct(p.cdi), '11');
      expect(pct(p.ofCdi), '190.91');
      expect(pct(p.ipca), '5');
      expect(p.ipcaUntil, day('2025-06-30'));
      // 1,21 ÷ 1,05 − 1.
      expect(pct(p.real), '15.24');
      expect(p.cagr, isNull);
    });

    test('M-12: CDI só até o último dia publicado; sem nenhum dia depois do '
        'dia-base, nulo (não 0%); TIR só com 30 dias', () {
      final two = series([
        pt('2026-10-22', '2400', flow: '2000'),
        pt('2026-10-23', '2750', flow: '250'),
      ]);
      final short = PeriodPerformance.compute(
        two,
        from: day('2026-10-01'),
        to: day('2026-10-23'),
        cdi: levels(IndicatorSeries.cdi, {
          '2026-10-21': '1',
          '2026-10-22': '1.0005',
        }),
        ipca: levels(IndicatorSeries.ipca, {'2026-09-30': '1'}),
      )!;
      expect(short.cdi, isNull);
      expect(short.cdiUntil, isNull);
      expect(short.ipca, isNull);
      expect(short.real, isNull);
      expect(short.mwr, isNull, reason: '1 dia < 30');
      // A tabela mês a mês também: o CDI do ano não é 0%.
      expect(
        ReturnTable.build(
          two,
          cdi: levels(IndicatorSeries.cdi, {
            '2026-10-21': '1',
            '2026-10-22': '1.0005',
          }),
        ).single.cdi,
        isNull,
      );
      // A tabela mês a mês também: o CDI do ano não é 0%.
      expect(
        ReturnTable.build(
          two,
          cdi: levels(IndicatorSeries.cdi, {
            '2026-10-21': '1',
            '2026-10-22': '1.0005',
          }),
        ).single.cdi,
        isNull,
      );

      // Com parte do período publicada: o CDI até o último dia, e a data.
      final partial = PeriodPerformance.compute(
        s,
        from: day('2025-01-31'),
        to: day('2025-12-31'),
        cdi: levels(IndicatorSeries.cdi, {
          '2025-01-31': '1',
          '2025-06-30': '1.05',
        }),
      )!;
      expect(pct(partial.cdi), '5');
      expect(partial.cdiUntil, day('2025-06-30'));
      expect(partial.mwr, isNotNull);
    });

    test('desde o início: CAGR acima de um ano e TIR igual sem aportes', () {
      final p = PeriodPerformance.compute(
        s,
        from: day('2000-01-01'),
        to: day('2026-01-30'),
      )!;
      expect(p.from, day('2024-12-31'));
      expect(pct(p.twr), '46.41');
      expect(p.cdi, isNull);
      expect(p.real, isNull);
      // 395 dias: 1,4641^(365/395) − 1.
      expect(pct(p.cagr), '42.23');
      expect(pct(p.mwr!.rate), pct(p.cagr));
    });

    test('TWR × MWR (CASOS_DE_TESTE §6)', () {
      final p = PeriodPerformance.compute(
        series([
          pt('2024-01-01', '1000', flow: '1000'),
          pt('2025-01-01', '2100', flow: '1000'),
          pt('2026-01-01', '1890'),
        ]),
        from: day('2023-01-01'),
        to: day('2026-01-01'),
      )!;
      expect(pct(p.twr), '-1');
      expect(
        DecimalMath.roundHalfUp(p.mwr!.rate * Decimal.fromInt(100), scale: 4),
        d('-3.7093'),
      );
    });

    test('um ponto só: indisponível', () {
      expect(
        PeriodPerformance.compute(
          series([pt('2025-01-02', '10', flow: '10')]),
          from: day('2025-01-01'),
          to: day('2025-01-02'),
        ),
        isNull,
      );
    });
  });

  test('períodos sustentados pelos dados', () {
    expect(PerformancePeriod.available(s, day('2026-01-30')), [
      PerformancePeriod.m1,
      PerformancePeriod.m3,
      PerformancePeriod.m6,
      PerformancePeriod.ytd,
      PerformancePeriod.y1,
      PerformancePeriod.all,
      PerformancePeriod.custom,
    ]);
    expect(
      PerformancePeriod.available(WealthSeries.empty, day('2026-01-30')),
      isEmpty,
    );
  });
}
