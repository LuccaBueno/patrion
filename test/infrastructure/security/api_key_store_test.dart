import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/infrastructure/security/api_key_store.dart';

/// Chaves de API protegidas pelo DPAPI, fora do banco e do save
/// (DECISIONS D-34). Só roda no Windows.
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('patrion_keys_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('guarda, lê de novo do arquivo e apaga; o arquivo não tem a chave em '
      'claro; arquivo alterado não abre', () {
    const secret = 'token-brapi-secreto-123';
    DpapiApiKeyStore(tmp.path).write('brapi', '  $secret  ');

    // Outra instância lê do arquivo (sem o cache da primeira).
    final store = DpapiApiKeyStore(tmp.path);
    expect(store.read('brapi'), secret);
    expect(store.providersWithKey(), {'brapi'});
    final bytes = File(store.path).readAsBytesSync();
    expect(latin1.decode(bytes, allowInvalid: true), isNot(contains(secret)));
    expect(utf8.decode(bytes, allowMalformed: true), isNot(contains(secret)));

    bytes[bytes.length - 5] ^= 1;
    File(store.path).writeAsBytesSync(bytes);
    final tampered = DpapiApiKeyStore(tmp.path);
    expect(tampered.read('brapi'), isNull);
    expect(tampered.providersWithKey(), isEmpty);

    // Gravar de novo substitui o arquivo ilegível; apagar a última chave
    // remove o arquivo.
    tampered.write('finnhub', 'outra');
    expect(DpapiApiKeyStore(tmp.path).read('finnhub'), 'outra');
    tampered.delete('finnhub');
    expect(File(tampered.path).existsSync(), isFalse);
  }, skip: Platform.isWindows ? false : 'DPAPI só existe no Windows');

  test('chave vazia apaga', () {
    final store = MemoryApiKeyStore()..write('brapi', 'x');
    store.write('brapi', '   ');
    expect(store.read('brapi'), isNull);
  });
}
