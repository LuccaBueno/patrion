import 'package:drift/drift.dart';

import '../../core/errors/app_error.dart';
import '../../domain/sync/merge_planner.dart';
import '../../domain/sync/sync_rows.dart';
import '../db/app_database.dart';
import 'sync_context.dart';

/// Acesso genérico às tabelas sincronizáveis, para o save (SPEC §10).
///
/// Sincronizável é toda tabela que tem os campos de sincronização
/// (`SyncColumns`); as `dev_` nunca entram. As chaves estrangeiras vêm do
/// próprio SQLite (`PRAGMA foreign_key_list`), então uma tabela nova entra no
/// save sem código extra.
///
/// É a única exceção ao "toda escrita passa pelo `SyncRepository`": a
/// mesclagem grava linhas recebidas exatamente como vieram (com o HLC do
/// autor) e carimba com o HLC local só o que ela mesma altera.
class SyncTablesGateway {
  SyncTablesGateway(this._db, SyncContext this._sync);

  SyncTablesGateway._(this._db) : _sync = null;

  final AppDatabase _db;
  final SyncContext? _sync;

  Future<T> transaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

  /// Tabelas sincronizáveis, pelo nome.
  Future<Map<String, SyncTableSchema>> schemas() async {
    final result = <String, SyncTableSchema>{};
    for (final table in _db.allTables) {
      final name = table.actualTableName;
      final columns = [for (final c in table.$columns) c.name];
      if (name.startsWith('dev_') || !syncColumnNames.every(columns.contains)) {
        continue;
      }
      final fks = await _db
          .customSelect('PRAGMA foreign_key_list("$name")')
          .get();
      result[name] = SyncTableSchema(
        name: name,
        columns: columns,
        foreignKeys: {
          for (final fk in fks)
            fk.read<String>('from'): fk.read<String>('table'),
        },
      );
    }
    return result;
  }

  /// Todos os registros (inclusive tombstones), por tabela, em ordem de id.
  Future<Map<String, List<SyncRow>>> readAll(
    Map<String, SyncTableSchema> schemas,
  ) async {
    final result = <String, List<SyncRow>>{};
    for (final schema in schemas.values) {
      final rows = await _db
          .customSelect(
            'SELECT ${schema.columns.map((c) => '"$c"').join(', ')} '
            'FROM "${schema.name}" ORDER BY id',
          )
          .get();
      result[schema.name] = [for (final r in rows) _toSyncRow(r, schema)];
    }
    return result;
  }

  /// Maior HLC entre todos os registros sincronizáveis de [db] (usado ao
  /// restaurar um backup, antes de existir o contexto de sincronização).
  static Future<String?> maxHlcOf(AppDatabase db) async =>
      SyncTablesGateway._(db).maxHlc(await SyncTablesGateway._(db).schemas());

  /// Maior HLC entre todos os registros sincronizáveis.
  Future<String?> maxHlc(Map<String, SyncTableSchema> schemas) async {
    String? max;
    for (final name in schemas.keys) {
      final row = await _db
          .customSelect('SELECT MAX(hlc) AS m FROM "$name"')
          .getSingle();
      final value = row.read<String?>('m');
      if (value != null && (max == null || value.compareTo(max) > 0)) {
        max = value;
      }
    }
    return max;
  }

  /// Grava o plano. Deve rodar dentro de [transaction]: as chaves
  /// estrangeiras só são conferidas no fim dela (`defer_foreign_keys`), então
  /// a ordem das linhas não importa e uma falha desfaz tudo.
  ///
  /// [beforeWrite] existe para os testes simularem uma falha no meio.
  Future<void> apply(
    MergePlan plan,
    Map<String, SyncTableSchema> schemas, {
    void Function(int index)? beforeWrite,
  }) async {
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    for (final (index, write) in plan.writes.indexed) {
      beforeWrite?.call(index);
      final schema = schemas[write.table]!;
      final row = Map.of(write.row);
      if (write.localStamp) {
        final stamp = await _sync!.nextStamp();
        row
          ..['updated_at'] = stamp.at
          ..['hlc'] = stamp.hlc.toString()
          ..['device_id'] = stamp.deviceId;
        if (write.isNew) row['created_at'] = stamp.at;
        if (write.markDeleted) row['deleted_at'] = stamp.at;
      }
      final columns = schema.columns;
      final quoted = columns.map((c) => '"$c"').join(', ');
      final updates = columns
          .where((c) => c != 'id')
          .map((c) => '"$c" = excluded."$c"')
          .join(', ');
      await _db.customInsert(
        'INSERT INTO "${schema.name}" ($quoted) '
        'VALUES (${List.filled(columns.length, '?').join(', ')}) '
        'ON CONFLICT(id) DO UPDATE SET $updates',
        variables: [for (final c in columns) Variable<String>(row[c])],
      );
    }
  }

  static SyncRow _toSyncRow(QueryRow row, SyncTableSchema schema) {
    final result = <String, String?>{};
    for (final c in schema.columns) {
      final value = row.data[c];
      if (value != null && value is! String) {
        throw DataError('Valor não textual em ${schema.name}.$c');
      }
      result[c] = value as String?;
    }
    return result;
  }
}
