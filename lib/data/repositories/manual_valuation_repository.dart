import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../db/app_database.dart';
import 'sync_repository.dart';

/// Preços e saldos informados pelo usuário (`manual_valuations`).
class ManualValuationRepository
    extends SyncRepository<$ManualValuationsTable, ManualValuationRow> {
  ManualValuationRepository(super.db, super.sync);

  @override
  $ManualValuationsTable get table => db.manualValuations;

  Future<String> create(ManualValuation value) => insertRow(_companion(value));

  Future<void> save(ManualValuation value) =>
      updateRow(value.id, _companion(value));

  Future<void> remove(String id) => softDelete(id);

  /// Preços e saldos vivos, do mais recente para o mais antigo.
  Future<List<ManualValuation>> all() async =>
      (await _ordered().get()).map(_toEntity).toList();

  Stream<List<ManualValuation>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  /// Registro vivo do mesmo ativo, conta, tipo e data (para substituir em
  /// vez de duplicar).
  Future<ManualValuation?> findSame({
    required String assetId,
    required String? accountId,
    required ValuationKind kind,
    required LocalDate refDate,
  }) async {
    final query = selectAlive()
      ..where(
        (t) =>
            t.assetId.equals(assetId) &
            t.kind.equals(kind.code) &
            t.refDate.equals(refDate.toString()) &
            (accountId == null
                ? t.accountId.isNull()
                : t.accountId.equals(accountId)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.hlc)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  SimpleSelectStatement<$ManualValuationsTable, ManualValuationRow>
  _ordered() => selectAlive()
    ..orderBy([
      (t) => OrderingTerm.desc(t.refDate),
      (t) => OrderingTerm.desc(t.id),
    ]);

  static ManualValuationsCompanion _companion(ManualValuation v) =>
      ManualValuationsCompanion(
        assetId: Value(v.assetId),
        accountId: Value(v.accountId),
        refDate: Value(v.refDate.toString()),
        kind: Value(v.kind.code),
        value: Value(v.value),
        currency: Value(v.currency),
        notes: Value(v.notes),
      );

  static ManualValuation _toEntity(ManualValuationRow r) => ManualValuation(
    id: r.id,
    assetId: r.assetId,
    accountId: r.accountId,
    refDate: LocalDate.parse(r.refDate),
    kind: byCode(ValuationKind.values, r.kind),
    value: r.value,
    currency: r.currency,
    notes: r.notes,
  );
}
