import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../domain/finance/benchmark.dart';
import '../../domain/market/market_data.dart';
import '../../domain/portfolio/class_views.dart';
import '../../domain/portfolio/holdings.dart';
import '../../domain/portfolio/operation_type.dart';
import 'portfolio_query.dart';

/// Dados das visões por classe da Carteira (F8, parte 5). Não acessa a
/// rede: usa o que está guardado.
class ClassViewsData {
  const ClassViewsData({
    required this.fii,
    required this.fixedIncome,
    required this.foreign,
    required this.fxNow,
  });

  final Map<String, FiiMetrics> fii;
  final Map<String, FixedIncomeView> fixedIncome;

  /// Retorno em reais dos ativos em outra moeda (internacional e cripto em
  /// dólar).
  final Map<String, ForeignReturn> foreign;

  /// Câmbio mais recente de cada moeda (reais por unidade).
  final Map<String, Decimal> fxNow;
}

class ClassViewsService {
  const ClassViewsService(this._market);

  final MarketRepository _market;

  Future<ClassViewsData> load(
    PortfolioSnapshot snap, {
    Map<String, Decimal> toBrl = const {},
  }) async {
    final holdings = Holdings.build(snap.valued, toBrl: toBrl);
    final open = [
      for (final h in holdings)
        if (h.isOpen && h.asset != null) h,
    ];
    final today = snap.asOf;

    // FIIs: informe da CVM, proventos e volume.
    final fii = <String, FiiMetrics>{};
    for (final h in open) {
      final a = h.asset!;
      if (!ClassView.fii.includes(a)) continue;
      final symbol = a.symbol.toUpperCase();
      final isin = a.isin ?? await _market.isinOf(symbol, 'B3');
      final bars = await _market.prices(symbol, 'B3', from: today.addDays(-70));
      fii[a.id] = FiiMetrics.compute(
        assetId: a.id,
        today: today,
        price: h.unitPrice,
        report: isin == null ? null : await _market.latestFiiReport(isin),
        events: await _market.events(symbol, 'B3'),
        bars: bars,
      );
    }

    // Renda fixa: projeção pelo indexador e a TIR.
    final fixed = <String, FixedIncomeView>{};
    final fixedOpen = [
      for (final h in open)
        if (ClassView.fixedIncome.includes(h.asset!)) h,
    ];
    if (fixedOpen.isNotEmpty) {
      final flowsOf = {
        for (final h in fixedOpen)
          h.assetId: FixedIncomeView.flows(snap.operations, h.assetId),
      };
      final first = flowsOf.values
          .expand((f) => f)
          .map((f) => f.$1)
          .fold<LocalDate?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
      final since = (first ?? today).addDays(-40);
      final cdi = await _market.indicator(IndicatorSeries.cdi, from: since);
      final selic = await _market.indicator(IndicatorSeries.selic, from: since);
      final ipca = await _market.indicator(IndicatorSeries.ipca, from: since);
      final igpm = await _market.indicator(IndicatorSeries.igpm, from: since);
      final monthly = {
        if (ipca.isNotEmpty) IndicatorSeries.ipca: IndexLevels.ipca(ipca),
        if (igpm.isNotEmpty)
          IndicatorSeries.igpm: IndexLevels.of(IndicatorSeries.igpm, igpm)!,
      };
      final cdiLevels = cdi.isEmpty ? null : IndexLevels.cdi(cdi);
      for (final h in fixedOpen) {
        fixed[h.assetId] = FixedIncomeView.compute(
          assetId: h.assetId,
          terms: snap.fixedIncome[h.assetId],
          flows: flowsOf[h.assetId]!,
          today: today,
          daily: {IndicatorSeries.cdi: cdi, IndicatorSeries.selic: selic},
          monthly: monthly,
          cdiLevels: cdiLevels,
          // O valor da Carteira (saldo informado ou preço de mercado); sem
          // ele, a TIR usa a projeção.
          reference: h.marketValue,
        );
      }
    }

    // Outras moedas: câmbio de cada compra e o de hoje.
    final foreign = <String, ForeignReturn>{};
    final fxNow = <String, Decimal>{};
    final fxHistory = <String, List<(LocalDate, Decimal)>>{};
    for (final h in open) {
      if (h.currency == 'BRL') continue;
      final history = fxHistory[h.currency] ??= await _market.fxHistory(
        h.currency,
      );
      if (history.isEmpty) continue;
      fxNow[h.currency] = history.last.$2;
      final buys = <(Decimal, Decimal)>[];
      for (final o in snap.operations) {
        if (o.assetId != h.assetId) continue;
        if (o.type != OperationType.buy &&
            o.type != OperationType.contribution &&
            o.type != OperationType.reinvestment) {
          continue;
        }
        final fx = o.fxRate ?? IndexLevels.levelIn(history, o.tradeDate);
        if (fx == null) continue;
        buys.add((o.amount + o.charges, fx));
      }
      final value = h.marketValue;
      if (value == null) continue;
      final r = ForeignReturn.compute(
        costOriginal: h.totalCost,
        valueOriginal: value,
        buys: buys,
        fxNow: history.last.$2,
      );
      if (r != null) foreign[h.assetId] = r;
    }

    return ClassViewsData(
      fii: fii,
      fixedIncome: fixed,
      foreign: foreign,
      fxNow: fxNow,
    );
  }

  /// Visões com ativos em carteira (sempre "Todos" primeiro).
  static List<ClassView> available(PortfolioSnapshot snap) {
    final assets = [
      for (final p in snap.state.positions)
        if (p.isOpen) ?snap.assets[p.assetId],
    ];
    return [
      ClassView.all,
      for (final v in ClassView.values.skip(1))
        if (assets.any(v.includes)) v,
    ];
  }
}
