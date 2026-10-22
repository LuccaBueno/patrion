import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../sync/sync_context.dart';
import 'asset_repository.dart';
import 'institution_repository.dart';
import 'manual_valuation_repository.dart';
import 'operation_repository.dart';

/// Repositórios da carteira real, criados juntos sobre o mesmo banco.
class PortfolioRepositories {
  PortfolioRepositories(this.db, SyncContext sync)
    : institutions = InstitutionRepository(db, sync),
      accounts = AccountRepository(db, sync),
      assets = AssetRepository(db, sync),
      fixedIncome = FixedIncomeTermsRepository(db, sync),
      operations = OperationRepository(db, sync),
      valuations = ManualValuationRepository(db, sync),
      _sync = sync;

  final AppDatabase db;
  final InstitutionRepository institutions;
  final AccountRepository accounts;
  final AssetRepository assets;
  final FixedIncomeTermsRepository fixedIncome;
  final OperationRepository operations;
  final ManualValuationRepository valuations;
  final SyncContext _sync;

  /// Novo UUID v7 (ex.: o grupo que liga as pontas de uma transferência).
  String newId() => _sync.newId();

  /// Roda [action] em uma transação: ou grava tudo, ou nada.
  Future<T> transaction<T>(Future<T> Function() action) =>
      db.transaction(action);

  /// Avisa a cada alteração em qualquer tabela da carteira real.
  Stream<void> watchChanges() => db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.institutions,
      db.accounts,
      db.assets,
      db.fixedIncomeTerms,
      db.operations,
      db.manualValuations,
      // Preferências da carteira, como o controle de caixa (M-03).
      db.sharedSettings,
    ]),
  );
}
