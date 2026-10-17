import 'dart:io';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../core/errors/app_error.dart';

final _log = Logger('backup');

/// Backup automático do banco antes de uma migração de schema (SPEC §11,
/// `docs/BANCO.md` §9).
///
/// Roda **antes** de o Drift abrir o banco: lê o `user_version` do arquivo
/// e, se ele for menor que a versão atual do app, grava uma cópia
/// consistente com `VACUUM INTO` na pasta de backups e confere a cópia
/// (`PRAGMA integrity_check` e versão). Se qualquer passo falhar, lança
/// [DataError] e o banco não é aberto, ou seja, a migração não acontece sem
/// um backup válido.
///
/// Guarda só os [keep] backups de migração mais recentes.
class PreMigrationBackup {
  const PreMigrationBackup({
    required this.backupsDir,
    required this.appVersion,
    this.keep = 10,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  /// Sufixo que identifica os backups de migração (para a retenção).
  static const reasonTag = 'pre-migracao';

  final String backupsDir;
  final String appVersion;
  final int keep;
  final Clock _clock;

  /// Prepara [databaseFile] para abrir na versão [targetVersion].
  ///
  /// Devolve o caminho do backup criado, ou `null` quando não há migração
  /// (banco novo ou já na versão atual). Lança [DataError] se o banco for de
  /// uma versão mais nova do app ou se o backup falhar.
  String? run({required String databaseFile, required int targetVersion}) {
    if (!File(databaseFile).existsSync()) return null;

    final fromVersion = _userVersion(databaseFile);
    if (fromVersion == 0 || fromVersion == targetVersion) return null;
    if (fromVersion > targetVersion) {
      throw DataError(
        'O banco de dados foi criado por uma versão mais nova do Patrion '
        '(schema $fromVersion; esta versão conhece até o $targetVersion). '
        'Atualize o aplicativo para abrir esses dados.',
      );
    }

    final target = p.join(
      backupsDir,
      fileNameFor(
        at: _clock.now(),
        fromVersion: fromVersion,
        toVersion: targetVersion,
        appVersion: appVersion,
      ),
    );
    try {
      Directory(backupsDir).createSync(recursive: true);
      final source = sqlite3.open(databaseFile, mode: OpenMode.readOnly);
      try {
        source.execute('VACUUM INTO ?', [target]);
      } finally {
        source.close();
      }
      _verify(target, fromVersion);
    } catch (error) {
      _deleteQuietly(target);
      _log.severe('Backup anterior à migração falhou', error);
      throw DataError(
        'Não foi possível fazer o backup do banco antes de atualizar o '
        'schema (versão $fromVersion para $targetVersion). Os dados não '
        'foram alterados.',
        cause: error,
      );
    }
    _log.info(
      'Backup antes da migração v$fromVersion→v$targetVersion: '
      '${p.basename(target)}',
    );
    _applyRetention();
    return target;
  }

  /// Nome do arquivo: data e hora UTC (ordenável), motivo, versões do schema
  /// e do app. Sem `:` (proibido em nomes de arquivo no Windows).
  static String fileNameFor({
    required DateTime at,
    required int fromVersion,
    required int toVersion,
    required String appVersion,
  }) {
    final u = at.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    final stamp =
        '${u.year}-${two(u.month)}-${two(u.day)}_'
        '${two(u.hour)}-${two(u.minute)}-${two(u.second)}-'
        '${u.millisecond.toString().padLeft(3, '0')}Z';
    return 'patrion_${stamp}_${reasonTag}_v$fromVersion-v${toVersion}_'
        'app-$appVersion.db';
  }

  static int _userVersion(String file) {
    final db = sqlite3.open(file, mode: OpenMode.readOnly);
    try {
      return db.select('PRAGMA user_version').single.columnAt(0) as int;
    } finally {
      db.close();
    }
  }

  static void _verify(String backup, int expectedVersion) {
    final db = sqlite3.open(backup, mode: OpenMode.readOnly);
    try {
      final check = db.select('PRAGMA integrity_check').first.columnAt(0);
      if (check != 'ok') {
        throw StateError('integrity_check: $check');
      }
      final version =
          db.select('PRAGMA user_version').single.columnAt(0) as int;
      if (version != expectedVersion) {
        throw StateError(
          'versão $version no backup, esperada $expectedVersion',
        );
      }
    } finally {
      db.close();
    }
  }

  void _applyRetention() {
    final files =
        Directory(backupsDir).listSync().whereType<File>().where((f) {
            final name = p.basename(f.path);
            return name.startsWith('patrion_') &&
                name.contains('_${reasonTag}_') &&
                name.endsWith('.db');
          }).toList()
          // O nome começa pela data UTC: ordem de nome = ordem cronológica.
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    for (final old in files.skip(keep)) {
      try {
        old.deleteSync();
      } on FileSystemException catch (error) {
        _log.warning('Não consegui apagar um backup antigo', error);
      }
    }
  }

  static void _deleteQuietly(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } on FileSystemException {
      // Nada a fazer: o erro original é o que importa.
    }
  }
}
