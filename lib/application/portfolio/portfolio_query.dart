import 'dart:async';

import 'package:clock/clock.dart';

import '../../core/time/local_date.dart';
import '../../data/repositories/portfolio_repositories.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/portfolio_calculator.dart';
import '../../domain/portfolio/portfolio_summary.dart';
import '../../domain/portfolio/portfolio_valuation.dart';

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
    );
    final summary = PortfolioSummary.build(
      state: state,
      valued: valued,
      termsByAsset: {for (final t in fixedIncome) t.assetId: t},
      asOf: asOf,
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

/// Lê a carteira real e a recalcula a cada alteração nas tabelas.
class PortfolioQuery {
  PortfolioQuery(this._repos, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final PortfolioRepositories _repos;
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
    return PortfolioSnapshot.compute(
      asOf: LocalDate.fromDateTime(_clock.now()),
      institutions: results[0].cast<Institution>(),
      accounts: results[1].cast<Account>(),
      assets: results[2].cast<Asset>(),
      fixedIncome: results[3].cast<FixedIncomeTerms>(),
      operations: results[4].cast<Operation>(),
      valuations: results[5].cast<ManualValuation>(),
    );
  }

  /// Retrato atual e um novo a cada alteração.
  ///
  /// As leituras são enfileiradas, para os retratos saírem na ordem das
  /// alterações. O cancelamento não espera o fim da assinatura do Drift
  /// (um gerador `async*` aqui travava ao cancelar).
  Stream<PortfolioSnapshot> watch() {
    late final StreamController<PortfolioSnapshot> controller;
    StreamSubscription<void>? changes;
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
        changes = _repos.watchChanges().listen((_) => refresh());
      },
      onCancel: () {
        unawaited(changes?.cancel());
        changes = null;
        unawaited(controller.close());
      },
    );
    return controller.stream;
  }
}
