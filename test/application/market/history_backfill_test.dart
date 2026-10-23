import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/market/history_backfill.dart';
import 'package:patrion/application/market/market_data_service.dart';
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

import '../../helpers/portfolio_fixture.dart';

const _collected = '2026-10-17T12:00:00.000Z';

/// COTAHIST de mentira: um fechamento por mês útil de cada ano pedido, e
/// falha de rede nos anos de [offlineYears].
class YearBatch implements BatchHistoryProvider {
  final calls = <(Set<String>, LocalDate, LocalDate)>[];
  final offlineYears = <int>{};

  @override
  String get code => 'b3_cotahist';

  @override
  bool supports(MarketInstrument i) => i.market == 'B3';

  @override
  Future<List<PriceBar>> history(
    MarketInstrument instrument, {
    required LocalDate from,
    required LocalDate to,
  }) async => const [];

  @override
  Future<({Map<String, List<PriceBar>> bars, Map<String, String> isins})>
  historyBatch(
    Set<String> symbols, {
    required LocalDate from,
    required LocalDate to,
    void Function(int percent)? onProgress,
  }) async {
    calls.add((symbols, from, to));
    if (offlineYears.contains(from.year)) {
      throw const NetworkError('sem conexão');
    }
    onProgress?.call(50);
    onProgress?.call(100);
    return (
      bars: {
        for (final s in symbols)
          s: [
            for (var m = 1; m <= 12; m++)
              if (!LocalDate(from.year, m, 10).isAfter(to))
                PriceBar(
                  symbol: s,
                  market: 'B3',
                  refDate: LocalDate(from.year, m, 10),
                  close: Decimal.fromInt(from.year - 2000),
                  currency: 'BRL',
                  source: code,
                  dataType: MarketDataType.close,
                  collectedAt: _collected,
                ),
          ],
      },
      isins: const <String, String>{},
    );
  }
}

class FakeEvents implements CorporateEventsProvider {
  int calls = 0;

  @override
  String get code => 'b3_events';

  @override
  bool supports(MarketInstrument i) => i.assetClass == 'stock_br';

  @override
  Future<List<CorporateEvent>> events(MarketInstrument i) async {
    calls++;
    return [
      CorporateEvent(
        symbol: i.symbol,
        market: i.market,
        kind: CorporateEventKind.cashDividend,
        exDate: LocalDate(2024, 5, 2),
        amount: Decimal.parse('1.25'),
        currency: 'BRL',
        status: CorporateEventStatus.paid,
        source: code,
        seq: 0,
        collectedAt: _collected,
      ),
    ];
  }
}

void main() {
  late PortfolioFixture f;
  late MarketRepository repo;
  late YearBatch cotahist;
  late FakeEvents events;
  late HistoryBackfillService backfill;
  late DeviceSettingsRepository settings;
  var cleaned = 0;

  Future<void> marketPriced(String symbol) async {
    final a = (await f.repos.assets.all()).firstWhere(
      (a) => a.symbol == symbol,
    );
    await f.registry.updateAsset(
      Asset(
        id: a.id,
        symbol: a.symbol,
        market: a.market,
        assetClass: a.assetClass,
        name: a.name,
        currency: a.currency,
        country: a.country,
        priceSource: PriceSource.market,
      ),
    );
  }

  setUp(() async {
    f = await PortfolioFixture.open();
    f.t.wall.now = DateTime.utc(2026, 10, 23, 15);
    repo = MarketRepository(f.t.db);
    settings = DeviceSettingsRepository(f.t.db);
    cotahist = YearBatch();
    events = FakeEvents();
    cleaned = 0;
    final query = PortfolioQuery(
      PortfolioRepositories(f.t.db, f.t.sync),
      wallClock: f.t.wall.clock,
      market: repo,
    );
    final market = MarketDataService(
      repo: repo,
      states: ProviderStateRepository(f.t.db),
      providers: MarketProviders(batchHistory: cotahist, events: [events]),
      preferences: MarketPreferences(settings),
      portfolio: query,
      wallClock: f.t.wall.clock,
    );
    backfill = HistoryBackfillService(
      market: market,
      settings: settings,
      preferences: MarketPreferences(settings),
      portfolio: query,
      cleanCache: () => cleaned++,
      wallClock: f.t.wall.clock,
    );
    await marketPriced('PETR4');
  });

  tearDown(() => f.t.close());

  List<int> years() => [for (final c in cotahist.calls) c.$2.year];

  test('baixa dez anos, do mais recente ao mais antigo, uma vez só', () async {
    final progress = <BackfillProgress>[];
    await backfill.run(onProgress: progress.add);
    expect(years(), [for (var y = 2026; y >= 2016; y--) y]);
    // O ano corrente vai até o último pregão completo.
    expect(cotahist.calls.first.$3, LocalDate(2026, 10, 22));
    final range = await repo.priceRange('PETR4', 'B3');
    expect(range!.$1, LocalDate(2016, 1, 10));
    expect(range.$2, LocalDate(2026, 10, 10));
    expect(progress.first.label, 'Baixando histórico de PETR4… 2026');
    expect(progress.any((p) => p.percent == 50), isTrue);
    expect(progress.last.step, BackfillProgress.eventsStep);
    expect(events.calls, 1);
    expect(await repo.events('PETR4', 'B3'), hasLength(1));
    // Sobras do cache apagadas no início e no fim.
    expect(cleaned, 2);

    cotahist.calls.clear();
    await backfill.run();
    expect(cotahist.calls, isEmpty);
    expect(events.calls, 1);
  });

  test('sem rede no meio, para e continua de onde parou', () async {
    cotahist.offlineYears.add(2020);
    final first = await backfill.run();
    expect(first.offline, isTrue);
    expect(years(), [2026, 2025, 2024, 2023, 2022, 2021, 2020]);

    // App fechado e aberto de novo: só os anos que faltam.
    cotahist
      ..offlineYears.clear()
      ..calls.clear();
    await backfill.run();
    expect(years(), [2020, 2019, 2018, 2017, 2016]);
  });

  test('o ano corrente é relido depois de dez dias', () async {
    await backfill.run();
    cotahist.calls.clear();
    f.t.wall.now = DateTime.utc(2026, 11, 3, 15);
    await backfill.run();
    expect(years(), [2026]);
  });

  test('ano lido antes de terminar é relido no ano seguinte', () {
    final today = LocalDate(2027, 3, 1);
    expect(
      HistoryBackfillService.yearComplete(2026, LocalDate(2026, 12, 20), today),
      isFalse,
    );
    expect(
      HistoryBackfillService.yearComplete(2026, LocalDate(2027, 1, 5), today),
      isTrue,
    );
    expect(
      HistoryBackfillService.yearComplete(2027, LocalDate(2027, 2, 25), today),
      isTrue,
    );
  });

  test('ativo novo: um arquivo por ano serve aos dois', () async {
    await backfill.run();
    cotahist.calls.clear();
    await f.registry.createAsset(
      const Asset(
        id: '',
        symbol: 'VALE3',
        market: Market.b3,
        assetClass: AssetClass.stockBr,
        name: 'Vale ON',
        currency: 'BRL',
        country: 'BR',
        priceSource: PriceSource.market,
      ),
    );
    await backfill.run();
    expect(years(), [for (var y = 2026; y >= 2016; y--) y]);
    expect(cotahist.calls.first.$1, {'PETR4', 'VALE3'});
    expect((await repo.priceRange('VALE3', 'B3'))!.$1, LocalDate(2016, 1, 10));
  });

  test('respeita o ano inicial escolhido', () async {
    await MarketPreferences(settings).setHistoryStartYear(2024);
    await backfill.run();
    expect(years(), [2026, 2025, 2024]);
    expect(await backfill.firstYearRead('PETR4'), 2024);
  });

  test('"Baixar histórico completo" esquece o que foi lido', () async {
    await backfill.run();
    cotahist.calls.clear();
    await backfill.forget('PETR4');
    await backfill.run();
    expect(years(), hasLength(11));
    expect(events.calls, 2);
  });

  test('chamada durante a execução vira uma volta a mais', () async {
    final a = backfill.run();
    final b = backfill.run();
    await Future.wait([a, b]);
    expect(years(), hasLength(11));
  });

  test('sem ativos com preço de mercado, não baixa nada', () async {
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
        priceSource: PriceSource.manual,
      ),
    );
    await backfill.run();
    expect(cotahist.calls, isEmpty);
  });
}
