import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/data/db/app_database.dart';
import 'package:patrion/infrastructure/backup/pre_migration_backup.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../data/db/migrations/patrion/generated/schema_v1.dart' as v1;

/// Backup automático antes de migrar o schema (SPEC §11).
void main() {
  late Directory tmp;
  late String dbFile;
  late String backupsDir;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('patrion_backup_test_');
    dbFile = p.join(tmp.path, 'patrion.db');
    backupsDir = p.join(tmp.path, 'backups');
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  /// Cria um banco real no schema 1 com uma configuração compartilhada.
  Future<void> createV1Database() async {
    final old = v1.DatabaseAtV1(NativeDatabase(File(dbFile)));
    await old.customStatement(
      'INSERT INTO shared_settings (id, created_at, updated_at, hlc, '
      'device_id, deleted_at, key, value_json) VALUES (?, ?, ?, ?, ?, NULL, '
      '?, ?)',
      [
        'id-1',
        '2026-10-17T12:00:00.000Z',
        '2026-10-17T12:00:00.000Z',
        '001760702400000-00001-pc',
        'pc',
        'display_currency',
        '"BRL"',
      ],
    );
    await old.close();
  }

  int userVersion(String file) {
    final db = sqlite3.open(file, mode: OpenMode.readOnly);
    try {
      return db.select('PRAGMA user_version').single.columnAt(0) as int;
    } finally {
      db.close();
    }
  }

  PreMigrationBackup backup({DateTime? at, int keep = 10}) =>
      PreMigrationBackup(
        backupsDir: backupsDir,
        appVersion: '0.2.0',
        keep: keep,
        wallClock: Clock.fixed(at ?? DateTime.utc(2026, 10, 17, 18, 30, 5, 7)),
      );

  test('banco novo (arquivo ausente) não gera backup', () {
    final result = backup().run(databaseFile: dbFile, targetVersion: 2);
    expect(result, isNull);
    expect(Directory(backupsDir).existsSync(), isFalse);
  });

  test('banco já na versão atual não gera backup', () async {
    final db = AppDatabase.open(dbFile);
    await db.customSelect('SELECT 1').get(); // cria e migra
    await db.close();

    final result = backup().run(
      databaseFile: dbFile,
      targetVersion: AppDatabase.latestSchemaVersion,
    );
    expect(result, isNull);
  });

  test('banco antigo: backup íntegro, com data e versões no nome, antes de '
      'migrar', () async {
    await createV1Database();

    final path = backup().run(databaseFile: dbFile, targetVersion: 2);

    expect(path, isNotNull);
    expect(
      p.basename(path!),
      'patrion_2026-10-17_18-30-05-007Z_pre-migracao_v1-v2_app-0.2.0.db',
    );
    // O backup é do estado anterior: schema 1 e com os dados.
    expect(userVersion(path), 1);
    final copy = sqlite3.open(path, mode: OpenMode.readOnly);
    expect(
      copy.select('SELECT key FROM shared_settings').single['key'],
      'display_currency',
    );
    expect(copy.select('PRAGMA integrity_check').first.columnAt(0), 'ok');
    copy.close();
    // O original ainda não foi tocado.
    expect(userVersion(dbFile), 1);

    // Depois do backup, o Drift migra o original sem perder dados.
    final db = AppDatabase.open(dbFile);
    final settings = await db.select(db.sharedSettings).get();
    expect(settings.single.key, 'display_currency');
    expect(await db.select(db.operations).get(), isEmpty);
    await db.close();
    expect(userVersion(dbFile), AppDatabase.latestSchemaVersion);
    expect(userVersion(path), 1);
  });

  test('falha no backup impede a migração e preserva o banco', () async {
    await createV1Database();
    // Um arquivo no lugar da pasta de backups faz a cópia falhar.
    File(backupsDir).writeAsStringSync('não é uma pasta');

    expect(
      () => backup().run(databaseFile: dbFile, targetVersion: 2),
      throwsA(isA<DataError>()),
    );
    expect(userVersion(dbFile), 1);
  });

  test('banco de uma versão mais nova do app é recusado', () async {
    await createV1Database();
    final db = sqlite3.open(dbFile)..execute('PRAGMA user_version = 99');
    db.close();

    expect(
      () => backup().run(databaseFile: dbFile, targetVersion: 2),
      throwsA(
        isA<DataError>().having((e) => e.message, 'message', contains('99')),
      ),
    );
    expect(Directory(backupsDir).existsSync(), isFalse);
  });

  test('retenção mantém só os backups de migração mais recentes', () async {
    await createV1Database();
    Directory(backupsDir).createSync();
    // Backup de outro tipo (manual, F5) não entra na retenção.
    final manual = File(p.join(backupsDir, 'patrion_2020-01-01_manual.db'))
      ..writeAsStringSync('x');

    final paths = [
      for (var i = 0; i < 5; i++)
        backup(
          at: DateTime.utc(2026, 10, 17, 10 + i),
          keep: 3,
        ).run(databaseFile: dbFile, targetVersion: 2)!,
    ];

    final remaining =
        Directory(backupsDir)
            .listSync()
            .map((f) => p.basename(f.path))
            .where((n) => n.contains('pre-migracao') && n.endsWith('.db'))
            .toList()
          ..sort();
    expect(remaining, [for (final path in paths.skip(2)) p.basename(path)]);
    expect(manual.existsSync(), isTrue);
  });
}
