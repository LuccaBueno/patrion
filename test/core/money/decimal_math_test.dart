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
}
