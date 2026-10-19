import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../portfolio/portfolio_summary.dart';
import 'market_data.dart';

/// Indicadores derivados das séries guardadas (`docs/FORMULAS.md` §2.2).
/// Tudo é calculado a partir dos dados publicados: sem dado, sem resultado.
abstract final class MarketIndicators {
  static final _hundred = Decimal.fromInt(100);

  /// Taxa anual equivalente na base 252 de uma taxa diária em % ao dia:
  /// `(1 + d ÷ 100)^252 − 1`, como fração (0,1490 = 14,90% a.a.).
  static Decimal annualizeDaily(Decimal pctPerDay) =>
      DecimalMath.pow(
        Decimal.one + DecimalMath.divide(pctPerDay, _hundred),
        Decimal.fromInt(252),
      ) -
      Decimal.one;

  /// Variação acumulada dos últimos 12 meses de uma série mensal em %:
  /// `∏(1 + mᵢ ÷ 100) − 1`, como fração. Nulo se faltar algum dos 12 meses
  /// terminados no mês mais recente (nunca preenche lacunas).
  static ({Decimal value, LocalDate from, LocalDate to})? accumulated12m(
    List<IndicatorPoint> monthly,
  ) {
    if (monthly.isEmpty) return null;
    final byMonth = {
      for (final p in monthly) (p.refDate.year, p.refDate.month): p.value,
    };
    final last = monthly
        .map((p) => p.refDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    var factor = Decimal.one;
    var year = last.year;
    var month = last.month;
    for (var i = 0; i < 12; i++) {
      final v = byMonth[(year, month)];
      if (v == null) return null;
      factor *= Decimal.one + DecimalMath.divide(v, _hundred);
      month--;
      if (month == 0) {
        month = 12;
        year--;
      }
    }
    final from = LocalDate(
      month == 12 ? year + 1 : year,
      month == 12 ? 1 : month + 1,
      1,
    );
    return (
      value: DecimalMath.rescale(factor - Decimal.one),
      from: from,
      to: LocalDate(last.year, last.month, 1),
    );
  }
}

/// Patrimônio de todas as moedas convertido para reais pelo câmbio mais
/// recente guardado (`docs/FORMULAS.md` §2.3).
class ConsolidatedEquity {
  const ConsolidatedEquity({
    required this.equity,
    required this.rates,
    required this.partial,
  });

  /// Soma, em reais, do patrimônio de cada moeda × câmbio de venda.
  final Decimal equity;

  /// Câmbio usado para cada moeda estrangeira (com fonte e data).
  final Map<String, FxRate> rates;

  /// Algum dos patrimônios somados é parcial (posição sem preço).
  final bool partial;

  /// Data do câmbio mais antigo usado.
  LocalDate? get oldestRate => rates.isEmpty
      ? null
      : rates.values
            .map((r) => r.refDate)
            .reduce((a, b) => a.isBefore(b) ? a : b);

  /// Converte. Nulo se faltar o câmbio de alguma moeda (o total seria
  /// inventado).
  static ConsolidatedEquity? build(
    Map<String, CurrencySummary> byCurrency,
    Map<String, FxRate> latestRates,
  ) {
    var total = Decimal.zero;
    var partial = false;
    final used = <String, FxRate>{};
    for (final MapEntry(key: currency, value: s) in byCurrency.entries) {
      partial = partial || s.isPartial;
      if (currency == 'BRL') {
        total += s.equity;
        continue;
      }
      final rate = latestRates[currency];
      final value = rate?.mid;
      if (rate == null || value == null || value <= Decimal.zero) return null;
      used[currency] = rate;
      total += s.equity * value;
    }
    return ConsolidatedEquity(
      equity: DecimalMath.roundHalfUp(total),
      rates: used,
      partial: partial,
    );
  }
}
