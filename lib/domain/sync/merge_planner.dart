import '../../core/errors/app_error.dart';
import 'natural_keys.dart';
import 'sync_rows.dart';

/// Lado de um registro numa mesclagem.
enum MergeSide { local, incoming }

typedef RowRef = ({String table, String id});

/// O que cada lado já sabia do outro antes desta importação. Define o que é
/// conflito (SPEC §10.4).
class MergeContext {
  const MergeContext({this.peerKnowsLocalUpTo, this.localKnowsPeerUpTo});

  /// Maior HLC deste PC que o autor do save já tinha recebido (vem no
  /// manifesto). Alterações locais até ele já eram conhecidas pelo autor.
  final String? peerKnowsLocalUpTo;

  /// Maior HLC do autor que este PC recebeu na última importação.
  /// Alterações do autor até ele já eram conhecidas aqui.
  final String? localKnowsPeerUpTo;
}

/// Mesmo registro alterado nos dois PCs desde a última troca entre eles.
class SyncConflict {
  const SyncConflict({
    required this.table,
    required this.local,
    required this.incoming,
    required this.defaultSide,
    required this.chosenSide,
  });

  final String table;
  final SyncRow local;
  final SyncRow incoming;

  /// Padrão: a versão de maior HLC (a mais recente).
  final MergeSide defaultSide;
  final MergeSide chosenSide;

  String get id => local.id;
  RowRef get ref => (table: table, id: id);
}

/// Dois registros com a mesma chave natural unificados num só.
class Unification {
  const Unification({
    required this.table,
    required this.entity,
    required this.canonical,
    required this.absorbed,
  });

  final String table;
  final String entity;

  /// Registro que permanece (o de menor `id`, nos dois PCs).
  final SyncRow canonical;

  /// Registro absorvido: recebe tombstone e vira alias.
  final SyncRow absorbed;
}

/// Operações vivas com mesma data, ativo, tipo, quantidade e preço e ids
/// diferentes. Só sinalizadas, nunca apagadas.
class PossibleDuplicateGroup {
  const PossibleDuplicateGroup(this.operations);

  final List<SyncRow> operations;
}

enum ChangeKind { inserted, updated, deleted }

/// Uma escrita da mesclagem.
///
/// Com [localStamp], o aplicador grava `updated_at`, `hlc` e `device_id` deste
/// PC (e `created_at` em registros novos; `deleted_at` com [markDeleted]):
/// toda alteração feita pela própria mesclagem é uma alteração local, para se
/// propagar e para os dois PCs convergirem. Sem ele, a linha recebida é
/// gravada exatamente como veio.
class PlannedWrite {
  const PlannedWrite({
    required this.table,
    required this.row,
    required this.isNew,
    required this.localStamp,
    required this.markDeleted,
    required this.change,
  });

  final String table;
  final SyncRow row;
  final bool isNew;
  final bool localStamp;
  final bool markDeleted;
  final ChangeKind change;
}

class TableChanges {
  int inserted = 0;
  int updated = 0;
  int deleted = 0;

  int get total => inserted + updated + deleted;

  Map<String, int> toJson() => {
    'inserted': inserted,
    'updated': updated,
    'deleted': deleted,
  };
}

class MergePlan {
  const MergePlan({
    required this.writes,
    required this.changes,
    required this.conflicts,
    required this.unifications,
    required this.duplicates,
    required this.maxIncomingHlc,
  });

  /// Em ordem de dependência das tabelas.
  final List<PlannedWrite> writes;

  /// Alterações por tabela (só tabelas com alguma alteração).
  final Map<String, TableChanges> changes;
  final List<SyncConflict> conflicts;
  final List<Unification> unifications;
  final List<PossibleDuplicateGroup> duplicates;

  /// Maior HLC recebido; o relógio local avança para depois dele.
  final String? maxIncomingHlc;

  int get totalChanges => writes.length;
  bool get isEmpty => writes.isEmpty;
}

/// Calcula a mesclagem de um save com o banco local (SPEC §10.4).
///
/// Regras, nesta ordem:
///
/// 1. **Por `id`:** registro só de um lado é mantido ou adicionado; dos dois
///    lados, vence o maior `hlc` (o texto do HLC já desempata pelo
///    `device_id`). Tombstones se propagam como qualquer alteração.
/// 2. **Conflito:** o registro mudou dos dois lados desde a última troca
///    (pelo [MergeContext]) e as versões diferem. O padrão é a de maior HLC;
///    se o usuário escolher a outra, ela é regravada como alteração local.
/// 3. **Aliases:** referências a registros absorvidos (`asset_aliases`) são
///    remapeadas para o registro que permaneceu, e um registro absorvido que
///    chegue vivo é dobrado nele.
/// 4. **Chave natural:** registros vivos com a mesma chave
///    ([naturalKeySpecs]) são unificados no de menor `id`; o outro recebe
///    tombstone, vira alias e as referências são remapeadas.
/// 5. **Duplicatas de operações** são só sinalizadas.
///
/// Função pura: não lê nem grava nada. Importar o mesmo save de novo produz
/// um plano vazio (idempotência), e um save antigo não desfaz nada.
class MergePlanner {
  MergePlanner(
    Iterable<SyncTableSchema> schemas, {
    List<NaturalKeySpec>? naturalKeys,
  }) : _order = dependencyOrder(schemas),
       _naturalKeys = naturalKeys ?? naturalKeySpecs;

  final List<SyncTableSchema> _order;
  final List<NaturalKeySpec> _naturalKeys;

  MergePlan plan({
    required Map<String, List<SyncRow>> local,
    required Map<String, List<SyncRow>> incoming,
    required MergeContext context,
    required String Function() newId,
    required String now,
    Map<RowRef, MergeSide> resolutions = const {},
  }) {
    final run = _Run(_order, local, newId, now);

    // Aliases primeiro: as regras 3 e 4 dependem deles.
    final tables = [
      ..._order.where((t) => t.name == aliasTable),
      ..._order.where((t) => t.name != aliasTable),
    ];
    String? maxIncoming;
    for (final table in tables) {
      final rows = [...?incoming[table.name]]
        ..sort((a, b) => a.id.compareTo(b.id));
      for (final row in rows) {
        if (maxIncoming == null || row.hlc.compareTo(maxIncoming) > 0) {
          maxIncoming = row.hlc;
        }
        run.mergeById(table, row, context, resolutions);
      }
    }

    run.normalizeAliases();
    for (final spec in _naturalKeys) {
      if (_order.any((t) => t.name == spec.table)) run.unify(spec);
    }
    run.checkReferences();

    return MergePlan(
      writes: run.writes(),
      changes: run.changes(),
      conflicts: run.conflicts,
      unifications: run.unifications,
      duplicates: run.duplicates(),
      maxIncomingHlc: maxIncoming,
    );
  }
}

class _Write {
  bool localStamp = false;
  bool markDeleted = false;
}

class _Run {
  _Run(this.order, Map<String, List<SyncRow>> local, this.newId, this.now)
    : original = {
        for (final t in order)
          t.name: {for (final r in local[t.name] ?? const <SyncRow>[]) r.id: r},
      } {
    for (final t in order) {
      rows[t.name] = Map.of(original[t.name]!);
      pending[t.name] = {};
    }
  }

  final List<SyncTableSchema> order;
  final String Function() newId;
  final String now;
  final Map<String, Map<String, SyncRow>> original;
  final rows = <String, Map<String, SyncRow>>{};
  final pending = <String, Map<String, _Write>>{};
  final aliases = <String, String>{};
  final conflicts = <SyncConflict>[];
  final unifications = <Unification>[];

  static const _localHlc = '\u{10FFFF}';

  void put(
    String table,
    SyncRow row, {
    bool localStamp = false,
    bool markDeleted = false,
  }) {
    rows[table]![row.id] = row;
    final w = pending[table]!.putIfAbsent(row.id, _Write.new);
    w.localStamp |= localStamp;
    w.markDeleted |= markDeleted;
  }

  /// HLC efetivo: uma alteração local desta mesclagem vence tudo.
  String effectiveHlc(String table, String id) =>
      pending[table]![id]?.localStamp ?? false
      ? _localHlc
      : rows[table]![id]!.hlc;

  static bool sameContent(SyncTableSchema t, SyncRow a, SyncRow b) {
    if (a.isDeleted != b.isDeleted) return false;
    return t.dataColumns.every((c) => a[c] == b[c]);
  }

  // -- 1 e 2: por id, com conflitos ------------------------------------------

  void mergeById(
    SyncTableSchema table,
    SyncRow incoming,
    MergeContext context,
    Map<RowRef, MergeSide> resolutions,
  ) {
    final local = rows[table.name]![incoming.id];
    if (local == null) {
      put(table.name, Map.of(incoming));
      return;
    }
    final cmp = incoming.hlc.compareTo(local.hlc);
    if (cmp == 0) return;
    final incomingNewer = cmp > 0;
    var side = incomingNewer ? MergeSide.incoming : MergeSide.local;

    final unseenByPeer =
        context.peerKnowsLocalUpTo == null ||
        local.hlc.compareTo(context.peerKnowsLocalUpTo!) > 0;
    final unseenLocally =
        context.localKnowsPeerUpTo == null ||
        incoming.hlc.compareTo(context.localKnowsPeerUpTo!) > 0;
    if (unseenByPeer && unseenLocally && !sameContent(table, local, incoming)) {
      final defaultSide = side;
      side = resolutions[(table: table.name, id: incoming.id)] ?? defaultSide;
      conflicts.add(
        SyncConflict(
          table: table.name,
          local: local,
          incoming: incoming,
          defaultSide: defaultSide,
          chosenSide: side,
        ),
      );
    }

    switch ((side, incomingNewer)) {
      case (MergeSide.incoming, true):
        put(table.name, Map.of(incoming));
      case (MergeSide.incoming, false):
        // Versão recebida, mais antiga, escolhida pelo usuário: regrava como
        // alteração local para vencer a outra nos dois PCs.
        put(table.name, Map.of(incoming), localStamp: true);
      case (MergeSide.local, true):
        put(table.name, Map.of(local), localStamp: true);
      case (MergeSide.local, false):
        break;
    }
  }

  // -- 3: aliases --------------------------------------------------------------

  void loadAliases() {
    for (final row in rows[aliasTable]?.values ?? const <SyncRow>[]) {
      if (row.isDeleted) continue;
      final alias = row['alias_id'];
      final canonical = row['canonical_id'];
      if (alias != null && canonical != null && alias != canonical) {
        aliases[alias] = canonical;
      }
    }
  }

  /// Segue a cadeia de aliases (a → b → c) até o registro final.
  String resolve(String id) {
    var current = id;
    for (var i = 0; i < 32 && aliases.containsKey(current); i++) {
      current = aliases[current]!;
    }
    return current;
  }

  void normalizeAliases() {
    loadAliases();
    for (var pass = 0; pass < 8; pass++) {
      if (!_normalizePass()) return;
    }
  }

  bool _normalizePass() {
    var changed = false;
    for (final table in order) {
      final byId = rows[table.name]!;
      for (final id in byId.keys.toList()..sort()) {
        final row = byId[id]!;
        if (row.isDeleted) continue;
        if (aliases.containsKey(id) && _fold(table, row)) {
          changed = true;
          continue;
        }
        SyncRow? remapped;
        for (final MapEntry(key: column) in table.foreignKeys.entries) {
          final value = row[column];
          if (value == null || !aliases.containsKey(value)) continue;
          remapped ??= Map.of(row);
          remapped[column] = resolve(value);
        }
        if (remapped != null) {
          put(table.name, remapped, localStamp: true);
          changed = true;
        }
      }
    }
    return changed;
  }

  /// Dobra o registro absorvido [row] no registro que permaneceu: se ele for
  /// mais recente, os dados dele passam para o canônico. Depois recebe
  /// tombstone.
  bool _fold(SyncTableSchema table, SyncRow row) {
    final canonicalId = resolve(row.id);
    final canonical = rows[table.name]![canonicalId];
    // Alias para um registro desconhecido: nada a dobrar.
    if (canonical == null) return false;
    if (effectiveHlc(
              table.name,
              row.id,
            ).compareTo(effectiveHlc(table.name, canonicalId)) >
            0 &&
        !sameContent(table, canonical, {...row, 'deleted_at': null})) {
      final merged = Map.of(canonical);
      for (final c in table.dataColumns) {
        merged[c] = row[c];
      }
      put(table.name, merged, localStamp: true);
    }
    put(
      table.name,
      {...row, 'deleted_at': now},
      localStamp: true,
      markDeleted: true,
    );
    return true;
  }

  // -- 4: chave natural ------------------------------------------------------

  void unify(NaturalKeySpec spec) {
    final groups = <String, List<String>>{};
    for (final row in rows[spec.table]!.values) {
      if (row.isDeleted) continue;
      groups.putIfAbsent(spec.keyOf(row), () => []).add(row.id);
    }
    var created = false;
    for (final ids in groups.values) {
      if (ids.length < 2) continue;
      ids.sort();
      final canonical = ids.first;
      for (final absorbed in ids.skip(1)) {
        unifications.add(
          Unification(
            table: spec.table,
            entity: spec.entity,
            canonical: rows[spec.table]![canonical]!,
            absorbed: rows[spec.table]![absorbed]!,
          ),
        );
        aliases[absorbed] = canonical;
        if (rows.containsKey(aliasTable)) {
          put(aliasTable, {
            'id': newId(),
            'created_at': now,
            'updated_at': now,
            'hlc': '',
            'device_id': '',
            'deleted_at': null,
            'entity': spec.entity,
            'alias_id': absorbed,
            'canonical_id': canonical,
          }, localStamp: true);
        }
        created = true;
      }
    }
    if (created) {
      for (var pass = 0; pass < 8; pass++) {
        if (!_normalizePass()) break;
      }
    }
  }

  // -- Verificações e resultado ----------------------------------------------

  /// Toda referência precisa apontar para um registro existente (vivo ou
  /// tombstone). Um save que referencia registros ausentes é recusado.
  void checkReferences() {
    for (final table in order) {
      for (final row in rows[table.name]!.values) {
        for (final MapEntry(key: column, value: target)
            in table.foreignKeys.entries) {
          final value = row[column];
          if (value == null) continue;
          if (!(rows[target]?.containsKey(value) ?? false)) {
            throw DataError(
              'O save está incompleto: um registro de ${table.name} '
              'referencia um registro inexistente de $target ($column).',
            );
          }
        }
      }
    }
  }

  List<PlannedWrite> writes() => [
    for (final table in order)
      for (final id in pending[table.name]!.keys.toList()..sort())
        PlannedWrite(
          table: table.name,
          row: rows[table.name]![id]!,
          isNew: original[table.name]![id] == null,
          localStamp: pending[table.name]![id]!.localStamp,
          markDeleted: pending[table.name]![id]!.markDeleted,
          change: _changeOf(table.name, id),
        ),
  ];

  ChangeKind _changeOf(String table, String id) {
    final before = original[table]![id];
    final after = rows[table]![id]!;
    if (before == null) {
      return after.isDeleted ? ChangeKind.deleted : ChangeKind.inserted;
    }
    if (!before.isDeleted && after.isDeleted) return ChangeKind.deleted;
    return ChangeKind.updated;
  }

  Map<String, TableChanges> changes() {
    final result = <String, TableChanges>{};
    for (final table in order) {
      for (final id in pending[table.name]!.keys) {
        final c = result.putIfAbsent(table.name, TableChanges.new);
        switch (_changeOf(table.name, id)) {
          case ChangeKind.inserted:
            c.inserted++;
          case ChangeKind.updated:
            c.updated++;
          case ChangeKind.deleted:
            c.deleted++;
        }
      }
    }
    return result;
  }

  /// Grupos de operações vivas iguais (data, ativo, tipo, quantidade e
  /// preço; para movimentos só de caixa, também conta e valor) em que pelo
  /// menos uma chegou ou mudou nesta mesclagem.
  List<PossibleDuplicateGroup> duplicates() {
    final ops = rows['operations'];
    if (ops == null) return const [];
    final touched = pending['operations']!.keys.toSet();
    final groups = <String, List<SyncRow>>{};
    for (final op in ops.values) {
      if (op.isDeleted) continue;
      final asset = op['asset_id'];
      final key = [
        op['trade_date'],
        asset,
        op['type'],
        op['quantity'],
        op['unit_price'],
        if (asset == null) ...[op['account_id'], op['gross_amount']],
      ].join('|');
      groups.putIfAbsent(key, () => []).add(op);
    }
    return [
      for (final g in groups.values)
        if (g.length > 1 && g.any((op) => touched.contains(op.id)))
          PossibleDuplicateGroup(g..sort((a, b) => a.id.compareTo(b.id))),
    ];
  }
}
