import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import 'codes.dart';
import 'entities.dart';
import 'operation_type.dart';

/// Posição de um ativo em uma conta, calculada a partir das operações.
///
/// Valores na moeda das operações do ativo. Regras em `docs/FORMULAS.md` §1.
class Position {
  const Position({
    required this.accountId,
    required this.assetId,
    required this.currency,
    required this.quantity,
    required this.totalCost,
    required this.realizedPnl,
    required this.incomeGross,
    required this.incomeNet,
    required this.lastOperationDate,
  });

  final String accountId;
  final String assetId;
  final String currency;
  final Decimal quantity;

  /// Custo de aquisição do que ainda está na carteira, com custos de compra.
  final Decimal totalCost;

  /// Lucro ou prejuízo realizado (vendas, resgates, amortizações,
  /// vencimentos), líquido de custos e impostos.
  final Decimal realizedPnl;

  /// Proventos recebidos: bruto e líquido de impostos e custos.
  final Decimal incomeGross;
  final Decimal incomeNet;
  final LocalDate lastOperationDate;

  /// Preço médio = custo total ÷ quantidade (20 casas, half-even). Nulo sem
  /// quantidade (posições acompanhadas só pelo valor).
  Decimal? get averagePrice =>
      quantity > Decimal.zero ? DecimalMath.divide(totalCost, quantity) : null;

  /// Ainda tem quantidade ou custo.
  bool get isOpen => quantity != Decimal.zero || totalCost != Decimal.zero;
}

/// Tipos de inconsistência encontrados ao recalcular a carteira.
enum PortfolioIssueKind {
  /// Venda, resgate ou transferência maior que a posição na data.
  oversold,

  /// Ponta de entrada de uma transferência sem a ponta de saída.
  missingTransferLeg,

  /// Operação ligada a um ativo cujo cadastro não existe.
  unknownAsset,

  /// Moeda da operação diferente da moeda da posição.
  currencyMismatch,
}

class PortfolioIssue {
  const PortfolioIssue(this.kind, this.operationId, this.date);

  final PortfolioIssueKind kind;
  final String operationId;
  final LocalDate date;
}

/// Resultado do recálculo: posições por conta e ativo, caixa por conta e
/// moeda, e inconsistências.
class PortfolioState {
  const PortfolioState({
    required this.positions,
    required this.cash,
    required this.issues,
  });

  static const empty = PortfolioState(positions: [], cash: {}, issues: []);

  final List<Position> positions;

  /// Caixa por conta e moeda: `{accountId: {moeda: saldo}}`.
  final Map<String, Map<String, Decimal>> cash;
  final List<PortfolioIssue> issues;

  Position? position(String accountId, String assetId) {
    for (final p in positions) {
      if (p.accountId == accountId && p.assetId == assetId) return p;
    }
    return null;
  }
}

/// Recalcula posições e caixa a partir de todas as operações (motor
/// financeiro, SPEC §9, convenções brasileiras):
///
/// - o preço médio inclui os custos de compra;
/// - proventos não alteram o preço médio;
/// - custos de venda reduzem o valor recebido;
/// - desdobramento e grupamento ajustam quantidade e preço médio, mantendo
///   o custo total.
///
/// É uma função pura: editar uma operação antiga e recalcular atualiza tudo
/// o que vem depois dela (SPEC §7).
abstract final class PortfolioCalculator {
  static PortfolioState compute({
    required Iterable<Operation> operations,
    Iterable<ManualValuation> valuations = const [],
    Map<String, Asset> assets = const {},
    LocalDate? until,
  }) {
    final ordered =
        operations
            .where((o) => until == null || !o.tradeDate.isAfter(until))
            .toList()
          ..sort(Operation.chronological);
    final balances = _BalanceHistory(valuations);
    final acc = <(String, String), _Acc>{};
    final cash = <String, Map<String, Decimal>>{};
    final issues = <PortfolioIssue>[];
    // Custo levado pela ponta de saída de cada transferência de ativo.
    final transferredCost = <String, Decimal>{};

    void addCash(Operation op, Decimal delta) {
      if (delta == Decimal.zero) return;
      final byCurrency = cash.putIfAbsent(op.accountId, () => {});
      byCurrency[op.currency] =
          (byCurrency[op.currency] ?? Decimal.zero) + delta;
    }

    for (final op in ordered) {
      final amount = op.amount;
      final charges = op.charges;
      final net = amount - charges;

      // Caixa da conta.
      switch (op.type) {
        case OperationType.buy ||
            OperationType.contribution ||
            OperationType.reinvestment ||
            OperationType.withdrawal ||
            OperationType.fee ||
            OperationType.tax ||
            OperationType.withholding:
          addCash(op, -(amount + charges));
        case OperationType.sell ||
            OperationType.redemption ||
            OperationType.deposit ||
            OperationType.dividend ||
            OperationType.jcp ||
            OperationType.fiiIncome ||
            OperationType.interest ||
            OperationType.amortization ||
            OperationType.maturity:
          addCash(op, net);
        case OperationType.transferOut:
          addCash(op, op.assetId == null ? -(amount + charges) : -charges);
        case OperationType.transferIn:
          addCash(op, op.assetId == null ? net : -charges);
        case OperationType.bonusShares ||
            OperationType.split ||
            OperationType.reverseSplit:
          addCash(op, -charges);
        case OperationType.manualAdjustment:
          if (op.assetId == null) addCash(op, op.grossAmount ?? Decimal.zero);
      }

      // Posição do ativo.
      final assetId = op.assetId;
      if (assetId == null) continue;
      if (assets.isNotEmpty && !assets.containsKey(assetId)) {
        issues.add(
          PortfolioIssue(PortfolioIssueKind.unknownAsset, op.id, op.tradeDate),
        );
      }
      final p = acc.putIfAbsent((
        op.accountId,
        assetId,
      ), () => _Acc(op.accountId, assetId, op.currency));
      if (op.currency != p.currency) {
        issues.add(
          PortfolioIssue(
            PortfolioIssueKind.currencyMismatch,
            op.id,
            op.tradeDate,
          ),
        );
      }
      p.lastDate = op.tradeDate;
      final quantity = op.quantity ?? Decimal.zero;

      switch (op.type) {
        case OperationType.buy ||
            OperationType.contribution ||
            OperationType.reinvestment:
          p.quantity += quantity;
          p.cost += amount + charges;

        case OperationType.sell || OperationType.redemption:
          final Decimal costOut;
          if (op.quantity != null && quantity > Decimal.zero) {
            costOut = _removeQuantity(p, quantity, op, issues);
          } else {
            // Resgate por valor (sem quantidade): baixa o custo na proporção
            // do valor resgatado sobre o saldo informado; sem saldo, sobre o
            // próprio custo.
            final balance =
                balances.latest(op.accountId, assetId, op.tradeDate) ?? p.cost;
            final fraction = balance > Decimal.zero
                ? DecimalMath.min(
                    Decimal.one,
                    DecimalMath.divide(amount, balance),
                  )
                : Decimal.one;
            costOut = fraction == Decimal.one
                ? p.cost
                : _scale(p.cost * fraction);
            if (fraction == Decimal.one) p.quantity = Decimal.zero;
          }
          p.cost -= costOut;
          p.realized += net - costOut;

        case OperationType.transferOut:
          final costOut = _removeQuantity(p, quantity, op, issues);
          p.cost -= costOut;
          final group = op.transferGroupId;
          if (group != null) transferredCost[group] = costOut;

        case OperationType.transferIn:
          final group = op.transferGroupId;
          final moved = group == null ? null : transferredCost[group];
          if (moved == null) {
            issues.add(
              PortfolioIssue(
                PortfolioIssueKind.missingTransferLeg,
                op.id,
                op.tradeDate,
              ),
            );
          }
          p.quantity += quantity;
          p.cost += moved ?? op.grossAmount ?? Decimal.zero;

        case OperationType.dividend ||
            OperationType.jcp ||
            OperationType.fiiIncome ||
            OperationType.interest:
          p.incomeGross += amount;
          p.incomeNet += net;

        case OperationType.amortization:
          // Devolução de principal: reduz o custo; o que passar dele é lucro.
          final reduction = DecimalMath.min(amount, p.cost);
          p.cost -= reduction;
          p.realized += net - reduction;

        case OperationType.bonusShares:
          // Custo atribuído pela empresa, se houver, entra no custo.
          p.quantity += quantity;
          p.cost += op.grossAmount ?? Decimal.zero;

        case OperationType.split || OperationType.reverseSplit:
          p.quantity = DecimalMath.divide(
            p.quantity * op.ratioTo!,
            op.ratioFrom!,
          );

        case OperationType.maturity:
          p.realized += net - p.cost;
          p.quantity = Decimal.zero;
          p.cost = Decimal.zero;

        case OperationType.manualAdjustment:
          p.quantity += quantity;
          p.cost += op.grossAmount ?? Decimal.zero;

        case OperationType.fee ||
            OperationType.tax ||
            OperationType.withholding ||
            OperationType.deposit ||
            OperationType.withdrawal:
          // Só afetam o caixa.
          break;
      }
    }

    return PortfolioState(
      positions: [for (final p in acc.values) p.toPosition()],
      cash: cash,
      issues: issues,
    );
  }

  /// Retira [quantity] da posição e devolve o custo correspondente
  /// (custo × quantidade retirada ÷ quantidade da posição).
  static Decimal _removeQuantity(
    _Acc p,
    Decimal quantity,
    Operation op,
    List<PortfolioIssue> issues,
  ) {
    if (quantity > p.quantity) {
      issues.add(
        PortfolioIssue(PortfolioIssueKind.oversold, op.id, op.tradeDate),
      );
    }
    final Decimal costOut;
    if (p.quantity <= Decimal.zero) {
      costOut = Decimal.zero;
    } else if (quantity >= p.quantity) {
      costOut = p.cost;
    } else {
      costOut = DecimalMath.divide(p.cost * quantity, p.quantity);
    }
    p.quantity -= quantity;
    return costOut;
  }

  static Decimal _scale(Decimal value) =>
      DecimalMath.divide(value, Decimal.one);
}

class _Acc {
  _Acc(this.accountId, this.assetId, this.currency);

  final String accountId;
  final String assetId;
  final String currency;
  Decimal quantity = Decimal.zero;
  Decimal cost = Decimal.zero;
  Decimal realized = Decimal.zero;
  Decimal incomeGross = Decimal.zero;
  Decimal incomeNet = Decimal.zero;
  late LocalDate lastDate;

  Position toPosition() => Position(
    accountId: accountId,
    assetId: assetId,
    currency: currency,
    quantity: quantity,
    totalCost: cost,
    realizedPnl: realized,
    incomeGross: incomeGross,
    incomeNet: incomeNet,
    lastOperationDate: lastDate,
  );
}

/// Saldos informados (`balance`) por conta e ativo, para consulta por data.
class _BalanceHistory {
  _BalanceHistory(Iterable<ManualValuation> valuations) {
    for (final v in valuations) {
      if (v.kind != ValuationKind.balance || v.accountId == null) continue;
      _byKey.putIfAbsent((v.accountId!, v.assetId), () => []).add(v);
    }
    for (final list in _byKey.values) {
      list.sort((a, b) => a.refDate.compareTo(b.refDate));
    }
  }

  final _byKey = <(String, String), List<ManualValuation>>{};

  /// Último saldo com data de referência até [date] (inclusive).
  Decimal? latest(String accountId, String assetId, LocalDate date) {
    final list = _byKey[(accountId, assetId)];
    if (list == null) return null;
    Decimal? result;
    for (final v in list) {
      if (v.refDate.isAfter(date)) break;
      result = v.value;
    }
    return result;
  }
}
