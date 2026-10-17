import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/performance.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/portfolio/portfolio_valuation.dart';

Decimal d(String s) => Decimal.parse(s);

Decimal pct(Decimal fraction, int places) =>
    DecimalMath.roundHalfUp(fraction * Decimal.fromInt(100), scale: places);

const acc = 'conta-1';
const acc2 = 'conta-2';
const stock = Asset(
  id: 'x',
  symbol: 'XPTO3',
  market: Market.b3,
  assetClass: AssetClass.stockBr,
  name: 'XPTO',
  currency: 'BRL',
  country: 'BR',
);

var _seq = 0;

Operation op(
  OperationType type,
  String date, {
  String account = acc,
  String? qty,
  String? price,
  String? gross,
  String fees = '0',
  String? from,
  String? to,
  String? group,
}) {
  _seq++;
  return Operation(
    id: 'op-${_seq.toString().padLeft(4, '0')}',
    accountId: account,
    assetId: stock.id,
    type: type,
    tradeDate: LocalDate.parse(date),
    currency: 'BRL',
    quantity: qty == null ? null : d(qty),
    unitPrice: price == null ? null : d(price),
    grossAmount: gross == null ? null : d(gross),
    fees: d(fees),
    ratioFrom: from == null ? null : d(from),
    ratioTo: to == null ? null : d(to),
    transferGroupId: group,
  );
}

ManualValuation price(String date, String value) => ManualValuation(
  id: 'v-$date',
  assetId: stock.id,
  refDate: LocalDate.parse(date),
  kind: ValuationKind.unitPrice,
  value: d(value),
  currency: 'BRL',
);

Performance perf(List<Operation> ops, List<ManualValuation> prices) {
  final state = PortfolioCalculator.compute(operations: ops);
  final valued = PortfolioValuator.value(
    state: state,
    valuations: prices,
    assets: {stock.id: stock},
    asOf: LocalDate(2030, 1, 1),
  );
  return PerformanceCalculator.forAsset(
    asset: stock,
    operations: ops,
    positions: valued,
  );
}

void main() {
  test('CASOS_DE_TESTE §6 pelas operações: MWR −3,7093% a.a.', () {
    final p = perf(
      [
        op(OperationType.buy, '2024-01-01', qty: '100', price: '10'),
        op(OperationType.buy, '2025-01-01', qty: '50', price: '20'),
      ],
      [price('2026-01-01', '12.6')], // 150 × 12,60 = 1.890
    );
    expect(p.endValue, d('1890'));
    expect(p.endDate, LocalDate(2026, 1, 1));
    expect(pct(p.net!.annual, 4), d('-3.7093'));
    expect(p.net!.isShortPeriod, isFalse);
    expect(p.totalResult, d('-110'));
    expect(p.gap, isNull);
  });

  group('CASOS_DE_TESTE §1 com preço final', () {
    late List<Operation> ops;
    setUp(() {
      ops = [
        op(OperationType.buy, '2024-01-10', qty: '100', price: '30', fees: '5'),
        op(OperationType.buy, '2024-02-10', qty: '50', price: '36', fees: '4'),
        op(OperationType.sell, '2024-03-10', qty: '60', price: '40', fees: '6'),
        op(OperationType.dividend, '2024-04-10', qty: '90', price: '0.5'),
        op(OperationType.split, '2024-05-10', from: '1', to: '2'),
      ];
    });

    test('totais: investido, devolvido, custos e proventos', () {
      final p = perf(ops, [price('2024-06-10', '20')]);
      expect(p.invested, d('4809'));
      expect(p.returned, d('2394'));
      expect(p.costs, d('15'));
      expect(p.incomeNet, d('45'));
      expect(p.endValue, d('3600')); // 180 × 20
      // 2.394 + 45 + 3.600 − 4.809 = 1.230
      expect(p.totalResult, d('1230'));
      expect(p.resultWithoutIncome, d('1185'));
    });

    test('com proventos rende mais que sem; bruto mais que líquido', () {
      final p = perf(ops, [price('2024-06-10', '20')]);
      expect(p.net!.annual > p.netWithoutIncome!.annual, isTrue);
      expect(p.gross!.annual > p.net!.annual, isTrue);
      expect(p.net!.isShortPeriod, isTrue);
      expect(p.net!.start, LocalDate(2024, 1, 10));
      expect(p.net!.end, LocalDate(2024, 6, 10));
    });

    test('sem preço: indisponível, nunca estimado pelo custo', () {
      final p = perf(ops, const []);
      expect(p.endValue, isNull);
      expect(p.totalResult, isNull);
      expect(p.net, isNull);
      expect(p.gap, PerformanceGap.unpricedPosition);
    });
  });

  test('posição encerrada não precisa de preço', () {
    final p = perf([
      op(OperationType.buy, '2023-01-01', qty: '10', price: '100'),
      op(OperationType.sell, '2024-01-01', qty: '10', price: '110'),
    ], const []);
    expect(p.endValue, Decimal.zero);
    expect(p.totalResult, d('100'));
    expect(pct(p.net!.annual, 4), d('10.0000'));
  });

  test('transferência entre contas não é fluxo; os custos são', () {
    final p = perf(
      [
        op(OperationType.buy, '2023-01-01', qty: '10', price: '100'),
        op(
          OperationType.transferOut,
          '2023-06-01',
          qty: '10',
          fees: '1',
          group: 'g',
        ),
        op(
          OperationType.transferIn,
          '2023-06-01',
          account: acc2,
          qty: '10',
          group: 'g',
        ),
      ],
      [price('2024-01-01', '110')],
    );
    expect(p.invested, d('1000'));
    expect(p.costs, d('1'));
    expect(p.totalResult, d('99'));
    expect(pct(p.gross!.annual, 4), d('10.0000'));
  });

  test('sem compras não há retorno', () {
    final p = perf(
      [op(OperationType.split, '2024-01-01', from: '1', to: '2')],
      [price('2024-02-01', '10')],
    );
    expect(p.net, isNull);
    expect(p.gap, PerformanceGap.noFlows);
  });
}
