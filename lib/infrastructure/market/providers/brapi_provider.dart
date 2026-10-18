import 'package:clock/clock.dart';

import '../../../application/market/market_ports.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/time/instant_format.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../market_http.dart';
import 'parse.dart';

/// brapi: cotação atual de ativos da B3 (`FONTES_DE_DADOS.md` §2.7).
///
/// Plano gratuito: atualização a cada 30 min, uma requisição por vez, um
/// ticker por requisição. A chave vai no cabeçalho `Authorization`, nunca na
/// URL. Sem chave, só os tickers de teste da brapi respondem.
class BrapiProvider implements QuoteProvider {
  BrapiProvider(
    this._http, {
    required this._apiKey,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String? Function() _apiKey;
  final Clock _clock;

  static const freeTickers = {
    'PETR4',
    'VALE3',
    'MGLU3',
    'ITUB4',
    'MXRF11',
    'HGLG11',
  };

  static const _classes = {'stock_br', 'fii', 'etf_br', 'bdr'};

  @override
  String get code => ProviderCatalog.brapi.code;

  @override
  bool supports(MarketInstrument i) =>
      i.market == 'B3' &&
      _classes.contains(i.assetClass) &&
      (_apiKey() != null || freeTickers.contains(i.symbol.toUpperCase()));

  @override
  Future<MarketQuote> quote(MarketInstrument instrument) async {
    final key = _apiKey();
    final uri = Uri.https(
      'brapi.dev',
      '/api/quote/${Uri.encodeComponent(instrument.symbol.toUpperCase())}',
    );
    final String text;
    try {
      text = await _http.getText(
        code,
        uri,
        headers: {if (key != null) 'Authorization': 'Bearer $key'},
      );
    } on HttpStatusError catch (e) {
      throw DataError(switch (e.statusCode) {
        401 => 'A chave da brapi foi recusada. Confira em Fontes de dados.',
        402 ||
        403 => 'O plano da brapi não permite consultar ${instrument.symbol}.',
        404 => 'A brapi não encontrou o ativo ${instrument.symbol}.',
        _ => 'A brapi recusou a consulta (${e.statusCode}).',
      });
    }
    return parse(text, instrument, collectedAt: formatInstant(_clock.now()));
  }

  /// `{"results":[{"symbol":"PETR4","currency":"BRL",
  /// "regularMarketPrice":59.68,"regularMarketTime":"2026-10-17T02:29:23.000Z"}]}`.
  static MarketQuote parse(
    String text,
    MarketInstrument instrument, {
    required String collectedAt,
  }) {
    const name = 'brapi';
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final results = MarketParse.list(name, json['results'], 'results');
    if (results.isEmpty) MarketParse.invalid(name, 'sem resultados');
    final r = MarketParse.map(name, results.first, 'resultado');
    final price = MarketParse.decimal(r['regularMarketPrice']);
    final at = r['regularMarketTime'];
    if (price == null || at is! String) {
      MarketParse.invalid(name, 'sem preço ou data');
    }
    final DateTime refAt;
    try {
      refAt = DateTime.parse(at).toUtc();
    } on FormatException {
      MarketParse.invalid(name, 'data inválida');
    }
    return MarketQuote(
      symbol: instrument.symbol,
      market: instrument.market,
      price: price,
      currency: '${r['currency'] ?? instrument.currency}',
      refAt: refAt,
      source: ProviderCatalog.brapi.code,
      dataType: MarketDataType.intraday,
      collectedAt: collectedAt,
      delayNote: 'atraso de até 30 min (plano gratuito da brapi)',
    );
  }
}
