import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../market/market_price.dart';
import 'entities.dart';
import 'portfolio_valuation.dart';

/// Um ativo na carteira, somando todas as contas (lista da Carteira, M-05).
///
/// Regras em `docs/FORMULAS.md` §2.4.
class Holding {
  Holding(this.assetId, this.asset, this.currency, this.positions);

  final String assetId;
  final Asset? asset;
  final String currency;

  /// Posições do ativo em cada conta (inclusive encerradas).
  final List<ValuedPosition> positions;

  Iterable<ValuedPosition> get _open =>
      positions.where((v) => v.position.isOpen);

  bool get isOpen => _open.isNotEmpty;

  Decimal get quantity =>
      _open.fold(Decimal.zero, (s, v) => s + v.position.quantity);

  /// Total aplicado: custo da posição atual (preço médio × quantidade).
  Decimal get totalCost =>
      _open.fold(Decimal.zero, (s, v) => s + v.position.totalCost);

  /// Valor da posição; nulo se alguma conta não tem preço nem saldo
  /// ("indisponível", regra 1).
  Decimal? get marketValue {
    if (!isOpen) return null;
    var total = Decimal.zero;
    for (final v in _open) {
      final value = v.marketValue;
      if (value == null) return null;
      total += value;
    }
    return total;
  }

  /// Preço médio = total aplicado ÷ quantidade.
  Decimal? get averagePrice =>
      quantity > Decimal.zero ? DecimalMath.divide(totalCost, quantity) : null;

  /// Posição que dá o preço atual (com fonte e data).
  ValuedPosition? get priced {
    for (final v in _open) {
      if (v.unitPrice != null) return v;
    }
    return null;
  }

  Decimal? get unitPrice => priced?.unitPrice;

  MarketPrice? get marketPrice => priced?.marketPrice;

  /// Valorização = (cotação atual − preço médio) ÷ preço médio. Sem preço
  /// unitário (avaliação por saldo): valor da posição ÷ total aplicado − 1.
  Decimal? get appreciation {
    final price = unitPrice;
    final average = averagePrice;
    if (price != null && average != null && average > Decimal.zero) {
      return DecimalMath.divide(price - average, average);
    }
    final value = marketValue;
    final cost = totalCost;
    if (value == null || cost <= Decimal.zero) return null;
    return DecimalMath.divide(value - cost, cost);
  }

  /// Lucro não realizado: valor da posição − total aplicado.
  Decimal? get unrealizedPnl {
    final value = marketValue;
    return value == null ? null : value - totalCost;
  }

  /// Lucro realizado em vendas, resgates e vencimentos (todas as contas).
  Decimal get realizedPnl =>
      positions.fold(Decimal.zero, (s, v) => s + v.position.realizedPnl);

  /// Lucro em R$ = não realizado + realizado.
  Decimal? get profit {
    final unrealized = unrealizedPnl;
    return unrealized == null ? null : unrealized + realizedPnl;
  }

  /// Proventos recebidos, líquidos.
  Decimal get incomeNet =>
      positions.fold(Decimal.zero, (s, v) => s + v.position.incomeNet);

  /// Variação do dia da posição: quantidade × (cotação − fechamento
  /// anterior). Nula sem cotação de mercado ou sem o fechamento anterior.
  Decimal? get dayChangeAmount {
    final change = marketPrice?.dayChange;
    if (change == null) return null;
    return quantity * change.perUnit;
  }
}

/// Monta e ordena a lista da Carteira.
abstract final class Holdings {
  /// Um item por ativo, na ordem da lista:
  /// 1. com posição, pelo valor da posição, do maior para o menor; sem
  ///    cotação, pelo total aplicado (o valor aparece "indisponível");
  /// 2. com zero cotas, no fim, pelo código.
  ///
  /// [toBrl] converte valores de outras moedas só para ordenar; sem a taxa,
  /// vale o número na moeda original.
  static List<Holding> build(
    Iterable<ValuedPosition> valued, {
    Map<String, Decimal> toBrl = const {},
  }) {
    final byAsset = <String, List<ValuedPosition>>{};
    for (final v in valued) {
      (byAsset[v.position.assetId] ??= []).add(v);
    }
    final list = [
      for (final MapEntry(key: id, value: ps) in byAsset.entries)
        Holding(id, ps.first.asset, ps.first.position.currency, ps),
    ];
    Decimal weight(Holding h) {
      final amount = h.marketValue ?? h.totalCost;
      return amount * (toBrl[h.currency] ?? Decimal.one);
    }

    String code(Holding h) => h.asset?.symbol ?? h.assetId;
    list.sort((a, b) {
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      if (!a.isOpen) return code(a).compareTo(code(b));
      final byWeight = weight(b).compareTo(weight(a));
      return byWeight != 0 ? byWeight : code(a).compareTo(code(b));
    });
    return list;
  }

  /// Fração da carteira na moeda do ativo (valor da posição ÷ soma dos
  /// valores com preço na mesma moeda).
  static Decimal? shareOf(Holding h, List<Holding> all) {
    final value = h.marketValue;
    if (value == null) return null;
    var total = Decimal.zero;
    for (final other in all) {
      if (other.currency != h.currency) continue;
      total += other.marketValue ?? Decimal.zero;
    }
    return total > Decimal.zero ? DecimalMath.divide(value, total) : null;
  }
}
