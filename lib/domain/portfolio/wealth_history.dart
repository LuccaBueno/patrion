import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../finance/business_calendar.dart';
import '../market/market_data.dart';
import '../market/market_price.dart';
import '../market/price_series.dart';
import 'codes.dart';
import 'entities.dart';
import 'operation_type.dart';
import 'portfolio_calculator.dart';
import 'portfolio_valuation.dart';

/// Um dia da evolução patrimonial, em reais (M-09; `docs/FORMULAS.md` §3.2).
class WealthPoint {
  const WealthPoint({
    required this.date,
    required this.value,
    required this.invested,
    required this.flow,
    required this.income,
    required this.buys,
    required this.sells,
    this.missing = const {},
  });

  final LocalDate date;

  /// Patrimônio: valor de mercado das posições avaliadas no fim do dia.
  final Decimal value;

  /// Total aplicado: aportes acumulados menos resgates dos ativos avaliados.
  final Decimal invested;

  /// Fluxo do dia que entra no TWR (aportes − resgates, mais a entrada de
  /// um ativo que passou a ter preço); positivo = dinheiro entrando.
  final Decimal flow;

  /// Proventos do dia (saem da carteira: o patrimônio não inclui o caixa).
  final Decimal income;

  /// Compras e vendas do dia (marcadores e barras).
  final Decimal buys;
  final Decimal sells;

  /// Ativos com posição e sem preço nesse dia (fora do valor e do aplicado).
  final Set<String> missing;

  Decimal get gain => value - invested;

  /// Ganho ÷ aplicado; nulo sem aplicado positivo.
  Decimal? get gainFraction =>
      invested > Decimal.zero ? DecimalMath.divide(gain, invested) : null;
}

/// Evolução patrimonial dia a dia e o TWR da carteira.
class WealthSeries {
  WealthSeries({
    required this.points,
    required this.entries,
    required this.excluded,
  });

  static final empty = WealthSeries(points: [], entries: {}, excluded: {});

  final List<WealthPoint> points;

  /// Ativos que entraram na avaliação depois da primeira compra (sem preço
  /// antes), com a data de entrada.
  final Map<String, LocalDate> entries;

  /// Ativos sem nenhum preço até hoje: fora da evolução.
  final Set<String> excluded;

  bool get isEmpty => points.isEmpty;

  /// Índice do TWR (1 no primeiro ponto). Os fluxos contam no fim do dia;
  /// os proventos saem como retirada (entram no retorno). Dia que começa
  /// sem capital (véspera vazia) não tem retorno: o fator fica igual.
  List<(LocalDate, Decimal)> twrIndex() => _twr;

  late final List<(LocalDate, Decimal)> _twr = _computeTwr();

  List<(LocalDate, Decimal)> _computeTwr() {
    final result = <(LocalDate, Decimal)>[];
    var factor = Decimal.one;
    Decimal? previousAfter;
    for (final p in points) {
      final after = p.value;
      // Valor antes do fluxo: o fim do dia sem o dinheiro que entrou, mais
      // os proventos que saíram.
      final before = after - p.flow + p.income;
      if (previousAfter != null && previousAfter > Decimal.zero) {
        factor = DecimalMath.rescale(
          factor * DecimalMath.divide(before, previousAfter),
        );
      }
      result.add((p.date, factor));
      previousAfter = after;
    }
    return result;
  }

  /// TWR entre o fim de [from] (ou o primeiro ponto depois) e [to].
  Decimal? twrBetween(LocalDate from, LocalDate to) {
    final index = twrIndex();
    (LocalDate, Decimal)? start;
    (LocalDate, Decimal)? end;
    for (final e in index) {
      if (e.$1.isAfter(to)) break;
      if (!e.$1.isAfter(from)) start = e;
      end = e;
    }
    start ??= index.isEmpty ? null : index.first;
    if (start == null || end == null || !end.$1.isAfter(start.$1)) {
      return null;
    }
    return DecimalMath.divide(end.$2, start.$2) - Decimal.one;
  }
}

/// Monta a evolução patrimonial a partir das operações e dos preços
/// históricos (`docs/FORMULAS.md` §3.2):
///
/// - quantidade de cada ativo em cada dia (o motor de posições, até o dia)
///   × o último fechamento até o dia (ou o preço ou saldo informado mais
///   recente, como na Carteira), convertido para reais pelo câmbio do dia;
/// - um ponto por dia útil, da primeira operação até [today];
/// - total aplicado = compras e aportes (com custos) − vendas e resgates
///   (líquidos de custos), acumulados;
/// - ativo com posição e sem preço num dia fica fora do valor e do
///   aplicado; ao ganhar o primeiro preço, entra com o aplicado acumulado
///   até ali (e, no TWR, como um aporte do valor dele);
/// - [finalValues] (valor de cada ativo no retrato da Carteira, em reais)
///   fecha o último dia com os mesmos números da Carteira.
abstract final class WealthHistory {
  static WealthSeries build({
    required List<Operation> operations,
    required Iterable<ManualValuation> valuations,
    required Map<String, Asset> assets,
    required Map<String, List<PricePoint>> closes,
    required Map<String, List<(LocalDate, Decimal)>> fxToBrl,
    required LocalDate today,
    BusinessCalendar? calendar,
    Map<String, Decimal>? finalValues,
  }) {
    final ops = [
      for (final o in operations)
        if (!o.tradeDate.isAfter(today)) o,
    ]..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
    if (ops.isEmpty) return WealthSeries.empty;
    final cal = calendar ?? BusinessCalendar.brazil;
    final opsByDate = <LocalDate, List<Operation>>{};
    for (final o in ops) {
      (opsByDate[o.tradeDate] ??= []).add(o);
    }
    final days = <LocalDate>{
      for (var d = ops.first.tradeDate; !d.isAfter(today); d = d.addDays(1))
        if (cal.isBusinessDay(d) || opsByDate.containsKey(d)) d,
    }.toList();
    final valuationList = valuations.toList();

    // Ponteiros nas séries de preço e câmbio (os dias só avançam).
    final closeAt = <String, int>{};
    PricePoint? closeOn(String assetId, LocalDate d) {
      final series = closes[assetId];
      if (series == null || series.isEmpty) return null;
      var i = closeAt[assetId] ?? -1;
      while (i + 1 < series.length && !series[i + 1].date.isAfter(d)) {
        i++;
      }
      closeAt[assetId] = i;
      return i < 0 ? null : series[i];
    }

    final fxAt = <String, int>{};
    Decimal? fxOn(String currency, LocalDate d) {
      if (currency == 'BRL') return Decimal.one;
      final series = fxToBrl[currency];
      if (series == null || series.isEmpty) return null;
      var i = fxAt[currency] ?? -1;
      while (i + 1 < series.length && !series[i + 1].$1.isAfter(d)) {
        i++;
      }
      fxAt[currency] = i;
      return i < 0 ? null : series[i].$2;
    }

    // Ativos sem nenhum preço até hoje ficam fora.
    final excluded = <String>{
      for (final o in ops)
        if (o.assetId != null &&
            assets[o.assetId] != null &&
            assets[o.assetId]!.assetClass != AssetClass.cash &&
            !_everPriced(
              o.assetId!,
              assets[o.assetId]!,
              closes,
              valuationList,
              finalValues,
            ))
          o.assetId!,
    };

    var state = PortfolioState.empty;
    final cumulative = <String, Decimal>{}; // aplicado de cada ativo
    final inValuation = <String>{};
    final everIn = <String>{};
    final lastValue = <String, Decimal>{};
    var heldYesterday = <String>{};
    final entries = <String, LocalDate>{};
    final points = <WealthPoint>[];
    for (final d in days) {
      final todayOps = opsByDate[d] ?? const <Operation>[];
      if (todayOps.isNotEmpty) {
        state = PortfolioCalculator.compute(
          operations: ops,
          valuations: valuationList,
          assets: assets,
          until: d,
        );
      }
      // Fluxos do dia por ativo, em reais.
      final tradeFlow = <String, Decimal>{};
      final incomeOf = <String, Decimal>{};
      final buysOf = <String, Decimal>{};
      final sellsOf = <String, Decimal>{};
      for (final o in todayOps) {
        final id = o.assetId;
        if (id == null || excluded.contains(id)) continue;
        final rate = o.currency == 'BRL'
            ? Decimal.one
            : (o.fxRate ?? fxOn(o.currency, d));
        if (rate == null) continue;
        final amount = o.amount * rate;
        final charges = o.charges * rate;
        switch (_kind(o.type)) {
          case _Flow.contribution:
            final v = amount + charges;
            tradeFlow[id] = (tradeFlow[id] ?? Decimal.zero) + v;
            buysOf[id] = (buysOf[id] ?? Decimal.zero) + v;
          case _Flow.redemption:
            final v = amount - charges;
            tradeFlow[id] = (tradeFlow[id] ?? Decimal.zero) - v;
            sellsOf[id] = (sellsOf[id] ?? Decimal.zero) + v;
          case _Flow.income:
            incomeOf[id] = (incomeOf[id] ?? Decimal.zero) + amount - charges;
          case _Flow.none:
            break;
        }
      }
      for (final MapEntry(:key, :value) in tradeFlow.entries) {
        cumulative[key] = (cumulative[key] ?? Decimal.zero) + value;
      }

      // Valor de cada ativo no fim do dia.
      final perAsset = <String, Decimal>{};
      final missing = <String>{};
      final held = {
        for (final p in state.positions)
          if (p.isOpen && !excluded.contains(p.assetId)) p.assetId,
      };
      if (d == days.last && finalValues != null) {
        for (final id in held) {
          final v = finalValues[id];
          if (v == null) {
            missing.add(id);
          } else {
            perAsset[id] = v;
          }
        }
      } else {
        final prices = <String, MarketPrice>{};
        for (final id in held) {
          final asset = assets[id];
          if (asset?.priceSource != PriceSource.market) continue;
          final c = closeOn(id, d);
          if (c == null) continue;
          prices[id] = MarketPrice(
            assetId: id,
            price: c.price,
            currency: asset!.currency,
            refDate: c.date,
            source: 'historico',
            dataType: MarketDataType.close,
            collectedAt: '',
          );
        }
        final valued = PortfolioValuator.value(
          state: state,
          valuations: valuationList,
          assets: assets,
          asOf: d,
          marketPrices: prices,
        );
        for (final v in valued) {
          final id = v.position.assetId;
          if (!held.contains(id)) continue;
          final mv = v.marketValue;
          final rate = fxOn(v.position.currency, d);
          if (mv == null || rate == null) {
            missing.add(id);
            continue;
          }
          perAsset[id] = (perAsset[id] ?? Decimal.zero) + mv * rate;
        }
        // Uma conta sem preço deixa o ativo inteiro sem valor no dia.
        missing.forEach(perAsset.remove);
      }

      // Entradas e saídas da avaliação, e o fluxo do TWR.
      var flow = Decimal.zero;
      var income = Decimal.zero;
      var buys = Decimal.zero;
      var sells = Decimal.zero;
      for (final id in {...held, ...inValuation, ...tradeFlow.keys}) {
        final valuedToday = perAsset.containsKey(id);
        final wasIn = inValuation.contains(id);
        if (!wasIn && valuedToday) {
          if (heldYesterday.contains(id)) {
            // Já tinha a posição, sem preço: entra pelo valor do dia.
            flow += perAsset[id]!;
            entries.putIfAbsent(id, () => d);
          } else {
            flow += tradeFlow[id] ?? Decimal.zero;
          }
          inValuation.add(id);
          everIn.add(id);
        } else if (wasIn && !held.contains(id)) {
          // Vendeu tudo hoje.
          flow += tradeFlow[id] ?? Decimal.zero;
          inValuation.remove(id);
        } else if (wasIn && !valuedToday) {
          // Perdeu o preço (sem câmbio, por exemplo): sai pelo último valor.
          flow -= lastValue[id] ?? Decimal.zero;
          inValuation.remove(id);
        } else if (wasIn) {
          flow += tradeFlow[id] ?? Decimal.zero;
        }
        if (everIn.contains(id)) {
          income += incomeOf[id] ?? Decimal.zero;
          buys += buysOf[id] ?? Decimal.zero;
          sells += sellsOf[id] ?? Decimal.zero;
        }
      }
      lastValue.addAll(perAsset);
      heldYesterday = held;

      var value = Decimal.zero;
      for (final v in perAsset.values) {
        value += v;
      }
      var invested = Decimal.zero;
      for (final id in everIn) {
        invested += cumulative[id] ?? Decimal.zero;
      }
      points.add(
        WealthPoint(
          date: d,
          value: value,
          invested: invested,
          flow: flow,
          income: income,
          buys: buys,
          sells: sells,
          missing: missing,
        ),
      );
    }
    return WealthSeries(points: points, entries: entries, excluded: excluded);
  }

  static bool _everPriced(
    String assetId,
    Asset asset,
    Map<String, List<PricePoint>> closes,
    List<ManualValuation> valuations,
    Map<String, Decimal>? finalValues,
  ) {
    if (finalValues?.containsKey(assetId) ?? false) return true;
    if (asset.priceSource == PriceSource.market &&
        (closes[assetId]?.isNotEmpty ?? false)) {
      return true;
    }
    return valuations.any((v) => v.assetId == assetId);
  }

  static _Flow _kind(OperationType t) => switch (t) {
    OperationType.buy ||
    OperationType.contribution ||
    OperationType.reinvestment ||
    OperationType.manualAdjustment => _Flow.contribution,
    OperationType.sell ||
    OperationType.redemption ||
    OperationType.amortization ||
    OperationType.maturity => _Flow.redemption,
    _ when t.isIncome => _Flow.income,
    _ => _Flow.none,
  };
}

enum _Flow { contribution, redemption, income, none }
