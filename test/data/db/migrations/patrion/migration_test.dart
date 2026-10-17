import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/data/db/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Migrações do schema (`docs/BANCO.md` §9).
///
/// Gerado por `dart run drift_dev make-migrations` e adaptado: cada nova
/// versão ganha aqui um teste de preservação de dados.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('migração sem dados', () {
    // Toda combinação de versões: o schema migrado precisa bater com o
    // snapshot da versão de destino.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('de $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('para $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 para v2 preserva os dados existentes', () async {
    const deviceId = '0199f2a0-0000-7000-8000-000000000001';
    const hlc = '001760702400000-00003-$deviceId';
    const at = '2026-10-17T12:00:00.000Z';

    final oldIdentity = [
      const v1.DevIdentityData(
        deviceId: deviceId,
        deviceName: 'PC-A',
        createdAt: at,
        lastHlc: hlc,
      ),
    ];
    final expectedIdentity = [
      const v2.DevIdentityData(
        deviceId: deviceId,
        deviceName: 'PC-A',
        createdAt: at,
        lastHlc: hlc,
      ),
    ];
    final oldDevSettings = [
      const v1.DevSettingsData(
        key: 'theme',
        valueJson: '"dark"',
        updatedAt: at,
      ),
    ];
    final expectedDevSettings = [
      const v2.DevSettingsData(
        key: 'theme',
        valueJson: '"dark"',
        updatedAt: at,
      ),
    ];
    final oldShared = [
      const v1.SharedSettingsData(
        id: '0199f2a0-0000-7000-8000-0000000000aa',
        createdAt: at,
        updatedAt: at,
        hlc: hlc,
        deviceId: deviceId,
        key: 'display_currency',
        valueJson: '"BRL"',
      ),
      const v1.SharedSettingsData(
        id: '0199f2a0-0000-7000-8000-0000000000bb',
        createdAt: at,
        updatedAt: at,
        hlc: hlc,
        deviceId: deviceId,
        deletedAt: at,
        key: 'removida',
        valueJson: '1',
      ),
    ];
    final expectedShared = [
      const v2.SharedSettingsData(
        id: '0199f2a0-0000-7000-8000-0000000000aa',
        createdAt: at,
        updatedAt: at,
        hlc: hlc,
        deviceId: deviceId,
        key: 'display_currency',
        valueJson: '"BRL"',
      ),
      const v2.SharedSettingsData(
        id: '0199f2a0-0000-7000-8000-0000000000bb',
        createdAt: at,
        updatedAt: at,
        hlc: hlc,
        deviceId: deviceId,
        deletedAt: at,
        key: 'removida',
        valueJson: '1',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.devIdentity, oldIdentity)
          ..insertAll(oldDb.devSettings, oldDevSettings)
          ..insertAll(oldDb.sharedSettings, oldShared);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.devIdentity).get(), expectedIdentity);
        expect(
          await newDb.select(newDb.devSettings).get(),
          expectedDevSettings,
        );
        expect(await newDb.select(newDb.sharedSettings).get(), expectedShared);
        expect(await newDb.select(newDb.operations).get(), isEmpty);
      },
    );
  });
}
