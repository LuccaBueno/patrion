import 'codes.dart';

/// Se a operação se refere a um ativo.
enum AssetUse { required, optional, none }

/// Grupo do tipo, para a interface organizar a escolha.
enum OperationGroup { trade, cash, income, event, cost, adjustment }

/// Tipos de operação da carteira real (SPEC §7, `docs/BANCO.md` §3).
///
/// Os efeitos de cada tipo na posição e no caixa estão em
/// `docs/FORMULAS.md` §1 e em `PortfolioCalculator`.
enum OperationType implements Coded {
  buy('buy', OperationGroup.trade, AssetUse.required),
  sell('sell', OperationGroup.trade, AssetUse.required),
  contribution('contribution', OperationGroup.trade, AssetUse.required),
  redemption('redemption', OperationGroup.trade, AssetUse.required),
  deposit('deposit', OperationGroup.cash, AssetUse.none),
  withdrawal('withdrawal', OperationGroup.cash, AssetUse.none),
  transferOut('transfer_out', OperationGroup.cash, AssetUse.optional),
  transferIn('transfer_in', OperationGroup.cash, AssetUse.optional),
  dividend('dividend', OperationGroup.income, AssetUse.required),
  jcp('jcp', OperationGroup.income, AssetUse.required),
  fiiIncome('fii_income', OperationGroup.income, AssetUse.required),
  interest('interest', OperationGroup.income, AssetUse.optional),
  amortization('amortization', OperationGroup.event, AssetUse.required),
  bonusShares('bonus_shares', OperationGroup.event, AssetUse.required),
  split('split', OperationGroup.event, AssetUse.required),
  reverseSplit('reverse_split', OperationGroup.event, AssetUse.required),
  maturity('maturity', OperationGroup.event, AssetUse.required),
  fee('fee', OperationGroup.cost, AssetUse.optional),
  tax('tax', OperationGroup.cost, AssetUse.optional),
  withholding('withholding', OperationGroup.cost, AssetUse.optional),
  reinvestment('reinvestment', OperationGroup.trade, AssetUse.required),
  manualAdjustment(
    'manual_adjustment',
    OperationGroup.adjustment,
    AssetUse.optional,
  );

  const OperationType(this.code, this.group, this.assetUse);

  @override
  final String code;
  final OperationGroup group;
  final AssetUse assetUse;

  bool get isIncome => group == OperationGroup.income;

  bool get isTransfer => this == transferOut || this == transferIn;

  /// Desdobramento e grupamento: usam a proporção `ratio_from:ratio_to`.
  bool get usesRatio => this == split || this == reverseSplit;

  /// Entradas que aumentam a posição com custo (compra, aporte,
  /// reinvestimento).
  bool get isAcquisition =>
      this == buy || this == contribution || this == reinvestment;

  /// Saídas que baixam o custo proporcionalmente (venda, resgate).
  bool get isDisposal => this == sell || this == redemption;

  /// Quantidade obrigatória.
  bool get requiresQuantity =>
      this == buy ||
      this == sell ||
      this == reinvestment ||
      this == bonusShares;
}
