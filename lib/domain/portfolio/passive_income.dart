import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../market/market_data.dart';
import 'entities.dart';
import 'operation_type.dart';
import 'portfolio_calculator.dart';

/// Renda passiva registrada (`docs/FORMULAS.md` §12): proventos das
/// operações, na moeda [currency].
class IncomeTotals {
  IncomeTotals._(this.currency);

  final String currency;

  /// Líquido por tipo, por ano e por ativo, desde o início.
  final byType = <OperationType, Decimal>{};
  final byYear = <int, Map<OperationType, Decimal>>{};
  final byAsset = <String, Decimal>{};

  /// Líquido por ativo nos últimos 12 meses.
  final byAsset12m = <String, Decimal>{};

  /// Últimos 12 meses (do mês de 12 meses atrás até hoje), líquido e bruto.
  var last12m = Decimal.zero;
  var last12mGross = Decimal.zero;

  /// Média mensal dos últimos 12 meses.
  Decimal get monthlyAverage =>
      DecimalMath.divide(last12m, Decimal.fromInt(12));

  Decimal get total => byType.values.fold(Decimal.zero, (a, v) => a + v);

  static const types = [
    OperationType.dividend,
    OperationType.jcp,
    OperationType.fiiIncome,
    OperationType.interest,
  ];

  /// Os 12 meses terminam em [asOf] e começam no primeiro dia do mês de 11
  /// meses antes (os mesmos meses das barras do Painel).
  static IncomeTotals of(
    Iterable<Operation> operations, {
    required String currency,
    required LocalDate asOf,
  }) {
    final t = IncomeTotals._(currency);
    final start = LocalDate(asOf.year, asOf.month, 1).addMonths(-11);
    for (final op in operations) {
      if (!types.contains(op.type) ||
          op.currency != currency ||
          op.tradeDate.isAfter(asOf)) {
        continue;
      }
      final net = op.amount - op.charges;
      t.byType[op.type] = (t.byType[op.type] ?? Decimal.zero) + net;
      final year = t.byYear[op.tradeDate.year] ??= {};
      year[op.type] = (year[op.type] ?? Decimal.zero) + net;
      final asset = op.assetId ?? '';
      t.byAsset[asset] = (t.byAsset[asset] ?? Decimal.zero) + net;
      if (!op.tradeDate.isBefore(start)) {
        t.last12m += net;
        t.last12mGross += op.amount;
        t.byAsset12m[asset] = (t.byAsset12m[asset] ?? Decimal.zero) + net;
      }
    }
    return t;
  }
}

/// Provento da B3 que já foi pago e ainda não foi registrado, numa conta.
class IncomeSuggestion {
  const IncomeSuggestion({
    required this.assetId,
    required this.accountId,
    required this.event,
    required this.type,
    required this.quantity,
  });

  final String assetId;
  final String accountId;
  final CorporateEvent event;
  final OperationType type;

  /// Quantidade na conta no fim da data-com, pelas operações.
  final Decimal quantity;

  /// Quantidade × valor por cota (bruto, como publicado pela B3).
  Decimal get gross => DecimalMath.roundHalfUp(quantity * event.amount!);

  LocalDate get paymentDate => event.paymentDate!;
}

/// Provento que não é sugerido, com o motivo.
class IncomeSkip {
  const IncomeSkip({
    required this.assetId,
    required this.event,
    required this.initialBalanceDate,
  });

  final String assetId;
  final CorporateEvent event;

  /// Data do saldo inicial lançado depois da data-com.
  final LocalDate initialBalanceDate;
}

/// Provento anunciado (pagamento depois de hoje), com a quantidade de hoje
/// ou da data-com (se já passou).
class AnnouncedIncome {
  const AnnouncedIncome({
    required this.assetId,
    required this.event,
    required this.quantity,
  });

  final String assetId;
  final CorporateEvent event;
  final Decimal quantity;

  /// Estimado: quantidade × valor por cota, bruto.
  Decimal get gross => DecimalMath.roundHalfUp(quantity * event.amount!);
}

/// Proventos da B3 contra as operações (`docs/FORMULAS.md` §12).
class IncomeEventMatch {
  const IncomeEventMatch({
    required this.suggestions,
    required this.skipped,
    required this.announced,
  });

  final List<IncomeSuggestion> suggestions;
  final List<IncomeSkip> skipped;
  final List<AnnouncedIncome> announced;

  /// Tipo da operação de cada tipo de provento da B3 (amortização e eventos
  /// em ações não são renda).
  static OperationType? typeOf(CorporateEventKind k) => switch (k) {
    CorporateEventKind.cashDividend ||
    CorporateEventKind.otherCash => OperationType.dividend,
    CorporateEventKind.jcp => OperationType.jcp,
    CorporateEventKind.fiiIncome => OperationType.fiiIncome,
    _ => null,
  };

  /// Nota gravada nas operações lançadas, com a data-com (identifica o
  /// provento mesmo que o valor seja editado depois).
  static String note(CorporateEvent e) =>
      'Lançado dos proventos da B3 (data-com ${_br(e.comDate!)})';

  static String _br(LocalDate d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// [events] por ativo (só ativos da B3 com eventos guardados).
  ///
  /// - Pago (pagamento até [today]) e com posição na data-com, pelas
  ///   operações: sugerido por conta, se ainda não estiver registrado
  ///   (mesmo ativo, conta e tipo, com a nota da data-com ou com data entre
  ///   a data-com e 10 dias depois do pagamento).
  /// - Se o ativo tem um saldo inicial (cadastro rápido) com data depois da
  ///   data-com, a quantidade daquele dia não é conhecida: o provento não é
  ///   sugerido e entra em [skipped].
  /// - Pagamento depois de [today]: anunciado, com a quantidade na data-com
  ///   (se já passou) ou a de hoje.
  static IncomeEventMatch match({
    required List<Operation> operations,
    required Map<String, Asset> assets,
    required Map<String, List<CorporateEvent>> events,
    required LocalDate today,
  }) {
    final suggestions = <IncomeSuggestion>[];
    final skipped = <IncomeSkip>[];
    final announced = <AnnouncedIncome>[];
    final states = <LocalDate, PortfolioState>{};
    PortfolioState stateAt(LocalDate d) =>
        states[d] ??= PortfolioCalculator.compute(
          operations: operations,
          assets: assets,
          until: d,
        );

    for (final MapEntry(key: assetId, value: list) in events.entries) {
      final initialDates = [
        for (final o in operations)
          if (o.assetId == assetId && InitialBalance.isInitial(o)) o.tradeDate,
      ];
      final income = [
        for (final o in operations)
          if (o.assetId == assetId && o.type.isIncome) o,
      ];
      for (final e in list) {
        final type = typeOf(e.kind);
        final com = e.comDate;
        if (type == null ||
            com == null ||
            e.amount == null ||
            e.amount! <= Decimal.zero ||
            e.status == CorporateEventStatus.suspect) {
          continue;
        }
        final pay = e.paymentDate;
        if (pay == null || pay.isAfter(today)) {
          // Anunciado: a quantidade da data-com, se já passou; senão, a de
          // hoje.
          final at = com.isAfter(today) ? today : com;
          var qty = Decimal.zero;
          for (final p in stateAt(at).positions) {
            if (p.assetId == assetId) qty += p.quantity;
          }
          if (pay != null && qty > Decimal.zero) {
            announced.add(
              AnnouncedIncome(assetId: assetId, event: e, quantity: qty),
            );
          }
          continue;
        }
        final laterInitial = initialDates.where((d) => d.isAfter(com));
        if (laterInitial.isNotEmpty) {
          // A quantidade daquele dia não é conhecida: o saldo inicial é a
          // primeira notícia da posição.
          skipped.add(
            IncomeSkip(
              assetId: assetId,
              event: e,
              initialBalanceDate: laterInitial.reduce(
                (a, b) => a.isBefore(b) ? a : b,
              ),
            ),
          );
          continue;
        }
        final positions = [
          for (final p in stateAt(com).positions)
            if (p.assetId == assetId && p.quantity > Decimal.zero) p,
        ];
        for (final p in positions) {
          final registered = income.any(
            (o) =>
                o.accountId == p.accountId &&
                o.type == type &&
                (o.notes == note(e) ||
                    (!o.tradeDate.isBefore(com) &&
                        !o.tradeDate.isAfter(pay.addDays(10)))),
          );
          if (registered) continue;
          suggestions.add(
            IncomeSuggestion(
              assetId: assetId,
              accountId: p.accountId,
              event: e,
              type: type,
              quantity: p.quantity,
            ),
          );
        }
      }
    }
    int byPay(LocalDate? a, LocalDate? b) => (a ?? today).compareTo(b ?? today);
    suggestions.sort((a, b) => byPay(a.paymentDate, b.paymentDate));
    skipped.sort((a, b) => a.event.comDate!.compareTo(b.event.comDate!));
    announced.sort((a, b) => byPay(a.event.paymentDate, b.event.paymentDate));
    return IncomeEventMatch(
      suggestions: suggestions,
      skipped: skipped,
      announced: announced,
    );
  }
}
