import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../market/market_price.dart';
import 'entities.dart';
import 'holdings.dart';
import 'operation_type.dart';

/// Movimento de um mês (Painel, M-04): aportes (compras e aportes, com
/// custos), vendas e resgates (líquidos) e proventos (líquidos).
class MonthFlow {
  MonthFlow(this.year, this.month);

  final int year;
  final int month;
  Decimal buys = Decimal.zero;
  Decimal sells = Decimal.zero;
  Decimal income = Decimal.zero;

  bool contains(LocalDate d) => d.year == year && d.month == month;
}

/// Variação do dia da carteira numa moeda.
class PortfolioDayChange {
  const PortfolioDayChange({
    required this.amount,
    required this.base,
    required this.covered,
    required this.missing,
    required this.since,
  });

  /// Σ quantidade × (cotação − fechamento anterior).
  final Decimal amount;

  /// Σ quantidade × fechamento anterior dos ativos considerados.
  final Decimal base;

  /// Ativos com a variação calculada e ativos com posição sem ela (sem
  /// cotação de mercado ou sem o fechamento anterior).
  final int covered;
  final int missing;

  /// Data mais antiga dos fechamentos de referência.
  final LocalDate since;

  Decimal? get fraction =>
      base > Decimal.zero ? DecimalMath.divide(amount, base) : null;

  bool get partial => missing > 0;
}

/// Ativo com a variação do preço no dia ou no mês.
class Mover {
  const Mover(this.holding, this.change);

  final Holding holding;
  final PriceChange change;
}

/// Números do Painel que vêm das operações e dos preços (`docs/FORMULAS.md`
/// §3.1). Nada é estimado: sem dado, o resultado fica nulo ou vazio.
abstract final class DashboardMetrics {
  /// Os últimos [months] meses até o de [asOf] (inclusive), do mais antigo
  /// para o mais recente, na moeda [currency].
  ///
  /// O saldo inicial do cadastro rápido conta como aporte na data informada
  /// (M-12): é o mesmo dinheiro que entra no total aplicado.
  static List<MonthFlow> monthly(
    Iterable<Operation> operations, {
    required String currency,
    required LocalDate asOf,
    int months = 12,
  }) {
    final list = <MonthFlow>[];
    var y = asOf.year;
    var m = asOf.month;
    for (var i = 0; i < months; i++) {
      list.insert(0, MonthFlow(y, m));
      m--;
      if (m == 0) {
        m = 12;
        y--;
      }
    }
    for (final op in operations) {
      if (op.currency != currency || op.tradeDate.isAfter(asOf)) continue;
      final month = list.where((f) => f.contains(op.tradeDate)).firstOrNull;
      if (month == null) continue;
      switch (op.type) {
        case OperationType.buy ||
            OperationType.contribution ||
            OperationType.reinvestment:
          month.buys += op.amount + op.charges;
        case OperationType.sell || OperationType.redemption:
          month.sells += op.amount - op.charges;
        case OperationType.dividend ||
            OperationType.jcp ||
            OperationType.fiiIncome ||
            OperationType.interest:
          month.income += op.amount - op.charges;
        default:
          break;
      }
    }
    return list;
  }

  /// Aportes do ano de [asOf] até [asOf] (com o saldo inicial).
  static Decimal investedInYear(
    Iterable<Operation> operations, {
    required String currency,
    required LocalDate asOf,
  }) {
    var total = Decimal.zero;
    for (final f in monthly(
      operations,
      currency: currency,
      asOf: asOf,
      months: asOf.month,
    )) {
      total += f.buys;
    }
    return total;
  }

  /// Variação do dia da carteira na moeda [currency]; nula se nenhum ativo
  /// tem cotação de mercado com o fechamento anterior guardado.
  static PortfolioDayChange? dayChange(
    List<Holding> holdings,
    String currency,
  ) {
    var amount = Decimal.zero;
    var base = Decimal.zero;
    var covered = 0;
    var missing = 0;
    LocalDate? since;
    for (final h in holdings) {
      if (!h.isOpen || h.currency != currency) continue;
      final change = h.marketPrice?.dayChange;
      if (change == null || h.quantity <= Decimal.zero) {
        missing++;
        continue;
      }
      covered++;
      amount += h.quantity * change.perUnit;
      base += h.quantity * change.from.price;
      final d = change.from.refDate;
      if (since == null || d.isBefore(since)) since = d;
    }
    if (covered == 0) return null;
    return PortfolioDayChange(
      amount: amount,
      base: base,
      covered: covered,
      missing: missing,
      since: since!,
    );
  }

  /// Ativos com a variação do dia (ou do mês, com [month]) calculada, da
  /// maior alta para a maior baixa.
  static List<Mover> movers(List<Holding> holdings, {bool month = false}) {
    final list = [
      for (final h in holdings)
        if (h.isOpen)
          if ((month ? h.marketPrice?.monthChange : h.marketPrice?.dayChange)
              case final change?)
            Mover(h, change),
    ]..sort((a, b) => b.change.fraction.compareTo(a.change.fraction));
    return list;
  }
}
