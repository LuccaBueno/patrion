import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/ids/id_generator.dart';
import 'package:patrion/core/sync/hlc.dart';
import 'package:patrion/data/repositories/shared_settings_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('patrion_identity_');
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  Future<TestDb> openFile({DateTime? start}) => TestDb.open(
    start: start,
    executor: NativeDatabase(File(p.join(dir.path, 'patrion.db'))),
  );

  test('primeira execução cria device_id UUID v7', () async {
    final t = await openFile();
    expect(IdGenerator.isValid(t.identity.deviceId), isTrue);
    expect(t.identity.deviceName, 'PC-TESTE');
    expect(t.identity.lastHlc, Hlc.zero(t.identity.deviceId));
    await t.close();
  });

  test('device_id e HLC sobrevivem ao reinício do app', () async {
    final first = await openFile(start: DateTime.utc(2026, 10, 17, 12));
    final repo = SharedSettingsRepository(first.db, first.sync);
    final id = await repo.put('k', '1');
    final hlcBefore = Hlc.parse((await repo.findRowById(id))!.hlc);
    await first.close();

    // Reabre com o relógio do PC atrasado em um dia.
    final second = await openFile(start: DateTime.utc(2026, 10, 16, 12));
    expect(second.identity.deviceId, first.identity.deviceId);
    expect(second.identity.lastHlc, hlcBefore);

    final repo2 = SharedSettingsRepository(second.db, second.sync);
    await repo2.put('k', '2');
    final hlcAfter = Hlc.parse((await repo2.findRowById(id))!.hlc);
    expect(hlcAfter > hlcBefore, isTrue);
    await second.close();
  });
}
