import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  group('divide (20 casas, meio para o par)', () {
    test('divisões exatas não ganham casas', () {
      expect(DecimalMath.divide(d('4809'), d('150')), d('32.06'));
      expect(DecimalMath.divide(d('1'), d('8')), d('0.125'));
    });

    test('dízimas param em 20 casas', () {
      expect(DecimalMath.divide(d('1'), d('3')), d('0.33333333333333333333'));
      expect(DecimalMath.divide(d('2'), d('3')), d('0.66666666666666666667'));
      expect(DecimalMath.divide(d('-2'), d('3')), d('-0.66666666666666666667'));
    });

    test('empate arredonda para o par', () {
      expect(DecimalMath.divide(d('0.25'), d('1'), scale: 1), d('0.2'));
      expect(DecimalMath.divide(d('0.35'), d('1'), scale: 1), d('0.4'));
      expect(DecimalMath.divide(d('-0.25'), d('1'), scale: 1), d('-0.2'));
    });

    test('divisão por zero lança erro', () {
      expect(
        () => DecimalMath.divide(d('1'), Decimal.zero),
        throwsArgumentError,
      );
    });
  });

  test('roundHalfUp arredonda meio para cima (exibição)', () {
    expect(DecimalMath.roundHalfUp(d('0.125')), d('0.13'));
    expect(DecimalMath.roundHalfUp(d('2885.404')), d('2885.4'));
    expect(DecimalMath.roundHalfUp(d('-0.125')), d('-0.13'));
  });

  group('funções transcendentes (20 casas)', () {
    test('ln e exp de valores conhecidos', () {
      expect(DecimalMath.ln(d('2')), d('0.69314718055994530942'));
      expect(DecimalMath.ln(d('10')), d('2.30258509299404568402'));
      expect(DecimalMath.ln(Decimal.one), Decimal.zero);
      expect(DecimalMath.exp(Decimal.one), d('2.71828182845904523536'));
      expect(DecimalMath.exp(d('-1')), d('0.3678794411714423216'));
      expect(DecimalMath.exp(Decimal.zero), Decimal.one);
    });

    test('exp desfaz ln', () {
      for (final x in ['0.0001', '0.5', '1.1065', '37', '12345.678']) {
        final back = DecimalMath.exp(DecimalMath.ln(d(x)));
        expect((back - d(x)).abs() < d('1e-15') * d(x), isTrue, reason: x);
      }
    });

    test('pow com expoente inteiro, negativo e fracionário', () {
      expect(DecimalMath.pow(d('1.01'), d('12')), d('1.12682503013196972066'));
      expect(DecimalMath.pow(d('2'), d('-2')), d('0.25'));
      expect(DecimalMath.pow(d('-2'), d('3')), d('-8'));
      expect(DecimalMath.pow(d('2'), d('0.5')), d('1.4142135623730950488'));
      expect(DecimalMath.pow(d('5'), Decimal.zero), Decimal.one);
    });

    test('casos indefinidos lançam erro', () {
      expect(() => DecimalMath.ln(Decimal.zero), throwsArgumentError);
      expect(() => DecimalMath.ln(d('-1')), throwsArgumentError);
      expect(() => DecimalMath.pow(d('-2'), d('0.5')), throwsArgumentError);
      expect(() => DecimalMath.pow(Decimal.zero, d('-1')), throwsArgumentError);
    });
  });
}
