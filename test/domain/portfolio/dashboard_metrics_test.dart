import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/market/market_price.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/dashboard_metrics.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/holdings.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/portfolio/portfolio_valuation.dart';

Decimal d(String v) => Decimal.parse(v);
var _seq = 0;

Operation _op(
  OperationType type,
  String date, {
  String? qty,
  String? price,
  String? gross,
  String fees = '0',
  String? notes,
  String currency = 'BRL',
}) => Operation(
  id: 'op${_seq++}'.padLeft(8, '0'),
  accountId: 'conta',
  assetId: type.assetUse == AssetUse.none ? null : 'A',
  type: type,
  tradeDate: LocalDate.parse(date),
  currency: currency,
  quantity: qty == null ? null : d(qty),
  unitPrice: price == null ? null : d(price),
  grossAmount: gross == null ? null : d(gross),
  fees: d(fees),
  notes: notes,
);

Holding _holding(String symbol, String qty, String price, String? previous) {
  final quote = MarketPrice(
    assetId: symbol,
    price: d(price),
    currency: 'BRL',
    refDate: LocalDate(2026, 10, 22),
    source: 'brapi',
    dataType: MarketDataType.intraday,
    collectedAt: '2026-10-22T18:00:00.000Z',
    previousClose: previous == null
        ? null
        : PriceReference(
            price: d(previous),
            refDate: LocalDate(2026, 10, 21),
            source: 'b3_cotahist',
          ),
    previousMonthClose: previous == null
        ? null
        : PriceReference(
            price: d(previous) - d('1'),
            refDate: LocalDate(2026, 9, 30),
            source: 'b3_cotahist',
          ),
  );
  final position = Position(
    accountId: 'conta',
    assetId: symbol,
    currency: 'BRL',
    quantity: d(qty),
    totalCost: d(qty) * d('10'),
    realizedPnl: Decimal.zero,
    incomeGross: Decimal.zero,
    incomeNet: Decimal.zero,
    lastOperationDate: LocalDate(2026, 1, 2),
  );
  return Holding(
    symbol,
    Asset(
      id: symbol,
      symbol: symbol,
      market: Market.b3,
      assetClass: AssetClass.stockBr,
      name: symbol,
      currency: 'BRL',
      country: 'BR',
    ),
    'BRL',
    [
      ValuedPosition(
        position: position,
        marketValue: d(qty) * d(price),
        unitPrice: d(price),
        valuationDate: LocalDate(2026, 10, 22),
        marketPrice: quote,
      ),
    ],
  );
}

void main() {
  test('aportes, vendas e proventos por mês nos últimos 12 meses; o saldo '
      'inicial conta como aporte na data informada (M-12)', () {
    final ops = [
      _op(OperationType.buy, '2026-10-02', qty: '10', price: '20', fees: '1'),
      _op(
        OperationType.buy,
        '2026-10-05',
        qty: '100',
        price: '25',
        notes: InitialBalance.note,
      ),
      _op(OperationType.sell, '2026-10-10', qty: '5', price: '22', fees: '2'),
      _op(OperationType.dividend, '2026-10-15', gross: '30', fees: '0'),
      _op(OperationType.contribution, '2026-03-01', gross: '1000'),
      _op(OperationType.jcp, '2026-03-20', gross: '10', fees: '1.5'),
      _op(OperationType.buy, '2025-10-30', qty: '1', price: '9'), // fora
      _op(OperationType.deposit, '2026-10-01', gross: '5000'),
      _op(
        OperationType.buy,
        '2026-10-03',
        qty: '1',
        price: '7',
        currency: 'USD',
      ),
    ];
    final months = DashboardMetrics.monthly(
      ops,
      currency: 'BRL',
      asOf: LocalDate(2026, 10, 22),
    );
    expect(months, hasLength(12));
    expect((months.first.year, months.first.month), (2025, 11));
    final oct = months.last;
    // 10 × 20 + 1 de custo e o saldo inicial de 100 × 25.
    expect(oct.buys, d('2701'));
    expect(oct.sells, d('108'));
    expect(oct.income, d('30'));
    final mar = months.firstWhere((m) => m.month == 3);
    expect(mar.buys, d('1000'));
    expect(mar.income, d('8.5'));
    expect(
      DashboardMetrics.investedInYear(
        ops,
        currency: 'BRL',
        asOf: LocalDate(2026, 10, 22),
      ),
      d('3701'),
    );
  });

  test('variação do dia da carteira soma os ativos com fechamento anterior; '
      'sem nenhum, indisponível', () {
    final holdings = [
      _holding('AAAA3', '100', '23.92', '24.10'), // −18
      _holding('BBBB3', '10', '40', '38'), // +20
      _holding('CCCC3', '5', '10', null), // sem fechamento
    ];
    final change = DashboardMetrics.dayChange(holdings, 'BRL')!;
    expect(change.amount, d('2'));
    expect(change.base, d('2790'));
    expect(change.fraction, DecimalMath.divide(d('2'), d('2790')));
    expect(change.covered, 2);
    expect(change.partial, isTrue);
    expect(change.since, LocalDate(2026, 10, 21));
    expect(
      DashboardMetrics.dayChange([_holding('CCCC3', '5', '10', null)], 'BRL'),
      isNull,
    );
  });

  test('maiores altas e baixas, no dia e no mês', () {
    final holdings = [
      _holding('AAAA3', '100', '23.92', '24.10'),
      _holding('BBBB3', '10', '40', '38'),
      _holding('CCCC3', '5', '10', null),
    ];
    final day = DashboardMetrics.movers(holdings);
    expect([for (final m in day) m.holding.assetId], ['BBBB3', 'AAAA3']);
    final month = DashboardMetrics.movers(holdings, month: true);
    expect(month.first.holding.assetId, 'BBBB3');
    expect(month.first.change.from.refDate, LocalDate(2026, 9, 30));
  });
}
