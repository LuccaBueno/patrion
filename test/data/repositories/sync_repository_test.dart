import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/ids/id_generator.dart';
import 'package:patrion/core/sync/hlc.dart';
import 'package:patrion/core/time/instant_format.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/repositories/shared_settings_repository.dart';

import '../../helpers/test_database.dart';

/// Testes do repositório base (`SyncRepository`), exercitado pela tabela
/// sincronizável `shared_settings`.
void main() {
  late TestDb t;
  late SharedSettingsRepository repo;

  setUp(() async {
    t = await TestDb.open();
    repo = SharedSettingsRepository(t.db, t.sync);
  });

  tearDown(() => t.close());

  Future<SharedSettingRow> rowOf(String id) async =>
      (await repo.findRowById(id, includeDeleted: true))!;

  test('insert preenche id, datas, hlc e device_id', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(
        key: Value('moeda'),
        valueJson: Value('"BRL"'),
      ),
    );
    final row = await rowOf(id);

    expect(IdGenerator.isValid(row.id), isTrue);
    expect(row.createdAt, '2026-10-17T12:00:00.000Z');
    expect(row.updatedAt, row.createdAt);
    expect(row.deviceId, t.identity.deviceId);
    expect(Hlc.parse(row.hlc).deviceId, t.identity.deviceId);
    expect(row.deletedAt, isNull);
  });

  test('insert ignora campos de sync informados por quem chama', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(
        id: Value('id-forjado'),
        key: Value('k'),
        valueJson: Value('1'),
        hlc: Value('000000000000000-00000-x'),
        deviceId: Value('outro-pc'),
        deletedAt: Value('2020-01-01T00:00:00.000Z'),
      ),
    );
    final row = await rowOf(id);
    expect(id, isNot('id-forjado'));
    expect(row.deviceId, t.identity.deviceId);
    expect(row.deletedAt, isNull);
    expect(row.hlc, isNot('000000000000000-00000-x'));
  });

  test('update avança hlc e updated_at e preserva created_at', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
    );
    final before = await rowOf(id);
    t.wall.advance(const Duration(minutes: 5));

    await repo.updateRow(
      id,
      const SharedSettingsCompanion(
        valueJson: Value('2'),
        createdAt: Value('1999-01-01T00:00:00.000Z'),
      ),
    );
    final after = await rowOf(id);

    expect(after.valueJson, '2');
    expect(after.createdAt, before.createdAt);
    expect(after.updatedAt, '2026-10-17T12:05:00.000Z');
    expect(Hlc.parse(after.hlc) > Hlc.parse(before.hlc), isTrue);
  });

  test('softDelete grava tombstone e não apaga a linha', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
    );
    final before = await rowOf(id);
    t.wall.advance(const Duration(seconds: 1));

    await repo.softDelete(id);

    expect(await repo.findRowById(id), isNull);
    final tomb = await rowOf(id);
    expect(tomb.deletedAt, '2026-10-17T12:00:01.000Z');
    expect(Hlc.parse(tomb.hlc) > Hlc.parse(before.hlc), isTrue);
    final count = await t.db.sharedSettings.count().getSingle();
    expect(count, 1);
    expect(await repo.allRowsIncludingDeleted(), hasLength(1));
  });

  test('alterar ou excluir registro excluído lança DataError', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
    );
    await repo.softDelete(id);
    expect(
      () => repo.updateRow(id, const SharedSettingsCompanion()),
      throwsA(isA<DataError>()),
    );
    expect(() => repo.softDelete(id), throwsA(isA<DataError>()));
    expect(() => repo.softDelete('inexistente'), throwsA(isA<DataError>()));
  });

  test('cada escrita tem HLC maior, mesmo com o relógio voltando', () async {
    final hlcs = <Hlc>[];
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('0')),
    );
    hlcs.add(Hlc.parse((await rowOf(id)).hlc));
    for (var i = 1; i <= 5; i++) {
      t.wall.advance(Duration(hours: i.isEven ? 2 : -3));
      await repo.updateRow(id, SharedSettingsCompanion(valueJson: Value('$i')));
      hlcs.add(Hlc.parse((await rowOf(id)).hlc));
    }
    for (var i = 1; i < hlcs.length; i++) {
      expect(hlcs[i] > hlcs[i - 1], isTrue, reason: '$i');
    }
  });

  test('o último HLC fica gravado em dev_identity', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
    );
    final identity = await t.db.select(t.db.devIdentity).getSingle();
    expect(identity.lastHlc, (await rowOf(id)).hlc);
  });

  test('falha na transação desfaz a escrita e o HLC gravado', () async {
    final lastBefore =
        (await t.db.select(t.db.devIdentity).getSingle()).lastHlc;
    await expectLater(
      t.db.transaction(() async {
        await repo.insertRow(
          const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
        );
        throw StateError('falha simulada');
      }),
      throwsStateError,
    );
    expect(await t.db.sharedSettings.count().getSingle(), 0);
    final lastAfter = (await t.db.select(t.db.devIdentity).getSingle()).lastHlc;
    expect(lastAfter, lastBefore);
  });

  test('instantes gravados seguem o formato do app', () async {
    final id = await repo.insertRow(
      const SharedSettingsCompanion(key: Value('k'), valueJson: Value('1')),
    );
    final row = await rowOf(id);
    expect(() => parseInstant(row.createdAt), returnsNormally);
    expect(() => parseInstant(row.updatedAt), returnsNormally);
  });
}
