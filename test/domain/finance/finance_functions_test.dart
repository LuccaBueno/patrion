import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/cash_flow.dart';
import 'package:patrion/domain/finance/index_accrual.dart';
import 'package:patrion/domain/finance/interest.dart';
import 'package:patrion/domain/finance/returns.dart';
import 'package:patrion/domain/portfolio/codes.dart';

Decimal d(String s) => Decimal.parse(s);

Matcher closeTo(String expected, [String tolerance = '1e-15']) =>
    predicate<Decimal>(
      (v) => (v - d(expected)).abs() <= d(tolerance),
      'dentro de $tolerance de $expected',
    );

LocalDate day(String s) => LocalDate.parse(s);

void main() {
  group('juros', () {
    test('juros simples', () {
      expect(Interest.simpleAmount(d('1000'), d('0.01'), d('12')), d('1120'));
    });

    test('taxa nominal e efetiva', () {
      final effective = Interest.nominalToEffective(d('0.12'), 12);
      expect(effective, d('0.12682503013196972066'));
      expect(Interest.effectiveToNominal(effective, 12), closeTo('0.12'));
    });

    test('bases de contagem de dias', () {
      final start = day('2024-01-31');
      final end = day('2024-02-28');
      expect(Interest.days(DayCount.act365, start, end), 28);
      expect(Interest.days(DayCount.act360, start, end), 28);
      expect(Interest.days(DayCount.thirty360, start, end), 28);
      expect(Interest.days30360(day('2024-01-30'), day('2024-03-31')), 60);
      // 31/01 a 28/02/2024: 18 dias úteis (Carnaval em 12 e 13/02).
      expect(Interest.days(DayCount.bus252, start, end), 18);
    });

    test('fator anual composto e linear em cada base', () {
      final start = day('2023-01-01');
      expect(
        Interest.annualRateFactor(
          d('0.1'),
          DayCount.act365,
          start,
          start.addDays(365),
        ),
        closeTo('1.1'),
      );
      expect(
        Interest.annualRateSimpleFactor(
          d('0.1'),
          DayCount.act360,
          start,
          start.addDays(180),
        ),
        d('1.05'),
      );
    });

    test('nunca divide a taxa anual por 365: 1 dia útil de 12% a.a.', () {
      final factor = Interest.annualRateFactor(
        d('0.12'),
        DayCount.bus252,
        day('2025-01-06'),
        day('2025-01-07'),
      );
      expect(factor, closeTo('1.00044982', '1e-8'));
    });
  });

  group('indexadores', () {
    test('110% do CDI por 1 dia útil', () {
      final daily = IndexAccrual.dailyFactor(
        d('0.1065'),
        percentOfIndex: d('1.1'),
      );
      final cdiDay = IndexAccrual.dailyFactor(d('0.1065')) - Decimal.one;
      expect(daily - Decimal.one, closeTo((cdiDay * d('1.1')).toString()));
    });

    test('CDI + 2% a.a.: fatores multiplicados', () {
      final cdi = IndexAccrual.constantRateFactor(d('0.1065'), 252);
      final spread = IndexAccrual.spreadFactor(d('0.02'), 252);
      expect(cdi, closeTo('1.1065'));
      expect(cdi * spread, closeTo('1.12863'));
    });
  });

  group('retornos', () {
    test('simples e acumulado', () {
      expect(Returns.simple(d('100'), d('110')), d('0.1'));
      expect(Returns.simple(Decimal.zero, d('110')), isNull);
      expect(Returns.accumulate([d('0.1'), d('-0.1')]), d('-0.01'));
    });

    test('anualizar, desanualizar e CAGR', () {
      expect(Returns.annualize(d('0.21'), 730), closeTo('0.1'));
      expect(Returns.deannualize(d('0.1'), 730), closeTo('0.21'));
      expect(
        Returns.cagr(
          d('1000'),
          d('1210'),
          day('2024-01-01'),
          day('2025-12-31'),
        ),
        closeTo('0.1'),
      );
      expect(
        Returns.annualize(d('0.01'), 21, yearDays: 252),
        closeTo('0.12682503013196972', '1e-15'),
      );
      expect(Returns.annualize(d('0.1'), 0), isNull);
      expect(Returns.annualize(d('-1'), 30), isNull);
    });

    test('retorno real', () {
      expect(Returns.real(d('0.10'), d('0.04')), d('0.05769230769230769231'));
    });
  });

  group('XIRR', () {
    test('sem troca de sinal ou sem prazo não tem solução', () {
      expect(
        Xirr.compute([
          CashFlow(day('2024-01-01'), d('100')),
          CashFlow(day('2025-01-01'), d('100')),
        ]),
        isNull,
      );
      expect(
        Xirr.compute([
          CashFlow(day('2024-01-01'), d('-100')),
          CashFlow(day('2024-01-01'), d('110')),
        ]),
        isNull,
      );
    });

    test('retorno negativo', () {
      final r = Xirr.compute([
        CashFlow(day('2023-01-01'), d('-1000')),
        CashFlow(day('2024-01-01'), d('500')),
      ])!;
      expect(r.rate, closeTo('-0.5', '1e-12'));
    });

    test('fluxos intermediários e fora de ordem', () {
      // −1000; +100 em 1 ano; +1100 em 2 anos (365 dias cada): 10% a.a.
      final r = Xirr.compute([
        CashFlow(day('2023-01-01'), d('1100')),
        CashFlow(day('2021-01-01'), d('-1000')),
        CashFlow(day('2022-01-01'), d('100')),
      ])!;
      expect(r.rate, closeTo('0.1', '1e-12'));
    });

    test('várias trocas de sinal são sinalizadas', () {
      final r = Xirr.compute([
        CashFlow(day('2023-01-01'), d('-1000')),
        CashFlow(day('2024-01-01'), d('1500')),
        CashFlow(day('2025-01-01'), d('-200')),
        CashFlow(day('2026-01-01'), d('100')),
      ]);
      expect(r, isNotNull);
      expect(r!.multipleSignChanges, isTrue);
    });
  });

  group('TWR', () {
    test('subperíodo sem capital é pulado', () {
      final twr = Twr.compute([
        ValuationPoint(day('2024-01-01'), d('0')),
        ValuationPoint(day('2024-02-01'), d('0'), d('1000')),
        ValuationPoint(day('2024-03-01'), d('1050')),
      ]);
      expect(twr, d('0.05'));
    });

    test('valor surgindo sem aporte não tem retorno definido', () {
      expect(
        Twr.compute([
          ValuationPoint(day('2024-01-01'), d('0')),
          ValuationPoint(day('2024-02-01'), d('100')),
        ]),
        isNull,
      );
    });

    test('retirada no meio do período', () {
      // 1000 → 1100 (+10%), retira 600 → 500 → 450 (−10%).
      final twr = Twr.compute([
        ValuationPoint(day('2024-01-01'), d('0'), d('1000')),
        ValuationPoint(day('2024-06-01'), d('1100'), d('-600')),
        ValuationPoint(day('2024-12-01'), d('450')),
      ]);
      expect(twr, d('-0.01'));
    });
  });

  group('retornos por período', () {
    final index = [
      (day('2024-01-15'), d('1')),
      (day('2024-01-31'), d('1.1')),
      (day('2024-02-29'), d('0.99')),
      (day('2024-03-10'), d('1.089')),
    ];

    test('mensal', () {
      final months = PeriodReturns.compute(index, ReturnPeriodUnit.month);
      expect(
        [for (final m in months) m.start],
        [day('2024-01-01'), day('2024-02-01'), day('2024-03-01')],
      );
      expect(
        [for (final m in months) m.value],
        [d('0.1'), d('-0.1'), d('0.1')],
      );
    });

    test('anual e diário', () {
      final years = PeriodReturns.compute(index, ReturnPeriodUnit.year);
      expect(years.single.value, d('0.089'));
      expect(years.single.end, day('2024-03-10'));
      final days = PeriodReturns.compute(index, ReturnPeriodUnit.day);
      expect(days, hasLength(3));
      expect(days.first.start, day('2024-01-31'));
    });

    test('índice do TWR alimenta os períodos', () {
      final idx = Twr.index([
        ValuationPoint(day('2024-01-31'), d('0'), d('1000')),
        ValuationPoint(day('2024-02-29'), d('1100')),
        ValuationPoint(day('2024-03-31'), d('990')),
      ])!;
      final months = PeriodReturns.compute(idx, ReturnPeriodUnit.month);
      expect([for (final m in months) m.value], [d('0.1'), d('-0.1')]);
    });
  });
}
