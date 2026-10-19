import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/market/market_data_service.dart';
import 'package:patrion/application/market/market_overview.dart';
import 'package:patrion/application/market/market_ports.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/application/settings/market_preferences.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/data/repositories/provider_state_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../../helpers/portfolio_fixture.dart';

const _collected = '2026-10-17T12:00:00.000Z';

/// Cotação de mentira: devolve [prices] ou falha como pedido.
class FakeQuotes implements QuoteProvider {
  FakeQuotes(this.code, {this.prices = const {}, this.error});

  @override
  final String code;
  final Map<String, String> prices;
  AppError? error;
  final asked = <MarketInstrument>[];

  @override
  bool supports(MarketInstrument i) => prices.containsKey(i.symbol);

  @override
  Future<MarketQuote> quote(MarketInstrument i) async {
    asked.add(i);
    final e = error;
    if (e != null) throw e;
    return MarketQuote(
      symbol: i.symbol,
      market: i.market,
      price: Decimal.parse(prices[i.symbol]!),
      currency: i.currency,
      refAt: DateTime.utc(2026, 10, 16, 18),
      source: code,
      dataType: MarketDataType.intraday,
      collectedAt: _collected,
      delayNote: 'até 30 min de atraso',
    );
  }
}

class FakeBatch implements BatchHistoryProvider {
  final calls = <(Set<String>, LocalDate, LocalDate)>[];

  @override
  String get code => 'b3_cotahist';

  @override
  bool supports(MarketInstrument i) => i.market == 'B3';

  @override
  Future<List<PriceBar>> history(
    MarketInstrument instrument, {
    required LocalDate from,
    required LocalDate to,
  }) async => (await historyBatch(
    {instrument.symbol},
    from: from,
    to: to,
  )).bars[instrument.symbol]!;

  @override
  Future<({Map<String, List<PriceBar>> bars, Map<String, String> isins})>
  historyBatch(
    Set<String> symbols, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    calls.add((symbols, from, to));
    final bars = <String, List<PriceBar>>{};
    for (final s in symbols) {
      bars[s] = [
        for (var d = from; !d.isAfter(to); d = d.addDays(1))
          if (d.weekday <= 5)
            PriceBar(
              symbol: s,
              market: 'B3',
              refDate: d,
              close: Decimal.parse('30.${d.day.toString().padLeft(2, '0')}'),
              currency: 'BRL',
              source: code,
              dataType: MarketDataType.close,
              collectedAt: _collected,
            ),
      ];
    }
    return (bars: bars, isins: {for (final s in symbols) s: 'BR${s}ACNPR0'});
  }
}

class FakeFx implements FxProvider {
  FakeFx(this.code, {this.fail = false});

  @override
  final String code;
  bool fail;
  int calls = 0;

  @override
  bool supports(String currency) => true;

  @override
  Future<List<FxRate>> rates(
    String currency, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    calls++;
    if (fail) throw const NetworkError('sem conexão');
    return [
      FxRate(
        base: currency,
        quote: 'BRL',
        refDate: to.addDays(-1),
        kind: code == 'bcb_ptax' ? FxKind.ptaxClose : FxKind.reference,
        bid: Decimal.parse('5.40'),
        ask: Decimal.parse('5.41'),
        source: code,
        collectedAt: _collected,
      ),
    ];
  }
}

class FakeIndicators implements IndicatorProvider {
  @override
  String get code => 'bcb_sgs';

  final asked = <(IndicatorSeries, LocalDate)>[];

  @override
  bool supports(IndicatorSeries series) => series == IndicatorSeries.cdi;

  @override
  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    asked.add((series, from));
    return [
      IndicatorPoint(
        series: series,
        refDate: to.addDays(-1),
        value: Decimal.parse('0.055131'),
        source: code,
        collectedAt: _collected,
      ),
    ];
  }
}

void main() {
  late PortfolioFixture f;
  late MarketRepository repo;
  late ProviderStateRepository states;
  late FakeQuotes brapi;
  late FakeQuotes backup;
  late FakeBatch cotahist;
  late FakeFx ptax;
  late FakeFx ecb;
  late FakeIndicators sgs;
  late MarketDataService service;
  late PortfolioQuery query;

  setUp(() async {
    f = await PortfolioFixture.open();
    // Sexta, 16/10/2026, depois do fechamento: o último pregão completo
    // antes de hoje é quinta, 15/10.
    f.t.wall.now = DateTime.utc(2026, 10, 16, 21);
    repo = MarketRepository(f.t.db);
    states = ProviderStateRepository(f.t.db);
    brapi = FakeQuotes('brapi', prices: {'PETR4': '35.50'});
    backup = FakeQuotes('yahoo', prices: {'PETR4': '35.40'});
    cotahist = FakeBatch();
    ptax = FakeFx('bcb_ptax');
    ecb = FakeFx('frankfurter');
    sgs = FakeIndicators();
    query = PortfolioQuery(
      PortfolioRepositories(f.t.db, f.t.sync),
      wallClock: f.t.wall.clock,
      market: repo,
    );
    service = MarketDataService(
      repo: repo,
      states: states,
      providers: MarketProviders(
        quotes: [brapi, backup],
        batchHistory: cotahist,
        fx: [ptax, ecb],
        indicators: [sgs],
      ),
      preferences: MarketPreferences(DeviceSettingsRepository(f.t.db)),
      portfolio: query,
      wallClock: f.t.wall.clock,
    );
    // O Yahoo vem desligado por padrão; aqui ele é a segunda fonte.
    await states.setEnabled('yahoo', true);
    // PETR4 com preço de mercado e uma compra.
    final petr = (await f.repos.assets.all()).firstWhere(
      (a) => a.symbol == 'PETR4',
    );
    await f.registry.updateAsset(
      Asset(
        id: petr.id,
        symbol: petr.symbol,
        market: petr.market,
        assetClass: petr.assetClass,
        name: petr.name,
        currency: petr.currency,
        country: petr.country,
        priceSource: PriceSource.market,
      ),
    );
    await f.add(
      f.draft(OperationType.deposit, '2026-01-02', asset: null, gross: '5000'),
    );
    await f.add(
      f.draft(OperationType.buy, '2026-01-05', qty: '100', price: '30'),
    );
  });

  tearDown(() => f.t.close());

  test('atualiza a carteira: cotação com fonte e data entra na avaliação; '
      'só o código do ativo vai ao provedor', () async {
    final result = await service.refreshPortfolio();
    expect(result.failures, isEmpty);
    expect(brapi.asked.single.symbol, 'PETR4');
    expect(brapi.asked.single.market, 'B3');

    final snap = await query.load();
    final v = snap.valued.firstWhere((v) => v.asset?.symbol == 'PETR4');
    expect(v.marketValue, Decimal.parse('3550'));
    expect(v.marketPrice!.source, 'brapi');
    expect(v.marketPrice!.dataType, MarketDataType.intraday);
    expect(v.marketPrice!.delayNote, 'até 30 min de atraso');
    expect(v.valuationDate, LocalDate(2026, 10, 16));

    // Fechamentos recentes da B3 (só a janela que falta) e câmbio.
    expect(cotahist.calls.single.$1, {'PETR4'});
    expect(cotahist.calls.single.$3, LocalDate(2026, 10, 15));
    expect(await repo.isinOf('PETR4', 'B3'), 'BRPETR4ACNPR0');
    expect((await repo.latestFx('USD'))!.source, 'bcb_ptax');
    expect(
      (await repo.latestIndicator(IndicatorSeries.cdi))!.value,
      Decimal.parse('0.055131'),
    );
    expect((await states.of('brapi')).lastSuccessAt, isNotNull);
  });

  test('provedor desligado não é chamado; a próxima fonte responde', () async {
    await states.setEnabled('brapi', false);
    await service.refreshPortfolio();
    expect(brapi.asked, isEmpty);
    expect(backup.asked, hasLength(1));
    final snap = await query.load();
    expect(
      snap.valued
          .firstWhere((v) => v.asset?.symbol == 'PETR4')
          .marketPrice!
          .source,
      'yahoo',
    );
  });

  test(
    'falha de um provedor é registrada e a fonte seguinte é usada',
    () async {
      brapi.error = const DataError('Chave inválida.');
      final result = await service.refreshQuotes(
        (await f.repos.assets.all()).where((a) => a.symbol == 'PETR4'),
      );
      expect(result.failures.single.provider, 'brapi');
      expect(result.updated, 1);
      final s = await states.of('brapi');
      expect(s.failing, isTrue);
      expect(s.lastError, 'Chave inválida.');
    },
  );

  test('PTAX fora do ar: usa a referência do BCE', () async {
    ptax.fail = true;
    final result = await service.refreshFx(currencies: {'USD'});
    expect(result.failures.single.network, isTrue);
    expect((await repo.latestFx('USD'))!.source, 'frankfurter');
  });

  test('cota mensal atingida: o provedor deixa de ser chamado', () async {
    final limited = MarketDataService(
      repo: repo,
      states: states,
      providers: MarketProviders(quotes: [brapi]),
      preferences: MarketPreferences(DeviceSettingsRepository(f.t.db)),
      portfolio: query,
      wallClock: f.t.wall.clock,
      monthlyQuotas: const {'brapi': 1},
    );
    await limited.refreshPortfolio();
    final second = await limited.refreshPortfolio();
    expect(brapi.asked, hasLength(1));
    expect(second.failures.single.message, contains('Cota mensal'));
  });

  test('sem internet: o resultado diz "sem conexão" e a carteira continua '
      'com os últimos dados guardados, com a data deles', () async {
    await service.refreshPortfolio();
    // Dia seguinte, sem rede.
    f.t.wall.now = DateTime.utc(2026, 10, 19, 15);
    const offline = NetworkError('Não foi possível acessar o provedor.');
    brapi.error = offline;
    backup.error = offline;
    ptax.fail = true;
    ecb.fail = true;
    final offlineService = MarketDataService(
      repo: repo,
      states: states,
      providers: MarketProviders(quotes: [brapi, backup], fx: [ptax, ecb]),
      preferences: MarketPreferences(DeviceSettingsRepository(f.t.db)),
      portfolio: query,
      wallClock: f.t.wall.clock,
    );
    final ptaxBefore = ptax.calls;
    final result = await offlineService.refreshPortfolio();
    expect(result.offline, isTrue);
    // Duas fontes sem rede e nenhuma resposta: o resto é pulado, sem esperar
    // as retentativas de cada provedor.
    expect(ptax.calls, ptaxBefore);
    expect(
      result.failures.where((f) => f.message.contains("sem internet")),
      isNotEmpty,
    );
    final snap = await query.load();
    final v = snap.valued.firstWhere((v) => v.asset?.symbol == 'PETR4');
    expect(v.marketValue, Decimal.parse('3550'));
    expect(v.valuationDate, LocalDate(2026, 10, 16));
    final overview = await MarketOverview.load(repo);
    expect(overview.fx['USD']!.refDate, LocalDate(2026, 10, 15));
  });

  test(
    'histórico: só os trechos que faltam, a partir do ano inicial',
    () async {
      final petr = (await f.repos.assets.all()).firstWhere(
        (a) => a.symbol == 'PETR4',
      );
      await MarketPreferences(DeviceSettingsRepository(f.t.db))
          .setHistoryStartYear(2026);
      await service.downloadHistory(petr, from: LocalDate(2026, 10, 1));
      expect(cotahist.calls.single.$2, LocalDate(2026, 10, 1));
      expect(cotahist.calls.single.$3, LocalDate(2026, 10, 15));
      // De novo: nada falta, nenhum download.
      await service.downloadHistory(petr, from: LocalDate(2026, 10, 1));
      expect(cotahist.calls, hasLength(1));
      // Começo mais cedo: só o trecho antes do primeiro dia guardado.
      await service.downloadHistory(petr, from: LocalDate(2026, 9, 28));
      expect(cotahist.calls[1].$2, LocalDate(2026, 9, 28));
      expect(cotahist.calls[1].$3, LocalDate(2026, 9, 30));
      final range = await repo.priceRange('PETR4', 'B3');
      expect(range!.$1, LocalDate(2026, 9, 28));
      expect(range.$2, LocalDate(2026, 10, 15));
    },
  );

  test('indicadores: busca só depois do último dado guardado', () async {
    await service.refreshIndicators();
    await service.refreshIndicators();
    expect(sgs.asked, hasLength(2));
    expect(sgs.asked[0].$2, LocalDate(2021, 1, 1));
    expect(sgs.asked[1].$2, LocalDate(2026, 10, 16));
  });

  test('chamadas simultâneas da carteira viram uma só', () async {
    final a = service.refreshPortfolio();
    final b = service.refreshPortfolio();
    expect(identical(a, b), isTrue);
    await a;
    expect(brapi.asked, hasLength(1));
  });
}
