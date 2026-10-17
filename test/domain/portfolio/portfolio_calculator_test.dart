import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';

Decimal d(String s) => Decimal.parse(s);

const acc = 'conta-1';
const acc2 = 'conta-2';
const petr = 'ativo-petr4';
const cdb = 'ativo-cdb';

var _seq = 0;

/// Operação de teste. Os ids crescem na ordem de criação, como o UUID v7.
Operation op(
  OperationType type,
  String date, {
  String account = acc,
  String? asset = petr,
  String? qty,
  String? price,
  String? gross,
  String fees = '0',
  String taxes = '0',
  String? from,
  String? to,
  String? group,
  String currency = 'BRL',
}) {
  _seq++;
  return Operation(
    id: 'op-${_seq.toString().padLeft(4, '0')}',
    accountId: account,
    assetId: asset,
    type: type,
    tradeDate: LocalDate.parse(date),
    currency: currency,
    quantity: qty == null ? null : d(qty),
    unitPrice: price == null ? null : d(price),
    grossAmount: gross == null ? null : d(gross),
    fees: d(fees),
    taxes: d(taxes),
    ratioFrom: from == null ? null : d(from),
    ratioTo: to == null ? null : d(to),
    transferGroupId: group,
  );
}

Position positionOf(
  PortfolioState s, [
  String account = acc,
  String a = petr,
]) => s.position(account, a)!;

void main() {
  group('CASOS_DE_TESTE §1: preço médio, venda e eventos', () {
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

    PortfolioState upTo(int n) =>
        PortfolioCalculator.compute(operations: ops.take(n));

    test('op. 1: compra com custos entra no preço médio', () {
      final p = positionOf(upTo(1));
      expect(p.quantity, d('100'));
      expect(p.totalCost, d('3005'));
      expect(p.averagePrice, d('30.05'));
    });

    test('op. 2: segunda compra', () {
      final p = positionOf(upTo(2));
      expect(p.quantity, d('150'));
      expect(p.totalCost, d('4809'));
      expect(p.averagePrice, d('32.06'));
    });

    test('op. 3: venda baixa o custo pelo preço médio e realiza 470,40', () {
      final p = positionOf(upTo(3));
      expect(p.quantity, d('90'));
      expect(p.totalCost, d('2885.4'));
      expect(p.averagePrice, d('32.06'));
      expect(p.realizedPnl, d('470.4'));
      // Caixa: −3.005 − 1.804 + 2.394.
      expect(upTo(3).cash[acc]!['BRL'], d('-2415'));
    });

    test('op. 4: dividendo de R\$ 45,00 não muda o preço médio', () {
      final s = upTo(4);
      final p = positionOf(s);
      expect(p.incomeGross, d('45'));
      expect(p.incomeNet, d('45'));
      expect(p.averagePrice, d('32.06'));
      expect(p.totalCost, d('2885.4'));
      expect(s.cash[acc]!['BRL'], d('-2370'));
    });

    test('op. 5: desdobramento 1:2 mantém o custo total', () {
      final p = positionOf(upTo(5));
      expect(p.quantity, d('180'));
      expect(p.totalCost, d('2885.4'));
      expect(p.averagePrice, d('16.03'));
    });

    test('grupamento 10:1 depois da op. 5', () {
      ops.add(
        op(OperationType.reverseSplit, '2024-06-10', from: '10', to: '1'),
      );
      final p = positionOf(upTo(6));
      expect(p.quantity, d('18'));
      expect(p.averagePrice, d('160.3'));
      expect(p.totalCost, d('2885.4'));
    });

    test('editar a op. 1 (quantidade 200) recalcula as seguintes', () {
      final original = ops.first;
      ops[0] = Operation(
        id: original.id,
        accountId: original.accountId,
        assetId: original.assetId,
        type: original.type,
        tradeDate: original.tradeDate,
        currency: original.currency,
        quantity: d('200'),
        unitPrice: original.unitPrice,
        fees: original.fees,
      );
      // Op. 1: 200 × 30 + 5 = 6.005; op. 2: 250 cotas, custo 7.809,
      // médio 31,236; venda de 60 baixa 1.874,16 e realiza 519,84.
      final p = positionOf(upTo(3));
      expect(p.quantity, d('190'));
      expect(p.averagePrice, d('31.236'));
      expect(p.totalCost, d('5934.84'));
      expect(p.realizedPnl, d('519.84'));
      final split = positionOf(upTo(5));
      expect(split.quantity, d('380'));
      expect(split.totalCost, d('5934.84'));
    });

    test('a ordem de entrada não importa: vale a data e a criação', () {
      final shuffled = [ops[4], ops[2], ops[0], ops[3], ops[1]];
      final p = positionOf(PortfolioCalculator.compute(operations: shuffled));
      expect(p.quantity, d('180'));
      expect(p.realizedPnl, d('470.4'));
    });
  });

  group('outros tipos', () {
    test('venda maior que a posição gera inconsistência', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '10', price: '10'),
          op(OperationType.sell, '2024-01-02', qty: '15', price: '10'),
        ],
      );
      expect(s.issues.single.kind, PortfolioIssueKind.oversold);
    });

    test('depósito, retirada e custos avulsos mexem só no caixa', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.deposit, '2024-01-01', asset: null, gross: '1000'),
          op(OperationType.withdrawal, '2024-01-02', asset: null, gross: '200'),
          op(OperationType.fee, '2024-01-03', asset: null, gross: '10'),
          op(OperationType.tax, '2024-01-04', asset: null, gross: '5'),
        ],
      );
      expect(s.cash[acc]!['BRL'], d('785'));
      expect(s.positions, isEmpty);
    });

    test('transferência de caixa entre contas', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.deposit, '2024-01-01', asset: null, gross: '1000'),
          op(
            OperationType.transferOut,
            '2024-01-02',
            asset: null,
            gross: '400',
            group: 'g1',
          ),
          op(
            OperationType.transferIn,
            '2024-01-02',
            account: acc2,
            asset: null,
            gross: '400',
            group: 'g1',
          ),
        ],
      );
      expect(s.cash[acc]!['BRL'], d('600'));
      expect(s.cash[acc2]!['BRL'], d('400'));
    });

    test('transferência de custódia leva quantidade e custo, sem lucro', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(
            OperationType.buy,
            '2024-01-01',
            qty: '100',
            price: '30',
            fees: '5',
          ),
          op(OperationType.transferOut, '2024-02-01', qty: '40', group: 'g'),
          op(
            OperationType.transferIn,
            '2024-02-01',
            account: acc2,
            qty: '40',
            group: 'g',
          ),
        ],
      );
      final origin = positionOf(s);
      final dest = positionOf(s, acc2);
      expect(origin.quantity, d('60'));
      expect(origin.totalCost, d('1803'));
      expect(dest.quantity, d('40'));
      expect(dest.totalCost, d('1202'));
      expect(dest.averagePrice, d('30.05'));
      expect(origin.realizedPnl + dest.realizedPnl, Decimal.zero);
      expect(s.issues, isEmpty);
    });

    test('entrada de transferência sem a saída é sinalizada', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.transferIn, '2024-02-01', qty: '40', group: 'x'),
        ],
      );
      expect(s.issues.single.kind, PortfolioIssueKind.missingTransferLeg);
    });

    test('JCP com retenção: líquido no caixa, bruto e líquido no provento', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '100', price: '10'),
          op(OperationType.jcp, '2024-03-01', gross: '100', taxes: '15'),
        ],
      );
      final p = positionOf(s);
      expect(p.incomeGross, d('100'));
      expect(p.incomeNet, d('85'));
      expect(p.averagePrice, d('10'));
      expect(s.cash[acc]!['BRL'], d('-915'));
    });

    test('bonificação soma quantidade e o custo atribuído', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '100', price: '10'),
          op(OperationType.bonusShares, '2024-02-01', qty: '10', gross: '50'),
        ],
      );
      final p = positionOf(s);
      expect(p.quantity, d('110'));
      expect(p.totalCost, d('1050'));
    });

    test('aporte, amortização e vencimento de renda fixa', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(
            OperationType.contribution,
            '2024-01-01',
            asset: cdb,
            gross: '1000',
          ),
          op(
            OperationType.amortization,
            '2024-06-01',
            asset: cdb,
            gross: '300',
          ),
          op(
            OperationType.maturity,
            '2025-01-01',
            asset: cdb,
            gross: '820',
            taxes: '20',
          ),
        ],
      );
      final p = positionOf(s, acc, cdb);
      expect(p.totalCost, Decimal.zero);
      expect(p.isOpen, isFalse);
      // Custo 700 depois da amortização; vencimento líquido 800.
      expect(p.realizedPnl, d('100'));
      expect(s.cash[acc]!['BRL'], d('100'));
    });

    test('resgate parcial por valor usa o saldo informado', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(
            OperationType.contribution,
            '2024-01-01',
            asset: cdb,
            gross: '1000',
          ),
          op(OperationType.redemption, '2024-07-01', asset: cdb, gross: '600'),
        ],
        valuations: [
          ManualValuation(
            id: 'v1',
            assetId: cdb,
            accountId: acc,
            refDate: LocalDate(2024, 6, 30),
            kind: ValuationKind.balance,
            value: d('1200'),
            currency: 'BRL',
          ),
        ],
      );
      final p = positionOf(s, acc, cdb);
      // Resgatou metade do saldo: baixa metade do custo.
      expect(p.totalCost, d('500'));
      expect(p.realizedPnl, d('100'));
    });

    test('resgate por valor sem saldo informado baixa pelo custo', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(
            OperationType.contribution,
            '2024-01-01',
            asset: cdb,
            gross: '1000',
          ),
          op(OperationType.redemption, '2024-07-01', asset: cdb, gross: '250'),
        ],
      );
      final p = positionOf(s, acc, cdb);
      expect(p.totalCost, d('750'));
      expect(p.realizedPnl, Decimal.zero);
    });

    test('reinvestimento funciona como compra', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '10', price: '100'),
          op(OperationType.reinvestment, '2024-02-01', qty: '1', price: '110'),
        ],
      );
      expect(positionOf(s).quantity, d('11'));
      expect(positionOf(s).totalCost, d('1110'));
    });

    test('ajuste manual altera quantidade, custo ou caixa', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '10', price: '100'),
          op(
            OperationType.manualAdjustment,
            '2024-02-01',
            qty: '-1',
            gross: '-100',
          ),
          op(
            OperationType.manualAdjustment,
            '2024-02-02',
            asset: null,
            gross: '50',
          ),
        ],
      );
      expect(positionOf(s).quantity, d('9'));
      expect(positionOf(s).totalCost, d('900'));
      expect(s.cash[acc]!['BRL'], d('-950'));
    });

    test('until ignora operações posteriores', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '10', price: '100'),
          op(OperationType.buy, '2024-03-01', qty: '10', price: '100'),
        ],
        until: LocalDate(2024, 2, 1),
      );
      expect(positionOf(s).quantity, d('10'));
    });

    test('moeda da operação diferente da posição é sinalizada', () {
      final s = PortfolioCalculator.compute(
        operations: [
          op(OperationType.buy, '2024-01-01', qty: '10', price: '100'),
          op(
            OperationType.buy,
            '2024-01-02',
            qty: '1',
            price: '20',
            currency: 'USD',
          ),
        ],
      );
      expect(s.issues.single.kind, PortfolioIssueKind.currencyMismatch);
    });
  });
}
