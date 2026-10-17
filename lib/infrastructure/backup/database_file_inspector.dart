import 'package:sqlite3/sqlite3.dart';

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
/// versão do schema antes de migrar e confere backups antes de registrar ou
/// restaurar (DECISIONS D-24, item 1). Com o banco criptografado (F5B), é aqui
/// que a chave entra.
abstract final class DatabaseFileInspector {
  /// Só a versão do schema.
  static int userVersion(String path) =>
      _withReadOnly(path, (db) => _userVersion(db));

  /// Versão, integridade e identidade do dispositivo (se houver).
  static DatabaseFileInspection inspect(String path) {
    return _withReadOnly(path, (db) {
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

  static int _userVersion(Database db) =>
      db.select('PRAGMA user_version').single.columnAt(0) as int;

  static T _withReadOnly<T>(String path, T Function(Database db) action) {
    Database? db;
    try {
      db = sqlite3.open(path, mode: OpenMode.readOnly);
      return action(db);
    } on SqliteException catch (error) {
      throw DataError(
        'O arquivo não é um banco do Patrion ou está corrompido.',
        cause: error,
      );
    } finally {
      db?.close();
    }
  }
}
