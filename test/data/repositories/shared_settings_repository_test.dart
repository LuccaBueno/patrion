import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/data/repositories/shared_settings_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late TestDb t;
  late SharedSettingsRepository repo;

  setUp(() async {
    t = await TestDb.open();
    repo = SharedSettingsRepository(t.db, t.sync);
  });

  tearDown(() => t.close());

  test('put cria e depois altera o mesmo registro (chave natural)', () async {
    final id1 = await repo.put('moeda_exibicao', '"BRL"');
    final id2 = await repo.put('moeda_exibicao', '"USD"');

    expect(id2, id1);
    expect((await repo.get('moeda_exibicao'))!.valueJson, '"USD"');
    expect(await t.db.sharedSettings.count().getSingle(), 1);
  });

  test('put com o mesmo valor não gera alteração', () async {
    final id = await repo.put('k', '1');
    final hlc = (await repo.findRowById(id))!.hlc;
    await repo.put('k', '1');
    expect((await repo.findRowById(id))!.hlc, hlc);
  });

  test('remove grava tombstone; put depois cria registro novo', () async {
    final id1 = await repo.put('k', '1');
    await repo.remove('k');
    expect(await repo.get('k'), isNull);

    final id2 = await repo.put('k', '2');
    expect(id2, isNot(id1));
    expect(
      (await repo.findRowById(id1, includeDeleted: true))!.deletedAt,
      isNotNull,
    );
    expect(await t.db.sharedSettings.count().getSingle(), 2);
  });

  test('remove de chave inexistente não faz nada', () async {
    await repo.remove('nada');
    expect(await t.db.sharedSettings.count().getSingle(), 0);
  });

  test('watchAll emite só os registros vivos, em ordem de chave', () async {
    await repo.put('b', '2');
    await repo.put('a', '1');
    await repo.put('c', '3');
    await repo.remove('c');

    final list = await repo.watchAll().first;
    expect(list.map((s) => s.key), ['a', 'b']);
  });
}
