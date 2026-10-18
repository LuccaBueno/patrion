import 'dart:io';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../core/crypto/database_key.dart';
import '../../core/errors/app_error.dart';
import '../../core/time/instant_format.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../domain/security/key_file.dart';
import 'database_file_inspector.dart';
import 'local_backup_file_system.dart';

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
/// Grava os metadados ao lado da cópia (`<backup>.json`); o registro em
/// `dev_backups` é feito depois que o banco abre (`BackupService`).
/// Guarda só os [keep] backups de migração mais recentes.
class PreMigrationBackup {
  const PreMigrationBackup({
    required this.backupsDir,
    required this.appVersion,
    this.keep = 10,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  /// Sufixo que identifica os backups de migração (para a retenção).
  static final reasonTag = BackupReason.preMigration.code;

  final String backupsDir;
  final String appVersion;
  final int keep;
  final Clock _clock;

  /// Prepara [databaseFile] para abrir na versão [targetVersion].
  ///
  /// Devolve o caminho do backup criado, ou `null` quando não há migração
  /// (banco novo ou já na versão atual). Lança [DataError] se o banco for de
  /// uma versão mais nova do app ou se o backup falhar.
  ///
  /// Com o banco criptografado, [key] abre o arquivo; a cópia sai
  /// criptografada com a mesma chave (`VACUUM INTO` do SQLCipher) e leva ao
  /// lado uma cópia de [keys].
  String? run({
    required String databaseFile,
    required int targetVersion,
    DatabaseKey? key,
    KeyFile? keys,
  }) {
    if (!File(databaseFile).existsSync()) return null;

    final fromVersion = DatabaseFileInspector.userVersion(
      databaseFile,
      key: key,
    );
    if (fromVersion == 0 || fromVersion == targetVersion) return null;
    if (fromVersion > targetVersion) {
      throw DataError(
        'O banco de dados foi criado por uma versão mais nova do Patrion '
        '(schema $fromVersion; esta versão conhece até o $targetVersion). '
        'Atualize o aplicativo para abrir esses dados.',
      );
    }

    final at = _clock.now();
    final target = p.join(
      backupsDir,
      fileNameFor(
        at: at,
        fromVersion: fromVersion,
        toVersion: targetVersion,
        appVersion: appVersion,
      ),
    );
    try {
      Directory(backupsDir).createSync(recursive: true);
      DatabaseFileInspector.withDatabase(
        databaseFile,
        key: key,
        (source) => source.execute('VACUUM INTO ?', [target]),
      );
      final check = DatabaseFileInspector.inspect(target, key: key);
      if (!check.integrityOk) {
        throw StateError('integrity_check: ${check.integrity}');
      }
      if (check.userVersion != fromVersion) {
        throw StateError(
          'versão ${check.userVersion} no backup, esperada $fromVersion',
        );
      }
      final bytes = File(target).readAsBytesSync();
      const LocalBackupFileSystem().writeMetadata(
        target,
        BackupMetadata(
          createdAt: formatInstant(at),
          reason: BackupReason.preMigration,
          schemaVersion: fromVersion,
          appVersion: appVersion,
          deviceId: check.deviceId,
          deviceName: check.deviceName,
          size: bytes.length,
          sha256: sha256.convert(bytes).toString(),
          encryption: key == null
              ? BackupMetadata.encryptionNone
              : BackupMetadata.encryptionSqlcipher,
          keyId: keys?.keyId,
        ),
      );
      if (key != null && keys != null) {
        const LocalBackupFileSystem().writeKeyFile(target, keys);
      }
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
    LocalBackupFileSystem.retain(
      directory: backupsDir,
      reasonCode: reasonTag,
      keep: keep,
    );
    return target;
  }

  /// Nome do arquivo: data e hora UTC (ordenável), motivo, versões do schema
  /// e do app. Sem `:` (proibido em nomes de arquivo no Windows).
  static String fileNameFor({
    required DateTime at,
    required int fromVersion,
    required int toVersion,
    required String appVersion,
  }) =>
      'patrion_${LocalBackupFileSystem.stampOf(at)}_${reasonTag}_'
      'v$fromVersion-v${toVersion}_app-$appVersion.db';

  static void _deleteQuietly(String path) {
    try {
      const LocalBackupFileSystem().delete(path);
    } on FileSystemException {
      // Nada a fazer: o erro original é o que importa.
    }
  }
}
