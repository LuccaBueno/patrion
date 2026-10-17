import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Backups conhecidos por este PC (`dev_backups`, SPEC §11). Só deste PC.
class BackupRegistryRepository {
  const BackupRegistryRepository(this._db);

  final AppDatabase _db;

  /// Versão do schema do banco aberto.
  int get schemaVersion => _db.schemaVersion;

  /// Cópia consistente do banco aberto em [path] (`VACUUM INTO`). Passa pela
  /// conexão do app, o único ponto que abre o `patrion.db` (DECISIONS D-24).
  Future<void> vacuumInto(String path) =>
      _db.customStatement('VACUUM INTO ?', [path]);

  Future<void> add(DevBackupRow row) =>
      _db.into(_db.devBackups).insertOnConflictUpdate(row);

  Future<void> addAll(Iterable<DevBackupRow> rows) => _db.batch(
    (b) => b.insertAllOnConflictUpdate(_db.devBackups, rows.toList()),
  );

  Future<List<DevBackupRow>> all() => _query().get();

  Stream<List<DevBackupRow>> watchAll() => _query().watch();

  Future<DevBackupRow?> byPath(String path) => (_db.select(
    _db.devBackups,
  )..where((t) => t.path.equals(path))).getSingleOrNull();

  /// Esquece os backups dos caminhos [paths] (arquivos apagados pela
  /// retenção).
  Future<void> removePaths(Iterable<String> paths) async {
    final list = paths.toList();
    if (list.isEmpty) return;
    await (_db.delete(_db.devBackups)..where((t) => t.path.isIn(list))).go();
  }

  SimpleSelectStatement<$DevBackupsTable, DevBackupRow> _query() =>
      _db.select(_db.devBackups)..orderBy([(t) => OrderingTerm.desc(t.at)]);
}
