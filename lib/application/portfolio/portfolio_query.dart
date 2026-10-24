import 'dart:async';

import 'package:clock/clock.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/market/market_price.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/performance.dart';
import '../../domain/portfolio/portfolio_calculator.dart';
import '../../domain/portfolio/portfolio_summary.dart';
import '../../domain/portfolio/portfolio_valuation.dart';
import '../market/market_price_book.dart';
import '../settings/portfolio_preferences.dart';

/// Retrato da carteira real: cadastros, operações e tudo o que é calculado a
/// partir deles. Nada daqui é gravado: é recalculado a cada alteração
/// (dados derivados, CLAUDE.md).
class PortfolioSnapshot {
  PortfolioSnapshot({
    required this.asOf,
    required List<Institution> institutions,
    required List<Account> accounts,
    required List<Asset> assets,
    required List<FixedIncomeTerms> fixedIncome,
    required this.operations,
    required this.valuations,
    required this.state,
    required this.valued,
    required this.summary,
    this.marketPrices = const {},
  }) : institutions = {for (final i in institutions) i.id: i},
       accounts = {for (final a in accounts) a.id: a},
       assets = {for (final a in assets) a.id: a},
       fixedIncome = {for (final t in fixedIncome) t.assetId: t};

  static PortfolioSnapshot compute({
    required LocalDate asOf,
    required List<Institution> institutions,
    required List<Account> accounts,
    required List<Asset> assets,
    required List<FixedIncomeTerms> fixedIncome,
    required List<Operation> operations,
    required List<ManualValuation> valuations,
    Map<String, MarketPrice> marketPrices = const {},
    bool trackCash = PortfolioPreferences.defaultTrackCash,
  }) {
    final assetMap = {for (final a in assets) a.id: a};
    final state = PortfolioCalculator.compute(
      operations: operations,
      valuations: valuations,
      assets: assetMap,
    );
    final valued = PortfolioValuator.value(
      state: state,
      valuations: valuations,
      assets: assetMap,
      asOf: asOf,
      marketPrices: marketPrices,
    );
    final summary = PortfolioSummary.build(
      state: state,
      valued: valued,
      termsByAsset: {for (final t in fixedIncome) t.assetId: t},
      asOf: asOf,
      trackCash: trackCash,
    );
    return PortfolioSnapshot(
      asOf: asOf,
      institutions: institutions,
      accounts: accounts,
      assets: assets,
      fixedIncome: fixedIncome,
      operations: operations,
      valuations: valuations,
      state: state,
      valued: valued,
      summary: summary,
      marketPrices: marketPrices,
    );
  }

  /// Data usada para escolher preços e saldos (hoje).
  final LocalDate asOf;
  final Map<String, Institution> institutions;
  final Map<String, Account> accounts;
  final Map<String, Asset> assets;
  final Map<String, FixedIncomeTerms> fixedIncome;

  /// Operações vivas, da mais recente para a mais antiga.
  final List<Operation> operations;

  /// Preços e saldos vivos, do mais recente para o mais antigo.
  final List<ManualValuation> valuations;
  final PortfolioState state;

  /// Todas as posições (inclusive encerradas), com valor de mercado.
  final List<ValuedPosition> valued;
  final PortfolioSummary summary;

  /// Preço de mercado de cada ativo com preço automático, com ou sem
  /// posição (ativo recém-cadastrado também mostra a cotação).
  final Map<String, MarketPrice> marketPrices;

  /// O controle de caixa está ligado (M-03).
  bool get trackCash => summary.trackCash;

  /// Cadastros, operações e preços informados, comparáveis: duas leituras
  /// com a mesma chave são a mesma carteira (sem os preços de mercado). As
  /// telas só recalculam quando ela muda (M-10).
  late final SnapshotKey holdingsKey = SnapshotKey([
    asOf,
    trackCash,
    for (final i in institutions.values)
      (i.id, i.name, i.kind, i.country, i.notes),
    for (final a in accounts.values)
      (a.id, a.institutionId, a.name, a.kind, a.currency, a.archived),
    for (final a in assets.values)
      (
        a.id,
        a.symbol,
        a.market,
        a.assetClass,
        a.name,
        a.currency,
        a.country,
        a.priceSource,
        a.isin,
        a.sector,
        a.segment,
        a.liquidity,
        a.notes,
      ),
    for (final t in fixedIncome.values)
      (
        t.id,
        t.assetId,
        t.product,
        t.issuer,
        t.indexer,
        t.rate,
        t.spread,
        t.dayCount,
        t.issueDate,
        t.maturityDate,
        t.graceUntil,
        t.liquidity,
        t.taxRegime,
        t.costsNotes,
      ),
    for (final o in operations)
      (
        o.id,
        o.accountId,
        o.assetId,
        o.type,
        o.tradeDate,
        o.settlementDate,
        o.quantity,
        o.unitPrice,
        o.grossAmount,
        o.fees,
        o.taxes,
        o.currency,
        o.fxRate,
        (o.ratioFrom, o.ratioTo, o.transferGroupId, o.relatedOperationId),
        (o.justification, o.notes, o.origin),
      ),
    for (final v in valuations)
      (v.id, v.assetId, v.accountId, v.refDate, v.kind, v.value, v.currency),
  ]);

  /// [holdingsKey] e os preços de mercado usados: mesma chave, mesmo
  /// retrato.
  late final SnapshotKey dataKey = SnapshotKey([
    holdingsKey,
    for (final p in marketPrices.values)
      (
        p.assetId,
        p.price,
        p.currency,
        p.refDate,
        p.refAt,
        p.source,
        p.dataType,
        p.collectedAt,
        p.delayNote,
        _reference(p.previousClose),
        _reference(p.previousMonthClose),
      ),
  ]);

  static Object? _reference(PriceReference? r) =>
      r == null ? null : (r.price, r.refDate, r.source);

  final _performanceByCurrency = <String, Performance>{};
  final _performanceByAsset = <String, Performance>{};

  /// Desempenho (MWR) da carteira na moeda [currency], calculado na
  /// primeira consulta.
  Performance performance(String currency) =>
      _performanceByCurrency.putIfAbsent(
        currency,
        () => PerformanceCalculator.compute(
          currency: currency,
          operations: operations,
          positions: valued,
        ),
      );

  /// Ativos com posição aberta sem preço nem saldo (fora do patrimônio).
  late final Set<String> unpricedAssets = {
    for (final v in valued)
      if (v.position.isOpen && v.marketValue == null) v.position.assetId,
  };

  final _pricedByCurrency = <String, Performance>{};

  /// Desempenho só dos ativos com valor, que acompanha o patrimônio: o
  /// ganho total e o total aplicado do Painel e da Carteira (M-12). Igual a
  /// [performance] quando todas as posições têm preço; senão, parcial.
  Performance pricedPerformance(String currency) =>
      _pricedByCurrency.putIfAbsent(
        currency,
        () => PerformanceCalculator.compute(
          currency: currency,
          operations: operations.where(
            (o) => o.assetId == null || !unpricedAssets.contains(o.assetId),
          ),
          positions: valued.where(
            (v) => !unpricedAssets.contains(v.position.assetId),
          ),
        ),
      );

  /// Desempenho de um ativo, somando todas as contas. Nulo se o ativo não
  /// existe.
  Performance? assetPerformance(String assetId) {
    final asset = assets[assetId];
    if (asset == null) return null;
    return _performanceByAsset.putIfAbsent(
      assetId,
      () => PerformanceCalculator.forAsset(
        asset: asset,
        operations: operations,
        positions: valued,
      ),
    );
  }

  Institution? institutionOfAccount(String accountId) {
    final account = accounts[accountId];
    return account == null ? null : institutions[account.institutionId];
  }

  /// "Instituição · Conta", para listas e tabelas.
  String accountLabel(String accountId) {
    final account = accounts[accountId];
    if (account == null) return '—';
    final institution = institutions[account.institutionId];
    return institution == null
        ? account.name
        : '${institution.name} · ${account.name}';
  }
}

/// Lista de valores comparada elemento a elemento (registros, datas e
/// decimais já comparam pelo conteúdo).
class SnapshotKey {
  SnapshotKey(List<Object?> parts) : _parts = List.unmodifiable(parts);

  final List<Object?> _parts;

  @override
  late final int hashCode = Object.hashAll(_parts);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SnapshotKey || other.hashCode != hashCode) return false;
    if (other._parts.length != _parts.length) return false;
    for (var i = 0; i < _parts.length; i++) {
      if (_parts[i] != other._parts[i]) return false;
    }
    return true;
  }
}

/// Lê a carteira real e a recalcula a cada alteração nas tabelas (e nos
/// dados de mercado, quando há [MarketRepository]).
class PortfolioQuery {
  PortfolioQuery(
    this._repos, {
    Clock wallClock = const Clock(),
    this._market,
    this._preferences,
  }) : _clock = wallClock;

  final PortfolioRepositories _repos;
  final MarketRepository? _market;

  /// Sem preferências (testes de serviço), vale o padrão: sem controle de
  /// caixa.
  final PortfolioPreferences? _preferences;
  final Clock _clock;

  Future<PortfolioSnapshot> load() async {
    final results = await Future.wait<List<Object>>([
      _repos.institutions.all(),
      _repos.accounts.all(),
      _repos.assets.all(),
      _repos.fixedIncome.all(),
      _repos.operations.all(),
      _repos.valuations.all(),
    ]);
    final assets = results[2].cast<Asset>();
    final fixedIncome = results[3].cast<FixedIncomeTerms>();
    final market = _market;
    final asOf = LocalDate.fromDateTime(_clock.now());
    final trackCash =
        await _preferences?.trackCash() ??
        PortfolioPreferences.defaultTrackCash;
    return PortfolioSnapshot.compute(
      trackCash: trackCash,
      asOf: asOf,
      institutions: results[0].cast<Institution>(),
      accounts: results[1].cast<Account>(),
      assets: assets,
      fixedIncome: fixedIncome,
      operations: results[4].cast<Operation>(),
      valuations: results[5].cast<ManualValuation>(),
      marketPrices: market == null
          ? const {}
          : await MarketPriceBook.load(
              market,
              assets: assets,
              asOf: asOf,
              termsByAsset: {for (final t in fixedIncome) t.assetId: t},
            ),
    );
  }

  /// Retrato atual e um novo a cada alteração.
  ///
  /// As leituras são enfileiradas, para os retratos saírem na ordem das
  /// alterações. O cancelamento não espera o fim da assinatura do Drift
  /// (um gerador `async*` aqui travava ao cancelar).
  Stream<PortfolioSnapshot> watch() {
    late final StreamController<PortfolioSnapshot> controller;
    final subscriptions = <StreamSubscription<void>>[];
    var queue = Future<void>.value();

    void refresh() {
      queue = queue.then((_) async {
        try {
          final snapshot = await load();
          if (!controller.isClosed) controller.add(snapshot);
        } catch (error, stack) {
          if (!controller.isClosed) controller.addError(error, stack);
        }
      });
    }

    controller = StreamController<PortfolioSnapshot>(
      onListen: () {
        refresh();
        subscriptions.addAll([
          _repos.watchChanges().listen((_) => refresh()),
          ?_market?.watchChanges().listen((_) => refresh()),
          // Só o controle de caixa muda o retrato (M-03); as outras
          // preferências (alvos, F8) não recalculam a carteira.
          ?_preferences
              ?.watchTrackCash()
              .distinct()
              .skip(1)
              .listen((_) => refresh()),
        ]);
      },
      onCancel: () {
        for (final s in subscriptions) {
          unawaited(s.cancel());
        }
        subscriptions.clear();
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }
}
