import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/operation_type.dart';

/// Rótulos em português das enumerações do domínio.
extension InstitutionKindLabel on InstitutionKind {
  String get label => switch (this) {
    InstitutionKind.broker => 'Corretora',
    InstitutionKind.bank => 'Banco',
    InstitutionKind.exchange => 'Exchange (cripto)',
    InstitutionKind.other => 'Outra',
  };
}

extension AccountKindLabel on AccountKind {
  String get label => switch (this) {
    AccountKind.brokerage => 'Conta de investimentos',
    AccountKind.checking => 'Conta corrente',
    AccountKind.savings => 'Poupança',
    AccountKind.cryptoWallet => 'Carteira de cripto',
    AccountKind.other => 'Outra',
  };
}

extension AssetClassLabel on AssetClass {
  String get label => switch (this) {
    AssetClass.stockBr => 'Ações BR',
    AssetClass.fii => 'FIIs',
    AssetClass.etfBr => 'ETFs BR',
    AssetClass.bdr => 'BDRs',
    AssetClass.fixedIncome => 'Renda fixa',
    AssetClass.treasury => 'Tesouro Direto',
    AssetClass.bankProduct => 'Produtos bancários',
    AssetClass.stockIntl => 'Ações internacionais',
    AssetClass.etfIntl => 'ETFs internacionais',
    AssetClass.reit => 'REITs',
    AssetClass.crypto => 'Cripto',
    AssetClass.cash => 'Caixa',
  };
}

extension MarketLabel on Market {
  String get label => switch (this) {
    Market.b3 => 'B3',
    Market.nyse => 'NYSE',
    Market.nasdaq => 'Nasdaq',
    Market.crypto => 'Cripto',
    Market.tesouro => 'Tesouro Direto',
    Market.otc => 'Balcão',
    Market.manual => 'Manual',
  };
}

extension LiquidityLabel on Liquidity {
  String get label => switch (this) {
    Liquidity.daily => 'Diária',
    Liquidity.dPlusN => 'D+N',
    Liquidity.atMaturity => 'No vencimento',
    Liquidity.other => 'Outra',
  };
}

extension FixedIncomeProductLabel on FixedIncomeProduct {
  String get label => switch (this) {
    FixedIncomeProduct.cdb => 'CDB',
    FixedIncomeProduct.rdb => 'RDB',
    FixedIncomeProduct.lci => 'LCI',
    FixedIncomeProduct.lca => 'LCA',
    FixedIncomeProduct.lc => 'LC',
    FixedIncomeProduct.debenture => 'Debênture',
    FixedIncomeProduct.cri => 'CRI',
    FixedIncomeProduct.cra => 'CRA',
    FixedIncomeProduct.tesouroSelic => 'Tesouro Selic',
    FixedIncomeProduct.tesouroPrefixado => 'Tesouro Prefixado',
    FixedIncomeProduct.tesouroIpca => 'Tesouro IPCA+',
  };
}

extension IndexerLabel on Indexer {
  String get label => switch (this) {
    Indexer.pre => 'Prefixado',
    Indexer.cdi => 'CDI',
    Indexer.selic => 'Selic',
    Indexer.ipca => 'IPCA',
    Indexer.igpm => 'IGP-M',
  };
}

extension DayCountLabel on DayCount {
  String get label => switch (this) {
    DayCount.bus252 => 'Dias úteis/252',
    DayCount.act365 => 'Corridos/365',
    DayCount.act360 => 'Corridos/360',
    DayCount.thirty360 => '30/360',
  };
}

extension TaxRegimeLabel on TaxRegime {
  String get label => switch (this) {
    TaxRegime.regressiveIr => 'IR regressivo',
    TaxRegime.exempt => 'Isento',
    TaxRegime.other => 'Outro',
  };
}

extension OperationTypeLabel on OperationType {
  String get label => switch (this) {
    OperationType.buy => 'Compra',
    OperationType.sell => 'Venda',
    OperationType.contribution => 'Aporte',
    OperationType.redemption => 'Resgate',
    OperationType.deposit => 'Depósito',
    OperationType.withdrawal => 'Retirada',
    OperationType.transferOut => 'Transferência (saída)',
    OperationType.transferIn => 'Transferência (entrada)',
    OperationType.dividend => 'Dividendo',
    OperationType.jcp => 'JCP',
    OperationType.fiiIncome => 'Rendimento de FII',
    OperationType.interest => 'Juros',
    OperationType.amortization => 'Amortização',
    OperationType.bonusShares => 'Bonificação',
    OperationType.split => 'Desdobramento',
    OperationType.reverseSplit => 'Grupamento',
    OperationType.maturity => 'Vencimento',
    OperationType.fee => 'Taxa',
    OperationType.tax => 'Imposto',
    OperationType.withholding => 'Retenção',
    OperationType.reinvestment => 'Reinvestimento',
    OperationType.manualAdjustment => 'Ajuste manual',
  };
}

extension OperationGroupLabel on OperationGroup {
  String get label => switch (this) {
    OperationGroup.trade => 'Negociação',
    OperationGroup.cash => 'Caixa',
    OperationGroup.income => 'Proventos',
    OperationGroup.event => 'Eventos',
    OperationGroup.cost => 'Custos',
    OperationGroup.adjustment => 'Ajuste',
  };
}
