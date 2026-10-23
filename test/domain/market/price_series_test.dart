import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/market/price_series.dart';

Decimal d(String v) => Decimal.parse(v);

PricePoint p(String date, String price) =>
    PricePoint(LocalDate.parse(date), d(price));

CorporateEvent ev(
  CorporateEventKind kind,
  String exDate, {
  String? amount,
  String? factor,
  CorporateEventStatus status = CorporateEventStatus.paid,
}) => CorporateEvent(
  symbol: 'BBAS3',
  market: 'B3',
  kind: kind,
  exDate: LocalDate.parse(exDate),
  amount: amount == null ? null : d(amount),
  factor: factor == null ? null : d(factor),
  status: status,
  source: 'b3_events',
  seq: 0,
  collectedAt: '2026-10-23T12:00:00.000Z',
);

void main() {
  test('fechamentos unitários: aplica o fator de cotação e ordena', () {
    PriceBar bar(String date, String close, [String? factor]) => PriceBar(
      symbol: 'X',
      market: 'B3',
      refDate: LocalDate.parse(date),
      close: d(close),
      quoteFactor: factor == null ? null : d(factor),
      currency: 'BRL',
      source: 'b3_cotahist',
      dataType: MarketDataType.close,
      collectedAt: '',
    );
    final s = PriceSeries.closes([
      bar('2026-01-06', '3100', '1000'),
      bar('2026-01-05', '30.00'),
    ]);
    expect(s.map((e) => '$e'), ['2026-01-05 30', '2026-01-06 3.1']);
  });

  test('desdobramento 1:2 (BBAS3, 16/04/2024): sem a queda falsa', () {
    // Fechamentos reais do COTAHIST.
    final closes = [
      p('2024-04-12', '57.10'),
      p('2024-04-15', '56.46'),
      p('2024-04-16', '27.91'),
      p('2024-04-17', '28.05'),
    ];
    final adj = PriceSeries.adjusted(closes, [
      ev(CorporateEventKind.split, '2024-04-16', factor: '2'),
    ]);
    expect(adj.map((e) => e.price), [
      d('28.55'),
      d('28.23'),
      d('27.91'),
      d('28.05'),
    ]);
    // Sem o evento, o salto de −50,6% é suspeito; com ele, não.
    expect(PriceSeries.suspectJumps(closes, const []), hasLength(1));
    expect(
      PriceSeries.suspectJumps(closes, [
        ev(CorporateEventKind.split, '2024-04-16', factor: '2'),
      ]),
      isEmpty,
    );
  });

  test('provento em dinheiro: fator 1 − D ÷ P da data com', () {
    final closes = [
      p('2026-03-02', '40.00'),
      p('2026-03-03', '40.00'), // data com
      p('2026-03-04', '39.00'), // data ex: R$ 1,00 por ação
      p('2026-03-05', '39.50'),
    ];
    final adj = PriceSeries.adjusted(closes, [
      ev(CorporateEventKind.cashDividend, '2026-03-04', amount: '1.00'),
      // JCP sem valor e evento suspeito não entram.
      ev(CorporateEventKind.jcp, '2026-03-04'),
      ev(
        CorporateEventKind.split,
        '2026-03-05',
        factor: '2',
        status: CorporateEventStatus.suspect,
      ),
    ]);
    // 40 × (1 − 1/40) = 39: a queda da data ex some.
    expect(adj.map((e) => e.price), [d('39'), d('39'), d('39'), d('39.5')]);
  });

  test('eventos acumulam; fora da série são ignorados', () {
    final closes = [
      p('2026-01-02', '20.00'),
      p('2026-02-02', '10.00'),
      p('2026-03-02', '9.00'),
    ];
    final adj = PriceSeries.adjusted(closes, [
      ev(CorporateEventKind.split, '2026-02-02', factor: '2'),
      ev(CorporateEventKind.cashDividend, '2026-03-02', amount: '1.00'),
      ev(CorporateEventKind.cashDividend, '2025-06-01', amount: '1.00'),
      ev(CorporateEventKind.cashDividend, '2026-05-01', amount: '1.00'),
    ]);
    // Dividendo de 1 sobre 10: fator 0,9 para os dois primeiros; o
    // desdobramento divide o primeiro por 2.
    expect(adj.map((e) => e.price), [d('9'), d('9'), d('9')]);
    // Grupamento 10:1 multiplica o passado por 10.
    final grouped = PriceSeries.adjusted(
      [p('2026-01-02', '1.00'), p('2026-01-05', '10.00')],
      [ev(CorporateEventKind.reverseSplit, '2026-01-05', factor: '0.1')],
    );
    expect(grouped.first.price, d('10'));
  });

  test('salto para cima sem evento também é suspeito', () {
    final jumps = PriceSeries.suspectJumps([
      p('2026-01-02', '10.00'),
      p('2026-01-05', '10.50'),
      p('2026-01-06', '100.00'),
    ], const []);
    expect(jumps.single.from.date, LocalDate(2026, 1, 5));
    expect(jumps.single.change, d('8.52380952380952380952'));
  });

  test('período: a partir da data, variação, máxima e mínima', () {
    final series = [
      p('2025-10-20', '30.00'),
      p('2025-10-23', '27.00'),
      p('2026-01-05', '36.00'),
      p('2026-10-22', '33.24'),
    ];
    final since = PriceSeries.since(series, LocalDate(2025, 10, 21));
    expect(since.first.date, LocalDate(2025, 10, 23));
    final s = PriceSeries.summary(since)!;
    expect(s.change, d('0.23111111111111111111'));
    expect(s.high.date, LocalDate(2026, 1, 5));
    expect(s.low.price, d('27'));
    expect(PriceSeries.summary([series.first]), isNull);
    expect(PriceSeries.since(series, LocalDate(2027, 1, 1)), isEmpty);
  });
}
