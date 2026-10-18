import 'package:clock/clock.dart';

import '../../../application/market/market_ports.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/json/exact_json.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

const _intlMarkets = {'NYSE', 'NASDAQ', 'OTC'};
const _intlClasses = {'stock_intl', 'etf_intl', 'reit'};

bool _isIntl(MarketInstrument i) =>
    _intlMarkets.contains(i.market) && _intlClasses.contains(i.assetClass);

DataError _refused(String provider, HttpStatusError e) =>
    DataError(switch (e.statusCode) {
      401 || 403 =>
        'A chave de $provider foi recusada ou o plano não permite esta '
            'consulta. Confira em Fontes de dados.',
      404 => '$provider não encontrou o ativo.',
      _ => '$provider recusou a consulta (${e.statusCode}).',
    });

/// CoinGecko: cotação atual de criptomoedas (`FONTES_DE_DADOS.md` §2.12).
/// Atribuição obrigatória ("Data provided by CoinGecko").
class CoinGeckoProvider implements QuoteProvider {
  CoinGeckoProvider(
    this._http, {
    required this._apiKey,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String? Function() _apiKey;
  final Clock _clock;
  final _ids = <String, String>{};

  /// Identificadores das moedas mais comuns; as outras são buscadas.
  static const knownIds = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
    'USDC': 'usd-coin',
    'BNB': 'binancecoin',
    'SOL': 'solana',
    'XRP': 'ripple',
    'ADA': 'cardano',
    'DOGE': 'dogecoin',
    'TRX': 'tron',
    'DOT': 'polkadot',
    'LTC': 'litecoin',
    'LINK': 'chainlink',
    'AVAX': 'avalanche-2',
    'BCH': 'bitcoin-cash',
  };

  @override
  String get code => ProviderCatalog.coingecko.code;

  @override
  bool supports(MarketInstrument i) => i.market == 'CRYPTO';

  Map<String, String> get _headers {
    final key = _apiKey();
    return {'x-cg-demo-api-key': ?key};
  }

  /// Identificador da moeda na CoinGecko.
  Future<String> idOf(String symbol) async {
    final upper = symbol.toUpperCase();
    final known = knownIds[upper] ?? _ids[upper];
    if (known != null) return known;
    final text = await _get(
      Uri.https('api.coingecko.com', '/api/v3/search', {'query': upper}),
    );
    final id = parseSearch(text, upper);
    if (id == null) {
      throw DataError('A CoinGecko não encontrou a criptomoeda $upper.');
    }
    return _ids[upper] = id;
  }

  @override
  Future<MarketQuote> quote(MarketInstrument i) async {
    final id = await idOf(i.symbol);
    final currency = i.currency.toLowerCase();
    final text = await _get(
      Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': id,
        'vs_currencies': currency,
        'include_last_updated_at': 'true',
      }),
    );
    return parseQuote(
      text,
      i,
      id: id,
      collectedAt: formatInstant(_clock.now()),
    );
  }

  Future<String> _get(Uri uri) async {
    try {
      return await _http.getText(code, uri, headers: _headers);
    } on HttpStatusError catch (e) {
      throw _refused('CoinGecko', e);
    }
  }

  /// A moeda de maior capitalização com exatamente este símbolo.
  static String? parseSearch(String text, String symbol) {
    final json = MarketParse.map(
      'CoinGecko',
      MarketParse.json('CoinGecko', text),
      'resposta',
    );
    String? best;
    int? bestRank;
    for (final c in (json['coins'] as List<Object?>?) ?? const []) {
      if (c is! Map<String, Object?>) continue;
      if ('${c['symbol']}'.toUpperCase() != symbol) continue;
      final rank = c['market_cap_rank'] is JsonNumber
          ? (c['market_cap_rank']! as JsonNumber).integer
          : null;
      if (best == null ||
          (rank != null && (bestRank == null || rank < bestRank))) {
        best = '${c['id']}';
        bestRank = rank;
      }
    }
    return best;
  }

  /// `{"bitcoin":{"brl":410477,"last_updated_at":1792281600}}`.
  static MarketQuote parseQuote(
    String text,
    MarketInstrument i, {
    required String id,
    required String collectedAt,
  }) {
    const name = 'CoinGecko';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final coin = MarketParse.map(name, json[id], id);
    final price = MarketParse.decimal(coin[i.currency.toLowerCase()]);
    final updated = coin['last_updated_at'];
    if (price == null || updated is! JsonNumber) {
      MarketParse.invalid(name, 'sem preço');
    }
    return MarketQuote(
      symbol: i.symbol,
      market: i.market,
      price: price,
      currency: i.currency,
      refAt: DateTime.fromMillisecondsSinceEpoch(
        updated.integer * 1000,
        isUtc: true,
      ),
      source: ProviderCatalog.coingecko.code,
      dataType: MarketDataType.intraday,
      collectedAt: collectedAt,
      delayNote: 'agregado de várias corretoras, atualizado a cada minutos',
    );
  }
}

/// Binance: histórico diário de criptomoedas contra o real
/// (`FONTES_DE_DADOS.md` §2.13). Dia em UTC; preço da corretora.
class BinanceProvider implements HistoryProvider {
  BinanceProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.binance.code;

  /// Só pares contra o real: um par contra USDT não é preço em dólar.
  @override
  bool supports(MarketInstrument i) =>
      i.market == 'CRYPTO' && i.currency == 'BRL';

  @override
  Future<List<PriceBar>> history(
    MarketInstrument i, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final pair = '${i.symbol.toUpperCase()}BRL';
    final result = <PriceBar>[];
    var start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day, 23, 59, 59);
    while (start.isBefore(end)) {
      final String text;
      try {
        text = await _http.getText(
          code,
          Uri.https('api.binance.com', '/api/v3/klines', {
            'symbol': pair,
            'interval': '1d',
            'startTime': '${start.millisecondsSinceEpoch}',
            'endTime': '${end.millisecondsSinceEpoch}',
            'limit': '1000',
          }),
        );
      } on HttpStatusError catch (e) {
        if (e.statusCode == 400) {
          throw DataError('A Binance não negocia o par $pair.');
        }
        throw _refused('Binance', e);
      }
      final bars = parse(text, i, collectedAt: formatInstant(_clock.now()));
      if (bars.isEmpty) break;
      result.addAll(bars);
      final last = bars.last.refDate;
      start = DateTime.utc(last.year, last.month, last.day + 1);
      if (bars.length < 1000) break;
    }
    return result;
  }

  /// `[[openTime, "open", "high", "low", "close", "volume", closeTime,
  /// "quoteVolume", ...], ...]`.
  static List<PriceBar> parse(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    const name = 'Binance';
    final rows = MarketParse.list(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final result = <PriceBar>[];
    for (final r in rows) {
      if (r is! List<Object?> || r.length < 8 || r[0] is! JsonNumber) continue;
      final open = DateTime.fromMillisecondsSinceEpoch(
        (r[0]! as JsonNumber).integer,
        isUtc: true,
      );
      final close = MarketParse.decimal(r[4]);
      if (close == null) continue;
      result.add(
        PriceBar(
          symbol: i.symbol,
          market: i.market,
          refDate: LocalDate(open.year, open.month, open.day),
          open: MarketParse.decimal(r[1]),
          high: MarketParse.decimal(r[2]),
          low: MarketParse.decimal(r[3]),
          close: close,
          volume: MarketParse.decimal(r[7]),
          currency: 'BRL',
          source: ProviderCatalog.binance.code,
          dataType: MarketDataType.close,
          collectedAt: collectedAt,
        ),
      );
    }
    return result;
  }
}

/// Finnhub: cotação atual de ações e ETFs dos EUA. Histórico e outras
/// bolsas são pagos (confirmado no swagger oficial em 18/10/2026).
class FinnhubProvider implements QuoteProvider {
  FinnhubProvider(
    this._http, {
    required this._apiKey,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String? Function() _apiKey;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.finnhub.code;

  @override
  bool supports(MarketInstrument i) =>
      _apiKey() != null && _isIntl(i) && i.currency == 'USD';

  @override
  Future<MarketQuote> quote(MarketInstrument i) async {
    final key = _apiKey();
    if (key == null) {
      throw const DataError('Cadastre a chave do Finnhub em Fontes de dados.');
    }
    final String text;
    try {
      text = await _http.getText(
        code,
        Uri.https('finnhub.io', '/api/v1/quote', {
          'symbol': i.symbol.toUpperCase(),
        }),
        headers: {'X-Finnhub-Token': key},
      );
    } on HttpStatusError catch (e) {
      throw _refused('Finnhub', e);
    }
    return parse(text, i, collectedAt: formatInstant(_clock.now()));
  }

  /// `{"c":261.74,"d":...,"t":1792180800}`; ticker desconhecido vem com
  /// `c` e `t` zerados.
  static MarketQuote parse(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    const name = 'Finnhub';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final price = MarketParse.decimal(json['c']);
    final t = json['t'];
    if (price == null || t is! JsonNumber || t.integer == 0) {
      throw DataError('O Finnhub não tem cotação para ${i.symbol}.');
    }
    return MarketQuote(
      symbol: i.symbol,
      market: i.market,
      price: price,
      currency: 'USD',
      refAt: DateTime.fromMillisecondsSinceEpoch(t.integer * 1000, isUtc: true),
      source: ProviderCatalog.finnhub.code,
      dataType: MarketDataType.intraday,
      collectedAt: collectedAt,
    );
  }
}

/// Twelve Data: histórico diário (sem ajuste) e última cotação de ações e
/// ETFs dos EUA (plano Basic; a B3 só nos pagos).
class TwelveDataProvider implements HistoryProvider, QuoteProvider {
  TwelveDataProvider(
    this._http, {
    required this._apiKey,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String? Function() _apiKey;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.twelveData.code;

  @override
  bool supports(MarketInstrument i) =>
      _apiKey() != null && _isIntl(i) && i.currency == 'USD';

  Future<String> _get(String path, Map<String, String> query) async {
    final key = _apiKey();
    if (key == null) {
      throw const DataError(
        'Cadastre a chave do Twelve Data em Fontes de dados.',
      );
    }
    final String text;
    try {
      text = await _http.getText(
        code,
        Uri.https('api.twelvedata.com', path, query),
        headers: {'Authorization': 'apikey $key'},
      );
    } on HttpStatusError catch (e) {
      throw _refused('Twelve Data', e);
    }
    // Erros vêm com HTTP 200 e `"status":"error"`.
    final json = MarketParse.json('Twelve Data', text);
    if (json is Map<String, Object?> && json['status'] == 'error') {
      final status = int.tryParse('${json['code']}') ?? 0;
      throw _refused('Twelve Data', HttpStatusError(code, status, ''));
    }
    return text;
  }

  @override
  Future<List<PriceBar>> history(
    MarketInstrument i, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final text = await _get('/time_series', {
      'symbol': i.symbol.toUpperCase(),
      'interval': '1day',
      'start_date': '$from',
      'end_date': '$to',
      'outputsize': '5000',
      'order': 'asc',
      'adjust': 'none',
    });
    return parseHistory(text, i, collectedAt: formatInstant(_clock.now()));
  }

  @override
  Future<MarketQuote> quote(MarketInstrument i) async {
    final text = await _get('/quote', {'symbol': i.symbol.toUpperCase()});
    return parseQuote(text, i, collectedAt: formatInstant(_clock.now()));
  }

  /// `{"meta":{"currency":"USD"},"values":[{"datetime":"2026-10-16",
  /// "open":"…","high":"…","low":"…","close":"…","volume":"…"}],
  /// "status":"ok"}`.
  static List<PriceBar> parseHistory(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    const name = 'Twelve Data';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final meta = json['meta'];
    final currency = meta is Map<String, Object?>
        ? '${meta['currency'] ?? i.currency}'
        : i.currency;
    return [
      for (final v in (json['values'] as List<Object?>?) ?? const [])
        if (v is Map<String, Object?>)
          if (MarketParse.isoDate(v['datetime']) case final date?)
            if (MarketParse.decimal(v['close']) case final close?)
              PriceBar(
                symbol: i.symbol,
                market: i.market,
                refDate: date,
                open: MarketParse.decimal(v['open']),
                high: MarketParse.decimal(v['high']),
                low: MarketParse.decimal(v['low']),
                close: close,
                volume: MarketParse.decimal(v['volume']),
                currency: currency,
                source: ProviderCatalog.twelveData.code,
                dataType: MarketDataType.close,
                collectedAt: collectedAt,
              ),
    ];
  }

  /// `{"close":"261.74","timestamp":1792180800,"currency":"USD"}`.
  static MarketQuote parseQuote(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    const name = 'Twelve Data';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final price = MarketParse.decimal(json['close']);
    final t = json['timestamp'];
    if (price == null || t is! JsonNumber) {
      MarketParse.invalid(name, 'sem preço');
    }
    return MarketQuote(
      symbol: i.symbol,
      market: i.market,
      price: price,
      currency: '${json['currency'] ?? i.currency}',
      refAt: DateTime.fromMillisecondsSinceEpoch(t.integer * 1000, isUtc: true),
      source: ProviderCatalog.twelveData.code,
      dataType: json['is_market_open'] == true
          ? MarketDataType.intraday
          : MarketDataType.close,
      collectedAt: collectedAt,
    );
  }
}

/// Yahoo Finance (endpoint `v8/finance/chart`, não oficial): alternativa
/// para internacional e índices, **desligado por padrão** (D-08).
class YahooProvider implements HistoryProvider, QuoteProvider {
  YahooProvider(this._http, {Clock wallClock = const Clock()})
    : _clock = wallClock;

  final MarketHttp _http;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.yahoo.code;

  @override
  bool supports(MarketInstrument i) =>
      _isIntl(i) || (i.market == 'INDEX' && i.symbol.startsWith('^'));

  Future<String> _chart(MarketInstrument i, Map<String, String> query) async {
    try {
      return await _http.getText(
        code,
        Uri.https(
          'query1.finance.yahoo.com',
          '/v8/finance/chart/${Uri.encodeComponent(i.symbol.toUpperCase())}',
          query,
        ),
        headers: const {'User-Agent': 'Mozilla/5.0'},
      );
    } on HttpStatusError catch (e) {
      throw _refused('Yahoo', e);
    }
  }

  @override
  Future<List<PriceBar>> history(
    MarketInstrument i, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day + 1);
    final text = await _chart(i, {
      'period1': '${start.millisecondsSinceEpoch ~/ 1000}',
      'period2': '${end.millisecondsSinceEpoch ~/ 1000}',
      'interval': '1d',
      'events': 'div,split',
    });
    return parseHistory(text, i, collectedAt: formatInstant(_clock.now()));
  }

  @override
  Future<MarketQuote> quote(MarketInstrument i) async {
    final text = await _chart(i, {'range': '1d', 'interval': '1d'});
    return parseQuote(text, i, collectedAt: formatInstant(_clock.now()));
  }

  static Map<String, Object?> _result(String text) {
    const name = 'Yahoo';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final chart = MarketParse.map(name, json['chart'], 'chart');
    final results = MarketParse.list(name, chart['result'], 'result');
    if (results.isEmpty) MarketParse.invalid(name, 'sem resultado');
    return MarketParse.map(name, results.first, 'resultado');
  }

  /// Preço bruto (`indicators.quote[0].close`), no fuso da bolsa.
  static List<PriceBar> parseHistory(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    final r = _result(text);
    final meta = MarketParse.map('Yahoo', r['meta'], 'meta');
    final offset = meta['gmtoffset'] is JsonNumber
        ? (meta['gmtoffset']! as JsonNumber).integer
        : 0;
    final times = (r['timestamp'] as List<Object?>?) ?? const [];
    final indicators = MarketParse.map('Yahoo', r['indicators'], 'indicators');
    final quotes = (indicators['quote'] as List<Object?>?) ?? const [];
    if (quotes.isEmpty) return const [];
    final q = MarketParse.map('Yahoo', quotes.first, 'quote');
    List<Object?> col(String name) => (q[name] as List<Object?>?) ?? const [];
    final opens = col('open');
    final highs = col('high');
    final lows = col('low');
    final closes = col('close');
    final volumes = col('volume');
    Object? at(List<Object?> l, int k) => k < l.length ? l[k] : null;
    final result = <PriceBar>[];
    for (var k = 0; k < times.length; k++) {
      final t = times[k];
      final close = MarketParse.decimal(at(closes, k));
      if (t is! JsonNumber || close == null) continue;
      final local = DateTime.fromMillisecondsSinceEpoch(
        (t.integer + offset) * 1000,
        isUtc: true,
      );
      result.add(
        PriceBar(
          symbol: i.symbol,
          market: i.market,
          refDate: LocalDate(local.year, local.month, local.day),
          open: MarketParse.decimal(at(opens, k)),
          high: MarketParse.decimal(at(highs, k)),
          low: MarketParse.decimal(at(lows, k)),
          close: close,
          volume: MarketParse.decimal(at(volumes, k)),
          currency: '${meta['currency'] ?? i.currency}',
          source: ProviderCatalog.yahoo.code,
          dataType: MarketDataType.close,
          collectedAt: collectedAt,
        ),
      );
    }
    return result;
  }

  static MarketQuote parseQuote(
    String text,
    MarketInstrument i, {
    required String collectedAt,
  }) {
    final meta = MarketParse.map('Yahoo', _result(text)['meta'], 'meta');
    final price = MarketParse.decimal(meta['regularMarketPrice']);
    final t = meta['regularMarketTime'];
    if (price == null || t is! JsonNumber) {
      MarketParse.invalid('Yahoo', 'sem preço');
    }
    return MarketQuote(
      symbol: i.symbol,
      market: i.market,
      price: price,
      currency: '${meta['currency'] ?? i.currency}',
      refAt: DateTime.fromMillisecondsSinceEpoch(t.integer * 1000, isUtc: true),
      source: ProviderCatalog.yahoo.code,
      dataType: MarketDataType.intraday,
      collectedAt: collectedAt,
      delayNote: 'fonte não oficial; atraso não informado',
    );
  }
}
