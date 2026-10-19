import 'package:drift/drift.dart';

import '../../core/errors/app_error.dart';
import '../../domain/sync/invsave_codec.dart';
import '../db/app_database.dart';
import '../repositories/market_repository.dart';

/// Pasta `market/` do save (SPEC §10.1; DECISIONS D-36): lê e mescla as
/// tabelas `mkt_`, que não são sincronizáveis (sem HLC nem tombstone).
///
/// A mesclagem é por chave natural (a chave primária de cada tabela): um
/// registro novo é inserido; um que já existe só é trocado pelo recebido se
/// a coleta recebida for mais recente. Nada é apagado.
class MarketSaveGateway {
  const MarketSaveGateway(this._db);

  final AppDatabase _db;

  Map<String, TableInfo<Table, dynamic>> get _tables => {
    for (final t in MarketRepository.marketTables(_db)) t.actualTableName: t,
  };

  /// Todas as linhas das tabelas `mkt_` com algum registro.
  Future<MarketRows> readAll() async {
    final result = <String, List<Map<String, String?>>>{};
    for (final MapEntry(key: name, value: table) in _tables.entries) {
      final columns = [for (final c in table.$columns) c.name];
      final rows = await _db
          .customSelect(
            'SELECT ${columns.map((c) => '"$c"').join(', ')} FROM "$name" '
            'ORDER BY ${table.$primaryKey.map((c) => '"${c.name}"').join(', ')}',
            readsFrom: {table},
          )
          .get();
      if (rows.isEmpty) continue;
      result[name] = [
        for (final r in rows)
          {for (final c in columns) c: r.data[c] as String?},
      ];
    }
    return result;
  }

  /// Confere se cada tabela existe e se cada linha tem exatamente as colunas
  /// dela, com a chave preenchida. Lança [DataError] na primeira falha.
  void validate(MarketRows incoming) {
    final tables = _tables;
    for (final MapEntry(key: name, value: rows) in incoming.entries) {
      final table = tables[name];
      if (table == null) {
        throw DataError(
          'O save tem dados de mercado de uma tabela desconhecida ($name).',
        );
      }
      final expected = {for (final c in table.$columns) c.name};
      final required = {
        for (final c in table.$columns)
          if (!c.$nullable) c.name,
      };
      for (final row in rows) {
        if (row.length != expected.length ||
            !row.keys.toSet().containsAll(expected)) {
          throw DataError(
            'O save tem dados de mercado de $name com colunas diferentes das '
            'esperadas.',
          );
        }
        if (required.any((c) => row[c] == null)) {
          throw DataError(
            'O save tem dados de mercado de $name com campos obrigatórios '
            'vazios.',
          );
        }
      }
    }
  }

  /// Mescla [incoming]. Deve rodar dentro da transação da importação.
  Future<void> merge(MarketRows incoming) async {
    validate(incoming);
    final tables = _tables;
    await _db.batch((b) {
      for (final MapEntry(key: name, value: rows) in incoming.entries) {
        if (rows.isEmpty) continue;
        final table = tables[name]!;
        final columns = [for (final c in table.$columns) c.name];
        final keys = [for (final c in table.$primaryKey) c.name];
        final updates = [
          for (final c in columns)
            if (!keys.contains(c)) '"$c" = excluded."$c"',
        ];
        final sql =
            'INSERT INTO "$name" (${columns.map((c) => '"$c"').join(', ')}) '
            'VALUES (${List.filled(columns.length, '?').join(', ')}) '
            'ON CONFLICT (${keys.map((c) => '"$c"').join(', ')}) DO UPDATE '
            'SET ${updates.join(', ')} '
            'WHERE excluded."collected_at" > "$name"."collected_at"';
        for (final row in rows) {
          b.customStatement(sql, [for (final c in columns) row[c]]);
        }
      }
    });
  }
}
