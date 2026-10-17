import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../db/app_database.dart';
import 'sync_repository.dart';

/// Catálogo de ativos (`assets`).
class AssetRepository extends SyncRepository<$AssetsTable, AssetRow> {
  AssetRepository(super.db, super.sync);

  @override
  $AssetsTable get table => db.assets;

  Future<String> create(Asset value) => insertRow(_companion(value));

  Future<void> save(Asset value) => updateRow(value.id, _companion(value));

  Future<void> remove(String id) => softDelete(id);

  Future<Asset?> byId(String id) async {
    final row = await findRowById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<List<Asset>> all() async =>
      (await _ordered().get()).map(_toEntity).toList();

  Stream<List<Asset>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  /// Ativos vivos com o mesmo símbolo e mercado.
  Future<List<Asset>> findBySymbol(String symbol, Market market) async {
    final query = selectAlive()
      ..where(
        (t) =>
            t.symbol.equals(symbol.trim().toUpperCase()) &
            t.market.equals(market.code),
      );
    return (await query.get()).map(_toEntity).toList();
  }

  SimpleSelectStatement<$AssetsTable, AssetRow> _ordered() =>
      selectAlive()..orderBy([(t) => OrderingTerm.asc(t.symbol)]);

  static AssetsCompanion _companion(Asset v) => AssetsCompanion(
    symbol: Value(v.symbol.trim().toUpperCase()),
    market: Value(v.market.code),
    assetClass: Value(v.assetClass.code),
    name: Value(v.name.trim()),
    currency: Value(v.currency),
    country: Value(v.country),
    isin: Value(v.isin),
    sector: Value(v.sector),
    segment: Value(v.segment),
    liquidity: Value(v.liquidity?.code),
    priceSource: Value(v.priceSource.code),
    notes: Value(v.notes),
  );

  static Asset _toEntity(AssetRow r) => Asset(
    id: r.id,
    symbol: r.symbol,
    market: byCode(Market.values, r.market),
    assetClass: byCode(AssetClass.values, r.assetClass),
    name: r.name,
    currency: r.currency,
    country: r.country,
    isin: r.isin,
    sector: r.sector,
    segment: r.segment,
    liquidity: r.liquidity == null
        ? null
        : byCode(Liquidity.values, r.liquidity!),
    priceSource: byCode(PriceSource.values, r.priceSource),
    notes: r.notes,
  );
}

/// Características de renda fixa (`fixed_income_terms`), uma por ativo.
class FixedIncomeTermsRepository
    extends SyncRepository<$FixedIncomeTermsTable, FixedIncomeTermsRow> {
  FixedIncomeTermsRepository(super.db, super.sync);

  @override
  $FixedIncomeTermsTable get table => db.fixedIncomeTerms;

  /// Cria ou altera as características do ativo `terms.assetId`.
  Future<String> put(FixedIncomeTerms terms) {
    return db.transaction(() async {
      final existing = await _aliveFor(terms.assetId);
      if (existing == null) return insertRow(_companion(terms));
      await updateRow(existing.id, _companion(terms));
      return existing.id;
    });
  }

  /// Exclui (tombstone) as características do ativo, se houver.
  Future<void> removeFor(String assetId) async {
    await db.transaction(() async {
      final existing = await _aliveFor(assetId);
      if (existing != null) await softDelete(existing.id);
    });
  }

  Future<FixedIncomeTerms?> forAsset(String assetId) async {
    final row = await _aliveFor(assetId);
    return row == null ? null : _toEntity(row);
  }

  Future<List<FixedIncomeTerms>> all() async =>
      (await selectAlive().get()).map(_toEntity).toList();

  /// Registro vivo do ativo. Se a mesclagem deixar dois, vale o de maior HLC
  /// até a unificação (F5).
  Future<FixedIncomeTermsRow?> _aliveFor(String assetId) {
    final query = selectAlive()
      ..where((t) => t.assetId.equals(assetId))
      ..orderBy([(t) => OrderingTerm.desc(t.hlc)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  static FixedIncomeTermsCompanion _companion(FixedIncomeTerms v) =>
      FixedIncomeTermsCompanion(
        assetId: Value(v.assetId),
        product: Value(v.product.code),
        issuer: Value(v.issuer),
        indexer: Value(v.indexer.code),
        rate: Value(v.rate),
        spread: Value(v.spread),
        dayCount: Value(v.dayCount.code),
        issueDate: Value(v.issueDate.toString()),
        maturityDate: Value(v.maturityDate.toString()),
        graceUntil: Value(v.graceUntil?.toString()),
        liquidity: Value(v.liquidity.code),
        taxRegime: Value(v.taxRegime.code),
        costsNotes: Value(v.costsNotes),
      );

  static FixedIncomeTerms _toEntity(FixedIncomeTermsRow r) => FixedIncomeTerms(
    id: r.id,
    assetId: r.assetId,
    product: byCode(FixedIncomeProduct.values, r.product),
    issuer: r.issuer,
    indexer: byCode(Indexer.values, r.indexer),
    rate: r.rate,
    spread: r.spread,
    dayCount: byCode(DayCount.values, r.dayCount),
    issueDate: LocalDate.parse(r.issueDate),
    maturityDate: LocalDate.parse(r.maturityDate),
    graceUntil: r.graceUntil == null ? null : LocalDate.parse(r.graceUntil!),
    liquidity: byCode(Liquidity.values, r.liquidity),
    taxRegime: byCode(TaxRegime.values, r.taxRegime),
    costsNotes: r.costsNotes,
  );
}
