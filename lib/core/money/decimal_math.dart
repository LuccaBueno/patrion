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

  /// [value] com [scale] casas, meio para o par.
  static Decimal rescale(Decimal value, {int scale = divisionScale}) =>
      value.scale <= scale ? value : divide(value, Decimal.one, scale: scale);

  // Funções transcendentes (DECISIONS D-26). Calculadas em ponto fixo sobre
  // BigInt com [_workScale] casas e devolvidas com [scale] casas, meio para o
  // par. Nada passa por ponto flutuante (regra 6).

  /// Casas do cálculo interno: folga sobre as 20 casas do resultado para
  /// absorver a perda das reduções de argumento.
  static const _workScale = 60;
  static final _unit = _ten.pow(_workScale);
  static BigInt? _ln2Cache;

  /// Logaritmo natural. Lança [ArgumentError] se [x] ≤ 0.
  static Decimal ln(Decimal x, {int scale = divisionScale}) {
    if (x <= Decimal.zero) {
      throw ArgumentError.value(x, 'x', 'logaritmo de número não positivo');
    }
    return _out(_lnFixed(_in(x)), scale);
  }

  /// Exponencial e^[x].
  static Decimal exp(Decimal x, {int scale = divisionScale}) =>
      _out(_expFixed(_in(x)), scale);

  /// [base] elevado a [exponent], com expoente fracionário ou negativo.
  ///
  /// Expoente inteiro: multiplicações sucessivas (base ≤ 0 permitida, exceto
  /// zero com expoente negativo). Expoente fracionário: e^(expoente × ln
  /// base), só para base > 0. Lança [ArgumentError] nos casos indefinidos.
  static Decimal pow(
    Decimal base,
    Decimal exponent, {
    int scale = divisionScale,
  }) {
    if (exponent == Decimal.zero) return Decimal.one;
    if (exponent.isInteger) {
      final n = exponent.toBigInt();
      if (base == Decimal.zero) {
        if (n.isNegative) {
          throw ArgumentError.value(base, 'base', 'zero com expoente negativo');
        }
        return Decimal.zero;
      }
      if (n.abs() <= BigInt.from(100000)) {
        final positive = _powIntFixed(_in(base), n.abs().toInt());
        final fixed = n.isNegative ? _divFixed(_unit, positive) : positive;
        return _out(fixed, scale);
      }
    }
    if (base <= Decimal.zero) {
      throw ArgumentError.value(
        base,
        'base',
        'base não positiva com expoente fracionário',
      );
    }
    final lnBase = _lnFixed(_in(base));
    return _out(_expFixed(_mulFixed(_in(exponent), lnBase)), scale);
  }

  // --- Ponto fixo: um BigInt v representa v ÷ 10^_workScale. ---

  static BigInt _in(Decimal x) =>
      rescale(x, scale: _workScale).shift(_workScale).toBigInt();

  static Decimal _out(BigInt v, int scale) =>
      divide(Decimal.fromBigInt(v), Decimal.fromBigInt(_unit), scale: scale);

  static BigInt _mulFixed(BigInt a, BigInt b) => _roundHalfEven(a * b, _unit);

  static BigInt _divFixed(BigInt a, BigInt b) {
    if (b.isNegative) return _roundHalfEven(-a * _unit, -b);
    return _roundHalfEven(a * _unit, b);
  }

  static BigInt _powIntFixed(BigInt base, int n) {
    var result = _unit;
    var b = base;
    var e = n;
    while (e > 0) {
      if (e.isOdd) result = _mulFixed(result, b);
      e >>= 1;
      if (e > 0) b = _mulFixed(b, b);
    }
    return result;
  }

  /// e^x: divide x por 2^k até |x| ≤ 1/16, soma a série de Taylor e eleva
  /// o resultado ao quadrado k vezes.
  static BigInt _expFixed(BigInt x) {
    if (x == BigInt.zero) return _unit;
    final limit = _unit ~/ BigInt.from(16);
    var r = x;
    var k = 0;
    while (r.abs() > limit) {
      r = _roundHalfEven(r, BigInt.two);
      k++;
    }
    var sum = _unit;
    var term = _unit;
    for (var n = 1; term != BigInt.zero; n++) {
      term = _roundHalfEven(term * r, _unit * BigInt.from(n));
      sum += term;
    }
    for (var i = 0; i < k; i++) {
      sum = _mulFixed(sum, sum);
    }
    return sum;
  }

  /// ln x (x > 0): traz x para [1, 2) com potências de 2 e usa
  /// ln m = 2 · atanh((m − 1) ÷ (m + 1)).
  static BigInt _lnFixed(BigInt x) {
    var m = x;
    var k = 0;
    final two = _unit * BigInt.two;
    while (m >= two) {
      m = _roundHalfEven(m, BigInt.two);
      k++;
    }
    while (m < _unit) {
      m *= BigInt.two;
      k--;
    }
    final z = _divFixed(m - _unit, m + _unit);
    return _atanhTimesTwo(z) + _ln2() * BigInt.from(k);
  }

  static BigInt _ln2() =>
      _ln2Cache ??= _atanhTimesTwo(_divFixed(_unit, _unit * BigInt.from(3)));

  /// 2 · atanh z = 2 · (z + z³/3 + z⁵/5 + …), para |z| < 1/2.
  static BigInt _atanhTimesTwo(BigInt z) {
    final z2 = _mulFixed(z, z);
    var power = z;
    var sum = BigInt.zero;
    for (var n = 1; power != BigInt.zero; n += 2) {
      sum += _roundHalfEven(power, BigInt.from(n));
      power = _mulFixed(power, z2);
    }
    return sum * BigInt.two;
  }

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
