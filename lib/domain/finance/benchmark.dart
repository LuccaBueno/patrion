import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../market/market_data.dart';
import '../portfolio/wealth_history.dart';

/// Nível acumulado de um índice ao longo do tempo (`docs/FORMULAS.md`
/// §3.3): a razão entre dois níveis é o crescimento do índice entre as
/// duas datas.
class IndexLevels {
  const IndexLevels(this.series, this.levels);

  final IndicatorSeries series;

  /// Nível no fim de cada data com dado, em ordem.
  final List<(LocalDate, Decimal)> levels;

  bool get isEmpty => levels.isEmpty;

  /// Primeira e última data com dado.
  LocalDate? get first => levels.isEmpty ? null : levels.first.$1;
  LocalDate? get last => levels.isEmpty ? null : levels.last.$1;

  /// Nível no fim de [d] (o último até a data); nulo antes do primeiro dado.
  Decimal? levelOn(LocalDate d) => levelIn(levels, d);

  /// O último nível até [d] numa sequência em ordem de data.
  static Decimal? levelIn(List<(LocalDate, Decimal)> levels, LocalDate d) {
    var lo = 0;
    var hi = levels.length - 1;
    var found = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (levels[mid].$1.isAfter(d)) {
        hi = mid - 1;
      } else {
        found = mid;
        lo = mid + 1;
      }
    }
    return found < 0 ? null : levels[found].$2;
  }

  /// Crescimento entre o fim de [from] e o fim de [to] (fração); nulo se o
  /// índice não tem dado até [from] ou se [to] não é depois de [from].
  Decimal? growth(LocalDate from, LocalDate to) {
    if (!to.isAfter(from)) return null;
    final start = levelOn(from);
    final end = levelOn(to);
    if (start == null || end == null || start <= Decimal.zero) return null;
    return DecimalMath.divide(end, start) - Decimal.one;
  }

  /// CDI (taxa diária em %): nível = produto de `1 + taxa ÷ 100` dos dias.
  static IndexLevels cdi(List<IndicatorPoint> daily) {
    var level = Decimal.one;
    final result = <(LocalDate, Decimal)>[];
    for (final p in _sorted(daily)) {
      level = DecimalMath.rescale(
        level * (Decimal.one + DecimalMath.divide(p.value, _hundred)),
      );
      result.add((p.refDate, level));
    }
    return IndexLevels(IndicatorSeries.cdi, result);
  }

  /// IPCA (variação mensal em %): o mês rende `1 + v ÷ 100`, distribuído
  /// por dia corrido de forma geométrica; meses ainda não publicados não
  /// rendem (o nível para no último mês publicado).
  static IndexLevels ipca(List<IndicatorPoint> monthly) {
    var level = Decimal.one;
    final result = <(LocalDate, Decimal)>[];
    for (final p in _sorted(monthly)) {
      final start = LocalDate(p.refDate.year, p.refDate.month, 1);
      final days = start.addMonths(1).daysSince(start);
      final monthFactor = Decimal.one + DecimalMath.divide(p.value, _hundred);
      final daily = DecimalMath.pow(
        monthFactor,
        DecimalMath.divide(Decimal.one, Decimal.fromInt(days)),
      );
      final base = level;
      var dayLevel = base;
      for (var i = 0; i < days; i++) {
        dayLevel = DecimalMath.rescale(dayLevel * daily);
        result.add((start.addDays(i), dayLevel));
      }
      // O fim do mês fica exato (sem o erro de arredondamento da potência).
      level = DecimalMath.rescale(base * monthFactor);
      result[result.length - 1] = (result.last.$1, level);
    }
    return IndexLevels(IndicatorSeries.ipca, result);
  }

  /// Índice publicado em pontos (Ibovespa): o próprio valor é o nível.
  static IndexLevels points(IndicatorSeries series, List<IndicatorPoint> p) =>
      IndexLevels(series, [for (final x in _sorted(p)) (x.refDate, x.value)]);

  /// Níveis de qualquer série pela unidade: taxa diária como o CDI, variação
  /// mensal como o IPCA, pontos como o Ibovespa. Nulo para taxa ao ano (a
  /// meta Selic não é um índice de retorno).
  static IndexLevels? of(IndicatorSeries series, List<IndicatorPoint> p) =>
      switch (series.unit) {
        IndicatorUnit.pctDay => IndexLevels(series, cdi(p).levels),
        IndicatorUnit.pctMonth => IndexLevels(series, ipca(p).levels),
        IndicatorUnit.indexNumber => points(series, p),
        IndicatorUnit.pctYear => null,
      };

  /// Série em outra moeda convertida para reais (calculado): nível × câmbio
  /// do dia (o último publicado até a data). Datas antes do primeiro câmbio
  /// ficam de fora.
  IndexLevels inBrl(List<(LocalDate, Decimal)> fxToBrl) {
    return IndexLevels(series, [
      for (final (d, v) in levels)
        if (levelIn(fxToBrl, d) case final rate?)
          (d, DecimalMath.rescale(v * rate)),
    ]);
  }

  /// Série em base 100 no fim de [from], até [to] (a primeira data é [from]).
  /// Vazia se o índice não tem dado até [from].
  List<(LocalDate, Decimal)> normalized(LocalDate from, LocalDate to) =>
      normalize(levels, from, to);

  /// Base 100 para qualquer sequência de níveis (o índice do TWR, inclusive).
  static List<(LocalDate, Decimal)> normalize(
    List<(LocalDate, Decimal)> levels,
    LocalDate from,
    LocalDate to,
  ) {
    final base = levelIn(levels, from);
    if (base == null || base <= Decimal.zero) return const [];
    return [
      (from, _hundred),
      for (final (d, v) in levels)
        if (d.isAfter(from) && !d.isAfter(to))
          (d, DecimalMath.rescale(DecimalMath.divide(v * _hundred, base))),
    ];
  }

  static final _hundred = Decimal.fromInt(100);

  static List<IndicatorPoint> _sorted(List<IndicatorPoint> points) =>
      [...points]..sort((a, b) => a.refDate.compareTo(b.refDate));
}

/// Um dia da comparação com um índice.
class BenchmarkPoint {
  const BenchmarkPoint(this.date, this.value, this.cumulative);

  final LocalDate date;

  /// Quanto valeriam os mesmos aportes e resgates, nas mesmas datas, se
  /// tivessem ido para o índice (hipotético).
  final Decimal value;

  /// Retorno acumulado do índice desde o primeiro ponto (fração).
  final Decimal cumulative;
}

/// Comparação da carteira com um índice (`docs/FORMULAS.md` §3.3). Sempre
/// hipotética: não é previsão nem recomendação (regra 3).
abstract final class Benchmark {
  /// Simula a carteira no índice: cada dia, o valor anterior cresce como o
  /// índice e recebe a mudança do total aplicado do dia (aportes −
  /// resgates). Sem dado do índice num dia, o valor fica parado (o índice
  /// não andou ou ainda não foi publicado). Nulo se o índice não cobre o
  /// primeiro dia da série.
  static List<BenchmarkPoint>? simulate(
    List<WealthPoint> points,
    IndexLevels index,
  ) {
    if (points.isEmpty || index.isEmpty) return null;
    final first = index.first!;
    if (first.isAfter(points.first.date)) return null;
    var i = -1;
    Decimal? levelOn(LocalDate d) {
      while (i + 1 < index.levels.length &&
          !index.levels[i + 1].$1.isAfter(d)) {
        i++;
      }
      return i < 0 ? null : index.levels[i].$2;
    }

    final result = <BenchmarkPoint>[];
    Decimal? previousLevel;
    Decimal? startLevel;
    var value = Decimal.zero;
    var previousInvested = Decimal.zero;
    for (final p in points) {
      final level = levelOn(p.date);
      if (level == null) return null;
      startLevel ??= level;
      if (previousLevel != null) {
        value = DecimalMath.rescale(
          value * DecimalMath.divide(level, previousLevel),
        );
      }
      value += p.invested - previousInvested;
      previousInvested = p.invested;
      previousLevel = level;
      result.add(
        BenchmarkPoint(
          p.date,
          value,
          DecimalMath.divide(level, startLevel) - Decimal.one,
        ),
      );
    }
    return result;
  }
}
