import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/domain/sync/merge_planner.dart';
import 'package:patrion/domain/sync/natural_keys.dart';
import 'package:patrion/domain/sync/sync_rows.dart';

/// Regras da mesclagem (SPEC §10.4), sobre linhas em memória.
void main() {
  const assets = SyncTableSchema(
    name: 'assets',
    columns: [...syncColumnNames, 'symbol', 'market', 'asset_class'],
  );
  const operations = SyncTableSchema(
    name: 'operations',
    columns: [
      ...syncColumnNames,
      'asset_id',
      'account_id',
      'type',
      'trade_date',
      'quantity',
      'unit_price',
      'gross_amount',
    ],
    foreignKeys: {'asset_id': 'assets'},
  );
  const aliases = SyncTableSchema(
    name: aliasTable,
    columns: [...syncColumnNames, 'entity', 'alias_id', 'canonical_id'],
  );
  final planner = MergePlanner([operations, assets, aliases]);

  String hlc(int ms, [String device = 'dev-a']) =>
      '${ms.toString().padLeft(15, '0')}-00000-$device';

  SyncRow asset(
    String id,
    int ms, {
    String symbol = 'PETR4',
    bool deleted = false,
  }) => {
    'id': id,
    'created_at': 'c',
    'updated_at': 'u',
    'hlc': hlc(ms),
    'device_id': 'dev-a',
    'deleted_at': deleted ? 'd' : null,
    'symbol': symbol,
    'market': 'B3',
    'asset_class': 'stock_br',
  };

  SyncRow op(String id, int ms, {String asset = 'a1', String qty = '10'}) => {
    'id': id,
    'created_at': 'c',
    'updated_at': 'u',
    'hlc': hlc(ms),
    'device_id': 'dev-a',
    'deleted_at': null,
    'asset_id': asset,
    'account_id': 'acc',
    'type': 'buy',
    'trade_date': '2026-01-05',
    'quantity': qty,
    'unit_price': '10',
    'gross_amount': null,
  };

  var counter = 0;
  MergePlan plan(
    Map<String, List<SyncRow>> local,
    Map<String, List<SyncRow>> incoming, {
    MergeContext context = const MergeContext(),
    Map<RowRef, MergeSide> resolutions = const {},
  }) => planner.plan(
    local: local,
    incoming: incoming,
    context: context,
    resolutions: resolutions,
    newId: () => 'novo-${counter++}',
    now: 'agora',
  );

  test('ordem de dependência: referenciadas antes', () {
    expect(dependencyOrder([operations, assets, aliases]).map((t) => t.name), [
      aliasTable,
      'assets',
      'operations',
    ]);
  });

  test('registro só de um lado é adicionado; o de maior HLC vence', () {
    final p = plan(
      {
        'assets': [asset('a1', 100), asset('a2', 300, symbol: 'VALE3')],
      },
      {
        'assets': [
          asset('a1', 200, symbol: 'PETR4'),
          asset('a2', 200, symbol: 'XXX'),
          asset('a3', 50, symbol: 'ITUB4'),
        ],
      },
    );
    final byId = {for (final w in p.writes) w.row.id: w};
    expect(byId.keys, unorderedEquals(['a1', 'a3']));
    expect(byId['a1']!.localStamp, isFalse);
    expect(byId['a3']!.isNew, isTrue);
    expect(p.changes['assets']!.inserted, 1);
    expect(p.changes['assets']!.updated, 1);
    expect(p.maxIncomingHlc, hlc(200));
  });

  test('sem contexto (nunca sincronizaram), versões diferentes são '
      'conflito; com contexto, só o que mudou dos dois lados', () {
    final local = {
      'assets': [asset('a1', 300, symbol: 'LOCAL')],
    };
    final incoming = {
      'assets': [asset('a1', 200, symbol: 'REMOTO')],
    };
    expect(plan(local, incoming).conflicts, hasLength(1));
    // O autor já tinha visto a versão local (HLC 300): não é conflito.
    expect(
      plan(
        local,
        incoming,
        context: MergeContext(peerKnowsLocalUpTo: hlc(300)),
      ).conflicts,
      isEmpty,
    );
    // Este PC já tinha recebido a versão do autor: não é conflito.
    expect(
      plan(
        local,
        incoming,
        context: MergeContext(localKnowsPeerUpTo: hlc(200)),
      ).conflicts,
      isEmpty,
    );
  });

  test('escolher a versão mais antiga regrava como alteração local', () {
    final local = {
      'assets': [asset('a1', 300, symbol: 'LOCAL')],
    };
    final incoming = {
      'assets': [asset('a1', 200, symbol: 'REMOTO')],
    };
    final p = plan(
      local,
      incoming,
      resolutions: {(table: 'assets', id: 'a1'): MergeSide.incoming},
    );
    final w = p.writes.single;
    expect(w.localStamp, isTrue);
    expect(w.row['symbol'], 'REMOTO');
    expect(p.conflicts.single.chosenSide, MergeSide.incoming);
    expect(p.conflicts.single.defaultSide, MergeSide.local);
  });

  test('unificação por chave natural: fica o menor id, o outro vira alias e '
      'as referências são remapeadas', () {
    final p = plan(
      {
        'assets': [asset('a2', 100)],
        'operations': [op('o2', 110, asset: 'a2')],
      },
      {
        'assets': [asset('a1', 90)],
        'operations': [op('o1', 95, asset: 'a1')],
      },
    );
    expect(p.unifications.single.canonical.id, 'a1');
    expect(p.unifications.single.absorbed.id, 'a2');
    final byId = {for (final w in p.writes) w.row.id: w};
    expect(byId['a2']!.markDeleted, isTrue);
    expect(byId['o2']!.row['asset_id'], 'a1');
    expect(byId['o2']!.localStamp, isTrue);
    final alias = p.writes.singleWhere((w) => w.table == aliasTable);
    expect(alias.row['alias_id'], 'a2');
    expect(alias.row['canonical_id'], 'a1');
    expect(alias.isNew, isTrue);
  });

  test('alias recebido remapeia referências locais, seguindo a cadeia', () {
    SyncRow aliasRow(String id, String from, String to) => {
      'id': id,
      'created_at': 'c',
      'updated_at': 'u',
      'hlc': hlc(500),
      'device_id': 'dev-b',
      'deleted_at': null,
      'entity': 'asset',
      'alias_id': from,
      'canonical_id': to,
    };
    final p = plan(
      {
        'assets': [
          asset('a1', 100),
          asset('a2', 100, symbol: 'X'),
          asset('a3', 100, symbol: 'Y'),
        ],
        'operations': [op('o1', 100, asset: 'a3')],
      },
      {
        aliasTable: [aliasRow('al1', 'a3', 'a2'), aliasRow('al2', 'a2', 'a1')],
      },
    );
    final o1 = p.writes.singleWhere((w) => w.row.id == 'o1');
    expect(o1.row['asset_id'], 'a1');
  });

  test('referência a um registro inexistente recusa o save', () {
    expect(
      () => plan({}, {
        'operations': [op('o1', 100, asset: 'nao-existe')],
      }),
      throwsA(isA<DataError>()),
    );
  });

  test('duplicatas: só sinalizadas, e só quando alguma chegou agora', () {
    final local = {
      'assets': [asset('a1', 100)],
      'operations': [op('o1', 100), op('o2', 100)],
    };
    // As duas iguais já existiam: nada a sinalizar.
    expect(plan(local, {}).duplicates, isEmpty);
    final p = plan(local, {
      'operations': [op('o3', 200)],
    });
    expect(p.duplicates.single.operations.map((r) => r.id), ['o1', 'o2', 'o3']);
    expect(p.writes.where((w) => w.markDeleted), isEmpty);
  });

  test('importar duas vezes o mesmo conteúdo produz plano vazio', () {
    final incoming = {
      'assets': [asset('a1', 100)],
      'operations': [op('o1', 120)],
    };
    final first = plan({}, incoming);
    final after = <String, List<SyncRow>>{};
    for (final w in first.writes) {
      after.putIfAbsent(w.table, () => []).add(w.row);
    }
    expect(plan(after, incoming).isEmpty, isTrue);
  });
}
