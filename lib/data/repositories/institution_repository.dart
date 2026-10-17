import 'package:drift/drift.dart';

import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../db/app_database.dart';
import 'sync_repository.dart';

/// Instituições (`institutions`).
///
/// O `id` das entidades recebidas em `create` é ignorado: quem gera é o
/// repositório base.
class InstitutionRepository
    extends SyncRepository<$InstitutionsTable, InstitutionRow> {
  InstitutionRepository(super.db, super.sync);

  @override
  $InstitutionsTable get table => db.institutions;

  Future<String> create(Institution value) => insertRow(_companion(value));

  Future<void> save(Institution value) =>
      updateRow(value.id, _companion(value));

  Future<void> remove(String id) => softDelete(id);

  Future<List<Institution>> all() async =>
      (await _ordered().get()).map(_toEntity).toList();

  Stream<List<Institution>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  /// Instituições vivas com o mesmo nome normalizado.
  Future<List<Institution>> findByNameKey(String nameKey) async {
    final query = selectAlive()..where((t) => t.nameKey.equals(nameKey));
    return (await query.get()).map(_toEntity).toList();
  }

  SimpleSelectStatement<$InstitutionsTable, InstitutionRow> _ordered() =>
      selectAlive()..orderBy([(t) => OrderingTerm.asc(t.nameKey)]);

  static InstitutionsCompanion _companion(Institution v) =>
      InstitutionsCompanion(
        name: Value(v.name.trim()),
        nameKey: Value(v.nameKey),
        kind: Value(v.kind.code),
        country: Value(v.country),
        notes: Value(v.notes),
      );

  static Institution _toEntity(InstitutionRow r) => Institution(
    id: r.id,
    name: r.name,
    kind: byCode(InstitutionKind.values, r.kind),
    country: r.country,
    notes: r.notes,
  );
}

/// Contas (`accounts`).
class AccountRepository extends SyncRepository<$AccountsTable, AccountRow> {
  AccountRepository(super.db, super.sync);

  @override
  $AccountsTable get table => db.accounts;

  /// Cria a conta. Arquivada só se `value.archived`, com o instante [at].
  Future<String> create(Account value, {String? at}) =>
      insertRow(_companion(value, at));

  /// Grava os dados da conta. [archivedAt] é o instante do arquivamento
  /// (nulo para conta ativa).
  Future<void> save(Account value, {required String? archivedAt}) =>
      updateRow(value.id, _companion(value, archivedAt));

  Future<void> remove(String id) => softDelete(id);

  Future<Account?> byId(String id) async {
    final row = await findRowById(id);
    return row == null ? null : _toEntity(row);
  }

  /// Instante do arquivamento da conta [id], se arquivada.
  Future<String?> archivedAt(String id) async =>
      (await findRowById(id))?.archivedAt;

  Future<List<Account>> all() async =>
      (await _ordered().get()).map(_toEntity).toList();

  Stream<List<Account>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  /// Contas vivas da instituição [institutionId].
  Future<List<Account>> ofInstitution(String institutionId) async {
    final query = selectAlive()
      ..where((t) => t.institutionId.equals(institutionId));
    return (await query.get()).map(_toEntity).toList();
  }

  SimpleSelectStatement<$AccountsTable, AccountRow> _ordered() =>
      selectAlive()..orderBy([(t) => OrderingTerm.asc(t.name)]);

  static AccountsCompanion _companion(Account v, String? archivedAt) =>
      AccountsCompanion(
        institutionId: Value(v.institutionId),
        name: Value(v.name.trim()),
        kind: Value(v.kind.code),
        currency: Value(v.currency),
        archivedAt: Value(archivedAt),
      );

  static Account _toEntity(AccountRow r) => Account(
    id: r.id,
    institutionId: r.institutionId,
    name: r.name,
    kind: byCode(AccountKind.values, r.kind),
    currency: r.currency,
    archived: r.archivedAt != null,
  );
}
