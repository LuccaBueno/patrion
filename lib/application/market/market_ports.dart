import '../../core/time/local_date.dart';
import '../../domain/market/market_data.dart';

/// Ativo como os provedores o enxergam: só o código, o mercado e a moeda.
/// Nunca leva quantidade, valor ou conta (regra 8).
class MarketInstrument {
  const MarketInstrument({
    required this.symbol,
    required this.market,
    required this.assetClass,
    required this.currency,
    this.isin,
  });

  final String symbol;

  /// `B3`, `NYSE`, `NASDAQ`, `CRYPTO`, `TESOURO`, `OTC`.
  final String market;

  /// Código da classe (`stock_br`, `crypto`…).
  final String assetClass;
  final String currency;
  final String? isin;

  @override
  String toString() => '$symbol ($market)';
}

/// Cotação atual.
abstract interface class QuoteProvider {
  String get code;

  /// O provedor atende este instrumento.
  bool supports(MarketInstrument instrument);

  Future<MarketQuote> quote(MarketInstrument instrument);
}

/// Histórico diário de preços.
abstract interface class HistoryProvider {
  String get code;

  bool supports(MarketInstrument instrument);

  /// Barras de [from] até [to] (inclusive). Pode devolver menos dias que o
  /// pedido (fins de semana, feriados, limite do provedor), nunca inventa.
  Future<List<PriceBar>> history(
    MarketInstrument instrument, {
    required LocalDate from,
    required LocalDate to,
  });
}

/// Proventos e eventos corporativos.
abstract interface class CorporateEventsProvider {
  String get code;

  bool supports(MarketInstrument instrument);

  Future<List<CorporateEvent>> events(MarketInstrument instrument);
}

/// Indicadores econômicos.
abstract interface class IndicatorProvider {
  String get code;

  bool supports(IndicatorSeries series);

  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    required LocalDate from,
    required LocalDate to,
  });
}

/// Câmbio contra o real.
abstract interface class FxProvider {
  String get code;

  bool supports(String currency);

  /// Quantos reais vale 1 [currency], de [from] até [to].
  Future<List<FxRate>> rates(
    String currency, {
    required LocalDate from,
    required LocalDate to,
  });
}

/// Preços do Tesouro Direto (todos os títulos de uma vez).
abstract interface class TreasuryProvider {
  String get code;

  /// Preços desde [from].
  Future<List<TreasuryPrice>> prices({required LocalDate from});
}

/// Dados de fundos da CVM.
abstract interface class FundReportProvider {
  String get code;

  /// Informe mensal dos FIIs com estes ISINs, no ano [year].
  Future<List<FundReport>> fiiMonthly(Set<String> isins, {required int year});

  /// Cotas diárias dos fundos com estes CNPJs no mês de [month].
  Future<List<FundReport>> dailyQuotas(
    Set<String> cnpjs, {
    required LocalDate month,
  });
}

/// Chaves de API, guardadas fora do banco e do save (DECISIONS D-34).
abstract interface class ApiKeyStore {
  /// Chave do provedor, se houver.
  String? read(String provider);

  void write(String provider, String key);

  void delete(String provider);

  /// Provedores com chave cadastrada (sem expor as chaves).
  Set<String> providersWithKey();
}

/// Histórico de vários ativos de uma vez (um arquivo do COTAHIST serve a
/// todos), com o ISIN de cada um quando a fonte informa. [onProgress] recebe
/// o percentual baixado do arquivo em andamento (o histórico completo, M-08).
abstract interface class BatchHistoryProvider implements HistoryProvider {
  Future<({Map<String, List<PriceBar>> bars, Map<String, String> isins})>
  historyBatch(
    Set<String> symbols, {
    required LocalDate from,
    required LocalDate to,
    void Function(int percent)? onProgress,
  });
}

/// Dados cadastrais de um ticker, para o cadastro rápido de ativos (M-01):
/// nome, classe, ISIN, setor e segmento, e a cotação quando a consulta a
/// traz. Campos nulos não vieram da fonte (nunca são inventados).
class TickerInfo {
  const TickerInfo({
    required this.symbol,
    required this.market,
    required this.source,
    this.name,
    this.assetClass,
    this.isin,
    this.sector,
    this.segment,
    this.quote,
  });

  final String symbol;
  final String market;

  /// Código do provedor que respondeu.
  final String source;
  final String? name;

  /// Código da classe (`stock_br`, `fii`, `etf_br`, `bdr`).
  final String? assetClass;
  final String? isin;
  final String? sector;
  final String? segment;
  final MarketQuote? quote;
}

/// Consulta os dados cadastrais de um ticker.
abstract interface class TickerInfoProvider {
  String get code;

  /// O provedor atende tickers do mercado [market] (`B3`).
  bool supports(String market);

  /// Nulo quando a fonte não conhece o ticker. Falha de rede lança
  /// `NetworkError`.
  Future<TickerInfo?> lookup(String symbol);
}
