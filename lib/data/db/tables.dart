import 'package:drift/drift.dart';

import 'converters.dart';

/// Campos de sincronização de toda tabela com dados do usuário
/// (CLAUDE.md e `docs/BANCO.md` §2).
///
/// Só o repositório base (`SyncRepository`) escreve nesses campos.
mixin SyncColumns on Table {
  /// UUID v7 gerado no app.
  TextColumn get id => text()();

  /// Instante UTC da criação (ISO-8601 com ms).
  TextColumn get createdAt => text()();

  /// Instante UTC da última escrita.
  TextColumn get updatedAt => text()();

  /// HLC da última alteração.
  TextColumn get hlc => text()();

  /// Dispositivo que fez a última alteração.
  TextColumn get deviceId => text()();

  /// Tombstone: preenchido na exclusão lógica.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Dispositivo (dev_): nunca vão no save.
// ---------------------------------------------------------------------------

/// Identidade deste PC. Uma linha só.
@DataClassName('DevIdentityRow')
class DevIdentity extends Table {
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text()();
  TextColumn get createdAt => text()();

  /// Último HLC emitido ou recebido, para o relógio continuar crescendo
  /// depois de reiniciar o app.
  TextColumn get lastHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

/// Configurações só deste PC (tema, tamanho da janela, pastas usadas).
@DataClassName('DevSettingRow')
class DevSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Configurações compartilhadas (sincronizáveis).
// ---------------------------------------------------------------------------

/// Preferências que valem em todos os PCs. Chave natural: `key`, aplicada
/// pelo app (não por índice único, ver `docs/BANCO.md` §2).
@DataClassName('SharedSettingRow')
@TableIndex(name: 'shared_settings_hlc', columns: {#hlc})
@TableIndex(name: 'shared_settings_key', columns: {#key})
class SharedSettings extends Table with SyncColumns {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
}

// ---------------------------------------------------------------------------
// Cadastros e carteira real (sincronizáveis, schema 2).
// Chaves naturais aplicadas pelo app, não por índice único (BANCO.md §2).
// ---------------------------------------------------------------------------

/// Corretoras, bancos e exchanges.
@DataClassName('InstitutionRow')
@TableIndex(name: 'institutions_hlc', columns: {#hlc})
@TableIndex(name: 'institutions_name_key', columns: {#nameKey})
class Institutions extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Nome normalizado: chave natural para detectar duplicatas.
  TextColumn get nameKey => text()();
  TextColumn get kind => text()();
  TextColumn get country => text()();
  TextColumn get notes => text().nullable()();
}

/// Contas dentro de uma instituição.
@DataClassName('AccountRow')
@TableIndex(name: 'accounts_hlc', columns: {#hlc})
@TableIndex(name: 'accounts_institution', columns: {#institutionId})
class Accounts extends Table with SyncColumns {
  TextColumn get institutionId => text().references(Institutions, #id)();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get currency => text()();
  TextColumn get archivedAt => text().nullable()();
}

/// Catálogo de ativos, compartilhado com as carteiras hipotéticas (F9).
@DataClassName('AssetRow')
@TableIndex(name: 'assets_hlc', columns: {#hlc})
@TableIndex(name: 'assets_symbol', columns: {#symbol, #market})
class Assets extends Table with SyncColumns {
  TextColumn get symbol => text()();
  TextColumn get market => text()();
  TextColumn get assetClass => text()();
  TextColumn get name => text()();
  TextColumn get currency => text()();
  TextColumn get country => text()();
  TextColumn get isin => text().nullable()();
  TextColumn get sector => text().nullable()();
  TextColumn get segment => text().nullable()();
  TextColumn get liquidity => text().nullable()();

  /// `market` (cotação dos provedores, F6) ou `manual`.
  TextColumn get priceSource => text()();
  TextColumn get notes => text().nullable()();
}

/// Características de renda fixa (1:1 com ativos `fixed_income`/`treasury`).
@DataClassName('FixedIncomeTermsRow')
@TableIndex(name: 'fixed_income_terms_hlc', columns: {#hlc})
@TableIndex(name: 'fixed_income_terms_asset', columns: {#assetId})
class FixedIncomeTerms extends Table with SyncColumns {
  TextColumn get assetId => text().references(Assets, #id)();
  TextColumn get product => text()();
  TextColumn get issuer => text().nullable()();
  TextColumn get indexer => text()();
  TextColumn get rate => text().map(const DecimalTextConverter())();
  TextColumn get spread =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get dayCount => text()();
  TextColumn get issueDate => text()();
  TextColumn get maturityDate => text()();
  TextColumn get graceUntil => text().nullable()();
  TextColumn get liquidity => text()();
  TextColumn get taxRegime => text()();
  TextColumn get costsNotes => text().nullable()();
}

/// Operações da carteira real (SPEC §7).
@DataClassName('OperationRow')
@TableIndex(name: 'operations_hlc', columns: {#hlc})
@TableIndex(name: 'operations_asset_date', columns: {#assetId, #tradeDate})
@TableIndex(name: 'operations_account_date', columns: {#accountId, #tradeDate})
@TableIndex(name: 'operations_date', columns: {#tradeDate})
class Operations extends Table with SyncColumns {
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Nulo para movimentos só de caixa.
  TextColumn get assetId => text().nullable().references(Assets, #id)();
  TextColumn get type => text()();
  TextColumn get tradeDate => text()();
  TextColumn get settlementDate => text().nullable()();
  TextColumn get quantity =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get unitPrice =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get grossAmount =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get fees => text().map(const DecimalTextConverter())();
  TextColumn get taxes => text().map(const DecimalTextConverter())();
  TextColumn get currency => text()();
  TextColumn get fxRate =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get ratioFrom =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get ratioTo =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get transferGroupId => text().nullable()();
  TextColumn get relatedOperationId =>
      text().nullable().references(Operations, #id)();
  TextColumn get justification => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// `manual`, `csv_import` ou `save_merge`.
  TextColumn get origin => text()();
}

/// Preços e saldos informados pelo usuário.
@DataClassName('ManualValuationRow')
@TableIndex(name: 'manual_valuations_hlc', columns: {#hlc})
@TableIndex(name: 'manual_valuations_asset_date', columns: {#assetId, #refDate})
class ManualValuations extends Table with SyncColumns {
  TextColumn get assetId => text().references(Assets, #id)();

  /// Obrigatório para saldos (`kind = balance`).
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  TextColumn get refDate => text()();

  /// `unit_price` ou `balance`.
  TextColumn get kind => text()();
  TextColumn get value => text().map(const DecimalTextConverter())();
  TextColumn get currency => text()();
  TextColumn get notes => text().nullable()();
}

// ---------------------------------------------------------------------------
// Sincronização (schema 3).
// ---------------------------------------------------------------------------

/// Unificações feitas pela mesclagem do save (SPEC §10.4): o registro
/// `alias_id` foi absorvido por `canonical_id`. Permite remapear referências
/// que cheguem depois, vindas de saves antigos.
@DataClassName('AssetAliasRow')
@TableIndex(name: 'asset_aliases_hlc', columns: {#hlc})
@TableIndex(name: 'asset_aliases_alias', columns: {#aliasId})
class AssetAliases extends Table with SyncColumns {
  /// `institution`, `account`, `asset`, `fixed_income_terms` ou
  /// `shared_setting`.
  TextColumn get entity => text()();
  TextColumn get aliasId => text()();
  TextColumn get canonicalId => text()();
}

// ---------------------------------------------------------------------------
// Carteiras hipotéticas (sincronizáveis, separadas da carteira real).
// Criadas no schema 3 para o save já levá-las (SPEC §10.4); telas e cálculos
// na F9. `hypo_runs` entra na F9 (DECISIONS D-29).
// ---------------------------------------------------------------------------

@DataClassName('HypoPortfolioRow')
@TableIndex(name: 'hypo_portfolios_hlc', columns: {#hlc})
class HypoPortfolios extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get objective => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get baseCurrency => text()();
  TextColumn get initialCapital => text().map(const DecimalTextConverter())();

  /// `weight` ou `quantity`.
  TextColumn get compositionMode => text()();
  TextColumn get benchmarkJson => text().nullable()();
  TextColumn get rebalanceJson => text()();
  TextColumn get assumptionsJson => text()();
  TextColumn get methodology => text().nullable()();
  TextColumn get archivedAt => text().nullable()();
  TextColumn get duplicatedFromId => text().nullable()();
}

@DataClassName('HypoHoldingRow')
@TableIndex(name: 'hypo_holdings_hlc', columns: {#hlc})
@TableIndex(name: 'hypo_holdings_portfolio', columns: {#portfolioId})
class HypoHoldings extends Table with SyncColumns {
  TextColumn get portfolioId => text().references(HypoPortfolios, #id)();
  TextColumn get assetId => text().references(Assets, #id)();
  TextColumn get weightPct =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get quantity =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get amount =>
      text().map(const DecimalTextConverter()).nullable()();
}

@DataClassName('HypoCashflowRuleRow')
@TableIndex(name: 'hypo_cashflow_rules_hlc', columns: {#hlc})
class HypoCashflowRules extends Table with SyncColumns {
  TextColumn get portfolioId => text().references(HypoPortfolios, #id)();

  /// `contribution` ou `withdrawal`.
  TextColumn get kind => text()();
  TextColumn get frequency => text()();
  TextColumn get amount =>
      text().map(const DecimalTextConverter()).nullable()();
  TextColumn get pct => text().map(const DecimalTextConverter()).nullable()();
  TextColumn get adjustment => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
}

@DataClassName('HypoScenarioRow')
@TableIndex(name: 'hypo_scenarios_hlc', columns: {#hlc})
class HypoScenarios extends Table with SyncColumns {
  /// Nulo para cenários dos simuladores.
  TextColumn get portfolioId =>
      text().nullable().references(HypoPortfolios, #id)();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get assumptionsJson => text()();
}

// ---------------------------------------------------------------------------
// Dispositivo: sincronização e backups (nunca vão no save).
// ---------------------------------------------------------------------------

/// O que este PC sabe de cada dispositivo com quem já trocou saves. Base da
/// detecção de conflitos (SPEC §10.4) e do aviso de sincronização antiga.
@DataClassName('DevSyncPeerRow')
class DevSyncPeers extends Table {
  TextColumn get peerDeviceId => text()();
  TextColumn get peerName => text()();

  /// Maior HLC do último save importado desse dispositivo.
  TextColumn get lastHlcReceived => text()();

  /// Maior HLC deste PC que esse dispositivo confirmou ter recebido (vem no
  /// manifesto dos saves dele).
  TextColumn get lastHlcSent => text().nullable()();
  TextColumn get lastSyncAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {peerDeviceId};
}

/// Histórico de exportações e importações de save.
@DataClassName('DevSyncHistoryRow')
class DevSyncHistory extends Table {
  TextColumn get id => text()();

  /// `export` ou `import`.
  TextColumn get direction => text()();
  TextColumn get peerDeviceId => text().nullable()();
  TextColumn get peerName => text().nullable()();
  TextColumn get fileName => text()();
  TextColumn get at => text()();
  TextColumn get maxHlc => text().nullable()();

  /// Contagens por tabela (JSON). Nunca valores patrimoniais.
  TextColumn get countsJson => text()();

  /// `ok` ou `failed`.
  TextColumn get result => text()();
  TextColumn get message => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Backups conhecidos por este PC (SPEC §11).
@DataClassName('DevBackupRow')
class DevBackups extends Table {
  TextColumn get id => text()();
  TextColumn get path => text()();
  TextColumn get at => text()();

  /// `manual`, `pre-migracao`, `pre-importacao` ou `pre-restauracao`.
  TextColumn get reason => text()();
  IntColumn get schemaVersion => integer()();
  TextColumn get appVersion => text()();
  IntColumn get size => integer()();
  TextColumn get sha256 => text()();

  /// `none` na v1.0. Preparação para o banco criptografado da F5B
  /// (DECISIONS D-24).
  TextColumn get encryption => text().withDefault(const Constant('none'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
