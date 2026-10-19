import 'dart:async';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/instant_format.dart';
import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../data/repositories/provider_state_repository.dart';
import '../../domain/finance/business_calendar.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/provider_catalog.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';
import '../portfolio/portfolio_query.dart';
import '../settings/market_preferences.dart';
import 'market_ports.dart';

final _log = Logger('mercado');

/// Falha de um provedor numa atualização.
class ProviderFailure {
  const ProviderFailure(this.provider, this.message, {this.network = false});

  final String provider;
  final String message;

  /// Falha de rede (sem conexão, fora do ar).
  final bool network;
}

/// Resultado de uma atualização.
class RefreshResult {
  RefreshResult();

  /// Registros gravados (cotações, barras, indicadores…).
  int updated = 0;
  final failures = <ProviderFailure>[];

  /// Ativos sem nenhuma fonte disponível (sem chave, fonte desligada…).
  final unsupported = <String>[];

  /// Todas as falhas foram de rede: o app está sem internet.
  bool get offline => failures.isNotEmpty && failures.every((f) => f.network);

  void merge(RefreshResult other) {
    updated += other.updated;
    failures.addAll(other.failures);
    unsupported.addAll(other.unsupported);
  }
}

/// Provedores na ordem de preferência de cada tipo de dado (DECISIONS D-08
/// e D-35).
class MarketProviders {
  const MarketProviders({
    this.quotes = const [],
    this.history = const [],
    this.batchHistory,
    this.events = const [],
    this.indicators = const [],
    this.fx = const [],
    this.treasury,
    this.funds,
  });

  final List<QuoteProvider> quotes;
  final List<HistoryProvider> history;

  /// COTAHIST: histórico da B3 em lote.
  final BatchHistoryProvider? batchHistory;
  final List<CorporateEventsProvider> events;
  final List<IndicatorProvider> indicators;
  final List<FxProvider> fx;
  final TreasuryProvider? treasury;
  final FundReportProvider? funds;
}

/// Atualiza os dados de mercado (SPEC §4 e §5): escolhe a fonte de cada
/// ativo, respeita fontes desligadas e cotas, registra sucesso e erro de cada
/// provedor e grava tudo com fonte e datas. Nenhuma requisição leva
/// quantidades, valores ou contas: só códigos de ativos e séries (regra 8).
class MarketDataService {
  MarketDataService({
    required this._repo,
    required this._states,
    required this._providers,
    required this._preferences,
    this._portfolio,
    Clock wallClock = const Clock(),
    BusinessCalendar? calendar,
    this.monthlyQuotas = const {'brapi': 15000},
  }) : _clock = wallClock,
       _calendar = calendar ?? BusinessCalendar.brazil;

  final MarketRepository _repo;
  final ProviderStateRepository _states;
  final MarketProviders _providers;
  final MarketPreferences _preferences;
  final PortfolioQuery? _portfolio;
  final Clock _clock;
  final BusinessCalendar _calendar;

  /// Cota mensal por provedor (o app para de chamar ao atingir).
  final Map<String, int> monthlyQuotas;

  Future<RefreshResult>? _running;

  /// Provedores que falharam por rede na atualização da carteira em
  /// andamento, e se algum respondeu. Duas fontes diferentes sem rede e
  /// nenhuma resposta: o PC está sem internet e o resto da atualização é
  /// pulado (cada fonte levaria vários segundos nas retentativas).
  Set<String>? _runNetworkDown;
  bool _runAnySuccess = false;

  bool get _looksOffline =>
      !_runAnySuccess && (_runNetworkDown?.length ?? 0) >= 2;

  /// Moedas sempre acompanhadas no câmbio.
  static const baseCurrencies = {'USD', 'EUR'};

  LocalDate get _today => LocalDate.fromDateTime(_clock.now().toLocal());

  /// Último dia útil antes de hoje (o último pregão completo).
  LocalDate get _lastSession {
    var d = _today.addDays(-1);
    while (!_calendar.isBusinessDay(d)) {
      d = d.addDays(-1);
    }
    return d;
  }

  static MarketInstrument instrumentOf(Asset a, {String? isin}) =>
      MarketInstrument(
        symbol: a.symbol.toUpperCase(),
        market: a.market.code,
        assetClass: a.assetClass.code,
        currency: a.currency,
        isin: a.isin ?? isin,
      );

  // -- Chamadas protegidas ----------------------------------------------------

  /// Chama [run] no provedor [code] se ele estiver ligado e dentro da cota.
  /// Registra o resultado; em falha, devolve `null` e anota em [result].
  Future<T?> _call<T>(
    String code,
    RefreshResult result,
    Future<T> Function() run,
  ) async {
    if (!await _states.isEnabled(code)) return null;
    if (_looksOffline) {
      result.failures.add(
        ProviderFailure(
          code,
          'Não consultado: o computador parece estar sem internet.',
          network: true,
        ),
      );
      return null;
    }
    final quota = monthlyQuotas[code];
    if (quota != null) {
      final used = await _states.addQuota(code, _clock.now());
      if (used > quota) {
        result.failures.add(
          ProviderFailure(
            code,
            'Cota mensal de ${ProviderCatalog.nameOf(code)} atingida '
            '($quota requisições). Volta no mês que vem.',
          ),
        );
        return null;
      }
    }
    try {
      final value = await run();
      _runAnySuccess = true;
      await _states.recordSuccess(code, _clock.now());
      return value;
    } on AppError catch (error) {
      if (error is NetworkError) _runNetworkDown?.add(code);
      await _states.recordError(code, _clock.now(), error.message);
      result.failures.add(
        ProviderFailure(code, error.message, network: error is NetworkError),
      );
      _log.warning('$code: ${error.kind}');
      return null;
    } on Object catch (error, stack) {
      const message = 'Erro inesperado ao ler os dados do provedor.';
      await _states.recordError(code, _clock.now(), message);
      result.failures.add(ProviderFailure(code, message));
      _log.severe('$code: erro inesperado', error, stack);
      return null;
    }
  }

  // -- Carteira ---------------------------------------------------------------

  /// Atualiza tudo o que a carteira real usa: cotações dos ativos com
  /// posição aberta e preço de mercado, fechamentos da B3, Tesouro, informes
  /// de FII, câmbio e indicadores. Chamadas simultâneas viram uma só.
  Future<RefreshResult> refreshPortfolio() {
    final running = _running;
    if (running != null) return running;
    _runNetworkDown = {};
    _runAnySuccess = false;
    final future = _refreshPortfolio().whenComplete(() {
      _running = null;
      _runNetworkDown = null;
    });
    _running = future;
    return future;
  }

  Future<RefreshResult> _refreshPortfolio() async {
    final result = RefreshResult();
    final assets = await _portfolioAssets();
    _log.info('Atualização da carteira: ${assets.length} ativos');
    result
      ..merge(await refreshQuotes(assets))
      ..merge(await _refreshB3Closes(assets))
      ..merge(await _refreshTreasuryIfNeeded(assets))
      ..merge(await _refreshFiiReports(assets))
      ..merge(
        await refreshFx(
          currencies: {
            ...baseCurrencies,
            for (final a in assets)
              if (a.currency != 'BRL') a.currency,
          },
        ),
      )
      ..merge(await refreshIndicators());
    return result;
  }

  /// Ativos com posição aberta e preço de mercado.
  Future<List<Asset>> _portfolioAssets() async {
    final portfolio = _portfolio;
    if (portfolio == null) return const [];
    final snap = await portfolio.load();
    final ids = {
      for (final p in snap.state.positions)
        if (p.isOpen) p.assetId,
    };
    return [
      for (final id in ids)
        if (snap.assets[id] case final a?)
          if (a.priceSource == PriceSource.market &&
              a.assetClass != AssetClass.cash)
            a,
    ];
  }

  /// Cotação atual de cada ativo, pela primeira fonte que atende e responde.
  Future<RefreshResult> refreshQuotes(Iterable<Asset> assets) async {
    final result = RefreshResult();
    for (final asset in assets) {
      if (asset.assetClass == AssetClass.treasury) continue;
      final i = instrumentOf(
        asset,
        isin: await _repo.isinOf(asset.symbol, asset.market.code),
      );
      final candidates = [
        for (final p in _providers.quotes)
          if (p.supports(i) && await _states.isEnabled(p.code)) p,
      ];
      if (candidates.isEmpty) {
        if (asset.market != Market.b3) result.unsupported.add(asset.symbol);
        continue;
      }
      for (final p in candidates) {
        final quote = await _call(p.code, result, () => p.quote(i));
        if (quote != null) {
          await _repo.saveQuote(quote);
          result.updated++;
          break;
        }
      }
    }
    return result;
  }

  /// Fechamentos oficiais recentes da B3 (arquivos diários do COTAHIST),
  /// para os ativos da B3 cujo último fechamento guardado é antigo.
  Future<RefreshResult> _refreshB3Closes(List<Asset> assets) async {
    final result = RefreshResult();
    final cotahist = _providers.batchHistory;
    if (cotahist == null) return result;
    final b3 = [
      for (final a in assets)
        if (cotahist.supports(instrumentOf(a))) a,
    ];
    if (b3.isEmpty) return result;
    final target = _lastSession;
    var from = target;
    final symbols = <String>{};
    for (final a in b3) {
      final range = await _repo.priceRange(a.symbol.toUpperCase(), 'B3');
      if (range != null && !range.$2.isBefore(target)) continue;
      symbols.add(a.symbol.toUpperCase());
      final start = range == null ? target.addDays(-7) : range.$2.addDays(1);
      if (start.isBefore(from)) from = start;
    }
    if (symbols.isEmpty) return result;
    final earliest = _today.addDays(-15);
    if (from.isBefore(earliest)) from = earliest;
    final batch = await _call(
      cotahist.code,
      result,
      () => cotahist.historyBatch(symbols, from: from, to: target),
    );
    if (batch != null) result.updated += await _saveBatch(batch);
    return result;
  }

  Future<int> _saveBatch(
    ({Map<String, List<PriceBar>> bars, Map<String, String> isins}) batch,
  ) async {
    var n = 0;
    for (final bars in batch.bars.values) {
      await _repo.savePrices(bars);
      n += bars.length;
    }
    final now = formatInstant(_clock.now());
    for (final MapEntry(:key, :value) in batch.isins.entries) {
      await _repo.saveInstrument(
        symbol: key,
        market: 'B3',
        source: ProviderCatalog.b3Cotahist.code,
        isin: value,
        collectedAt: now,
      );
    }
    return n;
  }

  Future<RefreshResult> _refreshTreasuryIfNeeded(List<Asset> assets) async {
    if (!assets.any((a) => a.assetClass == AssetClass.treasury)) {
      return RefreshResult();
    }
    final last = await _repo.lastTreasuryDate();
    if (last != null && !last.isBefore(_lastSession)) return RefreshResult();
    return refreshTreasury();
  }

  /// Preços do Tesouro Direto desde o último dia guardado (ou desde o ano
  /// inicial do histórico).
  Future<RefreshResult> refreshTreasury() async {
    final result = RefreshResult();
    final provider = _providers.treasury;
    if (provider == null) return result;
    final last = await _repo.lastTreasuryDate();
    final from =
        last?.addDays(1) ??
        LocalDate(await _preferences.historyStartYear(_today.year), 1, 1);
    final prices = await _call(
      provider.code,
      result,
      () => provider.prices(from: from),
    );
    if (prices != null) {
      await _repo.saveTreasury(prices);
      result.updated += prices.length;
    }
    return result;
  }

  /// Informe mensal da CVM dos FIIs da carteira, se o guardado tiver mais de
  /// 40 dias.
  Future<RefreshResult> _refreshFiiReports(List<Asset> assets) async {
    final result = RefreshResult();
    final funds = _providers.funds;
    if (funds == null) return result;
    final isins = <String>{};
    for (final a in assets) {
      if (a.assetClass != AssetClass.fii) continue;
      final isin = a.isin ?? await _repo.isinOf(a.symbol.toUpperCase(), 'B3');
      if (isin == null) continue;
      final latest = await _repo.latestFiiReport(isin);
      if (latest != null && _today.daysSince(latest.refDate) <= 40) continue;
      isins.add(isin);
    }
    if (isins.isEmpty) return result;
    for (final year in {_today.year, _today.addDays(-45).year}) {
      final reports = await _call(
        funds.code,
        result,
        () => funds.fiiMonthly(isins, year: year),
      );
      if (reports != null) {
        await _repo.saveFundReports(reports);
        result.updated += reports.length;
      }
    }
    return result;
  }

  // -- Câmbio e indicadores ---------------------------------------------------

  /// Câmbio contra o real desde o último dia guardado (ou desde o ano
  /// inicial): PTAX primeiro, referência do BCE se a PTAX falhar ou não
  /// tiver a moeda.
  Future<RefreshResult> refreshFx({
    Set<String> currencies = baseCurrencies,
  }) async {
    final result = RefreshResult();
    final startYear = await _preferences.historyStartYear(_today.year);
    for (final currency in currencies) {
      final last = (await _repo.latestFx(currency))?.refDate;
      final from = last?.addDays(1) ?? LocalDate(startYear, 1, 1);
      if (from.isAfter(_today)) continue;
      for (final p in _providers.fx) {
        if (!p.supports(currency)) continue;
        final rates = await _call(
          p.code,
          result,
          () => p.rates(currency, from: from, to: _today),
        );
        if (rates != null) {
          await _repo.saveFx(rates);
          result.updated += rates.length;
          break;
        }
      }
    }
    return result;
  }

  /// CDI, Selic, meta Selic, IPCA e IGP-M desde o último dado guardado (ou
  /// desde o ano inicial).
  Future<RefreshResult> refreshIndicators() async {
    final result = RefreshResult();
    final startYear = await _preferences.historyStartYear(_today.year);
    for (final series in IndicatorSeries.values) {
      final last = (await _repo.latestIndicator(series))?.refDate;
      final from = last == null
          ? LocalDate(startYear, 1, 1)
          : series.isMonthly
          ? LocalDate(last.year, last.month + 1, 1)
          : last.addDays(1);
      if (from.isAfter(_today)) continue;
      for (final p in _providers.indicators) {
        if (!p.supports(series)) continue;
        final points = await _call(
          p.code,
          result,
          () => p.indicator(series, from: from, to: _today),
        );
        if (points != null) {
          await _repo.saveIndicators(points);
          result.updated += points.length;
          break;
        }
      }
    }
    return result;
  }

  // -- Um ativo ---------------------------------------------------------------

  /// Atualiza um ativo: cotação, fechamentos recentes (B3), proventos e
  /// informe (FII).
  Future<RefreshResult> refreshAsset(Asset asset) async {
    final result = RefreshResult()
      ..merge(await refreshQuotes([asset]))
      ..merge(await _refreshB3Closes([asset]))
      ..merge(await refreshEvents(asset));
    if (asset.assetClass == AssetClass.treasury) {
      result.merge(await refreshTreasury());
    }
    if (asset.assetClass == AssetClass.fii) {
      result.merge(await _refreshFiiReports([asset]));
    }
    return result;
  }

  /// Proventos e eventos corporativos do ativo.
  Future<RefreshResult> refreshEvents(Asset asset) async {
    final result = RefreshResult();
    final i = instrumentOf(
      asset,
      isin: await _repo.isinOf(asset.symbol.toUpperCase(), asset.market.code),
    );
    for (final p in _providers.events) {
      if (!p.supports(i)) continue;
      final events = await _call(p.code, result, () => p.events(i));
      if (events != null) {
        await _repo.replaceEvents(i.symbol, i.market, p.code, events);
        result.updated += events.length;
        break;
      }
    }
    return result;
  }

  /// Baixa o histórico diário do ativo desde o ano inicial configurado (ou
  /// [from]), só o que ainda não está guardado. Na B3, os anos necessários
  /// do COTAHIST (os arquivos são apagados depois da extração).
  Future<RefreshResult> downloadHistory(Asset asset, {LocalDate? from}) async {
    final result = RefreshResult();
    final i = instrumentOf(asset);
    final start =
        from ??
        LocalDate(await _preferences.historyStartYear(_today.year), 1, 1);
    final end = _lastSession;
    final range = await _repo.priceRange(i.symbol, i.market);
    // Só os trechos que faltam: antes do primeiro e depois do último dia.
    final gaps = <(LocalDate, LocalDate)>[
      if (range == null)
        (start, end)
      else ...[
        if (start.isBefore(range.$1)) (start, range.$1.addDays(-1)),
        if (range.$2.isBefore(end)) (range.$2.addDays(1), end),
      ],
    ];
    for (final (a, b) in gaps) {
      final cotahist = _providers.batchHistory;
      if (cotahist != null && cotahist.supports(i)) {
        final batch = await _call(
          cotahist.code,
          result,
          () => cotahist.historyBatch({i.symbol}, from: a, to: b),
        );
        if (batch != null) result.updated += await _saveBatch(batch);
        continue;
      }
      var served = false;
      for (final p in _providers.history) {
        if (!p.supports(i) || !await _states.isEnabled(p.code)) continue;
        served = true;
        final bars = await _call(
          p.code,
          result,
          () => p.history(i, from: a, to: b),
        );
        if (bars != null) {
          await _repo.savePrices(bars);
          result.updated += bars.length;
          break;
        }
      }
      if (!served) result.unsupported.add(asset.symbol);
    }
    return result;
  }

  /// Faz uma consulta pequena ao provedor, para conferir chave e conexão.
  Future<RefreshResult> testProvider(String code) async {
    final result = RefreshResult();
    final today = _today;
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
    Future<Object?> probe() async {
      for (final p in _providers.quotes) {
        if (p.code != code) continue;
        for (final i in [petr4, aapl, btc]) {
          if (p.supports(i)) return p.quote(i);
        }
      }
      for (final p in _providers.history) {
        if (p.code != code) continue;
        for (final i in [aapl, btc]) {
          if (p.supports(i)) {
            return p.history(i, from: today.addDays(-7), to: today);
          }
        }
      }
      for (final p in _providers.indicators) {
        if (p.code == code) {
          return p.indicator(
            IndicatorSeries.cdi.supportedBy(p)
                ? IndicatorSeries.cdi
                : IndicatorSeries.ipca,
            from: today.addDays(-70),
            to: today,
          );
        }
      }
      for (final p in _providers.fx) {
        if (p.code == code) {
          return p.rates('USD', from: today.addDays(-7), to: today);
        }
      }
      for (final p in _providers.events) {
        if (p.code == code) return p.events(petr4);
      }
      throw const DataError(
        'Este provedor baixa arquivos grandes e é testado na próxima '
        'atualização.',
      );
    }

    final value = await _call(code, result, probe);
    if (value != null) result.updated++;
    return result;
  }
}

extension on IndicatorSeries {
  bool supportedBy(IndicatorProvider p) => p.supports(this);
}
