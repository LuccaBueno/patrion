import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../core/crypto/database_key.dart';
import '../../core/errors/app_error.dart';

/// Resultado da inspeção de um arquivo de banco (ou backup) fechado.
class DatabaseFileInspection {
  const DatabaseFileInspection({
    required this.userVersion,
    required this.integrity,
    this.deviceId,
    this.deviceName,
    this.lastHlc,
  });

  /// `PRAGMA user_version`: a versão do schema.
  final int userVersion;

  /// Resultado do `PRAGMA integrity_check` (`ok` quando íntegro).
  final String integrity;
  final String? deviceId;
  final String? deviceName;
  final String? lastHlc;

  bool get integrityOk => integrity == 'ok';
}

/// Único ponto que abre um arquivo de banco fora da conexão do app: lê a
/// versão do schema antes de migrar, confere backups antes de registrar ou
/// restaurar e converte entre banco aberto e criptografado (DECISIONS D-24,
/// item 1). Com o banco criptografado (F5B), a chave entra aqui.
abstract final class DatabaseFileInspector {
  /// Os 16 primeiros bytes de um banco SQLite sem criptografia.
  static const _plainHeader = 'SQLite format 3\u0000';

  /// O arquivo é um banco SQLite sem criptografia (ou está vazio). Um banco
  /// do SQLCipher começa com bytes aleatórios (o sal).
  static bool isPlaintext(String path) {
    final file = File(path);
    if (!file.existsSync() || file.lengthSync() == 0) return true;
    final raf = file.openSync();
    try {
      final head = raf.readSync(16);
      return head.length == 16 && String.fromCharCodes(head) == _plainHeader;
    } finally {
      raf.closeSync();
    }
  }

  /// Só a versão do schema.
  static int userVersion(String path, {DatabaseKey? key}) =>
      withDatabase(path, key: key, (db) => _userVersion(db));

  /// Versão, integridade e identidade do dispositivo (se houver).
  static DatabaseFileInspection inspect(String path, {DatabaseKey? key}) {
    return withDatabase(path, key: key, (db) {
      final version = _userVersion(db);
      final integrity = db
          .select('PRAGMA integrity_check')
          .map((r) => '${r.columnAt(0)}')
          .join('; ');
      String? deviceId;
      String? deviceName;
      String? lastHlc;
      final hasIdentity = db
          .select(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' "
            "AND name = 'dev_identity'",
          )
          .isNotEmpty;
      if (hasIdentity) {
        final rows = db.select(
          'SELECT device_id, device_name, last_hlc FROM dev_identity LIMIT 1',
        );
        if (rows.isNotEmpty) {
          deviceId = rows.first['device_id'] as String?;
          deviceName = rows.first['device_name'] as String?;
          lastHlc = rows.first['last_hlc'] as String?;
        }
      }
      return DatabaseFileInspection(
        userVersion: version,
        integrity: integrity,
        deviceId: deviceId,
        deviceName: deviceName,
        lastHlc: lastHlc,
      );
    });
  }

  /// Quantos registros cada tabela tem (para conferir uma conversão).
  static Map<String, int> rowCounts(String path, {DatabaseKey? key}) =>
      withDatabase(path, key: key, _rowCounts);

  /// Abre [path] (somente leitura, por padrão), aplica a [key] se houver,
  /// confere que o arquivo é legível e roda [action]. Lança [DataError] se o
  /// arquivo não for um banco, estiver corrompido ou a chave não servir.
  static T withDatabase<T>(
    String path,
    T Function(Database db) action, {
    DatabaseKey? key,
    bool readOnly = true,
  }) {
    Database? db;
    try {
      db = sqlite3.open(
        path,
        mode: readOnly ? OpenMode.readOnly : OpenMode.readWriteCreate,
      );
      if (key != null) db.execute('PRAGMA key = ${key.pragmaValue}');
      db.select('SELECT count(*) FROM sqlite_master');
      return action(db);
    } on SqliteException catch (error) {
      throw DataError(
        key == null && !isPlaintext(path)
            ? 'O arquivo está criptografado e precisa da chave para ser '
                  'aberto.'
            : 'O arquivo não é um banco do Patrion, está corrompido ou a '
                  'chave não confere.',
        cause: error,
      );
    } finally {
      db?.close();
    }
  }

  /// Copia [source] (aberto com [sourceKey], ou sem chave) para um arquivo
  /// novo [target], criptografado com [targetKey] (ou sem criptografia), com
  /// `sqlcipher_export`. Copia também o `user_version`, que o
  /// `sqlcipher_export` não leva, e confere a cópia: integridade, versão e
  /// contagem de registros de cada tabela. Se algo falhar, apaga [target] e
  /// lança [DataError]. [source] precisa estar fechado.
  static void convert({
    required String source,
    required String target,
    DatabaseKey? sourceKey,
    DatabaseKey? targetKey,
  }) {
    _deleteQuietly(target);
    try {
      final expected = rowCounts(source, key: sourceKey);
      final version = userVersion(source, key: sourceKey);
      withDatabase(source, key: sourceKey, readOnly: false, (db) {
        db
          ..execute(
            'ATTACH DATABASE ? AS converted KEY '
            '${targetKey?.pragmaValue ?? "''"}',
            [target],
          )
          ..execute("SELECT sqlcipher_export('converted')")
          ..execute('PRAGMA converted.user_version = $version')
          ..execute('DETACH DATABASE converted');
      });
      final check = inspect(target, key: targetKey);
      if (!check.integrityOk) {
        throw StateError('integrity_check: ${check.integrity}');
      }
      if (check.userVersion != version) {
        throw StateError('versão ${check.userVersion}, esperada $version');
      }
      final counts = rowCounts(target, key: targetKey);
      if (counts.length != expected.length ||
          expected.entries.any((e) => counts[e.key] != e.value)) {
        throw StateError('contagem de registros diferente na cópia');
      }
      if ((targetKey != null) == isPlaintext(target)) {
        throw StateError('criptografia da cópia diferente da pedida');
      }
    } catch (error) {
      _deleteQuietly(target);
      if (error is DataError) rethrow;
      throw DataError(
        'Não foi possível converter o banco. Os dados não foram alterados.',
        cause: error,
      );
    }
  }

  static Map<String, int> _rowCounts(Database db) {
    final tables = db
        .select(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .map((r) => r['name'] as String);
    return {
      for (final t in tables)
        t: db.select('SELECT count(*) AS n FROM "$t"').single['n'] as int,
    };
  }

  static int _userVersion(Database db) =>
      db.select('PRAGMA user_version').single.columnAt(0) as int;

  static void _deleteQuietly(String path) {
    for (final suffix in ['', '-journal', '-wal', '-shm']) {
      try {
        final f = File('$path$suffix');
        if (f.existsSync()) f.deleteSync();
      } on FileSystemException {
        // O erro original é o que importa.
      }
    }
  }
}
