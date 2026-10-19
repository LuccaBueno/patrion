import 'dart:async';

import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/market_indicators.dart';

/// Câmbio e indicadores mais recentes guardados, com fonte e data (SPEC §5;
/// regra 2). Não acessa a rede.
class MarketOverview {
  const MarketOverview({
    required this.fx,
    required this.indicators,
    this.cdiAnnual,
    this.ipca12m,
  });

  static const empty = MarketOverview(fx: {}, indicators: {});

  /// Câmbio mais recente de cada moeda contra o real.
  final Map<String, FxRate> fx;

  /// Último valor publicado de cada indicador.
  final Map<IndicatorSeries, IndicatorPoint> indicators;

  /// CDI do último dia, anualizado na base 252 (fração).
  final Decimal? cdiAnnual;

  /// IPCA acumulado nos 12 meses até o último mês publicado.
  final ({Decimal value, LocalDate from, LocalDate to})? ipca12m;

  bool get isEmpty => fx.isEmpty && indicators.isEmpty;

  static Future<MarketOverview> load(MarketRepository repo) async {
    final fx = <String, FxRate>{};
    for (final c in await repo.fxCurrencies()) {
      final rate = await repo.latestFx(c);
      if (rate != null) fx[c] = rate;
    }
    final indicators = <IndicatorSeries, IndicatorPoint>{};
    for (final s in IndicatorSeries.values) {
      final p = await repo.latestIndicator(s);
      if (p != null) indicators[s] = p;
    }
    final cdi = indicators[IndicatorSeries.cdi];
    final ipca = indicators[IndicatorSeries.ipca];
    return MarketOverview(
      fx: fx,
      indicators: indicators,
      cdiAnnual: cdi == null
          ? null
          : MarketIndicators.annualizeDaily(cdi.value),
      ipca12m: ipca == null
          ? null
          : MarketIndicators.accumulated12m(
              await repo.indicator(
                IndicatorSeries.ipca,
                from: LocalDate(ipca.refDate.year - 1, ipca.refDate.month, 1),
              ),
            ),
    );
  }

  /// Recarrega quando qualquer dado de mercado muda.
  static Stream<MarketOverview> watch(MarketRepository repo) {
    late final StreamController<MarketOverview> controller;
    StreamSubscription<void>? changes;
    var queue = Future<void>.value();
    void refresh() {
      queue = queue.then((_) async {
        if (controller.isClosed) return;
        try {
          final value = await load(repo);
          if (!controller.isClosed) controller.add(value);
        } on Object catch (error, stack) {
          if (!controller.isClosed) controller.addError(error, stack);
        }
      });
    }

    controller = StreamController<MarketOverview>(
      onListen: () {
        refresh();
        changes = repo.watchChanges().listen((_) => refresh());
      },
      onCancel: () {
        unawaited(changes?.cancel());
        changes = null;
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }
}
