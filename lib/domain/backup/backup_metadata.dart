import '../../core/errors/app_error.dart';

/// Motivo de um backup (SPEC §11). O código vai no nome do arquivo e em
/// `dev_backups.reason`.
enum BackupReason {
  manual('manual', 'Manual'),
  preMigration('pre-migracao', 'Antes de atualizar o banco'),
  preImport('pre-importacao', 'Antes de importar um save'),
  preRestore('pre-restauracao', 'Antes de restaurar um backup'),
  preLock('pre-bloqueio', 'Antes de ativar o bloqueio'),
  preUnlock('pre-desbloqueio', 'Antes de desativar o bloqueio');

  const BackupReason(this.code, this.label);

  final String code;
  final String label;

  /// Automáticos têm retenção limitada; manuais nunca são apagados pelo app.
  bool get isAutomatic => this != manual;

  static BackupReason? fromCode(String code) {
    for (final r in values) {
      if (r.code == code) return r;
    }
    return null;
  }
}

/// Metadados de um backup, gravados ao lado do arquivo (`<backup>.json`) e em
/// `dev_backups`.
///
/// [encryption] é `none` ou `sqlcipher-4` (F5B, DECISIONS D-32); com
/// o banco criptografado, [keyId] diz qual chave abre o arquivo, e uma cópia
/// do arquivo de chaves fica ao lado (`<backup>.keys.json`).
class BackupMetadata {
  const BackupMetadata({
    required this.createdAt,
    required this.reason,
    required this.schemaVersion,
    required this.appVersion,
    required this.deviceId,
    required this.deviceName,
    required this.size,
    required this.sha256,
    this.encryption = encryptionNone,
    this.keyId,
  });

  static const formatId = 'patrion-backup';
  static const formatVersion = 1;
  static const encryptionNone = 'none';
  static const encryptionSqlcipher = 'sqlcipher-4';

  /// Instante UTC (ISO-8601 com ms).
  final String createdAt;
  final BackupReason reason;
  final int schemaVersion;
  final String appVersion;
  final String? deviceId;
  final String? deviceName;
  final int size;
  final String sha256;
  final String encryption;

  /// Chave do banco usada (`KeyFile.keyId`), se criptografado.
  final String? keyId;

  bool get encrypted => encryption != encryptionNone;

  Map<String, Object?> toJson() => {
    'format': formatId,
    'formatVersion': formatVersion,
    'createdAt': createdAt,
    'reason': reason.code,
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'device': {'id': deviceId, 'name': deviceName},
    'size': size,
    'sha256': sha256,
    'encryption': {'scheme': encryption, 'keyId': ?keyId},
  };

  factory BackupMetadata.fromJson(Object? json) {
    Never invalid() => throw const DataError(
      'Os metadados do backup (arquivo .json ao lado) estão inválidos.',
    );
    if (json is! Map<String, Object?> || json['format'] != formatId) {
      invalid();
    }
    final reason = BackupReason.fromCode('${json['reason']}');
    final device = json['device'];
    final encryption = json['encryption'];
    final schema = json['schemaVersion'];
    final size = json['size'];
    final sha = json['sha256'];
    final createdAt = json['createdAt'];
    final appVersion = json['appVersion'];
    if (reason == null ||
        schema is! int ||
        size is! int ||
        sha is! String ||
        createdAt is! String ||
        appVersion is! String ||
        encryption is! Map<String, Object?> ||
        encryption['scheme'] is! String) {
      invalid();
    }
    return BackupMetadata(
      createdAt: createdAt,
      reason: reason,
      schemaVersion: schema,
      appVersion: appVersion,
      deviceId: device is Map<String, Object?> ? device['id'] as String? : null,
      deviceName: device is Map<String, Object?>
          ? device['name'] as String?
          : null,
      size: size,
      sha256: sha,
      encryption: encryption['scheme']! as String,
      keyId: encryption['keyId'] as String?,
    );
  }
}
