import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../core/crypto/database_key.dart';
import 'app_database.steps.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Banco SQLite do app (`docs/BANCO.md`).
///
/// Cada mudança de schema sobe [schemaVersion], ganha um passo de migração e
/// um snapshot em `drift_schemas/` (gerados por
/// `dart run drift_dev make-migrations`).
@DriftDatabase(
  tables: [
    DevIdentity,
    DevSettings,
    SharedSettings,
    Institutions,
    Accounts,
    Assets,
    FixedIncomeTerms,
    Operations,
    ManualValuations,
    AssetAliases,
    HypoPortfolios,
    HypoHoldings,
    HypoCashflowRules,
    HypoScenarios,
    DevSyncPeers,
    DevSyncHistory,
    DevBackups,
    MktPrices,
    MktQuotes,
    MktCorporateEvents,
    MktIndicators,
    MktFxRates,
    MktTreasuryPrices,
    MktFundQuotas,
    MktInstruments,
    DevProviderState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Abre (ou cria) o banco no arquivo [path], em um isolate de fundo. Com
  /// [key], o arquivo é criptografado pelo SQLCipher (SPEC §3, F5B).
  factory AppDatabase.open(String path, {DatabaseKey? key}) {
    final pragma = key?.pragmaValue;
    return AppDatabase(
      NativeDatabase.createInBackground(
        File(path),
        setup: pragma == null
            ? null
            : (raw) => raw.execute('PRAGMA key = $pragma'),
      ),
    );
  }

  /// Banco em memória, para testes.
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  /// Versão atual do schema. Também é lida antes de abrir o banco, para
  /// decidir se é preciso o backup anterior à migração (SPEC §11).
  static const latestSchemaVersion = 4;

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // O backup anterior à migração é feito antes de abrir o banco
    // (`PreMigrationBackup`, em infrastructure/backup), não aqui.
    onUpgrade: stepByStep(
      // F3: cadastros e carteira real. Só cria tabelas e índices novos.
      from1To2: (m, schema) async {
        for (final table in [
          schema.institutions,
          schema.accounts,
          schema.assets,
          schema.fixedIncomeTerms,
          schema.operations,
          schema.manualValuations,
        ]) {
          await m.createTable(table);
        }
        for (final index in [
          schema.institutionsHlc,
          schema.institutionsNameKey,
          schema.accountsHlc,
          schema.accountsInstitution,
          schema.assetsHlc,
          schema.assetsSymbol,
          schema.fixedIncomeTermsHlc,
          schema.fixedIncomeTermsAsset,
          schema.operationsHlc,
          schema.operationsAssetDate,
          schema.operationsAccountDate,
          schema.operationsDate,
          schema.manualValuationsHlc,
          schema.manualValuationsAssetDate,
        ]) {
          await m.createIndex(index);
        }
      },
      // F5: aliases da mesclagem, carteiras hipotéticas (só as tabelas) e
      // tabelas de sincronização e backups do dispositivo. Só cria.
      from2To3: (m, schema) async {
        for (final table in [
          schema.assetAliases,
          schema.hypoPortfolios,
          schema.hypoHoldings,
          schema.hypoCashflowRules,
          schema.hypoScenarios,
          schema.devSyncPeers,
          schema.devSyncHistory,
          schema.devBackups,
        ]) {
          await m.createTable(table);
        }
        for (final index in [
          schema.assetAliasesHlc,
          schema.assetAliasesAlias,
          schema.hypoPortfoliosHlc,
          schema.hypoHoldingsHlc,
          schema.hypoHoldingsPortfolio,
          schema.hypoCashflowRulesHlc,
          schema.hypoScenariosHlc,
        ]) {
          await m.createIndex(index);
        }
      },
      // F6: dados de mercado (`mkt_`) e estado dos provedores. Só cria.
      from3To4: (m, schema) async {
        for (final table in [
          schema.mktPrices,
          schema.mktQuotes,
          schema.mktCorporateEvents,
          schema.mktIndicators,
          schema.mktFxRates,
          schema.mktTreasuryPrices,
          schema.mktFundQuotas,
          schema.mktInstruments,
          schema.devProviderState,
        ]) {
          await m.createTable(table);
        }
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
