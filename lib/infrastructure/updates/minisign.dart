import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Conferência de assinaturas no formato minisign (Ed25519 sobre o BLAKE2b-512
/// do arquivo; DECISIONS D-62). Só verifica: a chave privada nunca chega ao
/// app.
abstract final class Minisign {
  static const _keyIdLength = 8;
  static const _publicKeyLength = 32;
  static const _signatureLength = 64;
  static const _trustedPrefix = 'trusted comment: ';

  /// Confere [signatureFile] (conteúdo do `.minisig`) sobre [message] com uma
  /// das [publicKeys] (Base64, como o minisign imprime). Formato ilegível,
  /// chave desconhecida ou assinatura errada dão `false`, nunca exceção.
  static Future<bool> verify({
    required List<int> message,
    required String signatureFile,
    required Iterable<String> publicKeys,
  }) async {
    final lines = const LineSplitter().convert(signatureFile.trim());
    if (lines.length != 4 || !lines[2].startsWith(_trustedPrefix)) return false;
    final Uint8List signed;
    final Uint8List global;
    try {
      signed = base64.decode(lines[1].trim());
      global = base64.decode(lines[3].trim());
    } on FormatException {
      return false;
    }
    // "ED": só o modo com BLAKE2b, o padrão do minisign.
    if (signed.length != 2 + _keyIdLength + _signatureLength ||
        global.length != _signatureLength ||
        signed[0] != 0x45 ||
        signed[1] != 0x44) {
      return false;
    }
    final keyId = signed.sublist(2, 2 + _keyIdLength);
    final signature = signed.sublist(2 + _keyIdLength);
    final publicKey = _keyWithId(publicKeys, keyId);
    if (publicKey == null) return false;

    final digest = await Blake2b().hash(message);
    if (!await _check(digest.bytes, signature, publicKey)) return false;
    // A segunda assinatura cobre o comentário confiável.
    final comment = utf8.encode(lines[2].substring(_trustedPrefix.length));
    return _check([...signature, ...comment], global, publicKey);
  }

  static List<int>? _keyWithId(Iterable<String> keys, List<int> keyId) {
    for (final key in keys) {
      final Uint8List raw;
      try {
        raw = base64.decode(key);
      } on FormatException {
        continue;
      }
      if (raw.length != 2 + _keyIdLength + _publicKeyLength) continue;
      if (raw[0] != 0x45 || raw[1] != 0x64) continue; // "Ed"
      var same = true;
      for (var i = 0; i < _keyIdLength; i++) {
        same = same && raw[2 + i] == keyId[i];
      }
      if (same) return raw.sublist(2 + _keyIdLength);
    }
    return null;
  }

  static Future<bool> _check(
    List<int> message,
    List<int> signature,
    List<int> publicKey,
  ) => Ed25519().verify(
    message,
    signature: Signature(
      signature,
      publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
    ),
  );
}
