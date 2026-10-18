import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/json/exact_json.dart';
import 'package:patrion/infrastructure/market/market_http.dart';

import '../../helpers/fake_http.dart';

/// Acesso HTTP dos adaptadores (SPEC §4: timeout, retentativa com backoff,
/// limites, sem requisições duplicadas).
void main() {
  late FakeHttpAdapter adapter;
  late List<Duration> sleeps;
  late MarketHttp http;
  final uri = Uri.https('exemplo.test', '/dados', {'x': '1'});

  setUp(() {
    adapter = FakeHttpAdapter();
    sleeps = [];
    http = fakeMarketHttp(adapter, sleeps: sleeps);
  });

  test('5xx: tenta de novo com espera de 1 s e 2 s e então desiste com '
      'NetworkError', () async {
    adapter.on('exemplo.test', FakeReply.text('erro', status: 503));
    await expectLater(http.getText('p', uri), throwsA(isA<NetworkError>()));
    expect(adapter.requests, hasLength(3));
    expect(sleeps.where((d) => d.inSeconds >= 1), [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
    ]);
  });

  test('429 respeita o Retry-After e depois funciona', () async {
    adapter.on('exemplo.test', [
      FakeReply(
        429,
        const [],
        headers: {
          'retry-after': ['7'],
        },
      ),
      FakeReply.text('ok'),
    ]);
    expect(await http.getText('p', uri), 'ok');
    expect(sleeps, contains(const Duration(seconds: 7)));
  });

  test('Retry-After longo demais: falha sem esperar', () async {
    adapter.on(
      'exemplo.test',
      FakeReply(
        429,
        const [],
        headers: {
          'retry-after': ['3600'],
        },
      ),
    );
    await expectLater(http.getText('p', uri), throwsA(isA<NetworkError>()));
    expect(sleeps, isNot(contains(const Duration(hours: 1))));
  });

  test('4xx não é repetido e não expõe a URL nem os cabeçalhos', () async {
    adapter.on('exemplo.test', FakeReply.text('chave inválida', status: 401));
    final error = await http
        .getText('p', uri, headers: {'Authorization': 'Bearer SEGREDO'})
        .then<Object>((_) => 'sem erro', onError: (Object e) => e);
    expect(error, isA<HttpStatusError>());
    expect((error as HttpStatusError).statusCode, 401);
    expect(error.toString(), isNot(contains('SEGREDO')));
    expect(adapter.requests, hasLength(1));
  });

  test('sem rede: NetworkError com mensagem clara, sem a query', () async {
    adapter.offline = true;
    final error = await http
        .getText('p', Uri.https('exemplo.test', '/a', {'token': 'SEGREDO'}))
        .then<Object>((_) => 'sem erro', onError: (Object e) => e);
    expect(error, isA<NetworkError>());
    expect((error as NetworkError).message, contains('sem conexão'));
    expect(error.message, isNot(contains('SEGREDO')));
  });

  test('requisições iguais em andamento viram uma só', () async {
    adapter.on('exemplo.test', FakeReply.text('ok'));
    final results = await Future.wait([
      http.getText('p', uri),
      http.getText('p', uri),
      http.getText('p', uri),
    ]);
    expect(results, ['ok', 'ok', 'ok']);
    expect(adapter.requests, hasLength(1));
  });

  test(
    'download grava o arquivo; em falha não deixa arquivo parcial',
    () async {
      final dir = Directory.systemTemp.createTempSync('patrion_http_');
      addTearDown(() => dir.deleteSync(recursive: true));
      adapter
        ..on('bom', FakeReply(200, List.filled(1000, 7)))
        ..on('ruim', FakeReply.text('x', status: 500));
      final ok = '${dir.path}/ok.bin';
      await http.download('p', Uri.https('bom.test', '/f'), ok);
      expect(File(ok).lengthSync(), 1000);

      final bad = '${dir.path}/ruim.bin';
      await expectLater(
        http.download('p', Uri.https('ruim.test', '/f'), bad),
        throwsA(isA<NetworkError>()),
      );
      expect(File(bad).existsSync(), isFalse);
    },
  );

  group('ExactJson', () {
    test('números ficam exatos, como texto', () {
      final json =
          ExactJson.decode(
                '{"a":5.61470,"b":[1,-2.5e3,0.1],"c":"t\\u00e1","d":null,'
                '"e":true}',
              )!
              as Map<String, Object?>;
      expect(json['a'], const JsonNumber('5.61470'));
      expect((json['a']! as JsonNumber).decimal.toString(), '5.6147');
      expect(json['b'], [
        const JsonNumber('1'),
        const JsonNumber('-2.5e3'),
        const JsonNumber('0.1'),
      ]);
      expect(json['c'], 'tá');
      expect(json['d'], isNull);
      expect(json['e'], isTrue);
    });

    test('JSON inválido é recusado', () {
      for (final bad in ['{', '[1,]', '{"a" 1}', 'abc', '1 2']) {
        expect(() => ExactJson.decode(bad), throwsFormatException, reason: bad);
      }
    });
  });
}
