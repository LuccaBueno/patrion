import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../errors/app_error.dart';

/// Parâmetros da derivação de chave a partir de uma senha (Argon2id,
/// DECISIONS D-32). Ficam gravados junto com o dado protegido, então podem
/// subir no futuro sem quebrar arquivos antigos.
class KdfParams {
  const KdfParams({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.salt,
  });

  static const algorithm = 'argon2id';

  /// Parâmetros de produção: 64 MiB, 3 passadas, paralelismo 1.
  factory KdfParams.standard(Uint8List salt) =>
      KdfParams(memoryKiB: 65536, iterations: 3, parallelism: 1, salt: salt);

  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final Uint8List salt;

  Map<String, Object?> toJson() => {
    'algorithm': algorithm,
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
    'salt': base64.encode(salt),
  };

  factory KdfParams.fromJson(Object? json) {
    if (json is! Map<String, Object?> || json['algorithm'] != algorithm) {
      throw const DataError('Parâmetros de derivação de chave inválidos.');
    }
    final memory = json['memoryKiB'];
    final iterations = json['iterations'];
    final parallelism = json['parallelism'];
    final salt = json['salt'];
    if (memory is! int ||
        iterations is! int ||
        parallelism is! int ||
        salt is! String ||
        memory < 8 ||
        iterations < 1 ||
        parallelism < 1 ||
        // Limite contra arquivos que pediriam memória absurda.
        memory > 4 * 1024 * 1024) {
      throw const DataError('Parâmetros de derivação de chave inválidos.');
    }
    return KdfParams(
      memoryKiB: memory,
      iterations: iterations,
      parallelism: parallelism,
      salt: CryptoBox.decodeBase64(salt),
    );
  }
}

/// Como gerar os parâmetros da derivação. Produção usa [standard]; os testes
/// usam [fastForTests], com pouca memória, para rodar rápido.
class KdfPolicy {
  const KdfPolicy._(this._memoryKiB, this._iterations);

  static const standard = KdfPolicy._(65536, 3);

  /// Só para testes: 64 KiB e 1 passada.
  static const fastForTests = KdfPolicy._(64, 1);

  final int _memoryKiB;
  final int _iterations;

  KdfParams newParams() => KdfParams(
    memoryKiB: _memoryKiB,
    iterations: _iterations,
    parallelism: 1,
    salt: CryptoBox.randomBytes(16),
  );
}

/// Falha ao abrir um dado protegido: senha ou chave errada, ou dado alterado
/// (o AES-GCM não distingue os dois casos).
class WrongSecretError implements Exception {
  const WrongSecretError();

  @override
  String toString() => 'WrongSecretError';
}

/// Primitivas de criptografia (DECISIONS D-32): números aleatórios do
/// sistema, Argon2id e AES-256-GCM. Dart puro (`pointycastle`).
abstract final class CryptoBox {
  static const nonceLength = 12;
  static const keyLength = 32;
  static const aead = 'aes-256-gcm';

  static final _random = Random.secure();

  static Uint8List randomBytes(int length) {
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = _random.nextInt(256);
    }
    return out;
  }

  /// Deriva 32 bytes de [secret] (UTF-8) com Argon2id.
  static Uint8List deriveKey(String secret, KdfParams params) {
    final generator = Argon2BytesGenerator()
      ..init(
        Argon2Parameters(
          Argon2Parameters.ARGON2_id,
          params.salt,
          desiredKeyLength: keyLength,
          iterations: params.iterations,
          memory: params.memoryKiB,
          lanes: params.parallelism,
        ),
      );
    return generator.process(Uint8List.fromList(utf8.encode(secret)));
  }

  /// [deriveKey] num isolate separado, para a interface não travar (leva por
  /// volta de um segundo com os parâmetros de produção). Parâmetros pequenos
  /// (testes) derivam aqui mesmo.
  static Future<Uint8List> deriveKeyAsync(
    String secret,
    KdfParams params,
  ) async {
    if (params.memoryKiB < 8192) return deriveKey(secret, params);
    return Isolate.run(() => deriveKey(secret, params));
  }

  /// Cifra [plaintext] com AES-256-GCM. Devolve o texto cifrado seguido da
  /// etiqueta de autenticação (16 bytes).
  static Uint8List seal({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List plaintext,
    Uint8List? aad,
  }) => _gcm(true, key, nonce, aad).process(plaintext);

  /// Decifra e confere a etiqueta. Lança [WrongSecretError] se a chave
  /// estiver errada ou o dado tiver sido alterado.
  static Uint8List open({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List sealed,
    Uint8List? aad,
  }) {
    try {
      return _gcm(false, key, nonce, aad).process(sealed);
    } on InvalidCipherTextException {
      throw const WrongSecretError();
    } on ArgumentError {
      throw const WrongSecretError();
    }
  }

  static GCMBlockCipher _gcm(
    bool encrypt,
    Uint8List key,
    Uint8List nonce,
    Uint8List? aad,
  ) {
    if (key.length != keyLength || nonce.length != nonceLength) {
      throw ArgumentError('Tamanho de chave ou nonce inválido');
    }
    return GCMBlockCipher(AESEngine())..init(
      encrypt,
      AEADParameters(KeyParameter(key), 128, nonce, aad ?? Uint8List(0)),
    );
  }

  static Uint8List decodeBase64(String text) {
    try {
      return base64.decode(text);
    } on FormatException {
      throw const DataError('Dado em Base64 inválido.');
    }
  }

  /// Comparação em tempo constante.
  static bool equalBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
