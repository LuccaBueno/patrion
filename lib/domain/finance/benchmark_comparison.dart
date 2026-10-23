import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../market/market_data.dart';
import '../portfolio/wealth_history.dart';
import 'benchmark.dart';
import 'returns.dart';

/// Índices da aba Benchmarks (SPEC §12.5; F8, parte 2).
enum BenchmarkIndex {
  cdi(IndicatorSeries.cdi),
  selic(IndicatorSeries.selic),
  ipca(IndicatorSeries.ipca),
  igpm(IndicatorSeries.igpm),
  ibovespa(IndicatorSeries.ibovespa),
  ifix(IndicatorSeries.ifix),
  btc(IndicatorSeries.btcUsd, inUsd: true),
  sp500(IndicatorSeries.sp500, inUsd: true),
  nasdaq(IndicatorSeries.nasdaq, inUsd: true),

  /// Sem fonte gratuita com histórico (ANBIMA; aprovado em 23/10/2026).
  ima(null),
  idka(null);

  const BenchmarkIndex(this.series, {this.inUsd = false});

  /// Série guardada; nula quando não há fonte.
  final IndicatorSeries? series;

  /// Cotado em dólares: comparado em reais pela PTAX.
  final bool inUsd;
}

/// Um índice contra a carteira no mesmo intervalo (`docs/FORMULAS.md`
/// §3.5). Sempre em reais; [original] traz o retorno em dólares.
class BenchmarkComparison {
  const BenchmarkComparison({
    required this.index,
    required this.from,
    required this.to,
    required this.value,
    required this.portfolio,
    this.original,
  });

  final BenchmarkIndex index;

  /// Dia-base e último dia com dado do índice (até o fim do período).
  final LocalDate from;
  final LocalDate to;

  /// Retorno acumulado do índice em reais (fração).
  final Decimal value;

  /// Retorno acumulado na moeda original (só nos índices em dólares).
  final Decimal? original;

  /// TWR da carteira no mesmo intervalo; nulo se ela não tem dois pontos
  /// nele.
  final Decimal? portfolio;

  int get days => to.daysSince(from);

  /// Taxa ao ano, só em intervalos de mais de 366 dias.
  Decimal? get annual => days > 366 ? Returns.annualize(value, days) : null;

  /// Carteira menos o índice (fração; × 100 = pontos percentuais).
  Decimal? get difference => portfolio == null ? null : portfolio! - value;

  /// Compara no intervalo do fim de [from] ao fim de [to]. [levels] são os
  /// níveis do índice na moeda dele; [usdToBrl], a PTAX (índices em dólar).
  /// Nulo se o índice não tem dado até [from] ou depois dele.
  static BenchmarkComparison? compute(
    BenchmarkIndex index, {
    required IndexLevels levels,
    required WealthSeries series,
    required LocalDate from,
    required LocalDate to,
    List<(LocalDate, Decimal)> usdToBrl = const [],
  }) {
    final brl = index.inUsd ? levels.inBrl(usdToBrl) : levels;
    final last = brl.last;
    if (last == null) return null;
    final end = last.isBefore(to) ? last : to;
    final value = brl.growth(from, end);
    if (value == null) return null;
    return BenchmarkComparison(
      index: index,
      from: from,
      to: end,
      value: value,
      original: index.inUsd ? levels.growth(from, end) : null,
      portfolio: series.twrBetween(from, end),
    );
  }
}
