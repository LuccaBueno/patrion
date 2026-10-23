import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Renda passiva (F8, parte 4).
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  CorporateEvent ev(
    CorporateEventKind kind,
    String com,
    String pay,
    String amount,
  ) => CorporateEvent(
    symbol: 'PETR4',
    market: 'B3',
    kind: kind,
    exDate: LocalDate.parse(com).addDays(1),
    comDate: LocalDate.parse(com),
    paymentDate: LocalDate.parse(pay),
    amount: Decimal.parse(amount),
    source: 'b3_events',
    seq: 0,
    status: CorporateEventStatus.paid,
    collectedAt: '2026-10-17T12:00:00.000Z',
  );

  Future<void> events(List<CorporateEvent> list) =>
      MarketRepository(f.t.db).replaceEvents('PETR4', 'B3', 'b3_events', list);

  String cell(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets('proventos pagos da B3: prévia, IR do JCP e lançamento; '
      'recebido e anunciado separados', (tester) async {
    await tester.runAsync(() async {
      await f.add(
        f.draft(OperationType.buy, '2025-01-10', qty: '100', price: '30'),
      );
      await f.add(f.draft(OperationType.dividend, '2025-03-20', gross: '50'));
      await events([
        // Já registrado.
        ev(CorporateEventKind.cashDividend, '2025-03-01', '2025-03-20', '0.5'),
        // Pago e não registrado: 100 × 0,30.
        ev(CorporateEventKind.jcp, '2025-06-01', '2025-07-15', '0.3'),
        // Anunciado: data-com ainda não chegou, quantidade de hoje.
        ev(CorporateEventKind.cashDividend, '2027-01-04', '2027-01-20', '0.8'),
      ]);
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/renda', size: const Size(1280, 2400), () async {
      await app.pumpUntil(find.byKey(const Key('income-pending')));
      expect(
        cell(tester, 'income-pending-title'),
        r'1 provento pago não registrado (R$ 30,00, bruto)',
      );
      expect(cell(tester, 'income-year-2025-1'), r'R$ 50,00');
      expect(cell(tester, 'income-announced'), r'R$ 80,00');
      expect(find.text('20/01/2027'), findsOneWidget, reason: 'calendário');

      await app.tap(find.byKey(const Key('income-review')));
      expect(find.textContaining('100 × R\$ 0,3 ·'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('income-jcp-rate')))
            .controller!
            .text,
        '15',
      );
      await app.tap(find.byKey(const Key('income-launch')));
      await app.pumpUntil(find.text('1 provento lançado.'));
      // JCP de R$ 30,00 com 15% de IR: R$ 25,50 líquidos em 2025.
      await app.pumpUntil(find.text(r'R$ 25,50'));
      expect(cell(tester, 'income-year-2025-2'), r'R$ 25,50');
      expect(find.byKey(const Key('income-pending')), findsNothing);
    });
    final saved = (await tester.runAsync(f.repos.operations.all))!
        .where((o) => o.type == OperationType.jcp)
        .single;
    expect(saved.tradeDate, LocalDate(2025, 7, 15));
    expect(saved.grossAmount, Decimal.parse('30'));
    expect(saved.taxes, Decimal.parse('4.5'));
    expect(saved.notes, 'Lançado dos proventos da B3 (data-com 01/06/2025)');
  });

  testWidgets('saldo inicial depois da data-com: não sugere e explica', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await f.add(
        OperationDraft(
          accountId: f.account,
          assetId: f.petr,
          type: OperationType.buy,
          tradeDate: LocalDate(2025, 8, 1),
          currency: 'BRL',
          quantity: Decimal.parse('200'),
          unitPrice: Decimal.parse('30'),
          notes: InitialBalance.note,
        ),
      );
      await events([
        ev(CorporateEventKind.cashDividend, '2025-03-01', '2025-03-20', '0.5'),
        ev(CorporateEventKind.jcp, '2025-06-01', '2025-07-15', '0.3'),
      ]);
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/renda', size: const Size(1280, 2400), () async {
      await app.pumpUntil(find.byKey(const Key('income-pending')));
      expect(find.byKey(const Key('income-review')), findsNothing);
      final text = cell(tester, 'income-skipped-PETR4');
      expect(text, contains('2 proventos com data-com antes do saldo inicial'));
      expect(text, contains('01/08/2025'));
      expect(text, contains('registre as compras com as datas reais'));
    });
  });
}
