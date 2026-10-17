/// Linhas das tabelas sincronizáveis, no formato do save (SPEC §10.1).
///
/// Todas as colunas das tabelas sincronizáveis são `TEXT` (`docs/BANCO.md`
/// §2), então uma linha é um mapa coluna → texto (ou nulo). É o mesmo formato
/// das linhas de `data/<tabela>.jsonl`.
library;

typedef SyncRow = Map<String, String?>;

/// Campos de sincronização, presentes em toda tabela sincronizável.
const syncColumnNames = [
  'id',
  'created_at',
  'updated_at',
  'hlc',
  'device_id',
  'deleted_at',
];

/// Estrutura de uma tabela sincronizável: colunas na ordem do banco e chaves
/// estrangeiras (coluna → tabela referenciada).
class SyncTableSchema {
  const SyncTableSchema({
    required this.name,
    required this.columns,
    this.foreignKeys = const {},
  });

  final String name;
  final List<String> columns;
  final Map<String, String> foreignKeys;

  /// Colunas de dados (sem os campos de sincronização).
  Iterable<String> get dataColumns =>
      columns.where((c) => !syncColumnNames.contains(c));
}

extension SyncRowFields on SyncRow {
  String get id => this['id']!;
  String get hlc => this['hlc']!;
  bool get isDeleted => this['deleted_at'] != null;
}

/// Tabelas em ordem de dependência: as referenciadas antes das que as
/// referenciam (autorreferências são ignoradas). Empates em ordem alfabética,
/// para o resultado ser determinístico.
List<SyncTableSchema> dependencyOrder(Iterable<SyncTableSchema> tables) {
  final byName = {for (final t in tables) t.name: t};
  final result = <SyncTableSchema>[];
  final done = <String>{};
  final visiting = <String>{};

  void visit(String name) {
    if (done.contains(name) || !byName.containsKey(name)) return;
    if (!visiting.add(name)) {
      throw StateError('Referência circular entre tabelas: $name');
    }
    final table = byName[name]!;
    final deps = table.foreignKeys.values.where((t) => t != name).toList()
      ..sort();
    deps.forEach(visit);
    visiting.remove(name);
    done.add(name);
    result.add(table);
  }

  (byName.keys.toList()..sort()).forEach(visit);
  return result;
}
