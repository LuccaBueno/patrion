import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'codes.dart';
import 'entities.dart';
import 'portfolio_calculator.dart';

/// Posição com o valor de mercado vindo dos preços e saldos informados.
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

/// Aplica preços e saldos informados às posições (SPEC §8, preço manual).
///
/// Regras (`docs/FORMULAS.md` §1.4):
/// - Se há saldo informado para a conta e o ativo, vale o mais recente até
///   [asOf].
/// - Senão, vale quantidade × o preço unitário mais recente até [asOf].
/// - Preço em moeda diferente da posição é ignorado (sem câmbio até a F6).
abstract final class PortfolioValuator {
  static List<ValuedPosition> value({
    required PortfolioState state,
    required Iterable<ManualValuation> valuations,
    required Map<String, Asset> assets,
    required LocalDate asOf,
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
        ),
    ];
  }

  static ValuedPosition _valueOne(
    Position p,
    Asset? asset,
    ManualValuation? balance,
    ManualValuation? price,
  ) {
    if (!p.isOpen) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: Decimal.zero,
      );
    }
    if (balance != null && balance.currency == p.currency) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: balance.value,
        valuationDate: balance.refDate,
        valuationKind: ValuationKind.balance,
        valuationStale: p.lastOperationDate.isAfter(balance.refDate),
      );
    }
    if (price != null &&
        price.currency == p.currency &&
        p.quantity > Decimal.zero) {
      return ValuedPosition(
        position: p,
        asset: asset,
        marketValue: p.quantity * price.value,
        unitPrice: price.value,
        valuationDate: price.refDate,
        valuationKind: ValuationKind.unitPrice,
      );
    }
    return ValuedPosition(position: p, asset: asset);
  }
}
