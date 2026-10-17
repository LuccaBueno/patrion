import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../../domain/portfolio/operation_type.dart';
import '../db/app_database.dart';
import 'sync_repository.dart';

/// Operações da carteira real (`operations`).
class OperationRepository
    extends SyncRepository<$OperationsTable, OperationRow> {
  OperationRepository(super.db, super.sync);

  @override
  $OperationsTable get table => db.operations;

  Future<String> create(OperationDraft value) => insertRow(_companion(value));

  /// Regrava todos os campos da operação [id] com [value].
  Future<void> save(String id, OperationDraft value) =>
      updateRow(id, _companion(value));

  Future<void> remove(String id) => softDelete(id);

  Future<Operation?> byId(String id) async {
    final row = await findRowById(id);
    return row == null ? null : _toEntity(row);
  }

  /// Operações vivas, da mais recente para a mais antiga.
  Future<List<Operation>> all() async =>
      (await _ordered().get()).map(_toEntity).toList();

  Stream<List<Operation>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  /// Operações vivas das duas pontas de uma transferência.
  Future<List<Operation>> ofTransferGroup(String groupId) async {
    final query = selectAlive()
      ..where((t) => t.transferGroupId.equals(groupId));
    return (await query.get()).map(_toEntity).toList();
  }

  /// Existe alguma operação viva na conta?
  Future<bool> anyForAccount(String accountId) =>
      _exists((t) => t.accountId.equals(accountId));

  /// Existe alguma operação viva do ativo?
  Future<bool> anyForAsset(String assetId) =>
      _exists((t) => t.assetId.equals(assetId));

  Future<bool> _exists(
    Expression<bool> Function($OperationsTable t) condition,
  ) async {
    final query = selectAlive()
      ..where(condition)
      ..limit(1);
    return (await query.getSingleOrNull()) != null;
  }

  SimpleSelectStatement<$OperationsTable, OperationRow> _ordered() =>
      selectAlive()..orderBy([
        (t) => OrderingTerm.desc(t.tradeDate),
        (t) => OrderingTerm.desc(t.id),
      ]);

  static OperationsCompanion _companion(OperationDraft v) =>
      OperationsCompanion(
        accountId: Value(v.accountId),
        assetId: Value(v.assetId),
        type: Value(v.type.code),
        tradeDate: Value(v.tradeDate.toString()),
        settlementDate: Value(v.settlementDate?.toString()),
        quantity: Value(v.quantity),
        unitPrice: Value(v.unitPrice),
        grossAmount: Value(v.grossAmount),
        fees: Value(v.fees),
        taxes: Value(v.taxes),
        currency: Value(v.currency),
        fxRate: Value(v.fxRate),
        ratioFrom: Value(v.ratioFrom),
        ratioTo: Value(v.ratioTo),
        transferGroupId: Value(v.transferGroupId),
        relatedOperationId: Value(v.relatedOperationId),
        justification: Value(v.justification),
        notes: Value(v.notes),
        origin: Value(v.origin.code),
      );

  static Operation _toEntity(OperationRow r) => Operation(
    id: r.id,
    accountId: r.accountId,
    assetId: r.assetId,
    type: byCode(OperationType.values, r.type),
    tradeDate: LocalDate.parse(r.tradeDate),
    settlementDate: r.settlementDate == null
        ? null
        : LocalDate.parse(r.settlementDate!),
    quantity: r.quantity,
    unitPrice: r.unitPrice,
    grossAmount: r.grossAmount,
    fees: r.fees,
    taxes: r.taxes,
    currency: r.currency,
    fxRate: r.fxRate,
    ratioFrom: r.ratioFrom,
    ratioTo: r.ratioTo,
    transferGroupId: r.transferGroupId,
    relatedOperationId: r.relatedOperationId,
    justification: r.justification,
    notes: r.notes,
    origin: byCode(OperationOrigin.values, r.origin),
  );
}
