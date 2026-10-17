import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/sync/hlc.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/repositories/sync_repository.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/sync/invsave_codec.dart';
import 'package:patrion/domain/sync/merge_planner.dart';
import 'package:patrion/domain/sync/save_manifest.dart';
import 'package:patrion/domain/sync/sync_rows.dart';

import '../../helpers/portfolio_fixture.dart';
import '../../helpers/sync_pc.dart';

/// Repositório só de teste para as carteiras hipotéticas (as telas e os
/// serviços delas chegam na F9).
class _HypoPortfolios
    extends SyncRepository<$HypoPortfoliosTable, HypoPortfolioRow> {
  _HypoPortfolios(super.db, super.sync);

  @override
  $HypoPortfoliosTable get table => db.hypoPortfolios;
}

class _HypoHoldings extends SyncRepository<$HypoHoldingsTable, HypoHoldingRow> {
  _HypoHoldings(super.db, super.sync);

  @override
  $HypoHoldingsTable get table => db.hypoHoldings;
}

/// Casos S1 a S10 de `docs/CASOS_DE_TESTE.md` §9 e os testes obrigatórios de
/// SPEC §10.7. Em todos, A e B começam sincronizados.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late SyncPc a;
  late SyncPc b;
  late String institution;
  late String account;
  late String asset;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('patrion_sync_test_');
    a = await SyncPc.open('PC-A', tmp);
    b = await SyncPc.open('PC-B', tmp);
    institution = await a.institution('Corretora Exemplo');
    account = await a.account(institution, 'Principal');
    asset = await a.stock('VALE3');
    await syncBoth(a, b);
  });

  tearDown(() async {
    await a.close();
    await b.close();
    tmp.deleteSync(recursive: true);
  });

  Future<String> qtyOf(SyncPc pc, String id) async =>
      (await pc.row('operations', id))!['quantity']!;

  test('começam sincronizados: mesmos registros, inclusive HLC', () async {
    expect(await b.dump(), await a.dump());
    expect((await b.dump())['accounts']!.single.id, account);
  });

  test('S1: A cria O1, exporta e B importa: B tem O1 com o mesmo id', () async {
    final o1 = await a.buy(account, asset, '10');

    final plan = await b.import(await a.export());

    expect(plan.changes['operations']!.inserted, 1);
    final row = await b.row('operations', o1);
    expect(row, isNotNull);
    expect(row, await a.row('operations', o1));
    // Ida e volta: B exporta, A importa, e os dois ficam iguais.
    await a.import(await b.export());
    expect(await b.dump(), await a.dump());
  });

  test(
    'a carteira observada (telas) é recalculada depois da importação',
    () async {
      await a.buy(account, asset, '10');
      final save = await a.export();
      final snapshots = <int>[];
      final sub = b.query.watch().listen(
        (s) => snapshots.add(s.state.positions.length),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(snapshots.last, 0);

      await b.import(save);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(snapshots.last, 1);
      await sub.cancel();
    },
  );

  test('S2: importar o mesmo arquivo de novo não muda nada', () async {
    await a.buy(account, asset, '10');
    final save = await a.export();
    await b.import(save);
    final before = await b.dump();

    final preview = await b.preview(save);

    expect(preview.plan.totalChanges, 0);
    expect(preview.plan.conflicts, isEmpty);
    await b.save.apply(preview);
    expect(await b.dump(), before);
  });

  group('S3: edição concorrente', () {
    late String o1;

    setUp(() async {
      o1 = await a.buy(account, asset, '10');
      await syncBoth(a, b);
      await a.editBuy(o1, account, asset, '20');
      b.tick(const Duration(hours: 1)); // B edita depois
      await b.editBuy(o1, account, asset, '30');
    });

    test('conflito na prévia; padrão é a de maior HLC (30); os dois PCs '
        'terminam iguais', () async {
      final preview = await b.preview(await a.export());

      expect(preview.plan.conflicts, hasLength(1));
      final conflict = preview.plan.conflicts.single;
      expect(conflict.id, o1);
      expect(conflict.local['quantity'], '30');
      expect(conflict.incoming['quantity'], '20');
      expect(conflict.defaultSide, MergeSide.local);

      await b.save.apply(preview);
      // A importa o save de B: B já tinha visto a edição de A, então não é
      // conflito para A.
      final back = await a.preview(await b.export());
      expect(back.plan.conflicts, isEmpty);
      await a.save.apply(back);

      expect(await qtyOf(a, o1), '30');
      expect(await qtyOf(b, o1), '30');
      expect(await b.dump(), await a.dump());
    });

    test('escolher a outra versão (20) vale nos dois PCs', () async {
      final preview = await b.preview(await a.export());
      final ref = preview.plan.conflicts.single.ref;

      await b.save.apply(preview, resolutions: {ref: MergeSide.incoming});
      await a.import(await b.export());

      expect(await qtyOf(a, o1), '20');
      expect(await qtyOf(b, o1), '20');
      expect(await b.dump(), await a.dump());
    });
  });

  group('prévia avisa quando a carteira resultante fica inconsistente', () {
    test('vendas feitas nos dois PCs somam mais que a posição: aviso de '
        'venda maior que a posição, sem alterar nada', () async {
      await a.buy(account, asset, '100');
      await syncBoth(a, b);
      final sellA = await a.sell(account, asset, '80');
      await b.sell(account, asset, '50', date: '2026-02-11');
      expect((await b.query.load()).state.issues, isEmpty);
      final before = await b.dump();
      final hlcBefore = b.t.sync.lastHlc;

      final preview = await b.preview(await a.export());

      final warning = preview.warnings.single;
      expect(warning.kind, PortfolioIssueKind.oversold);
      expect(warning.assetSymbol, 'VALE3');
      expect(warning.accountLabel, 'Corretora Exemplo · Principal');
      // A venda de A (10/02) passa; a de B (11/02) é a que fica sem posição.
      expect(warning.date.toString(), '2026-02-11');
      expect(warning.operationType, OperationType.sell);
      // A prévia não grava nada nem avança o relógio.
      expect(await b.dump(), before);
      expect(b.t.sync.lastHlc, hlcBefore);
      expect((await b.query.load()).state.issues, isEmpty);

      // A importação continua permitida; a inconsistência aparece depois.
      await b.save.apply(preview);
      final issues = (await b.query.load()).state.issues;
      expect(issues.single.kind, PortfolioIssueKind.oversold);
      expect((await b.row('operations', sellA)), isNotNull);
    });

    test('inconsistências que já existiam não são repetidas; importação '
        'consistente não avisa', () async {
      await a.buy(account, asset, '100');
      final preview = await b.preview(await a.export());
      expect(preview.plan.isEmpty, isFalse);
      expect(preview.warnings, isEmpty);
    });

    test('a escolha da versão num conflito recalcula o aviso', () async {
      final o1 = await a.buy(account, asset, '100');
      final o2 = await a.sell(account, asset, '50');
      await syncBoth(a, b);
      // B reduz a compra para 60 (a venda de 50 cabe).
      await b.editBuy(o1, account, asset, '60');
      // Depois, A aumenta a venda para 90 e ajusta a compra para 95.
      a.tick(const Duration(hours: 1));
      await a.operations.save(
        a.buyDraft(
          account,
          asset,
          '90',
          price: '12',
          date: '2026-02-10',
          type: OperationType.sell,
        ),
        id: o2,
      );
      await a.editBuy(o1, account, asset, '95');

      final preview = await b.preview(await a.export());
      final conflict = preview.plan.conflicts.single;
      expect(conflict.id, o1);
      expect(conflict.defaultSide, MergeSide.incoming);
      // Padrão (compra de 95 e venda de 90): consistente.
      expect(preview.warnings, isEmpty);

      // Mantendo a compra de 60 deste PC, a venda de 90 fica sem posição.
      final keepingLocal = await b.save.consistency(
        preview,
        resolutions: {conflict.ref: MergeSide.local},
      );
      expect(keepingLocal.single.kind, PortfolioIssueKind.oversold);
      expect(
        await b.save.consistency(
          preview,
          resolutions: {conflict.ref: MergeSide.incoming},
        ),
        isEmpty,
      );
    });
  });

  test('S4: A exclui O1; B importa e O1 fica excluída (tombstone)', () async {
    final o1 = await a.buy(account, asset, '10');
    await syncBoth(a, b);
    a.tick();
    await a.operations.delete(o1);

    final plan = await b.import(await a.export());

    expect(plan.changes['operations']!.deleted, 1);
    final row = await b.row('operations', o1);
    expect(row!['deleted_at'], isNotNull);
    expect(await b.repos.operations.byId(o1), isNull);
    expect(row, await a.row('operations', o1));
  });

  test('S5: importar um save antigo de A não faz nada regredir', () async {
    final o1 = await a.buy(account, asset, '10');
    await syncBoth(a, b);
    final oldSaveOfA = await a.export(); // antes da edição de S3
    final oldSaveOfB = await b.export();
    await a.editBuy(o1, account, asset, '20');
    b.tick(const Duration(hours: 1));
    await b.editBuy(o1, account, asset, '30');
    await syncBoth(a, b);
    final converged = await a.dump();

    final preview = await b.preview(oldSaveOfA);
    expect(preview.plan.totalChanges, 0);
    expect(preview.plan.conflicts, isEmpty);
    await b.save.apply(preview);
    await a.import(oldSaveOfB);

    expect(await qtyOf(b, o1), '30');
    expect(await a.dump(), converged);
    expect(await b.dump(), converged);
  });

  group('S6: relógio de B 2 dias adiantado', () {
    late String o1;

    setUp(() async {
      o1 = await a.buy(account, asset, '10');
      await syncBoth(a, b);
      b.tick(const Duration(days: 2));
    });

    test('B edita, A recebe e edita depois: a edição de A vence, apesar do '
        'relógio', () async {
      await b.editBuy(o1, account, asset, '30');
      final hlcB = Hlc.parse((await b.row('operations', o1))!.hlc);
      await a.import(await b.export());
      await a.editBuy(o1, account, asset, '40'); // relógio de A: 2 dias atrás

      final preview = await b.preview(await a.export());
      expect(preview.plan.conflicts, isEmpty);
      await b.save.apply(preview);
      await a.import(await b.export());

      expect(await qtyOf(a, o1), '40');
      expect(await qtyOf(b, o1), '40');
      expect(await b.dump(), await a.dump());
      // O HLC de A passou o de B, mesmo com o relógio de A atrasado.
      final hlcA = Hlc.parse((await a.row('operations', o1))!.hlc);
      expect(hlcA.deviceId, a.deviceId);
      expect(hlcA > hlcB, isTrue);
      expect(hlcA.millis, greaterThan(a.t.wall.now.millisecondsSinceEpoch));
    });

    test('edições sem troca: conflito com resultado previsível pelo HLC; a '
        'edição de A não se perde (aparece no conflito e pode ser '
        'escolhida)', () async {
      await b.editBuy(o1, account, asset, '30');
      await a.editBuy(o1, account, asset, '40');

      final preview = await b.preview(await a.export());
      final conflict = preview.plan.conflicts.single;
      expect(conflict.local['quantity'], '30');
      expect(conflict.incoming['quantity'], '40');
      expect(conflict.defaultSide, MergeSide.local); // HLC de B é maior

      await b.save.apply(
        preview,
        resolutions: {conflict.ref: MergeSide.incoming},
      );
      await a.import(await b.export());

      expect(await qtyOf(a, o1), '40');
      expect(await qtyOf(b, o1), '40');
      expect(await b.dump(), await a.dump());
    });
  });

  test('S7: PETR4 cadastrado nos dois PCs vira um único ativo, com as '
      'operações dos dois ligadas a ele', () async {
    final petrA = await a.stock('PETR4');
    final opA = await a.buy(account, petrA, '100');
    final petrB = await b.stock('PETR4');
    final opB = await b.buy(account, petrB, '50', price: '30');

    final preview = await b.preview(await a.export());
    expect(preview.plan.unifications, hasLength(1));
    await b.save.apply(preview);
    await a.import(await b.export());

    for (final pc in [a, b]) {
      final alive = (await pc.repos.assets.all())
          .where((x) => x.symbol == 'PETR4')
          .toList();
      expect(alive, hasLength(1), reason: pc.name);
      final canonical = alive.single.id;
      expect([petrA, petrB]..sort(), contains(canonical));
      for (final op in [opA, opB]) {
        expect((await pc.repos.operations.byId(op))!.assetId, canonical);
      }
      final aliases = (await pc.dump())['asset_aliases']!;
      expect(aliases.single['canonical_id'], canonical);
      expect(aliases.single['entity'], 'asset');
      final snapshot = await pc.query.load();
      expect(
        snapshot.state.positions
            .where((p) => p.assetId == canonical)
            .fold(0, (sum, p) => sum + p.quantity.toBigInt().toInt()),
        150,
      );
    }
    expect(await b.dump(), await a.dump());
    // Idempotente também depois da unificação.
    expect((await b.preview(await a.export())).plan.totalChanges, 0);
  });

  test('S7: um save antigo, de antes da unificação, não ressuscita o ativo '
      'absorvido', () async {
    final petrA = await a.stock('PETR4');
    await a.buy(account, petrA, '100');
    final oldSaveOfA = await a.export();
    final petrB = await b.stock('PETR4');
    await b.buy(account, petrB, '50');
    await syncBoth(a, b);
    final converged = await b.dump();

    await b.import(oldSaveOfA);

    expect(
      (await b.repos.assets.all()).where((x) => x.symbol == 'PETR4'),
      hasLength(1),
    );
    expect(await b.dump(), converged);
  });

  group('S8: arquivo com um byte alterado', () {
    test(
      'é recusado pela verificação de checksum e o banco fica intacto',
      () async {
        await a.buy(account, asset, '10');
        final save = await a.export();
        final before = await b.dump();
        final tampered = Uint8List.fromList(save);
        final dataOffset = _contentOffset(save, 'data/operations.jsonl');
        tampered[dataOffset + 5] ^= 0x01;

        await expectLater(b.preview(tampered), throwsA(isA<DataError>()));
        expect(await b.dump(), before);
      },
    );

    test('nenhum byte alterado em qualquer posição produz uma importação '
        'diferente da original', () async {
      await a.buy(account, asset, '10');
      final save = await a.export();
      final original = await b.preview(save);
      var rejected = 0;
      for (var i = 0; i < save.length; i++) {
        final tampered = Uint8List.fromList(save)..[i] ^= 0x01;
        try {
          final preview = await b.save.preview(tampered, fileName: 'x');
          // Bytes fora do conteúdo (datas e campos de cabeçalho do ZIP) não
          // mudam os dados: a prévia tem de ser a mesma.
          expect(
            preview.plan.writes.map((w) => w.row).toList(),
            original.plan.writes.map((w) => w.row).toList(),
            reason: 'byte $i',
          );
        } on DataError {
          rejected++;
        }
      }
      expect(rejected, greaterThan(0));
      // No conteúdo comprimido do manifesto e das tabelas, um byte alterado
      // é recusado, salvo quando a descompressão dá exatamente o mesmo
      // conteúdo (bits de preenchimento do deflate).
      final originalPackage = InvsaveCodec.decode(save);
      var contentBytes = 0;
      var contentRejected = 0;
      for (final name in [
        InvsaveCodec.manifestPath,
        InvsaveCodec.manifestChecksumPath,
        'data/operations.jsonl',
        'data/accounts.jsonl',
      ]) {
        final (start, length) = _contentRange(save, name);
        expect(length, greaterThan(0));
        for (var i = start; i < start + length; i++) {
          contentBytes++;
          final tampered = Uint8List.fromList(save)..[i] ^= 0x01;
          try {
            final package = InvsaveCodec.decode(tampered);
            expect(package.tables, originalPackage.tables, reason: 'byte $i');
            expect(
              package.manifest.toJson(),
              originalPackage.manifest.toJson(),
              reason: 'byte $i',
            );
          } on DataError {
            contentRejected++;
          }
        }
      }
      expect(contentRejected, greaterThan(contentBytes * 0.95));
    });
  });

  test('S9: falha no meio da importação desfaz tudo', () async {
    for (var i = 0; i < 5; i++) {
      await a.buy(account, asset, '${i + 1}');
    }
    final save = await a.export();
    final before = await b.dump();
    final peersBefore = await b.peers.peers();
    b.failAtWrite = 3;

    await expectLater(b.import(save), throwsA(isA<AppError>()));

    expect(await b.dump(), before);
    expect(await b.peers.peers(), peersBefore);
    final history = await b.peers.watchHistory().first;
    expect(history.first.result, 'failed');
    // Sem a falha, a mesma importação funciona.
    b.failAtWrite = null;
    final plan = await b.import(save);
    expect(plan.changes['operations']!.inserted, 5);
  });

  test('S10: carteiras hipotéticas chegam separadas e o patrimônio real de B '
      'não muda', () async {
    await b.buy(account, asset, '10');
    await a.import(await b.export());
    final realBefore = await b.query.load();
    final opsBefore = (await b.dump())['operations'];

    final hypo = _HypoPortfolios(a.t.db, a.t.sync);
    final portfolio = await hypo.insertRow(
      HypoPortfoliosCompanion(
        initialCapital: Value(dec('1000000')),
        name: Value('Teste hipotético'),
        startDate: Value('2020-01-01'),
        baseCurrency: Value('BRL'),
        compositionMode: Value('weight'),
        rebalanceJson: Value('{}'),
        assumptionsJson: Value('{}'),
      ),
    );
    await _HypoHoldings(a.t.db, a.t.sync).insertRow(
      HypoHoldingsCompanion(
        portfolioId: Value(portfolio),
        assetId: Value(asset),
        weightPct: Value(dec('100')),
      ),
    );

    await b.import(await a.export());

    final dump = await b.dump();
    expect(dump['hypo_portfolios']!.single.id, portfolio);
    expect(dump['hypo_holdings']!.single['portfolio_id'], portfolio);
    expect(dump['operations'], opsBefore);
    final realAfter = await b.query.load();
    final brl = realAfter.summary.byCurrency['BRL']!;
    final brlBefore = realBefore.summary.byCurrency['BRL']!;
    expect(brl.invested, brlBefore.invested);
    expect(brl.marketValue, brlBefore.marketValue);
    expect(brl.cash, brlBefore.cash);
    expect(
      realAfter.state.positions.map((p) => p.quantity),
      realBefore.state.positions.map((p) => p.quantity),
    );
  });

  group('SPEC §10.7: schema e formato', () {
    Future<Uint8List> reencode(
      Uint8List save,
      SaveManifest Function(SaveManifest m) change, {
      Set<String> dropTables = const {},
    }) async {
      final package = InvsaveCodec.decode(save);
      final tables = {
        for (final e in package.tables.entries)
          if (!dropTables.contains(e.key)) e.key: e.value,
      };
      final m = change(package.manifest);
      return InvsaveCodec.encode(
        SaveManifest(
          appVersion: m.appVersion,
          schemaVersion: m.schemaVersion,
          deviceId: m.deviceId,
          deviceName: m.deviceName,
          createdAt: m.createdAt,
          maxHlc: m.maxHlc,
          counts: {for (final e in tables.entries) e.key: e.value.length},
          knownPeers: m.knownPeers,
          encryption: m.encryption,
          formatVersion: m.formatVersion,
        ),
        tables,
      );
    }

    SaveManifest withSchema(SaveManifest m, int v, {String? encryption}) =>
        SaveManifest(
          appVersion: m.appVersion,
          schemaVersion: v,
          deviceId: m.deviceId,
          deviceName: m.deviceName,
          createdAt: m.createdAt,
          maxHlc: m.maxHlc,
          counts: m.counts,
          knownPeers: m.knownPeers,
          encryption: encryption ?? m.encryption,
        );

    test('schema mais novo que o do app é recusado', () async {
      final save = await reencode(await a.export(), (m) => withSchema(m, 99));
      final before = await b.dump();

      await expectLater(
        b.preview(save),
        throwsA(
          isA<DataError>().having((e) => e.message, 'm', contains('mais nova')),
        ),
      );
      expect(await b.dump(), before);
    });

    test('schema mais antigo é convertido na importação', () async {
      final o1 = await a.buy(account, asset, '10');
      final save = await reencode(
        await a.export(),
        (m) => withSchema(m, 2),
        dropTables: {
          'asset_aliases',
          'hypo_portfolios',
          'hypo_holdings',
          'hypo_cashflow_rules',
          'hypo_scenarios',
        },
      );

      final preview = await b.preview(save);
      expect(preview.upgradedFromOlderSchema, isTrue);
      await b.save.apply(preview);
      expect(await b.row('operations', o1), await a.row('operations', o1));
    });

    test(
      'save protegido por senha (F5B) é recusado com mensagem clara',
      () async {
        final save = await reencode(
          await a.export(),
          (m) => withSchema(m, m.schemaVersion, encryption: 'aes-256-gcm'),
        );
        await expectLater(
          b.preview(save),
          throwsA(
            isA<DataError>().having((e) => e.message, 'm', contains('senha')),
          ),
        );
      },
    );

    test('arquivo que não é ZIP é recusado', () async {
      await expectLater(
        b.preview(Uint8List.fromList(utf8.encode('não sou um save'))),
        throwsA(isA<DataError>()),
      );
    });

    test('o manifesto tem o campo de criptografia, as contagens e o SHA-256 '
        'de cada arquivo', () async {
      await a.buy(account, asset, '10');
      final package = InvsaveCodec.decode(await a.export());
      final m = package.manifest;
      expect(m.encryption, 'none');
      expect(m.toJson()['encryption'], {'scheme': 'none'});
      expect(m.schemaVersion, AppDatabase.latestSchemaVersion);
      expect(m.deviceId, a.deviceId);
      expect(m.counts['operations'], 1);
      expect(m.files.keys, contains('data/operations.jsonl'));
      expect(package.tables.keys, isNot(contains('dev_identity')));
      expect(package.tables.keys, isNot(contains('dev_settings')));
      expect(package.tables.keys, isNot(contains('dev_backups')));
      // B já tinha importado um save de A: B conhece o HLC de A.
      final fromB = InvsaveCodec.decode(await b.export()).manifest;
      expect(fromB.knownHlcOf(a.deviceId), isNotNull);
    });

    test(
      'importar faz um backup automático antes de alterar o banco',
      () async {
        await a.buy(account, asset, '10');
        final result = await b.save.apply(await b.preview(await a.export()));
        expect(File(result.backup.path).existsSync(), isTrue);
        expect(result.backup.reason, 'pre-importacao');
      },
    );
  });
}

/// Posição do conteúdo comprimido de [name] dentro do ZIP (depois do
/// cabeçalho local).
int _contentOffset(Uint8List zip, String name) => _contentRange(zip, name).$1;

/// Início e tamanho do conteúdo comprimido de [name] no ZIP.
(int, int) _contentRange(Uint8List zip, String name) {
  final nameBytes = utf8.encode(name);
  for (var i = 0; i + 30 < zip.length; i++) {
    if (zip[i] == 0x50 &&
        zip[i + 1] == 0x4b &&
        zip[i + 2] == 0x03 &&
        zip[i + 3] == 0x04) {
      final nameLen = zip[i + 26] | (zip[i + 27] << 8);
      final extraLen = zip[i + 28] | (zip[i + 29] << 8);
      final found = zip.sublist(i + 30, i + 30 + nameLen);
      if (_same(found, nameBytes)) {
        final size =
            zip[i + 18] |
            (zip[i + 19] << 8) |
            (zip[i + 20] << 16) |
            (zip[i + 21] << 24);
        return (i + 30 + nameLen + extraLen, size);
      }
    }
  }
  throw StateError('$name não encontrado');
}

bool _same(List<int> x, List<int> y) {
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}
