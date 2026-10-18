import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/crypto/database_key.dart';
import 'package:patrion/infrastructure/security/windows_hello.dart';

/// Cópia da chave do banco para o Windows Hello, protegida pelo DPAPI
/// (DECISIONS D-32). Só roda no Windows.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('patrion_hello_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('guarda e lê a chave; o arquivo não tem a chave em claro; outro keyId '
      'ou arquivo alterado não abrem', () {
    final vault = DpapiHelloKeyVault(tmp.path);
    final key = DatabaseKey.random();
    expect(vault.exists, isFalse);

    vault.store(key, 'chave-1');

    expect(vault.exists, isTrue);
    expect(vault.load('chave-1')!.sameAs(key), isTrue);
    expect(vault.load('chave-2'), isNull);
    final bytes = File(vault.path).readAsBytesSync();
    final hex = key.pragmaValue.substring(3, 67);
    expect(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      isNot(contains(hex)),
    );

    bytes[bytes.length - 5] ^= 1;
    File(vault.path).writeAsBytesSync(bytes);
    expect(vault.load('chave-1'), isNull);

    vault.delete();
    expect(vault.exists, isFalse);
  }, skip: Platform.isWindows ? false : 'DPAPI só existe no Windows');
}
