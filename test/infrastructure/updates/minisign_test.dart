import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/infrastructure/updates/minisign.dart';

import '../../../tool/signing/bin/signing.dart';

List<int> _hex(String s) => [
  for (var i = 0; i < s.length; i += 2)
    int.parse(s.substring(i, i + 2), radix: 16),
];

String _toHex(List<int> b) =>
    b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

void main() {
  // Semente do teste 1 da RFC 8032 (chave pública conhecida).
  final seed = _hex(
    '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
  );
  final key = SigningKey([1, 2, 3, 4, 5, 6, 7, 8], seed);
  final other = SigningKey([8, 7, 6, 5, 4, 3, 2, 1], List.filled(32, 7));
  final message = utf8.encode('abc  Patrion-1.5.0-instalador.exe\n');

  Future<bool> verify(String signature, {List<int>? on, List<String>? keys}) =>
      Minisign.verify(
        message: on ?? message,
        signatureFile: signature,
        publicKeys: keys ?? [_public],
      );

  late String signature;
  setUp(() async {
    _public = await key.publicKey();
    signature = await key.sign(message, comment: 'patrion 1.5.0');
  });

  test('primitivas: vetores da RFC 8032 e do BLAKE2b', () async {
    final pair = await Ed25519().newKeyPairFromSeed(seed);
    expect(
      _toHex((await pair.extractPublicKey()).bytes),
      'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
    );
    final signed = await Ed25519().sign(const [], keyPair: pair);
    expect(
      _toHex(signed.bytes),
      'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e06522490155'
      '5fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b',
    );
    expect(
      _toHex((await Blake2b().hash(utf8.encode('abc'))).bytes),
      'ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d1'
      '7d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923',
    );
  });

  test('a chave pública segue o formato do minisign', () {
    final raw = base64.decode(_public);
    expect(raw, hasLength(42));
    expect(ascii.decode(raw.sublist(0, 2)), 'Ed');
    expect(raw.sublist(2, 10), [1, 2, 3, 4, 5, 6, 7, 8]);
  });

  test('aceita a assinatura certa, com a chave entre outras', () async {
    expect(await verify(signature), isTrue);
    expect(
      await verify(signature, keys: [await other.publicKey(), _public]),
      isTrue,
    );
  });

  test('recusa o arquivo alterado em um byte', () async {
    final changed = [...message]..[0] ^= 1;
    expect(await verify(signature, on: changed), isFalse);
  });

  test('recusa assinatura de outra chave, mesmo com o mesmo id', () async {
    final impostor = SigningKey(key.keyId, other.seed);
    expect(
      await verify(await impostor.sign(message, comment: 'patrion 1.5.0')),
      isFalse,
    );
    expect(await verify(await other.sign(message, comment: 'x')), isFalse);
  });

  test('sem nenhuma chave embutida, nada é aceito', () async {
    expect(await verify(signature, keys: const []), isFalse);
  });

  test('recusa comentário confiável alterado', () async {
    expect(await verify(signature.replaceFirst('1.5.0', '9.9.9')), isFalse);
  });

  test('recusa o modo antigo sem BLAKE2b', () async {
    final lines = signature.split('\n');
    final raw = base64.decode(lines[1]);
    raw[1] = 0x64; // "Ed"
    lines[1] = base64.encode(raw);
    expect(await verify(lines.join('\n')), isFalse);
  });

  test('arquivo ilegível é recusado sem exceção', () async {
    for (final bad in [
      '',
      'lixo',
      'a\nb\nc\nd',
      'a\n!!\ntrusted comment: x\n!!',
    ]) {
      expect(await verify(bad), isFalse, reason: bad);
    }
  });
}

late String _public;
