import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/application/market/market_ports.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/infrastructure/market/providers/b3_cotahist_provider.dart';
import 'package:patrion/infrastructure/market/providers/b3_events_provider.dart';
import 'package:patrion/infrastructure/market/providers/bcb_providers.dart';
import 'package:patrion/infrastructure/market/providers/brapi_provider.dart';
import 'package:patrion/infrastructure/market/providers/global_providers.dart';
import 'package:patrion/infrastructure/market/providers/open_data_providers.dart';

import '../../helpers/fake_http.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);

/// Adaptadores dos provedores, com respostas reais gravadas em 18/10/2026
/// (`test/fixtures/market/`; só tickers públicos). O SGS estava fora do ar
/// nesse dia: a resposta dele segue o formato verificado na F1.
void main() {
  const at = '2026-10-18T12:00:00.000Z';
  final clock = Clock.fixed(DateTime.utc(2026, 10, 18, 12));
  late FakeHttpAdapter adapter;

  setUp(() => adapter = FakeHttpAdapter());

  const petr4 = MarketInstrument(
    symbol: 'PETR4',
    market: 'B3',
    assetClass: 'stock_br',
    currency: 'BRL',
  );
  const aapl = MarketInstrument(
    symbol: 'AAPL',
    market: 'NASDAQ',
    assetClass: 'stock_intl',
    currency: 'USD',
  );
  const btc = MarketInstrument(
    symbol: 'BTC',
    market: 'CRYPTO',
    assetClass: 'crypto',
    currency: 'BRL',
  );

  String read(String name) =>
      File(fixture(name))
          .readAsStringSync(encoding: name.startsWith('cvm') ? latin1 : utf8);

  group('Banco Central e IBGE', () {
    test('SGS: CDI diário, valores exatos; janelas de 5 anos', () async {
      adapter.on(
        'bcdata.sgs.12',
        FakeReply.text(
          '[{"data":"01/10/2026","valor":"0.055131"},'
          '{"data":"02/10/2026","valor":"0.055131"}]',
        ),
      );
      final sgs = BcbSgsProvider(fakeMarketHttp(adapter), wallClock: clock);
      final points = await sgs.indicator(
        IndicatorSeries.cdi,
        from: day('2014-01-01'),
        to: day('2026-10-17'),
      );
      // 2014–2018, 2019–2023, 2024–2026: três consultas.
      expect(adapter.requests, hasLength(3));
      expect(adapter.urls.first, contains('dataInicial=01%2F01%2F2014'));
      expect(adapter.urls.first, contains('dataFinal=31%2F12%2F2018'));
      expect(points.first.value, d('0.055131'));
      expect(points.first.refDate, day('2026-10-01'));
      expect(points.first.source, 'bcb_sgs');
    });

    test('SGS: "sem dados" é lista vazia; HTML ou erro é recusado', () {
      expect(
        BcbSgsProvider.parse(
          '{"error":"Value(s) not found"}',
          IndicatorSeries.ipca,
          collectedAt: at,
        ),
        isEmpty,
      );
      expect(
        () => BcbSgsProvider.parse(
          '<?xml version="1.0"?><html>Requisição inválida</html>',
          IndicatorSeries.ipca,
          collectedAt: at,
        ),
        throwsA(isA<DataError>()),
      );
      expect(
        () => BcbSgsProvider.parse(
          '{"erro":{"statusCode":500,"detail":"Internal error"}}',
          IndicatorSeries.cdi,
          collectedAt: at,
        ),
        throwsA(isA<DataError>()),
      );
    });

    test('PTAX: dólar (última cotação do dia) e euro (só o fechamento)', () {
      final usd = BcbPtaxProvider.parse(
        read('ptax_usd.json'),
        'USD',
        collectedAt: at,
      );
      expect(usd.map((r) => '${r.refDate}'), [
        '2026-10-13',
        '2026-10-14',
        '2026-10-15',
        '2026-10-16',
      ]);
      expect(usd.first.bid, d('5.00900'));
      expect(usd.first.ask, d('5.00960'));
      expect(usd.first.kind, FxKind.ptaxClose);
      // 13:04 em Brasília = 16:04 UTC.
      expect(usd.first.refAt!.hour, 16);

      final eur = BcbPtaxProvider.parse(
        read('ptax_eur.json'),
        'EUR',
        collectedAt: at,
      );
      expect(eur, isNotEmpty);
      expect(eur.map((r) => r.refDate).toSet(), hasLength(eur.length));
      expect(eur.every((r) => r.refAt!.hour >= 16), isTrue);
    });

    test('SIDRA: IPCA mensal, cabeçalho ignorado', () {
      final points = IbgeSidraProvider.parse(
        read('sidra_ipca.json'),
        collectedAt: at,
      );
      expect(points.first.refDate, day('2026-07-01'));
      expect(points.first.value, d('0.07'));
      expect(points[1].value, d('-0.32'));
      expect(points, hasLength(3));
    });

    test('Frankfurter: taxa de referência EUR→BRL', () {
      final rates = FrankfurterProvider.parse(
        read('frankfurter_eur.json'),
        'EUR',
        collectedAt: at,
      );
      expect(rates.first.refDate, day('2026-10-01'));
      expect(rates.first.mid, d('5.862'));
      expect(rates.first.kind, FxKind.reference);
    });
  });

  group('brapi', () {
    test('cotação com data, fonte e atraso; a chave vai no cabeçalho, '
        'nunca na URL', () async {
      adapter.on('brapi.dev', FakeReply.file(fixture('brapi_petr4.json')));
      final brapi = BrapiProvider(
        fakeMarketHttp(adapter),
        apiKey: () => 'CHAVE-SECRETA',
        wallClock: clock,
      );
      final q = await brapi.quote(petr4);
      expect(q.price, d('59.68'));
      expect(q.refAt, DateTime.utc(2026, 10, 17, 2, 29, 23));
      expect(q.dataType, MarketDataType.intraday);
      expect(q.delayNote, contains('30 min'));
      expect(adapter.urls.single, 'https://brapi.dev/api/quote/PETR4');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer CHAVE-SECRETA',
      );
    });

    test(
      'sem chave, só os tickers de teste; chave recusada vira aviso',
      () async {
        final noKey = BrapiProvider(
          fakeMarketHttp(adapter),
          apiKey: () => null,
        );
        expect(noKey.supports(petr4), isTrue);
        expect(
          noKey.supports(
            const MarketInstrument(
              symbol: 'BBAS3',
              market: 'B3',
              assetClass: 'stock_br',
              currency: 'BRL',
            ),
          ),
          isFalse,
        );
        adapter.on('brapi.dev', FakeReply.text('{}', status: 401));
        final withKey = BrapiProvider(
          fakeMarketHttp(adapter),
          apiKey: () => 'errada',
        );
        await expectLater(
          withKey.quote(petr4),
          throwsA(
            isA<DataError>().having((e) => e.message, 'm', contains('chave')),
          ),
        );
      },
    );
  });

  group('B3 COTAHIST', () {
    test('lê o layout oficial: PETR4 em 16/10/2026', () {
      final lines = const LineSplitter().convert(
        read('cotahist_d16102026.txt'),
      );
      final records = [
        for (final l in lines) ?B3CotahistProvider.parseLine(l, const {}),
      ];
      final petr = records.firstWhere((r) => r.symbol == 'PETR4');
      expect(petr.date, day('2026-10-16'));
      expect(petr.marketType, '010');
      expect(petr.open, d('57.66'));
      expect(petr.high, d('59.68'));
      expect(petr.low, d('57.53'));
      expect(petr.close, d('59.68'));
      expect(petr.quoteFactor, 1);
      expect(petr.isin, 'BRPETRACNPR6');
      final hglg = records.firstWhere((r) => r.symbol == 'HGLG11');
      expect(hglg.close, d('156.42'));
      expect(hglg.isin, 'BRHGLGCTF004');
      // Cabeçalho e rodapé não são cotações.
      expect(records.every((r) => r.symbol.isNotEmpty), isTrue);
    });

    test('baixa só o necessário, separa os tickers pedidos e apaga o ZIP e '
        'o TXT', () async {
      final cache = Directory.systemTemp.createTempSync('patrion_cotahist_');
      addTearDown(() => cache.deleteSync(recursive: true));
      final zip = ZipEncoder().encodeBytes(
        Archive()..addFile(
          ArchiveFile.bytes(
            'COTAHIST_D16102026.TXT',
            File(fixture('cotahist_d16102026.txt')).readAsBytesSync(),
          ),
        ),
      );
      adapter
        ..on('COTAHIST_D16102026', FakeReply(200, zip))
        ..on('COTAHIST_D', FakeReply.text('não', status: 404));
      final provider = B3CotahistProvider(
        fakeMarketHttp(adapter),
        cacheDir: cache.path,
        wallClock: clock,
      );
      final result = await provider.historyFor(
        {'PETR4', 'HGLG11'},
        from: day('2026-10-15'),
        to: day('2026-10-17'),
      );
      // 15/10 (não publicado), 16/10; 17/10 é sábado.
      expect(adapter.urls, [
        contains('COTAHIST_D15102026'),
        contains('COTAHIST_D16102026'),
      ]);
      expect(result.bars['PETR4']!.single.close, d('59.68'));
      expect(result.bars['HGLG11']!.single.close, d('156.42'));
      expect(result.bars.containsKey('BOVA11'), isFalse);
      expect(result.isins['PETR4'], 'BRPETRACNPR6');
      expect(
        Directory(p.join(cache.path, 'cotahist')).listSync(),
        isEmpty,
        reason: 'arquivos brutos apagados depois da extração (D-05)',
      );
    });

    test('período longo usa os arquivos anuais, um por ano', () async {
      final cache = Directory.systemTemp.createTempSync('patrion_cotahist_');
      addTearDown(() => cache.deleteSync(recursive: true));
      adapter.on('COTAHIST_A', FakeReply.text('falhou', status: 500));
      final provider = B3CotahistProvider(
        fakeMarketHttp(adapter),
        cacheDir: cache.path,
        wallClock: clock,
      );
      await expectLater(
        provider.historyFor(
          {'PETR4'},
          from: day('2024-03-01'),
          to: day('2026-10-17'),
        ),
        throwsA(isA<NetworkError>()),
      );
      expect(adapter.urls.first, contains('COTAHIST_A2024.ZIP'));
      expect(Directory(p.join(cache.path, 'cotahist')).listSync(), isEmpty);
    });
  });

  group('B3 proventos e eventos', () {
    final provider = B3EventsProvider(
      fakeMarketHttp(FakeHttpAdapter()),
      wallClock: clock,
    );

    test('PETR4: eventos em ações com o fator convertido; proventos só da '
        'PN', () {
      final s = B3EventsProvider.parseSupplement(
        read('b3_supp_petr.json'),
        symbol: 'PETR4',
        isin: null,
        fii: false,
      );
      expect(s.tradingName, 'PETROBRAS');
      expect(s.events.every((e) => e.isin == 'BRPETRACNPR6'), isTrue);
      final events = provider.finish(
        s.events,
        symbol: 'PETR4',
        collectedAt: at,
        today: day('2026-10-18'),
      );
      final split2008 = events.singleWhere(
        (e) => e.kind == CorporateEventKind.split,
      );
      expect(split2008.comDate, day('2008-04-25'));
      expect(split2008.exDate, day('2008-04-28')); // dia útil seguinte
      expect(split2008.factor, d('2')); // "100" = +100% = 1:2
      final reverse = events.singleWhere(
        (e) => e.kind == CorporateEventKind.reverseSplit,
      );
      expect(reverse.factor, d('0.01'));
      final bonus = events.singleWhere(
        (e) => e.kind == CorporateEventKind.bonusShares,
      );
      expect(bonus.factor, d('1.33333333333')); // "33,333333333" = +33,3…%
      final jcp = events.where((e) => e.kind == CorporateEventKind.jcp);
      expect(jcp, isNotEmpty);
      // Pagamento em dezembro de 2026: ainda anunciado.
      expect(
        events
            .where((e) => e.paymentDate == day('2026-12-21'))
            .every((e) => e.status == CorporateEventStatus.announced),
        isTrue,
      );
      // Dois JCP na mesma data ex ganham números de ordem diferentes.
      final sameDay = events.where(
        (e) =>
            e.kind == CorporateEventKind.jcp && e.comDate == day('2026-08-21'),
      );
      expect(sameDay.map((e) => e.seq).toSet(), hasLength(sameDay.length));
    });

    test('HGLG11: rendimentos de FII e desdobramento 1:10', () {
      final s = B3EventsProvider.parseSupplement(
        read('b3_supp_hglg.json'),
        symbol: 'HGLG11',
        isin: 'BRHGLGCTF004',
        fii: true,
      );
      final events = provider.finish(
        s.events,
        symbol: 'HGLG11',
        collectedAt: at,
        today: day('2026-10-18'),
      );
      final income = events.where(
        (e) => e.kind == CorporateEventKind.fiiIncome,
      );
      expect(income.first.amount, isNotNull);
      final last = income.last;
      expect(last.comDate, day('2026-09-30'));
      expect(last.amount, d('1.17'));
      expect(last.paymentDate, day('2026-10-15'));
      expect(last.status, CorporateEventStatus.paid);
      expect(
        events.singleWhere((e) => e.kind == CorporateEventKind.split).factor,
        d('10'),
      );
    });

    test('histórico paginado de proventos filtra pela espécie (ON/PN)', () {
      final (events, pages) = B3EventsProvider.parseCashHistory(
        read('b3_cash_petr.json'),
        symbol: 'PETR3',
      );
      expect(pages, 69);
      expect(events, isNotEmpty);
      expect(events.first.amount, d('0.67407131'));
      expect(events.first.kind, CorporateEventKind.jcp);
    });
  });

  group('Tesouro e CVM', () {
    test('Tesouro: preços e taxas com decimais exatos, a partir da data', () {
      final prices = TesouroProvider.parse(
        read('tesouro.csv'),
        from: day('2026-10-15'),
        collectedAt: at,
      );
      expect(prices, hasLength(4));
      final ipca = prices.singleWhere((t) => t.title == 'Tesouro IPCA+');
      expect(ipca.maturity, day('2035-05-15'));
      expect(ipca.refDate, day('2026-10-15'));
      expect(ipca.sellPu, d('2686.72'));
      expect(ipca.buyRate, d('6.84'));
    });

    test('CVM: informe do FII ligado pelo ISIN, maior versão do mês', () {
      final reports = CvmProvider.parseFiiMonthly(
        read('cvm_fii_geral.csv'),
        read('cvm_fii_complemento.csv'),
        {'BRHGLGCTF004'},
        collectedAt: at,
      );
      final sept = reports.singleWhere((r) => r.refDate == day('2026-09-01'));
      expect(sept.cnpj, '11.728.688/0001-47');
      expect(sept.quota, d('165.476630173739'));
      expect(sept.holders, 613837);
      expect(sept.isin, 'BRHGLGCTF004');
      expect(sept.kind, FundReportKind.fiiMonthly);
    });

    test('CVM: cotas diárias por CNPJ', () {
      final quotas = CvmProvider.parseDaily(read('cvm_inf_diario.csv'), {
        '00.017.024/0001-53',
      }, collectedAt: at);
      expect(quotas.first.refDate, day('2026-10-01'));
      expect(quotas.first.quota, d('44.9907626'));
    });
  });

  group('cripto e internacional', () {
    test('CoinGecko: cotação em real, com a chave Demo no cabeçalho', () async {
      adapter.on('simple/price', FakeReply.file(fixture('coingecko_btc.json')));
      final cg = CoinGeckoProvider(
        fakeMarketHttp(adapter),
        apiKey: () => 'DEMO',
        wallClock: clock,
      );
      final q = await cg.quote(btc);
      expect(q.price, d('409421'));
      expect(q.currency, 'BRL');
      expect(adapter.urls.single, contains('ids=bitcoin'));
      expect(adapter.urls.single, isNot(contains('DEMO')));
      expect(adapter.requests.single.headers['x-cg-demo-api-key'], 'DEMO');
      expect(
        CoinGeckoProvider.parseSearch(read('coingecko_search_eth.json'), 'ETH'),
        'ethereum',
      );
    });

    test('Binance: barras diárias em real, dia em UTC', () {
      final bars = BinanceProvider.parse(
        read('binance_btcbrl.json'),
        btc,
        collectedAt: at,
      );
      expect(bars, isNotEmpty);
      expect(bars.first.currency, 'BRL');
      expect(bars.first.dataType, MarketDataType.close);
      expect(
        BinanceProvider(fakeMarketHttp(adapter)).supports(
          const MarketInstrument(
            symbol: 'BTC',
            market: 'CRYPTO',
            assetClass: 'crypto',
            currency: 'USD',
          ),
        ),
        isFalse,
        reason: 'par contra USDT não é preço em dólar',
      );
    });

    test('Finnhub: cotação dos EUA; ticker desconhecido é recusado', () {
      final q = FinnhubProvider.parse(
        '{"c":261.74,"d":1.2,"dp":0.46,"h":262,"l":259,"o":260,"pc":260.54,'
        '"t":1792180800}',
        aapl,
        collectedAt: at,
      );
      expect(q.price, d('261.74'));
      expect(q.currency, 'USD');
      expect(
        () => FinnhubProvider.parse(
          '{"c":0,"d":null,"dp":null,"h":0,"l":0,"o":0,"pc":0,"t":0}',
          aapl,
          collectedAt: at,
        ),
        throwsA(isA<DataError>()),
      );
    });

    test(
      'Twelve Data: histórico sem ajuste; erro com HTTP 200 vira aviso',
      () async {
        final bars = TwelveDataProvider.parseHistory(
          '{"meta":{"symbol":"AAPL","currency":"USD"},"values":['
          '{"datetime":"2026-10-15","open":"258.1","high":"260.0",'
          '"low":"257.5","close":"259.9","volume":"41000000"},'
          '{"datetime":"2026-10-16","open":"260.0","high":"262.3",'
          '"low":"259.0","close":"261.74","volume":"39000000"}],"status":"ok"}',
          aapl,
          collectedAt: at,
        );
        expect(bars.last.close, d('261.74'));
        expect(bars.last.dataType, MarketDataType.close);

        adapter.on(
          'twelvedata',
          FakeReply.text(
            '{"code":401,"message":"**apikey** parameter is incorrect",'
            '"status":"error"}',
          ),
        );
        final td = TwelveDataProvider(
          fakeMarketHttp(adapter),
          apiKey: () => 'K',
        );
        await expectLater(
          td.history(aapl, from: day('2026-10-01'), to: day('2026-10-16')),
          throwsA(isA<DataError>()),
        );
        expect(adapter.requests.single.headers['Authorization'], 'apikey K');
        expect(adapter.urls.single, contains('adjust=none'));
      },
    );

    test('Yahoo: preço bruto na data da bolsa', () {
      final bars = YahooProvider.parseHistory(
        read('yahoo_aapl.json'),
        aapl,
        collectedAt: at,
      );
      expect(bars, isNotEmpty);
      expect(bars.last.currency, 'USD');
      expect(bars.map((b) => b.refDate).toSet(), hasLength(bars.length));
    });
  });
}
