import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Chave de assinatura das Releases, em texto de uma linha:
/// `patrion-update-key-v1:<Base64 de keyId (8 bytes) + semente (32 bytes)>`.
class SigningKey {
  SigningKey(this.keyId, this.seed);

  factory SigningKey.generate() {
    final random = Random.secure();
    List<int> bytes(int n) => [for (var i = 0; i < n; i++) random.nextInt(256)];
    return SigningKey(bytes(8), bytes(32));
  }

  factory SigningKey.parse(String text) {
    final t = text.trim();
    if (!t.startsWith(_prefix)) {
      throw const FormatException('Chave de assinatura ilegível.');
    }
    final raw = base64.decode(t.substring(_prefix.length));
    if (raw.length != 40) {
      throw const FormatException('Chave de assinatura ilegível.');
    }
    return SigningKey(raw.sublist(0, 8), raw.sublist(8));
  }

  static const _prefix = 'patrion-update-key-v1:';

  final List<int> keyId;
  final List<int> seed;

  String encode() => '$_prefix${base64.encode([...keyId, ...seed])}';

  Future<SimpleKeyPair> _pair() => Ed25519().newKeyPairFromSeed(seed);

  /// Chave pública no formato do minisign (Base64 de `Ed` + keyId + chave).
  Future<String> publicKey() async {
    final public = await (await _pair()).extractPublicKey();
    return base64.encode([0x45, 0x64, ...keyId, ...public.bytes]);
  }

  /// Conteúdo do `.minisig` de [message].
  Future<String> sign(List<int> message, {required String comment}) async {
    if (comment.contains('\n')) {
      throw const FormatException('O comentário deve ter uma linha.');
    }
    final pair = await _pair();
    final digest = await Blake2b().hash(message);
    final signature = await Ed25519().sign(digest.bytes, keyPair: pair);
    final global = await Ed25519().sign([
      ...signature.bytes,
      ...utf8.encode(comment),
    ], keyPair: pair);
    final signed = [0x45, 0x44, ...keyId, ...signature.bytes];
    return 'untrusted comment: assinatura do Patrion\n'
        '${base64.encode(signed)}\n'
        'trusted comment: $comment\n'
        '${base64.encode(global.bytes)}\n';
  }
}
