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

  static const freeTickers = {'PETR4', 'VALE3', 'MGLU3', 'ITUB4'};

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
        401 =>
          key == null
              ? 'Sem chave, a brapi só responde ${freeTickers.join(', ')}. '
                    'Cadastre a sua chave em Fontes de dados.'
              : 'A chave da brapi foi recusada. Confira em Fontes de dados.',
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

/// brapi: dados cadastrais de um ticker da B3 para o cadastro rápido
/// (M-01).
///
/// - A lista (`/api/quote/list?search=`) responde sem chave e traz nome,
///   setor, subsetor e tipo. Vai sem a chave, para não gastar a cota.
/// - Com chave, a cotação com o perfil (`modules=summaryProfile`) traz o
///   nome completo, setor e indústria em português e o preço, que é
///   guardado como qualquer cotação.
class BrapiLookup implements TickerInfoProvider {
  BrapiLookup(
    this._http, {
    required this._apiKey,
    Clock wallClock = const Clock(),
  }) : _clock = wallClock;

  final MarketHttp _http;
  final String? Function() _apiKey;
  final Clock _clock;

  @override
  String get code => ProviderCatalog.brapi.code;

  @override
  bool supports(String market) => market == 'B3';

  @override
  Future<TickerInfo?> lookup(String symbol) async {
    final wanted = symbol.toUpperCase();
    final listed = parseList(
      await _http.getText(
        code,
        Uri.https('brapi.dev', '/api/quote/list', {'search': wanted}),
      ),
      wanted,
    );
    final key = _apiKey();
    TickerInfo? detailed;
    if (key != null) {
      try {
        final text = await _http.getText(
          code,
          Uri.https('brapi.dev', '/api/quote/$wanted', {
            'modules': 'summaryProfile',
          }),
          headers: {'Authorization': 'Bearer $key'},
        );
        detailed = parseDetail(
          text,
          wanted,
          collectedAt: formatInstant(_clock.now()),
        );
      } on HttpStatusError catch (e) {
        // 404: ticker desconhecido; 401 a 403: chave ou plano. Vale a lista.
        if (e.statusCode >= 500) rethrow;
      }
    }
    if (listed == null && detailed == null) return null;
    return TickerInfo(
      symbol: wanted,
      market: 'B3',
      source: code,
      name: detailed?.name ?? listed?.name,
      assetClass: listed?.assetClass,
      sector: detailed?.sector ?? listed?.sector,
      segment: detailed?.segment ?? listed?.segment,
      quote: detailed?.quote,
    );
  }

  /// Item da lista com o código exato. Fundos vêm com o próprio código no
  /// lugar do nome: aí o nome fica de fora.
  static TickerInfo? parseList(String text, String symbol) {
    const name = 'brapi';
    final json = MarketParse.map(name, MarketParse.json(name, text), 'lista');
    final stocks = json['stocks'];
    if (stocks is! List<Object?>) return null;
    for (final item in stocks) {
      if (item is! Map<String, Object?>) continue;
      if ('${item['stock']}'.toUpperCase() != symbol) continue;
      final title = _text(item['name']);
      return TickerInfo(
        symbol: symbol,
        market: 'B3',
        source: ProviderCatalog.brapi.code,
        name: title == null || title.toUpperCase() == symbol ? null : title,
        assetClass: classOf(_text(item['type']), _text(item['subType'])),
        sector: sectorPt(_text(item['sector'])),
        segment: _text(item['subsector']),
      );
    }
    return null;
  }

  /// Cotação com `summaryProfile`.
  static TickerInfo parseDetail(
    String text,
    String symbol, {
    required String collectedAt,
  }) {
    const name = 'brapi';
    final instrument = MarketInstrument(
      symbol: symbol,
      market: 'B3',
      assetClass: 'stock_br',
      currency: 'BRL',
    );
    final json = MarketParse.map(
      name,
      MarketParse.json(name, text),
      'resposta',
    );
    final results = MarketParse.list(name, json['results'], 'results');
    if (results.isEmpty) MarketParse.invalid(name, 'sem resultados');
    final r = MarketParse.map(name, results.first, 'resultado');
    final profile = r['summaryProfile'];
    MarketQuote? quote;
    try {
      quote = BrapiProvider.parse(text, instrument, collectedAt: collectedAt);
    } on DataError {
      quote = null;
    }
    return TickerInfo(
      symbol: symbol,
      market: 'B3',
      source: ProviderCatalog.brapi.code,
      name: cleanName(_text(r['longName'])),
      sector: profile is Map<String, Object?>
          ? _text(profile['sectorDisp'] ?? profile['sector'])
          : null,
      segment: profile is Map<String, Object?>
          ? _text(profile['industryDisp'] ?? profile['industry'])
          : null,
      quote: quote,
    );
  }

  /// Tira o sufixo jurídico do nome dos fundos ("Patria Log - Fundo de
  /// Investimento Imobiliario - Responsabilidade Limitada Cotas" vira
  /// "Patria Log - Fundo de Investimento Imobiliario").
  static String? cleanName(String? name) {
    if (name == null) return null;
    final cleaned = name
        .replaceFirst(RegExp(r'\s+Cotas$', caseSensitive: false), '')
        .replaceFirst(
          RegExp(r'\s+-\s+Responsabilidade Limitada$', caseSensitive: false),
          '',
        )
        .trim();
    return cleaned.isEmpty ? name : cleaned;
  }

  /// `type` e `subType` da lista: `stock`, `fund` (`fii`, `fi-agro`,
  /// `etf`) e `bdr`.
  static String? classOf(String? type, String? subType) =>
      switch ((type, subType)) {
        (_, 'fii' || 'fi-agro') => 'fii',
        (_, 'etf') => 'etf_br',
        ('bdr', _) || (_, 'bdr') => 'bdr',
        ('stock', _) => 'stock_br',
        _ => null,
      };

  /// A lista dá o setor em inglês (classificação da brapi); o app mostra em
  /// português. Setor desconhecido fica como veio.
  static String? sectorPt(String? sector) =>
      sector == null ? null : _sectors[sector] ?? sector;

  static const _sectors = {
    'Commercial Services': 'Serviços Comerciais',
    'Communications': 'Comunicações',
    'Consumer Durables': 'Bens de Consumo Duráveis',
    'Consumer Non-Durables': 'Bens de Consumo Não Duráveis',
    'Consumer Services': 'Serviços ao Consumidor',
    'Distribution Services': 'Distribuição',
    'Electronic Technology': 'Tecnologia Eletrônica',
    'Energy Minerals': 'Minerais Energéticos',
    'Finance': 'Financeiro',
    'Health Services': 'Serviços de Saúde',
    'Health Technology': 'Tecnologia em Saúde',
    'Industrial Services': 'Serviços Industriais',
    'Miscellaneous': 'Diversos',
    'Non-Energy Minerals': 'Minerais Não Energéticos',
    'Process Industries': 'Indústrias de Processo',
    'Producer Manufacturing': 'Bens Industriais',
    'Retail Trade': 'Comércio Varejista',
    'Technology Services': 'Serviços de Tecnologia',
    'Transportation': 'Transporte',
    'Utilities': 'Utilidade Pública',
  };

  static String? _text(Object? value) {
    if (value == null) return null;
    final t = '$value'.trim();
    return t.isEmpty || t == 'null' ? null : t;
  }
}
