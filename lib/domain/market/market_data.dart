import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import '../portfolio/codes.dart';

/// Tipo do dado de mercado (regra 2).
enum MarketDataType implements Coded {
  /// Preço de fechamento do dia.
  close('close'),

  /// Preço durante o pregão (atrasado conforme o provedor).
  intraday('intraday'),

  /// Ajustado pelo provedor por proventos e eventos.
  adjusted('adjusted'),

  /// Estimado.
  estimated('estimated'),

  /// Calculado pelo app.
  calculated('calculated');

  const MarketDataType(this.code);

  @override
  final String code;
}

/// Barra diária de preço (sempre o preço da fonte, sem ajuste do app).
class PriceBar {
  const PriceBar({
    required this.symbol,
    required this.market,
    required this.refDate,
    required this.close,
    required this.currency,
    required this.source,
    required this.dataType,
    required this.collectedAt,
    this.open,
    this.high,
    this.low,
    this.volume,
    this.quoteFactor,
  });

  final String symbol;
  final String market;
  final LocalDate refDate;
  final Decimal? open;
  final Decimal? high;
  final Decimal? low;
  final Decimal close;
  final Decimal? volume;
  final String currency;

  /// Fator de cotação do COTAHIST (preço por lote de N ações).
  final Decimal? quoteFactor;

  /// Código do provedor (`ProviderInfo.code`).
  final String source;
  final MarketDataType dataType;

  /// Instante UTC da coleta (ISO-8601).
  final String collectedAt;
}

/// Última cotação de um ativo.
class MarketQuote {
  const MarketQuote({
    required this.symbol,
    required this.market,
    required this.price,
    required this.currency,
    required this.refAt,
    required this.source,
    required this.dataType,
    required this.collectedAt,
    this.delayNote,
  });

  final String symbol;
  final String market;
  final Decimal price;
  final String currency;

  /// Instante UTC a que o preço se refere, informado pelo provedor.
  final DateTime refAt;
  final String source;
  final MarketDataType dataType;
  final String collectedAt;

  /// Atraso declarado pelo provedor (nunca chamar de "tempo real" um dado
  /// atrasado, SPEC §5).
  final String? delayNote;
}

/// Tipo de provento ou evento corporativo.
enum CorporateEventKind implements Coded {
  split('split'),
  reverseSplit('reverse_split'),
  bonusShares('bonus_shares'),
  cashDividend('cash_dividend'),
  jcp('jcp'),
  fiiIncome('fii_income'),
  amortization('amortization'),
  otherCash('other_cash');

  const CorporateEventKind(this.code);

  @override
  final String code;

  /// Muda a quantidade de ações (e não paga dinheiro).
  bool get changesQuantity =>
      this == split || this == reverseSplit || this == bonusShares;
}

/// Situação de um evento.
enum CorporateEventStatus implements Coded {
  paid('paid'),
  announced('announced'),
  suspect('suspect');

  const CorporateEventStatus(this.code);

  @override
  final String code;
}

/// Provento em dinheiro ou evento em ações.
class CorporateEvent {
  const CorporateEvent({
    required this.symbol,
    required this.market,
    required this.kind,
    required this.exDate,
    required this.source,
    required this.seq,
    required this.status,
    required this.collectedAt,
    this.comDate,
    this.paymentDate,
    this.factor,
    this.amount,
    this.currency,
    this.rawLabel,
    this.isin,
  });

  final String symbol;
  final String market;
  final CorporateEventKind kind;

  /// Primeiro dia sem o direito ("data ex").
  final LocalDate exDate;

  /// Último dia com o direito ("data com").
  final LocalDate? comDate;
  final LocalDate? paymentDate;

  /// Multiplicador da quantidade: 2 num desdobramento 1:2, 0,1 num
  /// grupamento 10:1, 1,1 numa bonificação de 10%.
  final Decimal? factor;

  /// Valor por ação ou cota.
  final Decimal? amount;
  final String? currency;
  final CorporateEventStatus status;
  final String? rawLabel;
  final String? isin;
  final String source;

  /// Desempate de eventos iguais na mesma data.
  final int seq;
  final String collectedAt;
}

/// Séries de indicadores econômicos.
enum IndicatorSeries implements Coded {
  /// CDI, taxa diária (% ao dia). SGS 12.
  cdi('cdi', 'CDI', IndicatorUnit.pctDay),

  /// Selic efetiva diária (% ao dia). SGS 11.
  selic('selic', 'Selic', IndicatorUnit.pctDay),

  /// Meta Selic (% ao ano). SGS 432.
  selicTarget('selic_target', 'Meta Selic', IndicatorUnit.pctYear),

  /// IPCA, variação mensal (%). SGS 433 / SIDRA 1737.
  ipca('ipca', 'IPCA', IndicatorUnit.pctMonth),

  /// IGP-M, variação mensal (%). SGS 189.
  igpm('igpm', 'IGP-M', IndicatorUnit.pctMonth),

  /// Ibovespa, em pontos (fechamento diário; B3, M-09).
  ibovespa('ibov', 'Ibovespa', IndicatorUnit.indexNumber),

  /// IFIX, em pontos (fechamento diário; B3, F8).
  ifix('ifix', 'IFIX', IndicatorUnit.indexNumber),

  /// Bitcoin em dólares: fechamento diário do par BTC/USDT (Binance, F8).
  btcUsd('btc_usd', 'Bitcoin (US\$)', IndicatorUnit.indexNumber),

  /// S&P 500, em pontos (Yahoo, opcional; F8).
  sp500('sp500', 'S&P 500', IndicatorUnit.indexNumber),

  /// Nasdaq Composite, em pontos (Yahoo, opcional; F8).
  nasdaq('nasdaq', 'Nasdaq', IndicatorUnit.indexNumber);

  const IndicatorSeries(this.code, this.label, this.unit);

  @override
  final String code;
  final String label;
  final IndicatorUnit unit;

  bool get isMonthly => unit == IndicatorUnit.pctMonth;
}

enum IndicatorUnit implements Coded {
  pctDay('pct_day'),
  pctMonth('pct_month'),
  pctYear('pct_year'),
  indexNumber('index');

  const IndicatorUnit(this.code);

  @override
  final String code;
}

/// Valor de um indicador numa data (mensais: primeiro dia do mês).
class IndicatorPoint {
  const IndicatorPoint({
    required this.series,
    required this.refDate,
    required this.value,
    required this.source,
    required this.collectedAt,
  });

  final IndicatorSeries series;
  final LocalDate refDate;

  /// Em porcentagem, como publicado (0,055131 = 0,055131% ao dia).
  final Decimal value;
  final String source;
  final String collectedAt;
}

/// Tipo de taxa de câmbio.
enum FxKind implements Coded {
  /// PTAX de fechamento do Banco Central.
  ptaxClose('ptax_close'),

  /// Taxa de referência (BCE, via Frankfurter).
  reference('reference');

  const FxKind(this.code);

  @override
  final String code;
}

/// Cotação de câmbio: quantas unidades de [quote] valem 1 [base].
class FxRate {
  const FxRate({
    required this.base,
    required this.quote,
    required this.refDate,
    required this.kind,
    required this.source,
    required this.collectedAt,
    this.bid,
    this.ask,
    this.refAt,
  });

  final String base;
  final String quote;
  final LocalDate refDate;
  final FxKind kind;
  final Decimal? bid;
  final Decimal? ask;
  final DateTime? refAt;
  final String source;
  final String collectedAt;

  /// Valor de referência: venda se houver, senão compra.
  Decimal? get mid => ask ?? bid;
}

/// Preço e taxa de um título do Tesouro Direto num dia.
class TreasuryPrice {
  const TreasuryPrice({
    required this.title,
    required this.maturity,
    required this.refDate,
    required this.source,
    required this.collectedAt,
    this.buyRate,
    this.sellRate,
    this.buyPu,
    this.sellPu,
    this.basePu,
  });

  /// Nome do título no Tesouro (por exemplo, "Tesouro IPCA+").
  final String title;
  final LocalDate maturity;
  final LocalDate refDate;
  final Decimal? buyRate;
  final Decimal? sellRate;
  final Decimal? buyPu;

  /// Preço de venda (resgate antecipado) pela manhã.
  final Decimal? sellPu;
  final Decimal? basePu;
  final String source;
  final String collectedAt;
}

/// Tipo de dado de fundo da CVM.
enum FundReportKind implements Coded {
  daily('daily'),
  fiiMonthly('fii_monthly');

  const FundReportKind(this.code);

  @override
  final String code;
}

/// Cota diária de fundo ou informe mensal de FII (CVM).
class FundReport {
  const FundReport({
    required this.cnpj,
    required this.refDate,
    required this.kind,
    required this.source,
    required this.collectedAt,
    this.quota,
    this.nav,
    this.holders,
    this.isin,
    this.name,
  });

  final String cnpj;
  final LocalDate refDate;
  final FundReportKind kind;

  /// Cota (diária) ou valor patrimonial por cota (informe de FII).
  final Decimal? quota;

  /// Patrimônio líquido.
  final Decimal? nav;
  final int? holders;
  final String? isin;
  final String? name;
  final String source;
  final String collectedAt;
}
