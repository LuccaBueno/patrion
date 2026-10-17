import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/config/launch_options.dart';
import 'package:patrion/infrastructure/system/app_paths_resolver.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('patrion_paths_');
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('padrão: %APPDATA%\\Patrion e %LOCALAPPDATA%\\Patrion\\cache', () async {
    final roaming = p.join(dir.path, 'Roaming');
    final local = p.join(dir.path, 'Local');
    final paths = await AppPathsResolver(
      environment: {'APPDATA': roaming, 'LOCALAPPDATA': local},
    ).resolve(const LaunchOptions());

    expect(paths.dataDir, p.join(roaming, 'Patrion'));
    expect(paths.databaseFile, p.join(roaming, 'Patrion', 'patrion.db'));
    expect(paths.backupsDir, p.join(roaming, 'Patrion', 'backups'));
    expect(paths.logsDir, p.join(roaming, 'Patrion', 'logs'));
    expect(paths.cacheDir, p.join(local, 'Patrion', 'cache'));
    for (final d in [
      paths.dataDir,
      paths.backupsDir,
      paths.logsDir,
      paths.cacheDir,
    ]) {
      expect(Directory(d).existsSync(), isTrue, reason: d);
    }
  });

  test('--data-dir e --cache-dir têm prioridade', () async {
    final data = p.join(dir.path, 'dadosB');
    final cache = p.join(dir.path, 'cacheB');
    final paths = await AppPathsResolver(
      environment: {'APPDATA': 'X:\\nao-usar', 'LOCALAPPDATA': 'X:\\nao-usar'},
    ).resolve(LaunchOptions(dataDir: data, cacheDir: cache));

    expect(paths.dataDir, data);
    expect(paths.cacheDir, cache);
    expect(Directory(paths.logsDir).existsSync(), isTrue);
  });
}
