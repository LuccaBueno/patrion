import 'dart:convert';
import 'dart:typed_data';

import '../../core/crypto/crypto_box.dart';
import '../../core/crypto/database_key.dart';
import '../../core/errors/app_error.dart';
import 'recovery_key.dart';

/// Uma cópia da chave do banco, cifrada com AES-256-GCM por uma chave
/// derivada (Argon2id) de um segredo: a senha ou a chave de recuperação.
class WrappedKey {
  const WrappedKey({
    required this.kdf,
    required this.nonce,
    required this.data,
  });

  final KdfParams kdf;
  final Uint8List nonce;

  /// Chave cifrada seguida da etiqueta do GCM.
  final Uint8List data;

  static Future<WrappedKey> wrap({
    required DatabaseKey key,
    required String secret,
    required KdfPolicy policy,
    required Uint8List aad,
  }) async {
    final kdf = policy.newParams();
    final wrappingKey = await CryptoBox.deriveKeyAsync(secret, kdf);
    final nonce = CryptoBox.randomBytes(CryptoBox.nonceLength);
    final data = CryptoBox.seal(
      key: wrappingKey,
      nonce: nonce,
      plaintext: key.bytes,
      aad: aad,
    );
    wrappingKey.fillRange(0, wrappingKey.length, 0);
    return WrappedKey(kdf: kdf, nonce: nonce, data: data);
  }

  /// Lança [WrongSecretError] se [secret] não for o segredo certo.
  Future<DatabaseKey> unwrap(String secret, Uint8List aad) async {
    final wrappingKey = await CryptoBox.deriveKeyAsync(secret, kdf);
    try {
      final bytes = CryptoBox.open(
        key: wrappingKey,
        nonce: nonce,
        sealed: data,
        aad: aad,
      );
      final key = DatabaseKey(bytes);
      bytes.fillRange(0, bytes.length, 0);
      return key;
    } finally {
      wrappingKey.fillRange(0, wrappingKey.length, 0);
    }
  }

  Map<String, Object?> toJson() => {
    'kdf': kdf.toJson(),
    'aead': CryptoBox.aead,
    'nonce': base64.encode(nonce),
    'data': base64.encode(data),
  };

  factory WrappedKey.fromJson(Object? json) {
    if (json is! Map<String, Object?> ||
        json['aead'] != CryptoBox.aead ||
        json['nonce'] is! String ||
        json['data'] is! String) {
      throw const DataError('O arquivo de chaves está inválido.');
    }
    return WrappedKey(
      kdf: KdfParams.fromJson(json['kdf']),
      nonce: CryptoBox.decodeBase64(json['nonce']! as String),
      data: CryptoBox.decodeBase64(json['data']! as String),
    );
  }
}

/// Resultado da ativação do bloqueio: o arquivo de chaves, a chave do banco
/// e a chave de recuperação (mostrada uma única vez).
class NewKeys {
  const NewKeys({
    required this.file,
    required this.key,
    required this.recoveryKey,
  });

  final KeyFile file;
  final DatabaseKey key;
  final String recoveryKey;
}

/// Arquivo de chaves do bloqueio (`patrion.keys.json`, SPEC §3, DECISIONS
/// D-24 e D-32): a chave do banco embrulhada pela senha e pela chave de
/// recuperação. Nunca contém a senha nem a chave do banco em claro.
///
/// Uma cópia vai ao lado de cada backup criptografado, para ele poder ser
/// aberto mesmo depois de o bloqueio ser desativado e ativado de novo (com
/// outra chave).
class KeyFile {
  const KeyFile({
    required this.keyId,
    required this.createdAt,
    required this.updatedAt,
    required this.password,
    required this.recovery,
    this.windowsHello = false,
  });

  static const formatId = 'patrion-keys';
  static const formatVersion = 1;

  /// Esquema dos bancos e backups protegidos por estas chaves.
  static const cipher = 'sqlcipher-4';

  /// Identifica a chave do banco (aleatório; não deriva da chave).
  final String keyId;
  final String createdAt;
  final String updatedAt;
  final WrappedKey password;
  final WrappedKey recovery;

  /// O desbloqueio pelo Windows Hello está ativado neste PC.
  final bool windowsHello;

  Uint8List _aad(String slot) => _aadOf(keyId, slot);

  static Uint8List _aadOf(String keyId, String slot) =>
      Uint8List.fromList(utf8.encode('$formatId/v$formatVersion/$slot/$keyId'));

  /// Gera a chave do banco, a chave de recuperação e o arquivo.
  static Future<NewKeys> create({
    required String password,
    required String now,
    KdfPolicy policy = KdfPolicy.standard,
  }) async {
    final key = DatabaseKey.random();
    final recoveryKey = RecoveryKey.format(
      CryptoBox.randomBytes(RecoveryKey.byteLength),
    );
    final keyId = _hex(CryptoBox.randomBytes(16));
    final results = await Future.wait([
      WrappedKey.wrap(
        key: key,
        secret: password,
        policy: policy,
        aad: _aadOf(keyId, 'password'),
      ),
      WrappedKey.wrap(
        key: key,
        secret: RecoveryKey.normalize(recoveryKey)!,
        policy: policy,
        aad: _aadOf(keyId, 'recovery'),
      ),
    ]);
    return NewKeys(
      file: KeyFile(
        keyId: keyId,
        createdAt: now,
        updatedAt: now,
        password: results[0],
        recovery: results[1],
      ),
      key: key,
      recoveryKey: recoveryKey,
    );
  }

  /// Lança [WrongSecretError] se a senha estiver errada.
  Future<DatabaseKey> unlockWithPassword(String secret) =>
      password.unwrap(secret, _aad('password'));

  /// Lança [WrongSecretError] se a chave estiver errada ou mal digitada.
  Future<DatabaseKey> unlockWithRecoveryKey(String typed) {
    final normalized = RecoveryKey.normalize(typed);
    if (normalized == null) throw const WrongSecretError();
    return recovery.unwrap(normalized, _aad('recovery'));
  }

  /// Nova senha para a mesma chave do banco (o banco não muda).
  Future<KeyFile> withPassword(
    DatabaseKey key,
    String newPassword, {
    required String now,
    KdfPolicy policy = KdfPolicy.standard,
  }) async => _copy(
    password: await WrappedKey.wrap(
      key: key,
      secret: newPassword,
      policy: policy,
      aad: _aad('password'),
    ),
    updatedAt: now,
  );

  /// Nova chave de recuperação; a anterior deixa de valer.
  Future<(KeyFile, String)> withNewRecoveryKey(
    DatabaseKey key, {
    required String now,
    KdfPolicy policy = KdfPolicy.standard,
  }) async {
    final recoveryKey = RecoveryKey.format(
      CryptoBox.randomBytes(RecoveryKey.byteLength),
    );
    final file = _copy(
      recovery: await WrappedKey.wrap(
        key: key,
        secret: RecoveryKey.normalize(recoveryKey)!,
        policy: policy,
        aad: _aad('recovery'),
      ),
      updatedAt: now,
    );
    return (file, recoveryKey);
  }

  KeyFile withWindowsHello(bool enabled, {required String now}) =>
      _copy(windowsHello: enabled, updatedAt: now);

  KeyFile _copy({
    WrappedKey? password,
    WrappedKey? recovery,
    bool? windowsHello,
    String? updatedAt,
  }) => KeyFile(
    keyId: keyId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    password: password ?? this.password,
    recovery: recovery ?? this.recovery,
    windowsHello: windowsHello ?? this.windowsHello,
  );

  Map<String, Object?> toJson() => {
    'format': formatId,
    'formatVersion': formatVersion,
    'cipher': cipher,
    'keyId': keyId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'slots': {'password': password.toJson(), 'recovery': recovery.toJson()},
    'windowsHello': windowsHello,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory KeyFile.fromJson(Object? json) {
    Never invalid() =>
        throw const DataError('O arquivo de chaves do Patrion está inválido.');
    if (json is! Map<String, Object?> || json['format'] != formatId) {
      invalid();
    }
    final version = json['formatVersion'];
    if (version is! int || version < 1) invalid();
    if (version > formatVersion) {
      throw const DataError(
        'O arquivo de chaves é de uma versão mais nova do Patrion. Atualize o '
        'aplicativo.',
      );
    }
    final slots = json['slots'];
    final keyId = json['keyId'];
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];
    if (json['cipher'] != cipher ||
        slots is! Map<String, Object?> ||
        keyId is! String ||
        keyId.isEmpty ||
        createdAt is! String ||
        updatedAt is! String) {
      invalid();
    }
    return KeyFile(
      keyId: keyId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      password: WrappedKey.fromJson(slots['password']),
      recovery: WrappedKey.fromJson(slots['recovery']),
      windowsHello: json['windowsHello'] == true,
    );
  }

  static KeyFile decode(String text) {
    try {
      return KeyFile.fromJson(jsonDecode(text));
    } on FormatException {
      throw const DataError('O arquivo de chaves do Patrion está ilegível.');
    }
  }

  static String _hex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
