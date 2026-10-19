import 'package:path/path.dart' as p;

/// Pastas usadas pelo app (DECISIONS D-05).
///
/// ```
/// <dataDir>\        padrão %APPDATA%\Patrion
///   patrion.db
///   backups\
///   logs\
///   instance\       trava de instância única e pedidos de abertura (D-39)
/// <cacheDir>\       padrão %LOCALAPPDATA%\Patrion\cache
/// ```
class AppPaths {
  const AppPaths({required this.dataDir, required this.cacheDir});

  static const appFolderName = 'Patrion';
  static const databaseFileName = 'patrion.db';

  final String dataDir;
  final String cacheDir;

  String get databaseFile => p.join(dataDir, databaseFileName);
  String get backupsDir => p.join(dataDir, 'backups');
  String get logsDir => p.join(dataDir, 'logs');
  String get instanceDir => p.join(dataDir, 'instance');
}
