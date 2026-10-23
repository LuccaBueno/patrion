import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../data/repositories/market_repository.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/market/market_data.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/operation_type.dart';
import '../../domain/portfolio/passive_income.dart';
import 'operation_service.dart';
import 'portfolio_query.dart';

/// Renda passiva da carteira real (F8, parte 4).
class PassiveIncomeOverview {
  const PassiveIncomeOverview({
    required this.totals,
    required this.match,
    required this.otherCurrencies,
    this.eventsCollectedAt,
  });

  /// Proventos registrados em reais.
  final IncomeTotals totals;

  /// Proventos da B3 contra as operações.
  final IncomeEventMatch match;

  /// Proventos registrados em outras moedas (fora dos totais em reais).
  final Map<String, IncomeTotals> otherCurrencies;

  /// Coleta mais recente dos proventos da B3 (ISO-8601), para a nota.
  final String? eventsCollectedAt;
}

class PassiveIncomeService {
  PassiveIncomeService(this._repos, this._market);

  final PortfolioRepositories _repos;
  final MarketRepository _market;

  /// Alíquota padrão do IR retido sobre JCP, editável na prévia (o valor
  /// da B3 é bruto). Confira no informe da corretora.
  static final defaultJcpWithholding = Decimal.parse('0.15');

  Future<PassiveIncomeOverview> load(PortfolioSnapshot snap) async {
    final events = <String, List<CorporateEvent>>{};
    String? collected;
    for (final a in snap.assets.values) {
      if (a.market != Market.b3) continue;
      final list = await _market.events(a.symbol.toUpperCase(), 'B3');
      if (list.isEmpty) continue;
      events[a.id] = list;
      for (final e in list) {
        if (collected == null || e.collectedAt.compareTo(collected) > 0) {
          collected = e.collectedAt;
        }
      }
    }
    final currencies = {for (final o in snap.operations) o.currency};
    return PassiveIncomeOverview(
      totals: IncomeTotals.of(
        snap.operations,
        currency: 'BRL',
        asOf: snap.asOf,
      ),
      match: IncomeEventMatch.match(
        operations: snap.operations,
        assets: snap.assets,
        events: events,
        today: snap.asOf,
      ),
      otherCurrencies: {
        for (final c in currencies)
          if (c != 'BRL')
            c: IncomeTotals.of(snap.operations, currency: c, asOf: snap.asOf),
      },
      eventsCollectedAt: collected,
    );
  }

  /// Grava os proventos escolhidos como operações comuns, numa transação:
  /// valor bruto da B3 na data de pagamento, com o IR retido do JCP
  /// ([jcpWithholding] sobre o bruto) e a nota com a data-com. Devolve
  /// quantos foram gravados.
  Future<int> launch(
    List<IncomeSuggestion> items, {
    required Decimal jcpWithholding,
    required Map<String, Asset> assets,
  }) async {
    final operations = OperationService(_repos);
    await _repos.transaction(() async {
      for (final s in items) {
        final gross = s.gross;
        await operations.save(
          OperationDraft(
            accountId: s.accountId,
            assetId: s.assetId,
            type: s.type,
            tradeDate: s.paymentDate,
            currency: assets[s.assetId]?.currency ?? 'BRL',
            quantity: s.quantity,
            grossAmount: gross,
            taxes: s.type == OperationType.jcp
                ? DecimalMath.roundHalfUp(gross * jcpWithholding)
                : Decimal.zero,
            notes: IncomeEventMatch.note(s.event),
          ),
          allowDuplicate: true,
        );
      }
    });
    return items.length;
  }
}
