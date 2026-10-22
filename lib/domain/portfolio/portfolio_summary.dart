import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'entities.dart';
import 'portfolio_calculator.dart';
import 'portfolio_valuation.dart';

/// Totais da carteira real em uma moeda (dashboard, SPEC §8).
///
/// Sem câmbio (F6), cada moeda tem seus próprios totais: nada é convertido.
class CurrencySummary {
  const CurrencySummary({
    required this.currency,
    required this.invested,
    required this.marketValue,
    required this.pricedCost,
    required this.unpricedCount,
    required this.unpricedCost,
    required this.cash,
    required this.realizedPnl,
    required this.incomeGross,
    required this.incomeNet,
  });

  final String currency;

  /// Custo das posições abertas (valor investido).
  final Decimal invested;

  /// Soma do valor de mercado das posições com preço ou saldo.
  final Decimal marketValue;

  /// Custo das posições que têm valor de mercado.
  final Decimal pricedCost;

  /// Posições abertas sem preço nem saldo (ficam fora do valor de mercado).
  final int unpricedCount;
  final Decimal unpricedCost;
  final Decimal cash;
  final Decimal realizedPnl;
  final Decimal incomeGross;
  final Decimal incomeNet;

  /// Patrimônio = valor de mercado + caixa (zero sem o controle de caixa,
  /// M-03). É parcial quando [unpricedCount] > 0.
  Decimal get equity => marketValue + cash;

  bool get isPartial => unpricedCount > 0;

  /// Lucro ou prejuízo não realizado das posições com valor de mercado.
  Decimal get unrealizedPnl => marketValue - pricedCost;

  /// Retorno simples sobre o custo das posições com valor de mercado.
  Decimal? get simpleReturn => pricedCost > Decimal.zero
      ? DecimalMath.divide(unrealizedPnl, pricedCost)
      : null;
}

/// Fatia de uma alocação.
class AllocationSlice<K> {
  const AllocationSlice(this.key, this.value, this.fraction);

  final K key;
  final Decimal value;

  /// Fração do total (0,25 = 25%).
  final Decimal fraction;
}

/// Título de renda fixa com vencimento próximo.
class UpcomingMaturity {
  const UpcomingMaturity(this.asset, this.maturityDate, this.daysLeft);

  final Asset asset;
  final LocalDate maturityDate;
  final int daysLeft;
}

/// Tudo o que o dashboard inicial mostra.
class PortfolioSummary {
  const PortfolioSummary({
    required this.byCurrency,
    required this.positions,
    required this.lastValuationDate,
    required this.upcomingMaturities,
    required this.negativeCashAccounts,
    required this.issues,
    this.trackCash = true,
  });

  final Map<String, CurrencySummary> byCurrency;

  /// Posições abertas, com valor de mercado quando houver.
  final List<ValuedPosition> positions;

  /// Data de referência mais recente dos preços e saldos usados.
  final LocalDate? lastValuationDate;
  final List<UpcomingMaturity> upcomingMaturities;

  /// Contas com caixa negativo (faltam depósitos registrados).
  final Set<String> negativeCashAccounts;
  final List<PortfolioIssue> issues;

  /// O controle de caixa está ligado (M-03). Desligado, o caixa é zero, o
  /// patrimônio é o valor de mercado das posições e não há aviso de caixa
  /// negativo.
  final bool trackCash;

  bool get isEmpty => positions.isEmpty && byCurrency.isEmpty;

  /// Moedas em uso, com [primary] primeiro.
  List<String> currencies({String primary = 'BRL'}) {
    final list = byCurrency.keys.toList()..sort();
    if (list.remove(primary)) list.insert(0, primary);
    return list;
  }

  /// Maiores posições por valor de mercado, na moeda [currency].
  List<ValuedPosition> topPositions(String currency, {int limit = 5}) {
    final priced =
        positions
            .where((v) => v.position.currency == currency && v.hasMarketValue)
            .toList()
          ..sort((a, b) => b.marketValue!.compareTo(a.marketValue!));
    return priced.take(limit).toList();
  }

  /// Alocação do valor de mercado (mais o caixa, como fatia `null`) na moeda
  /// [currency], agrupada por [keyOf]. Posições sem preço ficam fora.
  List<AllocationSlice<K?>> allocation<K>(
    String currency,
    K Function(ValuedPosition) keyOf, {
    bool includeCash = true,
  }) {
    final totals = <K?, Decimal>{};
    for (final v in positions) {
      if (v.position.currency != currency || !v.hasMarketValue) continue;
      final key = keyOf(v);
      totals[key] = (totals[key] ?? Decimal.zero) + v.marketValue!;
    }
    final cash = byCurrency[currency]?.cash ?? Decimal.zero;
    if (includeCash && cash > Decimal.zero) {
      totals[null] = (totals[null] ?? Decimal.zero) + cash;
    }
    final total = totals.values.fold(Decimal.zero, (a, b) => a + b);
    if (total <= Decimal.zero) return const [];
    final slices = [
      for (final e in totals.entries)
        if (e.value > Decimal.zero)
          AllocationSlice<K?>(
            e.key,
            e.value,
            DecimalMath.divide(e.value, total),
          ),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return slices;
  }

  static PortfolioSummary build({
    required PortfolioState state,
    required List<ValuedPosition> valued,
    required Map<String, FixedIncomeTerms> termsByAsset,
    required LocalDate asOf,
    int maturityWindowDays = 90,
    bool trackCash = true,
  }) {
    final acc = <String, _CurrencyAcc>{};
    _CurrencyAcc of(String c) => acc.putIfAbsent(c, () => _CurrencyAcc(c));

    LocalDate? lastValuation;
    final open = <ValuedPosition>[];
    for (final v in valued) {
      final p = v.position;
      final a = of(p.currency)
        ..realized += p.realizedPnl
        ..incomeGross += p.incomeGross
        ..incomeNet += p.incomeNet;
      if (!p.isOpen) continue;
      open.add(v);
      a.invested += p.totalCost;
      if (v.hasMarketValue) {
        a.marketValue += v.marketValue!;
        a.pricedCost += p.totalCost;
        final date = v.valuationDate;
        if (date != null &&
            (lastValuation == null || date.isAfter(lastValuation))) {
          lastValuation = date;
        }
      } else {
        a.unpricedCount++;
        a.unpricedCost += p.totalCost;
      }
    }

    final negativeCash = <String>{};
    // Sem controle de caixa, compras e vendas não movimentam caixa (M-03).
    if (trackCash) {
      state.cash.forEach((accountId, byCurrency) {
        byCurrency.forEach((currency, amount) {
          of(currency).cash += amount;
          if (amount < Decimal.zero) negativeCash.add(accountId);
        });
      });
    }

    final maturities = <UpcomingMaturity>[];
    final seen = <String>{};
    for (final v in open) {
      final asset = v.asset;
      if (asset == null || !seen.add(asset.id)) continue;
      final terms = termsByAsset[asset.id];
      if (terms == null || terms.maturityDate.isBefore(asOf)) continue;
      final days = terms.maturityDate.daysSince(asOf);
      if (days <= maturityWindowDays) {
        maturities.add(UpcomingMaturity(asset, terms.maturityDate, days));
      }
    }
    maturities.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    return PortfolioSummary(
      byCurrency: {for (final e in acc.entries) e.key: e.value.build()},
      positions: open,
      lastValuationDate: lastValuation,
      upcomingMaturities: maturities,
      negativeCashAccounts: negativeCash,
      issues: state.issues,
      trackCash: trackCash,
    );
  }
}

class _CurrencyAcc {
  _CurrencyAcc(this.currency);

  final String currency;
  Decimal invested = Decimal.zero;
  Decimal marketValue = Decimal.zero;
  Decimal pricedCost = Decimal.zero;
  int unpricedCount = 0;
  Decimal unpricedCost = Decimal.zero;
  Decimal cash = Decimal.zero;
  Decimal realized = Decimal.zero;
  Decimal incomeGross = Decimal.zero;
  Decimal incomeNet = Decimal.zero;

  CurrencySummary build() => CurrencySummary(
    currency: currency,
    invested: invested,
    marketValue: marketValue,
    pricedCost: pricedCost,
    unpricedCount: unpricedCount,
    unpricedCost: unpricedCost,
    cash: cash,
    realizedPnl: realized,
    incomeGross: incomeGross,
    incomeNet: incomeNet,
  );
}
