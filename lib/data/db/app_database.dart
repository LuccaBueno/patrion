import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Banco SQLite do app (`docs/BANCO.md`).
///
/// Cada mudança de schema sobe [schemaVersion], ganha um passo de migração e
/// um snapshot em `drift_schemas/` (gerados por
/// `dart run drift_dev make-migrations`).
@DriftDatabase(tables: [DevIdentity, DevSettings, SharedSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Abre (ou cria) o banco no arquivo [path], em um isolate de fundo.
  factory AppDatabase.open(String path) =>
      AppDatabase(NativeDatabase.createInBackground(File(path)));

  /// Banco em memória, para testes.
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
