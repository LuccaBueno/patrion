import 'package:decimal/decimal.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/data/db/converters.dart';

import 'migrations/patrion/generated/schema.dart';

void main() {
  group('schema', () {
    late SchemaVerifier verifier;

    setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

    test('banco novo bate com o snapshot da versão atual', () async {
      final db = AppDatabase(await verifier.startAt(1));
      // O schema declarado no código precisa ser igual ao snapshot salvo em
      // drift_schemas/ (snapshot desatualizado = migração esquecida).
      await verifier.migrateAndValidate(db, db.schemaVersion);
      await db.close();
    });

    test('toda tabela sincronizável tem os campos e o índice de hlc', () async {
      final db = AppDatabase.memory();
      const syncTables = [
        'shared_settings',
        'institutions',
        'accounts',
        'assets',
        'fixed_income_terms',
        'operations',
        'manual_valuations',
      ];
      for (final table in syncTables) {
        final columns = await db
            .customSelect('PRAGMA table_info($table)')
            .map((r) => r.read<String>('name'))
            .get();
        expect(
          columns,
          containsAll([
            'id',
            'created_at',
            'updated_at',
            'hlc',
            'device_id',
            'deleted_at',
          ]),
          reason: table,
        );
        final indexes = await db
            .customSelect('PRAGMA index_list($table)')
            .map((r) => r.read<String>('name'))
            .get();
        expect(indexes, contains('${table}_hlc'), reason: table);
      }
      await db.close();
    });

    test('nenhuma coluna usa REAL (regra 6)', () async {
      final db = AppDatabase.memory();
      for (final table in db.allTables) {
        final types = await db
            .customSelect('PRAGMA table_info(${table.actualTableName})')
            .map((r) => r.read<String>('type').toUpperCase())
            .get();
        expect(types, isNot(contains('REAL')), reason: table.actualTableName);
      }
      await db.close();
    });
  });

  group('DecimalTextConverter', () {
    const c = DecimalTextConverter();

    test('grava a representação canônica', () {
      expect(c.toSql(Decimal.parse('3005.00')), '3005');
      expect(c.toSql(Decimal.parse('0.10')), '0.1');
      expect(c.toSql(Decimal.parse('-12.3400')), '-12.34');
      expect(c.toSql(Decimal.parse('0.00000001')), '0.00000001');
    });

    test('ida e volta sem perda', () {
      for (final s in ['0', '1', '30.05', '123456789012345.678901234567']) {
        expect(c.fromSql(c.toSql(Decimal.parse(s))), Decimal.parse(s));
      }
    });
  });
}
