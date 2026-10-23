import 'dart:isolate';

import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../../domain/finance/risk.dart';
import '../../domain/market/market_data.dart';
import 'wealth_service.dart';

/// Risco de um ativo no período (preço ajustado).
class AssetRisk {
  const AssetRisk({
    required this.assetId,
    required this.volatility,
    required this.drawdown,
    required this.firstDate,
  });

  final String assetId;
  final Decimal? volatility;
  final Drawdown? drawdown;

  /// Primeiro fechamento guardado no período (nulo sem nenhum).
  final LocalDate? firstDate;
}

/// Medidas de risco do período (`docs/FORMULAS.md` §11).
class RiskReport {
  const RiskReport({
    required this.from,
    required this.to,
    required this.volatility,
    required this.drawdown,
    required this.sharpe,
    required this.beta,
    required this.assets,
    required this.correlated,
    required this.correlations,
  });

  final LocalDate from;
  final LocalDate to;

  /// Da carteira, pelo índice do TWR.
  final Decimal? volatility;
  final Drawdown? drawdown;

  /// Contra o CDI e o Ibovespa; nulos com menos de 12 meses ou sem o
  /// índice.
  final Decimal? sharpe;
  final Decimal? beta;

  /// Ativos com posição aberta e preço de mercado, do maior valor para o
  /// menor.
  final List<AssetRisk> assets;

  /// Ativos da matriz de correlação (no máximo [maxCorrelated]).
  final List<String> correlated;

  /// Correlação de cada par (`a|b`, na ordem de [correlated]).
  final Map<String, Decimal?> correlations;

  static const maxCorrelated = 10;

  Decimal? correlation(String a, String b) =>
      a == b ? Decimal.one : correlations['$a|$b'] ?? correlations['$b|$a'];
}

/// Calcula o risco num isolate (correlações de anos de pregões).
class RiskService {
  const RiskService({this.useIsolate = true});

  final bool useIsolate;

  Future<RiskReport> compute(
    WealthOverview o, {
    required LocalDate from,
    required LocalDate to,
  }) {
    RiskReport run() => build(o, from: from, to: to);
    return useIsolate ? Isolate.run(run) : Future.value(run());
  }

  static RiskReport build(
    WealthOverview o, {
    required LocalDate from,
    required LocalDate to,
  }) {
    final twr = Risk.window(o.series.twrIndex(), from, to);
    final ids = [
      for (final e
          in (o.currentValues.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value))))
        if (o.adjusted.containsKey(e.key)) e.key,
    ];
    final windows = {
      for (final id in ids)
        id: Risk.window(
          [for (final p in o.adjusted[id]!) (p.date, p.price)],
          from,
          to,
        ),
    };
    final correlated = ids.take(RiskReport.maxCorrelated).toList();
    final correlations = <String, Decimal?>{};
    for (var i = 0; i < correlated.length; i++) {
      for (var j = i + 1; j < correlated.length; j++) {
        correlations['${correlated[i]}|${correlated[j]}'] = Risk.correlation(
          windows[correlated[i]]!,
          windows[correlated[j]]!,
        );
      }
    }
    final cdi = o.indices[IndicatorSeries.cdi];
    final ibov = o.indices[IndicatorSeries.ibovespa];
    return RiskReport(
      from: from,
      to: to,
      volatility: Risk.volatility(Risk.returns(twr)),
      drawdown: Risk.maxDrawdown(twr),
      sharpe: cdi == null ? null : Risk.sharpe(twr, cdi),
      beta: ibov == null
          ? null
          : Risk.beta(twr, Risk.window(ibov.levels, from, to)),
      assets: [
        for (final id in ids)
          AssetRisk(
            assetId: id,
            volatility: Risk.volatility(Risk.returns(windows[id]!)),
            drawdown: Risk.maxDrawdown(windows[id]!),
            firstDate: windows[id]!.firstOrNull?.$1,
          ),
      ],
      correlated: correlated,
      correlations: correlations,
    );
  }
}
