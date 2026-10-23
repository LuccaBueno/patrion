import 'dart:isolate';

import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../domain/finance/benchmark.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/price_series.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/wealth_history.dart';
import 'portfolio_query.dart';

/// Evolução patrimonial e os índices para comparar (Painel, M-09).
class WealthOverview {
  const WealthOverview({
    required this.series,
    required this.indices,
    required this.benchmarks,
    required this.asOf,
    this.usdToBrl = const [],
  });

  final WealthSeries series;

  /// Níveis de cada série de [loaded] com dados guardados (pode faltar
  /// alguma). Bitcoin, S&P 500 e Nasdaq em dólares.
  final Map<IndicatorSeries, IndexLevels> indices;

  /// PTAX do dólar, para converter as séries em dólares (Benchmarks).
  final List<(LocalDate, Decimal)> usdToBrl;

  /// "Os mesmos aportes no índice", para cada índice que cobre a carteira
  /// desde o primeiro dia (hipotético, regra 3).
  final Map<IndicatorSeries, List<BenchmarkPoint>> benchmarks;
  final LocalDate asOf;

  /// Índices do "Comparar com" do Painel.
  static const compared = [
    IndicatorSeries.cdi,
    IndicatorSeries.ibovespa,
    IndicatorSeries.ipca,
    IndicatorSeries.ifix,
  ];

  /// Séries carregadas para o Painel e o Desempenho (F8).
  static const loaded = [
    IndicatorSeries.cdi,
    IndicatorSeries.selic,
    IndicatorSeries.ipca,
    IndicatorSeries.igpm,
    IndicatorSeries.ibovespa,
    IndicatorSeries.ifix,
    IndicatorSeries.btcUsd,
    IndicatorSeries.sp500,
    IndicatorSeries.nasdaq,
  ];

  /// Séries cotadas em dólares.
  static const inUsd = {
    IndicatorSeries.btcUsd,
    IndicatorSeries.sp500,
    IndicatorSeries.nasdaq,
  };
}

/// Junta operações, fechamentos guardados, câmbio e índices e calcula a
/// evolução patrimonial num isolate (anos de pregões; a tela não trava).
/// Não acessa a rede.
class WealthService {
  const WealthService(this._market, {this.useIsolate = true});

  final MarketRepository _market;

  /// Calcula num isolate (desligado nos testes de tela, que usam relógio
  /// falso).
  final bool useIsolate;

  Future<WealthOverview> load(PortfolioSnapshot snap) async {
    final assets = snap.assets;
    final closes = <String, List<PricePoint>>{};
    for (final a in assets.values) {
      if (a.priceSource != PriceSource.market) continue;
      final bars = await _market.prices(a.symbol.toUpperCase(), a.market.code);
      if (bars.isNotEmpty) closes[a.id] = PriceSeries.closes(bars);
    }
    final fx = <String, List<(LocalDate, Decimal)>>{};
    for (final c in {for (final a in assets.values) a.currency}) {
      if (c == 'BRL') continue;
      fx[c] = await _market.fxHistory(c);
    }
    // Valor de cada ativo no retrato da Carteira, em reais: o último dia da
    // evolução fecha com ela.
    final finalValues = <String, Decimal>{};
    final unpriced = <String>{};
    for (final v in snap.valued) {
      if (!v.position.isOpen) continue;
      final id = v.position.assetId;
      final mv = v.marketValue;
      final series = fx[v.position.currency];
      final rate = v.position.currency == 'BRL'
          ? Decimal.one
          : (series == null || series.isEmpty ? null : series.last.$2);
      if (mv == null || rate == null) {
        unpriced.add(id);
        continue;
      }
      finalValues[id] = (finalValues[id] ?? Decimal.zero) + mv * rate;
    }
    unpriced.forEach(finalValues.remove);

    final first = snap.operations.isEmpty
        ? snap.asOf
        : snap.operations
              .map((o) => o.tradeDate)
              .reduce((a, b) => a.isBefore(b) ? a : b);
    final since = LocalDate(first.year, first.month, 1).addDays(-10);
    final raw = <IndicatorSeries, List<IndicatorPoint>>{
      for (final s in WealthOverview.loaded)
        s: await _market.indicator(s, from: since),
    };
    final usd = fx['USD'] ?? await _market.fxHistory('USD');

    final operations = snap.operations;
    final valuations = snap.valuations;
    final asOf = snap.asOf;
    WealthOverview compute() {
      final series = WealthHistory.build(
        operations: operations,
        valuations: valuations,
        assets: assets,
        closes: closes,
        fxToBrl: fx,
        today: asOf,
        finalValues: finalValues,
      );
      final indices = {
        for (final MapEntry(:key, :value) in raw.entries)
          if (value.isNotEmpty) key: ?IndexLevels.of(key, value),
      };
      // O TWR fica calculado aqui, fora da interface.
      series.twrIndex();
      return WealthOverview(
        series: series,
        indices: indices,
        benchmarks: {
          for (final s in WealthOverview.compared)
            if (indices[s] case final levels?)
              s: ?Benchmark.simulate(series.points, levels),
        },
        asOf: asOf,
        usdToBrl: usd,
      );
    }

    return useIsolate ? Isolate.run(compute) : compute();
  }
}
