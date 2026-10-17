import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../portfolio/codes.dart';
import 'business_calendar.dart';

/// Juros simples e compostos, equivalência de taxas e bases de contagem de
/// dias (SPEC §9, `docs/FORMULAS.md` §5).
///
/// Taxas são frações (0,12 = 12%). Uma taxa anual nunca é dividida por 365
/// como regra geral: a conversão para um prazo usa sempre a base do
/// instrumento ([DayCount]).
abstract final class Interest {
  /// Montante com juros simples: `PV × (1 + i × n)`.
  static Decimal simpleAmount(Decimal principal, Decimal rate, Decimal n) =>
      principal * (Decimal.one + rate * n);

  /// Montante com juros compostos: `PV × (1 + i)^n`. [n] pode ser
  /// fracionário.
  static Decimal compoundAmount(Decimal principal, Decimal rate, Decimal n) =>
      DecimalMath.rescale(principal * compoundFactor(rate, n));

  /// Fator `(1 + i)^n`.
  static Decimal compoundFactor(Decimal rate, Decimal n) =>
      DecimalMath.pow(Decimal.one + rate, n);

  /// Taxa equivalente em juros compostos: `(1 + i)^(de ÷ para) − 1`.
  ///
  /// [fromPerYear] e [toPerYear] são quantos períodos de cada taxa cabem num
  /// ano: 12% a.a. → a.m. é `equivalentRate(0,12, fromPerYear: 1,
  /// toPerYear: 12)`; → ao dia útil, `toPerYear: 252`.
  static Decimal equivalentRate(
    Decimal rate, {
    required int fromPerYear,
    required int toPerYear,
  }) {
    final exponent = DecimalMath.divide(
      Decimal.fromInt(fromPerYear),
      Decimal.fromInt(toPerYear),
    );
    return DecimalMath.pow(Decimal.one + rate, exponent) - Decimal.one;
  }

  /// Taxa efetiva anual de uma taxa nominal anual capitalizada
  /// [compoundingsPerYear] vezes: `(1 + j ÷ m)^m − 1`.
  static Decimal nominalToEffective(Decimal nominal, int compoundingsPerYear) {
    final m = Decimal.fromInt(compoundingsPerYear);
    return DecimalMath.pow(Decimal.one + DecimalMath.divide(nominal, m), m) -
        Decimal.one;
  }

  /// Inverso de [nominalToEffective]: `m × ((1 + i)^(1 ÷ m) − 1)`.
  static Decimal effectiveToNominal(
    Decimal effective,
    int compoundingsPerYear,
  ) {
    final m = Decimal.fromInt(compoundingsPerYear);
    final periodic =
        DecimalMath.pow(
          Decimal.one + effective,
          DecimalMath.divide(Decimal.one, m),
        ) -
        Decimal.one;
    return periodic * m;
  }

  /// Prazo de [start] a [end] na base [basis]: dias úteis (base 252),
  /// corridos (/365 e /360) ou 30/360.
  static int days(
    DayCount basis,
    LocalDate start,
    LocalDate end, {
    BusinessCalendar? calendar,
  }) => switch (basis) {
    DayCount.bus252 =>
      (calendar ?? BusinessCalendar.brazil).businessDaysBetween(start, end),
    DayCount.act365 || DayCount.act360 => end.daysSince(start),
    DayCount.thirty360 => days30360(start, end),
  };

  /// Dias do ano em cada base.
  static int yearDays(DayCount basis) => switch (basis) {
    DayCount.bus252 => 252,
    DayCount.act365 => 365,
    DayCount.act360 || DayCount.thirty360 => 360,
  };

  /// Prazo em anos: dias na base ÷ dias do ano da base.
  static Decimal years(
    DayCount basis,
    LocalDate start,
    LocalDate end, {
    BusinessCalendar? calendar,
  }) => DecimalMath.divide(
    Decimal.fromInt(days(basis, start, end, calendar: calendar)),
    Decimal.fromInt(yearDays(basis)),
  );

  /// Fator de uma taxa anual efetiva entre duas datas, em juros compostos:
  /// `(1 + i)^(dias ÷ dias do ano)`.
  static Decimal annualRateFactor(
    Decimal annualRate,
    DayCount basis,
    LocalDate start,
    LocalDate end, {
    BusinessCalendar? calendar,
  }) =>
      compoundFactor(annualRate, years(basis, start, end, calendar: calendar));

  /// Fator de uma taxa anual em juros simples (lineares) entre duas datas:
  /// `1 + i × dias ÷ dias do ano`. Usado por instrumentos que pedem a
  /// convenção linear (por exemplo, /360 de mercado monetário).
  static Decimal annualRateSimpleFactor(
    Decimal annualRate,
    DayCount basis,
    LocalDate start,
    LocalDate end, {
    BusinessCalendar? calendar,
  }) =>
      Decimal.one +
      DecimalMath.rescale(
        annualRate * years(basis, start, end, calendar: calendar),
      );

  /// Dias na convenção 30E/360 (europeia): o dia 31 vira 30 nas duas datas.
  static int days30360(LocalDate start, LocalDate end) {
    final d1 = start.day == 31 ? 30 : start.day;
    final d2 = end.day == 31 ? 30 : end.day;
    return 360 * (end.year - start.year) +
        30 * (end.month - start.month) +
        (d2 - d1);
  }
}
