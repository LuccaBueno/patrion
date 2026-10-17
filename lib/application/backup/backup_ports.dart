import '../../domain/backup/backup_metadata.dart';

/// Dados de um arquivo de backup, lidos do próprio arquivo.
class BackupFileInfo {
  const BackupFileInfo({
    required this.schemaVersion,
    required this.integrity,
    required this.size,
    required this.sha256,
    this.deviceId,
    this.deviceName,
    this.lastHlc,
  });

  final int schemaVersion;

  /// `ok` quando o `PRAGMA integrity_check` passa.
  final String integrity;
  final int size;
  final String sha256;
  final String? deviceId;
  final String? deviceName;
  final String? lastHlc;

  bool get integrityOk => integrity == 'ok';
}

/// Operações de arquivo dos backups (implementadas em
/// `infrastructure/backup/`).
abstract interface class BackupFileSystem {
  /// Caminho de um backup novo em [directory]: data UTC (ordenável), motivo,
  /// schema e versão do app no nome.
  String newBackupPath({
    required String directory,
    required BackupReason reason,
    required DateTime at,
    required int schemaVersion,
    required String appVersion,
  });

  /// Lê versão, integridade, tamanho e SHA-256. Lança `DataError` se o
  /// arquivo não for um banco legível.
  BackupFileInfo inspect(String path);

  void writeMetadata(String backupPath, BackupMetadata metadata);

  /// Metadados gravados ao lado do backup, se existirem.
  BackupMetadata? readMetadata(String backupPath);

  /// Apaga os backups de [reason] em [directory] além dos [keep] mais
  /// recentes e devolve os caminhos apagados.
  List<String> applyRetention({
    required String directory,
    required BackupReason reason,
    required int keep,
  });

  bool exists(String path);

  void delete(String path);

  /// Substitui [databaseFile] pelo conteúdo de [backup]: copia para um
  /// arquivo temporário na mesma pasta e só então troca. O banco precisa
  /// estar fechado.
  void replaceDatabase({required String backup, required String databaseFile});
}
