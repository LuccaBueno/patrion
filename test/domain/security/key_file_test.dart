import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/crypto/crypto_box.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/domain/security/key_file.dart';
import 'package:patrion/domain/security/recovery_key.dart';

/// Arquivo de chaves e chave de recuperação (SPEC §3, DECISIONS D-32).
void main() {
  const now = '2026-10-18T12:00:00.000Z';

  group('KeyFile', () {
    test('com os parâmetros de produção (Argon2id 64 MiB, 3 passadas): a '
        'senha certa abre, a errada não', () async {
      final created = await KeyFile.create(password: 'senha-forte-1', now: now);
      final kdf = created.file.password.kdf;
      expect(kdf.memoryKiB, 65536);
      expect(kdf.iterations, 3);
      expect(kdf.parallelism, 1);
      expect(kdf.salt, hasLength(16));

      final key = await created.file.unlockWithPassword('senha-forte-1');
      expect(key.sameAs(created.key), isTrue);
      await expectLater(
        created.file.unlockWithPassword('senha-forte-2'),
        throwsA(isA<WrongSecretError>()),
      );
    });

    final fast = KdfPolicy.fastForTests;

    test('ida e volta em JSON; a chave de recuperação abre', () async {
      final created = await KeyFile.create(
        password: 'abc12345',
        now: now,
        policy: fast,
      );
      final decoded = KeyFile.decode(created.file.encode());
      expect(decoded.keyId, created.file.keyId);
      expect(
        (await decoded.unlockWithRecoveryKey(created.recoveryKey))
            .sameAs(created.key),
        isTrue,
      );
      // Sais diferentes em cada cópia.
      expect(decoded.password.kdf.salt, isNot(decoded.recovery.kdf.salt));
    });

    test(
      'a cópia da senha não serve no lugar da de recuperação (AAD)',
      () async {
        final created = await KeyFile.create(
          password: 'abc12345',
          now: now,
          policy: fast,
        );
        final json = created.file.toJson();
        final slots = json['slots']! as Map<String, Object?>;
        final swapped = KeyFile.fromJson({
          ...json,
          'slots': {
            'password': slots['recovery'],
            'recovery': slots['password'],
          },
        });
        await expectLater(
          swapped.unlockWithRecoveryKey(created.recoveryKey),
          throwsA(isA<WrongSecretError>()),
        );
      },
    );

    test('arquivo alterado é recusado', () async {
      final created = await KeyFile.create(
        password: 'abc12345',
        now: now,
        policy: fast,
      );
      final json = jsonDecode(created.file.encode()) as Map<String, Object?>;
      final slots = json['slots']! as Map<String, Object?>;
      final password = slots['password']! as Map<String, Object?>;
      final data = base64.decode(password['data']! as String);
      data[0] ^= 1;
      password['data'] = base64.encode(data);
      await expectLater(
        KeyFile.fromJson(json).unlockWithPassword('abc12345'),
        throwsA(isA<WrongSecretError>()),
      );
      expect(() => KeyFile.decode('{'), throwsA(isA<DataError>()));
      expect(
        () => KeyFile.decode('{"format":"patrion-keys","formatVersion":9}'),
        throwsA(isA<DataError>()),
      );
    });

    test('trocar a senha mantém a chave do banco', () async {
      final created = await KeyFile.create(
        password: 'abc12345',
        now: now,
        policy: fast,
      );
      final changed = await created.file.withPassword(
        created.key,
        'nova-senha',
        now: now,
        policy: fast,
      );
      expect(
        (await changed.unlockWithPassword('nova-senha')).sameAs(created.key),
        isTrue,
      );
      await expectLater(
        changed.unlockWithPassword('abc12345'),
        throwsA(isA<WrongSecretError>()),
      );
      // A chave de recuperação continua valendo.
      expect(
        (await changed.unlockWithRecoveryKey(created.recoveryKey))
            .sameAs(created.key),
        isTrue,
      );
    });
  });

  group('RecoveryKey', () {
    test('formato e leitura tolerante', () {
      final code = RecoveryKey.format(Uint8List.fromList(List.filled(20, 0)));
      expect(code, '0000-0000-0000-0000-0000-0000-0000-0000');
      final random = RecoveryKey.format(CryptoBox.randomBytes(20));
      expect(random, matches(RegExp(r'^([0-9A-Z]{4}-){7}[0-9A-Z]{4}$')));
      expect(RecoveryKey.normalize(random.toLowerCase()), isNotNull);
      expect(
        RecoveryKey.normalize(' oooo iiii llll 0000 1111 2222 3333 4444 '),
        '0000111111110000111122223333'
        '4444',
      );
      expect(RecoveryKey.normalize('ABCD'), isNull);
      expect(RecoveryKey.normalize('U' * 32), isNull); // U não existe
    });
  });

  test('PasswordPolicy: pelo menos 8 caracteres', () {
    expect(PasswordPolicy.check('1234567'), isNotNull);
    expect(PasswordPolicy.check('        '), isNotNull);
    expect(PasswordPolicy.check('12345678'), isNull);
  });

  test('CryptoBox: AES-256-GCM recusa chave errada, nonce errado e AAD '
      'diferente', () {
    final key = CryptoBox.randomBytes(32);
    final nonce = CryptoBox.randomBytes(12);
    final plain = Uint8List.fromList(utf8.encode('carteira'));
    final aad = Uint8List.fromList([1, 2, 3]);
    final sealed = CryptoBox.seal(
      key: key,
      nonce: nonce,
      plaintext: plain,
      aad: aad,
    );
    expect(sealed.length, plain.length + 16);
    expect(
      CryptoBox.open(key: key, nonce: nonce, sealed: sealed, aad: aad),
      plain,
    );
    expect(
      () => CryptoBox.open(
        key: CryptoBox.randomBytes(32),
        nonce: nonce,
        sealed: sealed,
        aad: aad,
      ),
      throwsA(isA<WrongSecretError>()),
    );
    expect(
      () => CryptoBox.open(
        key: key,
        nonce: CryptoBox.randomBytes(12),
        sealed: sealed,
        aad: aad,
      ),
      throwsA(isA<WrongSecretError>()),
    );
    expect(
      () => CryptoBox.open(key: key, nonce: nonce, sealed: sealed),
      throwsA(isA<WrongSecretError>()),
    );
  });
}
