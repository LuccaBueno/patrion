import 'package:decimal/decimal.dart';

/// Aritmética de `Decimal` com o arredondamento definido em DECISIONS D-03.
abstract final class DecimalMath {
  /// Casas decimais das divisões internas.
  static const divisionScale = 20;

  static final _ten = BigInt.from(10);

  /// [a] / [b] com [scale] casas, arredondando meio para o par (half-even).
  ///
  /// Lança [ArgumentError] se [b] for zero.
  static Decimal divide(Decimal a, Decimal b, {int scale = divisionScale}) {
    if (b == Decimal.zero) {
      throw ArgumentError.value(b, 'b', 'divisão por zero');
    }
    // Fração exata (a × 10^scale) / b, arredondada para um inteiro.
    final exact = (a * Decimal.fromBigInt(_ten.pow(scale))) / b;
    final rounded = _roundHalfEven(exact.numerator, exact.denominator);
    return Decimal.fromBigInt(rounded).shift(-scale);
  }

  /// Arredonda meio para cima (comercial), usado na exibição: 2 casas para
  /// valores em moeda.
  static Decimal roundHalfUp(Decimal value, {int scale = 2}) =>
      value.round(scale: scale);

  static Decimal min(Decimal a, Decimal b) => a <= b ? a : b;
  static Decimal max(Decimal a, Decimal b) => a >= b ? a : b;

  /// n / d arredondado meio para o par; d é sempre positivo.
  static BigInt _roundHalfEven(BigInt n, BigInt d) {
    final q = n ~/ d; // trunca em direção a zero
    final twiceRemainder = n.remainder(d).abs() * BigInt.two;
    final step = n.isNegative ? -BigInt.one : BigInt.one;
    final cmp = twiceRemainder.compareTo(d);
    if (cmp > 0 || (cmp == 0 && q.isOdd)) return q + step;
    return q;
  }
}
