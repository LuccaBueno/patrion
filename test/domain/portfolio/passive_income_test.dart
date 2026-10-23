import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/passive_income.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);

const _petr = Asset(
  id: 'petr',
  symbol: 'PETR4',
  market: Market.b3,
  assetClass: AssetClass.stockBr,
  name: 'Petrobras',
  currency: 'BRL',
  country: 'BR',
  priceSource: PriceSource.market,
);

var _seq = 0;

Operation op(
  OperationType type,
  String date, {
  String asset = 'petr',
  String? qty,
  String? price,
  String? gross,
  String taxes = '0',
  String account = 'a',
  String? notes,
}) => Operation(
  id: 'op${(_seq++).toString().padLeft(4, '0')}',
  accountId: account,
  assetId: asset,
  type: type,
  tradeDate: day(date),
  currency: 'BRL',
  quantity: qty == null ? null : d(qty),
  unitPrice: price == null ? null : d(price),
  grossAmount: gross == null ? null : d(gross),
  taxes: d(taxes),
  notes: notes,
);

CorporateEvent ev(
  CorporateEventKind kind,
  String com,
  String? pay,
  String amount,
) => CorporateEvent(
  symbol: 'PETR4',
  market: 'B3',
  kind: kind,
  exDate: day(com).addDays(1),
  comDate: day(com),
  paymentDate: pay == null ? null : day(pay),
  amount: d(amount),
  source: 'b3_events',
  seq: 0,
  status: CorporateEventStatus.paid,
  collectedAt: '2026-10-23T00:00:00.000Z',
);

IncomeEventMatch match(List<Operation> ops, List<CorporateEvent> events) =>
    IncomeEventMatch.match(
      operations: ops,
      assets: {'petr': _petr},
      events: {'petr': events},
      today: day('2026-10-23'),
    );

void main() {
  group('proventos pagos da B3 não registrados', () {
    final buy = op(OperationType.buy, '2025-01-10', qty: '100', price: '30');

    test('quantidade na data-com pelas operações, por conta', () {
      final m = match(
        [
          buy,
          op(
            OperationType.buy,
            '2025-02-10',
            qty: '40',
            price: '31',
            account: 'b',
          ),
          // Comprado depois da data-com: não entra.
          op(OperationType.buy, '2025-03-05', qty: '10', price: '32'),
        ],
        [
          ev(
            CorporateEventKind.cashDividend,
            '2025-03-01',
            '2025-03-20',
            '0.5',
          ),
          ev(CorporateEventKind.jcp, '2025-03-01', '2025-04-20', '0.25'),
          ev(CorporateEventKind.amortization, '2025-03-01', '2025-03-20', '1'),
        ],
      );
      expect(m.skipped, isEmpty);
      expect(
        [
          for (final s in m.suggestions)
            (s.accountId, s.type, s.quantity, s.gross),
        ],
        [
          ('a', OperationType.dividend, d('100'), d('50')),
          ('b', OperationType.dividend, d('40'), d('20')),
          ('a', OperationType.jcp, d('100'), d('25')),
          ('b', OperationType.jcp, d('40'), d('10')),
        ],
      );
    });

    test('já registrado (pela data ou pela nota) não é sugerido de novo', () {
      final div = ev(
        CorporateEventKind.cashDividend,
        '2025-03-01',
        '2025-03-20',
        '0.5',
      );
      expect(
        match(
          [buy, op(OperationType.dividend, '2025-03-21', gross: '50')],
          [div],
        ).suggestions,
        isEmpty,
      );
      expect(
        match(
          [
            buy,
            op(
              OperationType.dividend,
              '2025-06-01',
              gross: '49',
              notes: IncomeEventMatch.note(div),
            ),
          ],
          [div],
        ).suggestions,
        isEmpty,
      );
      // Registrado em outra conta: esta conta ainda falta.
      expect(
        match(
          [
            buy,
            op(OperationType.dividend, '2025-03-20', gross: '50', account: 'x'),
          ],
          [div],
        ).suggestions,
        hasLength(1),
      );
    });

    test('vendido antes da data-com: nada a sugerir', () {
      final m = match(
        [buy, op(OperationType.sell, '2025-02-20', qty: '100', price: '33')],
        [ev(CorporateEventKind.cashDividend, '2025-03-01', '2025-03-20', '1')],
      );
      expect(m.suggestions, isEmpty);
      expect(m.skipped, isEmpty);
    });

    test(
      'saldo inicial lançado depois da data-com: não sugere e diz por quê',
      () {
        final initial = op(
          OperationType.buy,
          '2025-06-01',
          qty: '200',
          price: '30',
          notes: InitialBalance.note,
        );
        final m = match(
          [initial],
          [
            ev(
              CorporateEventKind.cashDividend,
              '2025-03-01',
              '2025-03-20',
              '1',
            ),
            // Depois do saldo inicial: sugerido normalmente.
            ev(
              CorporateEventKind.cashDividend,
              '2025-07-01',
              '2025-07-20',
              '1',
            ),
          ],
        );
        expect(m.skipped.single.event.comDate, day('2025-03-01'));
        expect(m.skipped.single.initialBalanceDate, day('2025-06-01'));
        expect(m.suggestions.single.event.comDate, day('2025-07-01'));
        expect(m.suggestions.single.gross, d('200'));
      },
    );

    test('anunciado: pagamento futuro, quantidade na data-com ou hoje', () {
      final m = match(
        [buy],
        [
          ev(
            CorporateEventKind.cashDividend,
            '2026-10-01',
            '2026-11-20',
            '0.8',
          ),
          ev(CorporateEventKind.fiiIncome, '2026-10-30', '2026-11-14', '0.1'),
          ev(CorporateEventKind.cashDividend, '2026-10-01', null, '0.3'),
        ],
      );
      expect(m.suggestions, isEmpty);
      expect([for (final a in m.announced) a.gross], [d('10'), d('80')]);
    });
  });

  test('totais: por tipo, ano, ativo, 12 meses e média mensal', () {
    final t = IncomeTotals.of(
      [
        op(OperationType.dividend, '2024-12-15', gross: '100'),
        op(OperationType.jcp, '2025-11-15', gross: '200', taxes: '30'),
        op(OperationType.fiiIncome, '2026-10-10', gross: '50', asset: 'hglg'),
        op(OperationType.buy, '2026-10-10', qty: '1', price: '1000'),
      ],
      currency: 'BRL',
      asOf: day('2026-10-23'),
    );
    expect(t.byType[OperationType.dividend], d('100'));
    expect(t.byType[OperationType.jcp], d('170'));
    expect(t.total, d('320'));
    expect(t.byYear[2025]![OperationType.jcp], d('170'));
    expect(t.byAsset['hglg'], d('50'));
    // 12 meses: de 01/11/2025 a 23/10/2026.
    expect(t.last12m, d('220'));
    expect(t.last12mGross, d('250'));
    expect(t.monthlyAverage.round(scale: 4), d('18.3333'));
    expect(t.byAsset12m['petr'], d('170'));
  });
}
