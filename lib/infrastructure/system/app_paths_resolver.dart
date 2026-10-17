import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_paths.dart';
import '../../core/config/launch_options.dart';

/// Resolve as pastas de dados e de cache e garante que existam.
///
/// No Windows usa `%APPDATA%` e `%LOCALAPPDATA%` diretamente, para que o
/// caminho não dependa do nome da empresa gravado no executável. Em outras
/// plataformas (futuro), cai no `path_provider`.
class AppPathsResolver {
  const AppPathsResolver({this._environment});

  final Map<String, String>? _environment;

  Future<AppPaths> resolve(LaunchOptions options) async {
    final env = _environment ?? Platform.environment;
    final dataDir = options.dataDir != null
        ? p.absolute(options.dataDir!)
        : await _defaultDataDir(env);
    final cacheDir = options.cacheDir != null
        ? p.absolute(options.cacheDir!)
        : await _defaultCacheDir(env);
    final paths = AppPaths(dataDir: dataDir, cacheDir: cacheDir);
    for (final dir in [
      paths.dataDir,
      paths.backupsDir,
      paths.logsDir,
      paths.cacheDir,
    ]) {
      await Directory(dir).create(recursive: true);
    }
    return paths;
  }

  Future<String> _defaultDataDir(Map<String, String> env) async {
    final appData = env['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      return p.join(appData, AppPaths.appFolderName);
    }
    final support = await getApplicationSupportDirectory();
    return support.path;
  }

  Future<String> _defaultCacheDir(Map<String, String> env) async {
    final localAppData = env['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.join(localAppData, AppPaths.appFolderName, 'cache');
    }
    final cache = await getApplicationCacheDirectory();
    return cache.path;
  }
}
