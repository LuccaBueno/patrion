import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../application/backup/backup_ports.dart';
import '../../core/errors/app_error.dart';
import '../../core/crypto/database_key.dart';
import '../../domain/backup/backup_metadata.dart';
import '../../domain/security/key_file.dart';
import '../security/key_file_store.dart';
import 'database_file_inspector.dart';

final _log = Logger('backup');

/// Backups em arquivos locais (SPEC §11).
///
/// Cada backup `patrion_<data>_<motivo>_....db` tem ao lado um
/// `patrion_<data>_<motivo>_....db.json` com os metadados ([BackupMetadata]).
class LocalBackupFileSystem implements BackupFileSystem {
  const LocalBackupFileSystem();

  static String metadataPathOf(String backupPath) => '$backupPath.json';

  static String keyFilePathOf(String backupPath) =>
      '${p.withoutExtension(backupPath)}.keys.json';

  /// Data e hora UTC para o nome do arquivo: ordenável e sem `:` (proibido
  /// em nomes de arquivo no Windows).
  static String stampOf(DateTime at) {
    final u = at.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}-${two(u.month)}-${two(u.day)}_'
        '${two(u.hour)}-${two(u.minute)}-${two(u.second)}-'
        '${u.millisecond.toString().padLeft(3, '0')}Z';
  }

  @override
  String newBackupPath({
    required String directory,
    required BackupReason reason,
    required DateTime at,
    required int schemaVersion,
    required String appVersion,
  }) {
    Directory(directory).createSync(recursive: true);
    final base =
        'patrion_${stampOf(at)}_${reason.code}_schema-v${schemaVersion}_'
        'app-$appVersion';
    var path = p.join(directory, '$base.db');
    for (var i = 2; File(path).existsSync(); i++) {
      path = p.join(directory, '${base}_$i.db');
    }
    return path;
  }

  @override
  BackupFileInfo inspect(String path, {DatabaseKey? key}) {
    final file = File(path);
    if (!file.existsSync()) {
      throw const DataError('O arquivo de backup não existe.');
    }
    final inspection = DatabaseFileInspector.inspect(path, key: key);
    return BackupFileInfo(
      schemaVersion: inspection.userVersion,
      integrity: inspection.integrity,
      size: file.lengthSync(),
      sha256: sha256.convert(file.readAsBytesSync()).toString(),
      deviceId: inspection.deviceId,
      deviceName: inspection.deviceName,
      lastHlc: inspection.lastHlc,
    );
  }

  @override
  void writeMetadata(String backupPath, BackupMetadata metadata) {
    File(metadataPathOf(backupPath)).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(metadata.toJson()),
    );
  }

  @override
  BackupMetadata? readMetadata(String backupPath) {
    final file = File(metadataPathOf(backupPath));
    if (!file.existsSync()) return null;
    try {
      return BackupMetadata.fromJson(jsonDecode(file.readAsStringSync()));
    } on FormatException {
      throw const DataError('Os metadados do backup estão ilegíveis.');
    }
  }

  @override
  List<String> applyRetention({
    required String directory,
    required BackupReason reason,
    required int keep,
  }) => retain(directory: directory, reasonCode: reason.code, keep: keep);

  /// Retenção por motivo: o nome começa pela data UTC, então ordem de nome é
  /// ordem cronológica. Apaga também o `.json` e o `.keys.json` ao lado.
  static List<String> retain({
    required String directory,
    required String reasonCode,
    required int keep,
  }) {
    final dir = Directory(directory);
    if (!dir.existsSync()) return const [];
    final files =
        dir.listSync().whereType<File>().where((f) {
            final name = p.basename(f.path);
            return name.startsWith('patrion_') &&
                name.contains('_${reasonCode}_') &&
                name.endsWith('.db');
          }).toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    final removed = <String>[];
    for (final old in files.skip(keep)) {
      try {
        old.deleteSync();
        for (final side in [
          File(metadataPathOf(old.path)),
          File(keyFilePathOf(old.path)),
        ]) {
          if (side.existsSync()) side.deleteSync();
        }
        removed.add(old.path);
      } on FileSystemException catch (error) {
        _log.warning('Não consegui apagar um backup antigo', error);
      }
    }
    return removed;
  }

  @override
  bool exists(String path) => File(path).existsSync();

  @override
  void delete(String path) {
    for (final f in [
      File(path),
      File(metadataPathOf(path)),
      File(keyFilePathOf(path)),
    ]) {
      if (f.existsSync()) f.deleteSync();
    }
  }

  @override
  bool isPlaintext(String path) => DatabaseFileInspector.isPlaintext(path);

  @override
  void writeKeyFile(String backupPath, KeyFile keys) =>
      KeyFileStore.writeAt(keyFilePathOf(backupPath), keys);

  @override
  KeyFile? readKeyFile(String backupPath) =>
      KeyFileStore.readAt(keyFilePathOf(backupPath));

  @override
  void replaceDatabase({
    required String backup,
    required String databaseFile,
    DatabaseKey? backupKey,
    DatabaseKey? databaseKey,
  }) {
    final temp = '$databaseFile.restaurando';
    final sameKey =
        (backupKey == null && databaseKey == null) ||
        (backupKey != null && backupKey.sameAs(databaseKey));
    if (sameKey) {
      File(backup).copySync(temp);
      try {
        final check = DatabaseFileInspector.inspect(temp, key: databaseKey);
        if (!check.integrityOk) {
          throw DataError('integrity_check: ${check.integrity}');
        }
      } catch (_) {
        File(temp).deleteSync();
        rethrow;
      }
    } else {
      // Backup com outra chave (ou sem criptografia): convertido para a
      // criptografia atual do banco e conferido.
      DatabaseFileInspector.convert(
        source: backup,
        sourceKey: backupKey,
        target: temp,
        targetKey: databaseKey,
      );
    }
    // Arquivos auxiliares do SQLite do banco antigo não podem sobrar.
    for (final suffix in ['', '-journal', '-wal', '-shm']) {
      final f = File('$databaseFile$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    File(temp).renameSync(databaseFile);
  }

  @override
  void encryptInPlace(String path, DatabaseKey key) {
    final temp = '$path.criptografando';
    DatabaseFileInspector.convert(source: path, target: temp, targetKey: key);
    File(path).deleteSync();
    File(temp).renameSync(path);
  }
}
