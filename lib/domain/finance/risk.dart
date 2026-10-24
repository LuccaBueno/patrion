import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'benchmark.dart';

/// Queda máxima de uma série (do pico ao fundo seguinte).
class Drawdown {
  const Drawdown({
    required this.depth,
    required this.peak,
    required this.trough,
    this.recovery,
  });

  /// Fração negativa (−0,25 = queda de 25%); zero sem queda.
  final Decimal depth;
  final LocalDate peak;
  final LocalDate trough;

  /// Primeiro dia em que a série voltou ao nível do pico; nulo se não
  /// voltou até o fim.
  final LocalDate? recovery;
}

/// Medidas de risco a partir de séries de nível (preço ajustado, índice do
/// TWR ou pontos de um índice), `docs/FORMULAS.md` §11. Todas com
/// [DecimalMath] (20 casas).
abstract final class Risk {
  /// Mínimo de retornos para volatilidade e drawdown (cerca de um mês).
  static const minReturns = 20;

  /// Mínimo de retornos em comum para a correlação.
  static const minCommon = 60;

  /// Sharpe e beta: pelo menos 12 meses e 200 retornos diários. Os 12 meses
  /// toleram 5 dias: no fim de semana, "1 ano" vai de sexta a sexta (364
  /// dias entre os pregões).
  static const minYearDays = 360;
  static const minYearReturns = 200;

  /// Níveis entre o fim de [from] (o último até ele) e [to].
  static List<(LocalDate, Decimal)> window(
    List<(LocalDate, Decimal)> levels,
    LocalDate from,
    LocalDate to,
  ) {
    (LocalDate, Decimal)? base;
    final result = <(LocalDate, Decimal)>[];
    for (final e in levels) {
      if (e.$1.isAfter(to)) break;
      if (!e.$1.isAfter(from)) {
        base = e;
      } else {
        result.add(e);
      }
    }
    return [?base, ...result];
  }

  /// Retornos de um nível para o seguinte: `nívelᵢ ÷ nívelᵢ₋₁ − 1`, na data
  /// do segundo. Níveis não positivos interrompem (o par é pulado).
  static List<(LocalDate, Decimal)> returns(List<(LocalDate, Decimal)> levels) {
    final result = <(LocalDate, Decimal)>[];
    for (var i = 1; i < levels.length; i++) {
      final prev = levels[i - 1].$2;
      if (prev <= Decimal.zero) continue;
      result.add((
        levels[i].$1,
        DecimalMath.rescale(DecimalMath.divide(levels[i].$2, prev)) -
            Decimal.one,
      ));
    }
    return result;
  }

  /// Retornos por ano observados na amostra: `n ÷ (dias corridos ÷ 365,25)`
  /// (cerca de 252 em pregões da B3, 365 em cripto).
  static Decimal periodsPerYear(List<(LocalDate, Decimal)> returns) {
    final days = returns.last.$1.daysSince(returns.first.$1) + 1;
    return DecimalMath.divide(
      Decimal.fromInt(returns.length) * Decimal.parse('365.25'),
      Decimal.fromInt(days),
    );
  }

  static Decimal _mean(List<Decimal> v) {
    var sum = Decimal.zero;
    for (final x in v) {
      sum += x;
    }
    return DecimalMath.divide(sum, Decimal.fromInt(v.length));
  }

  /// Desvio padrão amostral (n − 1).
  static Decimal _std(List<Decimal> v) {
    final m = _mean(v);
    var sum = Decimal.zero;
    for (final x in v) {
      final d = x - m;
      sum = DecimalMath.rescale(sum + d * d);
    }
    return sqrt(DecimalMath.divide(sum, Decimal.fromInt(v.length - 1)));
  }

  static Decimal sqrt(Decimal x) => x <= Decimal.zero
      ? Decimal.zero
      : DecimalMath.pow(x, Decimal.parse('0.5'));

  /// Volatilidade anualizada: desvio padrão dos retornos × √(retornos por
  /// ano). Nula com menos de [minReturns] retornos.
  static Decimal? volatility(List<(LocalDate, Decimal)> returns) {
    if (returns.length < minReturns) return null;
    return DecimalMath.rescale(
      _std([for (final r in returns) r.$2]) * sqrt(periodsPerYear(returns)),
    );
  }

  /// Maior queda do pico ao fundo. Nula com menos de dois níveis.
  static Drawdown? maxDrawdown(List<(LocalDate, Decimal)> levels) {
    if (levels.length < 2) return null;
    var peak = levels.first;
    var worst = Decimal.zero;
    var worstPeak = levels.first;
    var worstTrough = levels.first;
    for (final e in levels) {
      if (e.$2 > peak.$2) peak = e;
      if (peak.$2 <= Decimal.zero) continue;
      final dd = DecimalMath.divide(e.$2, peak.$2) - Decimal.one;
      if (dd < worst) {
        worst = dd;
        worstPeak = peak;
        worstTrough = e;
      }
    }
    LocalDate? recovery;
    if (worst < Decimal.zero) {
      for (final e in levels) {
        if (e.$1.isAfter(worstTrough.$1) && e.$2 >= worstPeak.$2) {
          recovery = e.$1;
          break;
        }
      }
    }
    return Drawdown(
      depth: worst,
      peak: worstPeak.$1,
      trough: worstTrough.$1,
      recovery: recovery,
    );
  }

  /// Retornos das duas séries entre as mesmas datas (só as datas que as duas
  /// têm), para correlação e beta.
  static (List<Decimal>, List<Decimal>) aligned(
    List<(LocalDate, Decimal)> a,
    List<(LocalDate, Decimal)> b,
  ) {
    final byDate = {for (final e in b) e.$1: e.$2};
    final common = [
      for (final e in a)
        if (byDate[e.$1] case final v?) (e.$1, e.$2, v),
    ];
    final ra = <Decimal>[];
    final rb = <Decimal>[];
    for (var i = 1; i < common.length; i++) {
      final (_, a0, b0) = common[i - 1];
      final (_, a1, b1) = common[i];
      if (a0 <= Decimal.zero || b0 <= Decimal.zero) continue;
      ra.add(DecimalMath.rescale(DecimalMath.divide(a1, a0)) - Decimal.one);
      rb.add(DecimalMath.rescale(DecimalMath.divide(b1, b0)) - Decimal.one);
    }
    return (ra, rb);
  }

  static Decimal _cov(List<Decimal> a, List<Decimal> b) {
    final ma = _mean(a);
    final mb = _mean(b);
    var sum = Decimal.zero;
    for (var i = 0; i < a.length; i++) {
      sum = DecimalMath.rescale(sum + (a[i] - ma) * (b[i] - mb));
    }
    return DecimalMath.divide(sum, Decimal.fromInt(a.length - 1));
  }

  /// Correlação de Pearson dos retornos nas datas em comum. Nula com menos
  /// de [minCommon] retornos em comum ou série sem variação.
  static Decimal? correlation(
    List<(LocalDate, Decimal)> a,
    List<(LocalDate, Decimal)> b,
  ) {
    final (ra, rb) = aligned(a, b);
    if (ra.length < minCommon) return null;
    final sa = _std(ra);
    final sb = _std(rb);
    if (sa == Decimal.zero || sb == Decimal.zero) return null;
    return DecimalMath.divide(_cov(ra, rb), DecimalMath.rescale(sa * sb));
  }

  static bool _year(List<(LocalDate, Decimal)> levels) =>
      levels.length > minYearReturns &&
      levels.last.$1.daysSince(levels.first.$1) >= minYearDays;

  /// Beta contra um índice: `cov(carteira, índice) ÷ var(índice)` nos
  /// retornos das datas em comum. Nulo com menos de 12 meses.
  static Decimal? beta(
    List<(LocalDate, Decimal)> portfolio,
    List<(LocalDate, Decimal)> market,
  ) {
    if (!_year(portfolio)) return null;
    final (rp, rm) = aligned(portfolio, market);
    if (rm.length < minYearReturns) return null;
    final varM = _cov(rm, rm);
    if (varM == Decimal.zero) return null;
    return DecimalMath.divide(_cov(rp, rm), varM);
  }

  /// Sharpe anualizado: média ÷ desvio dos retornos em excesso ao CDI de
  /// cada intervalo, × √(retornos por ano). Nulo com menos de 12 meses ou
  /// sem CDI em algum intervalo.
  static Decimal? sharpe(List<(LocalDate, Decimal)> levels, IndexLevels cdi) {
    if (!_year(levels)) return null;
    final excess = <Decimal>[];
    for (var i = 1; i < levels.length; i++) {
      final (d0, v0) = levels[i - 1];
      final (d1, v1) = levels[i];
      if (v0 <= Decimal.zero) continue;
      final rf = cdi.growth(d0, d1);
      if (rf == null) return null;
      excess.add(
        DecimalMath.rescale(DecimalMath.divide(v1, v0)) - Decimal.one - rf,
      );
    }
    final sd = _std(excess);
    if (sd == Decimal.zero) return null;
    final perYear = periodsPerYear(returns(levels));
    return DecimalMath.rescale(
      DecimalMath.divide(_mean(excess), sd) * sqrt(perYear),
    );
  }
}

/// Concentração de uma distribuição (por ativo, classe, setor, país ou
/// moeda), `docs/FORMULAS.md` §11.
class Concentration {
  const Concentration({
    required this.largest,
    required this.largestWeight,
    required this.top5,
    required this.hhi,
    required this.count,
  });

  final String largest;
  final Decimal largestWeight;

  /// Soma dos cinco maiores pesos.
  final Decimal top5;

  /// Índice Herfindahl-Hirschman: Σ peso² (de 1/n a 1).
  final Decimal hhi;
  final int count;

  /// Número efetivo de itens: 1 ÷ HHI.
  Decimal get effective => DecimalMath.divide(Decimal.one, hhi);

  /// Nula sem valores positivos.
  static Concentration? of(Map<String, Decimal> values) {
    final positive = [
      for (final e in values.entries)
        if (e.value > Decimal.zero) e,
    ]..sort((a, b) => b.value.compareTo(a.value));
    if (positive.isEmpty) return null;
    final total = positive.fold(Decimal.zero, (a, e) => a + e.value);
    final weights = [
      for (final e in positive) DecimalMath.divide(e.value, total),
    ];
    var hhi = Decimal.zero;
    for (final w in weights) {
      hhi = DecimalMath.rescale(hhi + w * w);
    }
    return Concentration(
      largest: positive.first.key,
      largestWeight: weights.first,
      top5: weights.take(5).fold(Decimal.zero, (a, w) => a + w),
      hhi: hhi,
      count: positive.length,
    );
  }
}
