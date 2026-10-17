import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/finance/cash_flow.dart';
import 'package:patrion/domain/finance/index_accrual.dart';
import 'package:patrion/domain/finance/interest.dart';
import 'package:patrion/domain/finance/returns.dart';

Decimal d(String s) => Decimal.parse(s);

/// Fração em percentual com [places] casas (0,0099714 → 0,9971 com 4).
Decimal pct(Decimal fraction, int places) =>
    DecimalMath.roundHalfUp(fraction * Decimal.fromInt(100), scale: places);

Decimal money(Decimal value) => DecimalMath.roundHalfUp(value);

/// Casos de `docs/CASOS_DE_TESTE.md` §2 a §7 (o §1 está em
/// `test/domain/portfolio/portfolio_calculator_test.dart`).
void main() {
  group('§2 juros compostos', () {
    test('R\$ 10.000,00 a 1% a.m. por 12 meses = R\$ 11.268,25', () {
      final amount = Interest.compoundAmount(d('10000'), d('0.01'), d('12'));
      expect(money(amount), d('11268.25'));
      // Sem arredondar: 10000 × 1,01¹² = 11268,250301319697...
      expect(amount.toStringAsFixed(10), '11268.2503013197');
    });
  });

  group('§3 equivalência de taxas', () {
    test('12% a.a. = 0,948879% a.m.', () {
      final monthly = Interest.equivalentRate(
        d('0.12'),
        fromPerYear: 1,
        toPerYear: 12,
      );
      expect(pct(monthly, 6), d('0.948879'));
    });

    test('12% a.a. = 0,044982% ao dia útil (base 252)', () {
      final daily = Interest.equivalentRate(
        d('0.12'),
        fromPerYear: 1,
        toPerYear: 252,
      );
      expect(pct(daily, 6), d('0.044982'));
    });

    test('volta da taxa mensal para a anual', () {
      final monthly = Interest.equivalentRate(
        d('0.12'),
        fromPerYear: 1,
        toPerYear: 12,
      );
      final annual = Interest.equivalentRate(
        monthly,
        fromPerYear: 12,
        toPerYear: 1,
      );
      expect(pct(annual, 10), d('12'));
    });
  });

  group('§4 CDI acumulado', () {
    test('10,65% a.a. por 21 dias úteis = 0,846915%', () {
      final factor = IndexAccrual.constantRateFactor(d('0.1065'), 21);
      expect(pct(factor - Decimal.one, 6), d('0.846915'));
    });

    test('R\$ 1.000,00 a 100% do CDI = R\$ 1.008,47', () {
      final factor = IndexAccrual.constantRateFactor(d('0.1065'), 21);
      expect(money(d('1000') * factor), d('1008.47'));
    });

    test('acumular 21 taxas diárias iguais dá o mesmo fator', () {
      final daily = List.filled(21, DailyIndexRate(d('0.1065')));
      final accumulated = IndexAccrual.accumulate(daily);
      final constant = IndexAccrual.constantRateFactor(d('0.1065'), 21);
      expect((accumulated - constant).abs() < d('1e-18'), isTrue);
      expect(money(d('1000') * accumulated), d('1008.47'));
    });

    test('21 dias úteis contados pelo calendário', () {
      // 01/03/2024 (sexta) a 02/04/2024: março de 2024 tem 20 dias úteis
      // (Sexta-feira Santa em 29/03) mais 01/04.
      final calendar = BusinessCalendar.brazil;
      final start = LocalDate(2024, 3, 1);
      final end = LocalDate(2024, 4, 2);
      expect(calendar.businessDaysBetween(start, end), 21);
    });
  });

  group('§5 XIRR', () {
    test('−1.000 em 01/01/2024 e +1.100 em 01/01/2025 = 9,9714% a.a.', () {
      final result = Xirr.compute([
        CashFlow(LocalDate(2024, 1, 1), d('-1000')),
        CashFlow(LocalDate(2025, 1, 1), d('1100')),
      ])!;
      expect(pct(result.rate, 4), d('9.9714'));
      // Confirma dias corridos ÷ 365 (366 dias): 1,1^(365/366) − 1.
      final expected =
          DecimalMath.pow(
            d('1.1'),
            DecimalMath.divide(Decimal.fromInt(365), Decimal.fromInt(366)),
          ) -
          Decimal.one;
      expect((result.rate - expected).abs() < d('1e-10'), isTrue);
      expect(result.multipleSignChanges, isFalse);
    });
  });

  group('§6 TWR versus MWR', () {
    final points = [
      ValuationPoint(LocalDate(2024, 1, 1), d('0'), d('1000')),
      ValuationPoint(LocalDate(2025, 1, 1), d('1100'), d('1000')),
      ValuationPoint(LocalDate(2026, 1, 1), d('1890')),
    ];

    test('TWR = 1,10 × 0,90 − 1 = −1,00%', () {
      expect(pct(Twr.compute(points)!, 2), d('-1.00'));
      expect(Twr.compute(points), d('-0.01'));
    });

    test('MWR (XIRR) = −3,7093% a.a.', () {
      final result = Xirr.compute([
        CashFlow(LocalDate(2024, 1, 1), d('-1000')),
        CashFlow(LocalDate(2025, 1, 1), d('-1000')),
        CashFlow(LocalDate(2026, 1, 1), d('1890')),
      ])!;
      expect(pct(result.rate, 4), d('-3.7093'));
    });
  });

  group('§7 ativo internacional e câmbio', () {
    // 10 ações a US$ 100 com câmbio 5,00; hoje US$ 110 com câmbio 5,50.
    final fx = FxDecomposition.fromValues(
      startValue: d('1000'),
      endValue: d('1100'),
      startFx: d('5.00'),
      endFx: d('5.50'),
    )!;

    test('valores em BRL', () {
      expect(d('10') * d('100') * d('5.00'), d('5000'));
      expect(d('10') * d('110') * d('5.50'), d('6050'));
    });

    test('retorno em USD 10,00% e em BRL 21,00%', () {
      expect(pct(fx.assetReturn, 2), d('10.00'));
      expect(pct(fx.totalReturn, 2), d('21.00'));
      expect(Returns.simple(d('5000'), d('6050')), d('0.21'));
    });

    test('efeitos: ativo 10%, câmbio 10%, cruzado 1%', () {
      expect(fx.assetReturn, d('0.1'));
      expect(fx.fxReturn, d('0.1'));
      expect(fx.crossEffect, d('0.01'));
    });
  });
}
