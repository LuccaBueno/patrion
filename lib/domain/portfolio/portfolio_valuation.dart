import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'codes.dart';
import 'entities.dart';
import 'portfolio_calculator.dart';
import '../market/market_price.dart';

/// Posição com o valor de mercado vindo dos preços e saldos informados ou
/// das cotações de mercado.
///
/// Sem preço ou saldo, o valor de mercado é nulo ("indisponível", regra 1):
/// nunca é estimado pelo custo.
class ValuedPosition {
  const ValuedPosition({
    required this.position,
    this.asset,
    this.marketValue,
    this.unitPrice,
    this.valuationDate,
    this.valuationKind,
    this.valuationStale = false,
    this.marketPrice,
  });

  final Position position;
  final Asset? asset;
  final Decimal? marketValue;

  /// Preço unitário usado (nulo quando o valor veio de um saldo).
  final Decimal? unitPrice;

  /// Data de referência do preço ou saldo usado.
  final LocalDate? valuationDate;
  final ValuationKind? valuationKind;

  /// O saldo informado é anterior à última operação da posição: o valor
  /// não reflete essa operação.
  final bool valuationStale;

  /// Preço de mercado usado (com fonte, data e tipo), quando o valor veio
  /// dele e não de um preço ou saldo informado.
  final MarketPrice? marketPrice;

  bool get hasMarketValue => marketValue != null;

  /// Lucro ou prejuízo não realizado: valor de mercado − custo.
  Decimal? get unrealizedPnl =>
      marketValue == null ? null : marketValue! - position.totalCost;

  /// Retorno simples sobre o custo, em fração (0,1 = 10%).
  Decimal? get simpleReturn {
    final pnl = unrealizedPnl;
    if (pnl == null || position.totalCost <= Decimal.zero) return null;
    return DecimalMath.divide(pnl, position.totalCost);
  }
}

/// Aplica preços e saldos às posições (SPEC §8; preço manual e de mercado).
///
/// Regras (`docs/FORMULAS.md` §2 e §2.1):
/// - Ativo com preço **manual**: saldo informado mais recente até [asOf]
///   para a conta e o ativo; senão, quantidade × o preço informado mais
///   recente.
/// - Ativo com preço **de mercado**: vale o mais recente entre o saldo
///   informado, o preço informado e o preço de mercado ([marketPrices]); na
///   mesma data, o informado pelo usuário.
/// - Preço em moeda diferente da posição é ignorado (sem conversão).
abstract final class PortfolioValuator {
  static List<ValuedPosition> value({
    required PortfolioState state,
    required Iterable<ManualValuation> valuations,
    required Map<String, Asset> assets,
    required LocalDate asOf,
    Map<String, MarketPrice> marketPrices = const {},
  }) {
    final latestBalance = <(String, String), ManualValuation>{};
    final latestPrice = <String, ManualValuation>{};
    for (final v in valuations) {
      if (v.refDate.isAfter(asOf)) continue;
      switch (v.kind) {
        case ValuationKind.balance:
          if (v.accountId == null) continue;
          final key = (v.accountId!, v.assetId);
          final current = latestBalance[key];
          if (current == null || !v.refDate.isBefore(current.refDate)) {
            latestBalance[key] = v;
          }
        case ValuationKind.unitPrice:
          final current = latestPrice[v.assetId];
          if (current == null || !v.refDate.isBefore(current.refDate)) {
            latestPrice[v.assetId] = v;
          }
      }
    }

    return [
      for (final p in state.positions)
        _valueOne(
          p,
          assets[p.assetId],
          latestBalance[(p.accountId, p.assetId)],
          latestPrice[p.assetId],
          assets[p.assetId]?.priceSource == PriceSource.market
              ? marketPrices[p.assetId]
              : null,
        ),
    ];
  }

  static ValuedPosition _valueOne(
    Position p,
    Asset? asset,
    ManualValuation? balance,
    ManualValuation? price,
    MarketPrice? market,
  ) {
    if (!p.isOpen) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: Decimal.zero,
      );
    }
    final usableBalance = balance != null && balance.currency == p.currency
        ? balance
        : null;
    final usablePrice =
        price != null &&
            price.currency == p.currency &&
            p.quantity > Decimal.zero
        ? price
        : null;
    final usableMarket =
        market != null &&
            market.currency == p.currency &&
            p.quantity > Decimal.zero
        ? market
        : null;

    // O preço de mercado só vence se for mais recente que o informado.
    final manualDate = [
      ?usableBalance?.refDate,
      ?usablePrice?.refDate,
    ].fold<LocalDate?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
    if (usableMarket != null &&
        (manualDate == null || usableMarket.refDate.isAfter(manualDate))) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: p.quantity * usableMarket.price,
        unitPrice: usableMarket.price,
        valuationDate: usableMarket.refDate,
        marketPrice: usableMarket,
      );
    }
    if (usableBalance != null &&
        (usablePrice == null ||
            !usablePrice.refDate.isAfter(usableBalance.refDate) ||
            asset?.priceSource != PriceSource.market)) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: usableBalance.value,
        valuationDate: usableBalance.refDate,
        valuationKind: ValuationKind.balance,
        valuationStale: p.lastOperationDate.isAfter(usableBalance.refDate),
      );
    }
    if (usablePrice != null) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: p.quantity * usablePrice.value,
        unitPrice: usablePrice.value,
        valuationDate: usablePrice.refDate,
        valuationKind: ValuationKind.unitPrice,
      );
    }
    return ValuedPosition(position: p, asset: asset);
  }
}
