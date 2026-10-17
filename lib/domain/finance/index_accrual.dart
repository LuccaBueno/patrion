import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';

/// Taxa de um indexador diário (CDI ou Selic) em um dia útil.
class DailyIndexRate {
  const DailyIndexRate(this.annualRate);

  /// Taxa anual efetiva na base 252 (0,1065 = 10,65% a.a.).
  final Decimal annualRate;
}

/// Acumulação de CDI e Selic na base 252 (SPEC §9, `docs/FORMULAS.md` §6).
///
/// Para cada dia útil, o fator diário do indexador é
/// `(1 + taxa anual)^(1 ÷ 252)`. Um título que paga `p` do indexador
/// (1,10 = 110% do CDI) rende `1 + p × (fator diário − 1)` no dia, e os
/// fatores diários são multiplicados.
///
/// O cálculo é feito com precisão total. Os truncamentos da B3 (fator diário
/// com 8 casas e acumulado com 16) não são aplicados; a diferença fica abaixo
/// de um centavo em valores usuais e é anotada em `FORMULAS.md`.
abstract final class IndexAccrual {
  static final _dayExponent = DecimalMath.divide(
    Decimal.one,
    Decimal.fromInt(252),
  );

  /// Fator diário de uma taxa anual na base 252, já com o percentual do
  /// indexador.
  static Decimal dailyFactor(Decimal annualRate, {Decimal? percentOfIndex}) {
    final daily =
        DecimalMath.pow(Decimal.one + annualRate, _dayExponent) - Decimal.one;
    final p = percentOfIndex ?? Decimal.one;
    return Decimal.one + DecimalMath.rescale(p * daily);
  }

  /// Fator acumulado de uma série de taxas diárias (uma por dia útil).
  static Decimal accumulate(
    Iterable<DailyIndexRate> rates, {
    Decimal? percentOfIndex,
  }) {
    var factor = Decimal.one;
    for (final r in rates) {
      factor = DecimalMath.rescale(
        factor * dailyFactor(r.annualRate, percentOfIndex: percentOfIndex),
      );
    }
    return factor;
  }

  /// Fator de uma taxa anual constante por [businessDays] dias úteis.
  ///
  /// A 100% do indexador, é `(1 + taxa)^(du ÷ 252)`; com outro percentual,
  /// é o fator diário elevado a `du`.
  static Decimal constantRateFactor(
    Decimal annualRate,
    int businessDays, {
    Decimal? percentOfIndex,
  }) {
    if (percentOfIndex == null || percentOfIndex == Decimal.one) {
      return DecimalMath.pow(
        Decimal.one + annualRate,
        DecimalMath.divide(Decimal.fromInt(businessDays), Decimal.fromInt(252)),
      );
    }
    return DecimalMath.pow(
      dailyFactor(annualRate, percentOfIndex: percentOfIndex),
      Decimal.fromInt(businessDays),
    );
  }

  /// Fator de uma taxa prefixada adicional (CDI + 2% a.a.) por
  /// [businessDays] dias úteis: `(1 + spread)^(du ÷ 252)`. Multiplica o
  /// fator do indexador.
  static Decimal spreadFactor(Decimal annualSpread, int businessDays) =>
      DecimalMath.pow(
        Decimal.one + annualSpread,
        DecimalMath.divide(Decimal.fromInt(businessDays), Decimal.fromInt(252)),
      );
}
