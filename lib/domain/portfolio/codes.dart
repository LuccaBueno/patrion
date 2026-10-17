import '../../core/errors/app_error.dart';

/// Enumeração gravada no banco por um código estável em inglês
/// (`docs/BANCO.md` §2).
abstract interface class Coded {
  String get code;
}

/// Procura o valor de [values] com o código [code].
///
/// Lança [DataError] para um código desconhecido (por exemplo, gravado por
/// uma versão mais nova do app).
T byCode<T extends Coded>(List<T> values, String code) {
  for (final v in values) {
    if (v.code == code) return v;
  }
  throw DataError('Código desconhecido: $code');
}

enum InstitutionKind implements Coded {
  broker('broker'),
  bank('bank'),
  exchange('exchange'),
  other('other');

  const InstitutionKind(this.code);

  @override
  final String code;
}

enum AccountKind implements Coded {
  brokerage('brokerage'),
  checking('checking'),
  savings('savings'),
  cryptoWallet('crypto_wallet'),
  other('other');

  const AccountKind(this.code);

  @override
  final String code;
}

enum AssetClass implements Coded {
  stockBr('stock_br'),
  fii('fii'),
  etfBr('etf_br'),
  bdr('bdr'),
  fixedIncome('fixed_income'),
  treasury('treasury'),
  bankProduct('bank_product'),
  stockIntl('stock_intl'),
  etfIntl('etf_intl'),
  reit('reit'),
  crypto('crypto'),
  cash('cash');

  const AssetClass(this.code);

  @override
  final String code;

  /// Renda fixa: tem características em `fixed_income_terms`.
  bool get hasFixedIncomeTerms => this == fixedIncome || this == treasury;

  /// Classes normalmente acompanhadas pelo saldo informado, não por
  /// quantidade × preço.
  bool get valuedByBalance =>
      this == bankProduct || this == fixedIncome || this == cash;
}

enum Market implements Coded {
  b3('B3'),
  nyse('NYSE'),
  nasdaq('NASDAQ'),
  crypto('CRYPTO'),
  tesouro('TESOURO'),
  otc('OTC'),
  manual('MANUAL');

  const Market(this.code);

  @override
  final String code;
}

enum Liquidity implements Coded {
  daily('daily'),
  dPlusN('d_plus_n'),
  atMaturity('at_maturity'),
  other('other');

  const Liquidity(this.code);

  @override
  final String code;
}

enum PriceSource implements Coded {
  market('market'),
  manual('manual');

  const PriceSource(this.code);

  @override
  final String code;
}

enum FixedIncomeProduct implements Coded {
  cdb('cdb'),
  rdb('rdb'),
  lci('lci'),
  lca('lca'),
  lc('lc'),
  debenture('debenture'),
  cri('cri'),
  cra('cra'),
  tesouroSelic('tesouro_selic'),
  tesouroPrefixado('tesouro_prefixado'),
  tesouroIpca('tesouro_ipca');

  const FixedIncomeProduct(this.code);

  @override
  final String code;
}

enum Indexer implements Coded {
  pre('pre'),
  cdi('cdi'),
  selic('selic'),
  ipca('ipca'),
  igpm('igpm');

  const Indexer(this.code);

  @override
  final String code;
}

enum DayCount implements Coded {
  bus252('bus252'),
  act365('act365'),
  act360('act360'),
  thirty360('30_360');

  const DayCount(this.code);

  @override
  final String code;
}

enum TaxRegime implements Coded {
  regressiveIr('regressive_ir'),
  exempt('exempt'),
  other('other');

  const TaxRegime(this.code);

  @override
  final String code;
}

enum ValuationKind implements Coded {
  unitPrice('unit_price'),
  balance('balance');

  const ValuationKind(this.code);

  @override
  final String code;
}

enum OperationOrigin implements Coded {
  manual('manual'),
  csvImport('csv_import'),
  saveMerge('save_merge');

  const OperationOrigin(this.code);

  @override
  final String code;
}
