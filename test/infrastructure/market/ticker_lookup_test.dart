import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/infrastructure/market/providers/b3_ticker_catalog.dart';
import 'package:patrion/infrastructure/market/providers/brapi_provider.dart';

import '../../helpers/fake_http.dart';

/// Consulta de tickers do cadastro rápido (M-01): catálogo da B3 tirado do
/// COTAHIST diário (linhas reais de 21/10/2026) e brapi (respostas reais de
/// 22/10/2026).
void main() {
  // Quinta, 22/10/2026: o último pregão completo é 21/10.
  final clock = Clock.fixed(DateTime.utc(2026, 10, 22, 15));
  late FakeHttpAdapter adapter;
  late Directory cache;

  setUp(() {
    adapter = FakeHttpAdapter();
    cache = Directory.systemTemp.createTempSync('patrion_catalog_');
  });
  tearDown(() => cache.deleteSync(recursive: true));

  List<int> zipOf(String fixtureName, String entry) => ZipEncoder().encodeBytes(
    Archive()..addFile(
      ArchiveFile.bytes(entry, File(fixture(fixtureName)).readAsBytesSync()),
    ),
  );

  B3TickerCatalog catalog({Clock? at}) => B3TickerCatalog(
    fakeMarketHttp(adapter),
    cacheDir: cache.path,
    wallClock: at ?? clock,
  );

  group('catálogo da B3', () {
    test('classe pelo código BDI: ação, unit, FII, Fiagro, ETF e BDR; '
        'fracionário, opções e direitos ficam de fora', () async {
      adapter.on(
        'COTAHIST_D21102026',
        FakeReply(
          200,
          zipOf('cotahist_d21102026_catalogo.txt', 'COTAHIST_D21102026.TXT'),
        ),
      );
      final c = catalog();
      final bbas = await c.lookup('BBAS3');
      expect(bbas!.name, 'BRASIL ON NM');
      expect(bbas.assetClass, 'stock_br');
      expect(bbas.isin, 'BRBBASACNOR3');
      expect((await c.lookup('TAEE11'))!.assetClass, 'stock_br');
      expect((await c.lookup('HGLG11'))!.assetClass, 'fii');
      expect((await c.lookup('RZAG11'))!.assetClass, 'fii');
      expect((await c.lookup('BBGO11'))!.assetClass, 'fii');
      expect((await c.lookup('BOVA11'))!.assetClass, 'etf_br');
      expect((await c.lookup('AAPL34'))!.assetClass, 'bdr');
      expect((await c.lookup('AURA33'))!.assetClass, 'bdr');
      expect(await c.lookup('BBAS3F'), isNull);
      expect(await c.lookup('PRNR1'), isNull);
      // Um download só, mesmo com tickers que não existem.
      expect(adapter.urls, hasLength(1));
      expect(
        Directory(p.join(cache.path, 'cotahist')).listSync(),
        isEmpty,
        reason: 'ZIP e TXT apagados depois da extração (D-05)',
      );
    });

    test(
      'sem internet, usa o catálogo já baixado; sem catálogo, avisa',
      () async {
        adapter.on(
          'COTAHIST_D21102026',
          FakeReply(
            200,
            zipOf('cotahist_d21102026_catalogo.txt', 'COTAHIST_D21102026.TXT'),
          ),
        );
        await catalog().lookup('BBAS3');
        final saved = jsonDecode(
          File(p.join(cache.path, B3TickerCatalog.fileName)).readAsStringSync(),
        ) as Map<String, Object?>;
        expect(saved['date'], '2026-10-21');

        // Outra sessão, sem rede, uma semana depois.
        adapter.offline = true;
        final later = catalog(at: Clock.fixed(DateTime.utc(2026, 10, 29, 15)));
        expect((await later.lookup('hglg11'))!.assetClass, 'fii');
        expect(await later.lookup('XPTO3'), isNull);

        final empty = Directory.systemTemp.createTempSync('patrion_catalog_');
        addTearDown(() => empty.deleteSync(recursive: true));
        final none = B3TickerCatalog(
          fakeMarketHttp(adapter),
          cacheDir: empty.path,
          wallClock: clock,
        );
        await expectLater(none.lookup('BBAS3'), throwsA(isA<NetworkError>()));
      },
    );

    test(
      'arquivo do último pregão ainda não publicado: usa o anterior',
      () async {
        adapter
          ..on('COTAHIST_D21102026', FakeReply.text('não', status: 404))
          ..on(
            'COTAHIST_D20102026',
            FakeReply(
              200,
              zipOf('cotahist_d16102026.txt', 'COTAHIST_D20102026.TXT'),
            ),
          );
        final info = await catalog().lookup('PETR4');
        expect(info!.assetClass, 'stock_br');
        expect(adapter.urls, [
          contains('COTAHIST_D21102026'),
          contains('COTAHIST_D20102026'),
        ]);
      },
    );

    test('catálogo do último pregão não é baixado de novo por ticker '
        'desconhecido', () async {
      adapter.on(
        'COTAHIST_D21102026',
        FakeReply(
          200,
          zipOf('cotahist_d21102026_catalogo.txt', 'COTAHIST_D21102026.TXT'),
        ),
      );
      await catalog().lookup('BBAS3');
      final next = catalog();
      expect(await next.lookup('XPTO3'), isNull);
      expect(adapter.urls, hasLength(1));
    });
  });

  group('brapi', () {
    test('sem chave: só a lista, sem o cabeçalho de autorização', () async {
      adapter.on(
        '/api/quote/list',
        FakeReply.text(
          File(fixture('brapi_list_bbas3.json')).readAsStringSync(),
        ),
      );
      final lookup = BrapiLookup(
        fakeMarketHttp(adapter),
        apiKey: () => null,
        wallClock: clock,
      );
      final info = await lookup.lookup('bbas3');
      expect(info!.symbol, 'BBAS3');
      expect(info.name, 'BCO BRASIL S.A.');
      expect(info.assetClass, 'stock_br');
      expect(info.sector, 'Financeiro');
      expect(info.segment, 'Bancos Diversificados');
      expect(info.quote, isNull);
      expect(adapter.urls.single, contains('search=BBAS3'));
      expect(adapter.requests.single.headers['Authorization'], isNull);
    });

    test('com chave: nome completo, setor em português e a cotação', () async {
      adapter
        ..on(
          '/api/quote/list',
          FakeReply.text(
            File(fixture('brapi_list_bbas3.json')).readAsStringSync(),
          ),
        )
        ..on(
          '/api/quote/BBAS3',
          FakeReply.text(
            File(fixture('brapi_bbas3_profile.json')).readAsStringSync(),
          ),
        );
      final lookup = BrapiLookup(
        fakeMarketHttp(adapter),
        apiKey: () => 'chave-teste',
        wallClock: clock,
      );
      final info = await lookup.lookup('BBAS3');
      expect(info!.name, 'Banco do Brasil S.A.');
      expect(info.sector, 'Serviços Financeiros');
      expect(info.segment, 'Bancos Diversificados');
      expect(info.assetClass, 'stock_br');
      expect(info.quote!.price, Decimal.parse('23.92'));
      expect(info.quote!.source, 'brapi');
      expect(info.quote!.refAt, DateTime.utc(2026, 10, 22, 20, 44, 30));
      expect(adapter.urls.last, contains('modules=summaryProfile'));
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer chave-teste',
      );
      expect(adapter.requests.first.headers['Authorization'], isNull);
    });

    test('FII sem nome na lista; ticker inexistente devolve nulo', () async {
      adapter.on(
        'search=HGLG11',
        FakeReply.text(
          File(fixture('brapi_list_hglg11.json')).readAsStringSync(),
        ),
      );
      adapter.on(
        'search=XPTO3',
        FakeReply.text(
          File(fixture('brapi_list_empty.json')).readAsStringSync(),
        ),
      );
      final lookup = BrapiLookup(
        fakeMarketHttp(adapter),
        apiKey: () => null,
        wallClock: clock,
      );
      final hglg = await lookup.lookup('HGLG11');
      expect(hglg!.name, isNull, reason: 'a lista repete o código no nome');
      expect(hglg.assetClass, 'fii');
      expect(await lookup.lookup('XPTO3'), isNull);
    });

    test('com chave, ticker inexistente (404) devolve nulo', () async {
      adapter
        ..on(
          '/api/quote/list',
          FakeReply.text(
            File(fixture('brapi_list_empty.json')).readAsStringSync(),
          ),
        )
        ..on(
          '/api/quote/XPTO3',
          FakeReply.text('{"error":true,"code":"NOT_FOUND"}', status: 404),
        );
      final lookup = BrapiLookup(
        fakeMarketHttp(adapter),
        apiKey: () => 'chave-teste',
        wallClock: clock,
      );
      expect(await lookup.lookup('XPTO3'), isNull);
    });

    test('tipos da lista viram classes', () {
      expect(BrapiLookup.classOf('stock', 'unit'), 'stock_br');
      expect(BrapiLookup.classOf('fund', 'fii'), 'fii');
      expect(BrapiLookup.classOf('fund', 'fi-agro'), 'fii');
      expect(BrapiLookup.classOf('fund', 'etf'), 'etf_br');
      expect(BrapiLookup.classOf('bdr', 'bdr'), 'bdr');
      expect(BrapiLookup.classOf('fund', null), isNull);
      expect(BrapiLookup.sectorPt('Utilities'), 'Utilidade Pública');
      expect(BrapiLookup.sectorPt('Algo Novo'), 'Algo Novo');
      expect(
        BrapiLookup.cleanName(
          'Patria Log - Fundo de Investimento Imobiliario - Responsabilidade '
          'Limitada Cotas',
        ),
        'Patria Log - Fundo de Investimento Imobiliario',
      );
      expect(
        BrapiLookup.cleanName('Banco do Brasil S.A.'),
        'Banco do Brasil S.A.',
      );
    });
  });
}
