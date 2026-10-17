import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../finance/cash_flow.dart';
import '../finance/returns.dart';
import 'entities.dart';
import 'operation_type.dart';
import 'portfolio_valuation.dart';

/// Por que o desempenho não pôde ser calculado.
enum PerformanceGap {
  /// Há posição aberta sem preço nem saldo: falta o valor final.
  unpricedPosition,

  /// Nenhum fluxo com dinheiro investido.
  noFlows,

  /// O XIRR não converge com estes fluxos (por exemplo, prazo zero).
  noSolution,
}

/// Retorno ponderado pelo dinheiro (MWR) de um conjunto de fluxos.
class MoneyWeightedReturn {
  const MoneyWeightedReturn({
    required this.annual,
    required this.period,
    required this.start,
    required this.end,
    required this.multipleSignChanges,
  });

  /// Taxa anual (XIRR, dias corridos ÷ 365).
  final Decimal annual;

  /// Equivalente no período: `(1 + anual)^(dias ÷ 365) − 1`.
  final Decimal period;
  final LocalDate start;
  final LocalDate end;
  final bool multipleSignChanges;

  int get days => end.daysSince(start);

  /// Menos de um ano: a interface mostra o retorno do período, não a taxa
  /// anual (anualizar prazos curtos exagera o resultado).
  bool get isShortPeriod => days < 365;

  ReturnFigure get annualFigure => ReturnFigure(
    value: annual,
    method: ReturnMethod.mwr,
    start: start,
    end: end,
    annualized: true,
  );

  ReturnFigure get periodFigure => ReturnFigure(
    value: period,
    method: ReturnMethod.mwr,
    start: start,
    end: end,
    annualized: false,
  );
}

/// Desempenho de um ativo (em todas as contas) ou da carteira numa moeda
/// (`docs/FORMULAS.md` §10).
class Performance {
  const Performance({
    required this.currency,
    required this.invested,
    required this.returned,
    required this.costs,
    required this.incomeNet,
    required this.endValue,
    required this.flowBalance,
    required this.flowBalanceWithoutIncome,
    required this.endDate,
    required this.net,
    required this.netWithoutIncome,
    required this.gross,
    required this.gap,
  });

  final String currency;

  /// Dinheiro aplicado: compras e aportes, com custos.
  final Decimal invested;

  /// Dinheiro devolvido: vendas, resgates, amortizações e vencimentos,
  /// líquidos de custos (sem proventos).
  final Decimal returned;

  /// Custos e impostos pagos nas operações (taxas, emolumentos, IR).
  final Decimal costs;

  /// Proventos líquidos recebidos.
  final Decimal incomeNet;

  /// Soma dos fluxos líquidos (entradas − saídas), com e sem proventos.
  final Decimal flowBalance;
  final Decimal flowBalanceWithoutIncome;

  /// Valor de mercado das posições abertas; nulo se alguma não tem preço.
  final Decimal? endValue;

  /// Data do valor final: a mais recente entre a dos preços usados e a da
  /// última operação.
  final LocalDate? endDate;

  /// MWR líquido de custos, com proventos.
  final MoneyWeightedReturn? net;

  /// MWR líquido de custos, sem proventos.
  final MoneyWeightedReturn? netWithoutIncome;

  /// MWR bruto: antes de custos e impostos, com proventos brutos.
  final MoneyWeightedReturn? gross;

  /// Motivo de [net] ser nulo.
  final PerformanceGap? gap;

  /// Resultado total em dinheiro: valor final + soma dos fluxos líquidos
  /// (devolvido + proventos − investido − outros custos). Nulo sem valor
  /// final.
  Decimal? get totalResult => endValue == null ? null : endValue! + flowBalance;

  /// Resultado sem os proventos.
  Decimal? get resultWithoutIncome =>
      endValue == null ? null : endValue! + flowBalanceWithoutIncome;
}

/// Monta os fluxos de caixa do investidor a partir das operações e calcula
/// o MWR (SPEC §9: retorno bruto e líquido, com e sem proventos).
///
/// Do ponto de vista do ativo (somando todas as contas):
///
/// - compra, aporte, reinvestimento: `−(V + C)` (bruto: `−V`);
/// - venda, resgate, amortização, vencimento: `+(V − C)` (bruto: `+V`);
/// - proventos: `+(V − C)` (bruto: `+V`; sem proventos: fora);
/// - taxa, imposto ou retenção ligados ao ativo: `−(V + C)` (bruto: fora);
/// - bonificação, desdobramento, grupamento e transferências entre contas:
///   só os custos, `−C` (o custo atribuído de uma bonificação não é
///   dinheiro);
/// - ajuste manual com ativo: `−V` (custo informado);
/// - valor final: `+` valor de mercado das posições abertas na data do
///   preço mais recente (ou da última operação, se for depois).
abstract final class PerformanceCalculator {
  static Performance compute({
    required String currency,
    required Iterable<Operation> operations,
    required Iterable<ValuedPosition> positions,
  }) {
    final net = <CashFlow>[];
    final netNoIncome = <CashFlow>[];
    final gross = <CashFlow>[];
    var invested = Decimal.zero;
    var returned = Decimal.zero;
    var costs = Decimal.zero;
    var income = Decimal.zero;
    LocalDate? lastDate;

    for (final op in operations) {
      if (op.assetId == null || op.currency != currency) continue;
      final v = op.amount;
      final c = op.charges;
      final date = op.tradeDate;
      if (lastDate == null || date.isAfter(lastDate)) lastDate = date;
      void add(Decimal n, Decimal g, {bool isIncome = false}) {
        if (n != Decimal.zero) net.add(CashFlow(date, n));
        if (!isIncome && n != Decimal.zero) {
          netNoIncome.add(CashFlow(date, n));
        }
        if (g != Decimal.zero) gross.add(CashFlow(date, g));
      }

      switch (op.type) {
        case OperationType.buy ||
            OperationType.contribution ||
            OperationType.reinvestment:
          invested += v + c;
          costs += c;
          add(-(v + c), -v);
        case OperationType.sell ||
            OperationType.redemption ||
            OperationType.amortization ||
            OperationType.maturity:
          returned += v - c;
          costs += c;
          add(v - c, v);
        case OperationType.dividend ||
            OperationType.jcp ||
            OperationType.fiiIncome ||
            OperationType.interest:
          income += v - c;
          costs += c;
          add(v - c, v, isIncome: true);
        case OperationType.fee ||
            OperationType.tax ||
            OperationType.withholding:
          costs += v + c;
          add(-(v + c), Decimal.zero);
        case OperationType.bonusShares ||
            OperationType.split ||
            OperationType.reverseSplit ||
            OperationType.transferIn ||
            OperationType.transferOut:
          costs += c;
          add(-c, Decimal.zero);
        case OperationType.manualAdjustment:
          final cost = op.grossAmount ?? Decimal.zero;
          if (cost > Decimal.zero) {
            invested += cost;
          } else {
            returned -= cost;
          }
          add(-cost, -cost);
        case OperationType.deposit || OperationType.withdrawal:
          break;
      }
    }

    // Valor final.
    var endValue = Decimal.zero;
    var anyOpen = false;
    var unpriced = false;
    LocalDate? endDate = lastDate;
    for (final p in positions) {
      if (p.position.currency != currency || !p.position.isOpen) continue;
      anyOpen = true;
      final mv = p.marketValue;
      if (mv == null) {
        unpriced = true;
        continue;
      }
      endValue += mv;
      final d = p.valuationDate;
      if (d != null && (endDate == null || d.isAfter(endDate))) endDate = d;
    }

    MoneyWeightedReturn? mwr(List<CashFlow> flows) {
      if (unpriced || endDate == null) return null;
      final all = [
        ...flows,
        if (anyOpen && endValue != Decimal.zero) CashFlow(endDate, endValue),
      ];
      final result = Xirr.compute(all);
      if (result == null) return null;
      final start = all
          .map((f) => f.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return MoneyWeightedReturn(
        annual: result.rate,
        period: Returns.deannualize(result.rate, endDate.daysSince(start)),
        start: start,
        end: endDate,
        multipleSignChanges: result.multipleSignChanges,
      );
    }

    final netResult = mwr(net);
    final PerformanceGap? gap;
    if (unpriced) {
      gap = PerformanceGap.unpricedPosition;
    } else if (!net.any((f) => f.amount < Decimal.zero)) {
      gap = PerformanceGap.noFlows;
    } else if (netResult == null) {
      gap = PerformanceGap.noSolution;
    } else {
      gap = null;
    }

    return Performance(
      currency: currency,
      invested: invested,
      returned: returned,
      costs: costs,
      incomeNet: income,
      flowBalance: _sum(net),
      flowBalanceWithoutIncome: _sum(netNoIncome),
      endValue: unpriced ? null : endValue,
      endDate: endDate,
      net: netResult,
      netWithoutIncome: mwr(netNoIncome),
      gross: mwr(gross),
      gap: gap,
    );
  }

  static Decimal _sum(List<CashFlow> flows) =>
      flows.fold(Decimal.zero, (a, f) => a + f.amount);

  /// Desempenho de um ativo, somando todas as contas.
  static Performance forAsset({
    required Asset asset,
    required Iterable<Operation> operations,
    required Iterable<ValuedPosition> positions,
  }) => compute(
    currency: asset.currency,
    operations: operations.where((o) => o.assetId == asset.id),
    positions: positions.where((p) => p.position.assetId == asset.id),
  );
}
