import 'package:drift/drift.dart';

import '../../core/errors/app_error.dart';
import '../db/app_database.dart';
import '../db/tables.dart';
import '../sync/sync_context.dart';

/// Repositório base das tabelas sincronizáveis (`docs/BANCO.md` §2).
///
/// Toda escrita passa por aqui, que preenche `id`, `created_at`,
/// `updated_at`, `hlc`, `device_id` e `deleted_at`. Valores que quem chama
/// colocar nesses campos são ignorados.
///
/// Não existe exclusão física: [softDelete] grava um tombstone, que se
/// propaga pelo save como qualquer outra alteração.
abstract class SyncRepository<T extends SyncColumns, D> {
  SyncRepository(this.db, this.sync);

  final AppDatabase db;
  final SyncContext sync;

  TableInfo<T, D> get table;

  static const syncColumnNames = {
    'id',
    'created_at',
    'updated_at',
    'hlc',
    'device_id',
    'deleted_at',
  };

  /// Insere um registro novo e devolve o `id` gerado.
  Future<String> insertRow(Insertable<D> values) {
    return db.transaction(() async {
      final stamp = await sync.nextStamp();
      final id = sync.newId();
      final columns = _withoutSyncColumns(values)
        ..addAll({
          'id': Variable<String>(id),
          'created_at': Variable<String>(stamp.at),
          'updated_at': Variable<String>(stamp.at),
          'hlc': Variable<String>(stamp.hlc.toString()),
          'device_id': Variable<String>(stamp.deviceId),
          'deleted_at': const Variable<String>(null),
        });
      await db.into(table).insert(RawValuesInsertable<D>(columns));
      return id;
    });
  }

  /// Altera os campos informados em [values] do registro [id].
  ///
  /// Lança [DataError] se o registro não existir ou já estiver excluído.
  Future<void> updateRow(String id, Insertable<D> values) {
    return db.transaction(() async {
      await _requireAlive(id);
      final stamp = await sync.nextStamp();
      final columns = _withoutSyncColumns(values)
        ..addAll({
          'updated_at': Variable<String>(stamp.at),
          'hlc': Variable<String>(stamp.hlc.toString()),
          'device_id': Variable<String>(stamp.deviceId),
        });
      await (db.update(
        table,
      )..where((t) => t.id.equals(id))).write(RawValuesInsertable<D>(columns));
    });
  }

  /// Exclusão lógica: grava o tombstone e avança o HLC.
  ///
  /// Lança [DataError] se o registro não existir ou já estiver excluído.
  Future<void> softDelete(String id) {
    return db.transaction(() async {
      await _requireAlive(id);
      final stamp = await sync.nextStamp();
      await (db.update(table)..where((t) => t.id.equals(id))).write(
        RawValuesInsertable<D>({
          'updated_at': Variable<String>(stamp.at),
          'hlc': Variable<String>(stamp.hlc.toString()),
          'device_id': Variable<String>(stamp.deviceId),
          'deleted_at': Variable<String>(stamp.at),
        }),
      );
    });
  }

  /// Registro pelo `id`. Excluídos só vêm com [includeDeleted].
  Future<D?> findRowById(String id, {bool includeDeleted = false}) {
    final query = db.select(table)..where((t) => t.id.equals(id));
    if (!includeDeleted) query.where((t) => t.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  /// Consulta dos registros não excluídos.
  SimpleSelectStatement<T, D> selectAlive() =>
      db.select(table)..where((t) => t.deletedAt.isNull());

  /// Todos os registros, inclusive tombstones, em ordem de HLC (base da
  /// exportação do save, F5).
  Future<List<D>> allRowsIncludingDeleted() =>
      (db.select(table)..orderBy([(t) => OrderingTerm.asc(t.hlc)])).get();

  Future<void> _requireAlive(String id) async {
    final row = await findRowById(id);
    if (row == null) {
      throw DataError(
        'Registro inexistente ou excluído em ${table.actualTableName}',
        cause: id,
      );
    }
  }

  Map<String, Expression<Object>> _withoutSyncColumns(Insertable<D> values) {
    return Map.of(values.toColumns(false))
      ..removeWhere((name, _) => syncColumnNames.contains(name));
  }
}
