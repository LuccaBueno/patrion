import 'package:decimal/decimal.dart';

import '../../core/time/local_date.dart';
import 'codes.dart';
import 'operation_type.dart';

/// Normaliza um nome para servir de chave natural: sem acentos, minúsculo e
/// com espaços simples (`docs/BANCO.md` §2).
String normalizeNameKey(String name) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = name.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final i = from.indexOf(char);
    buffer.write(i >= 0 ? to[i] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Corretora, banco ou exchange.
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.kind,
    required this.country,
    this.notes,
  });

  final String id;
  final String name;
  final InstitutionKind kind;

  /// ISO 3166 alfa-2.
  final String country;
  final String? notes;

  String get nameKey => normalizeNameKey(name);
}

/// Conta dentro de uma instituição.
class Account {
  const Account({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.kind,
    required this.currency,
    this.archived = false,
  });

  final String id;
  final String institutionId;
  final String name;
  final AccountKind kind;

  /// Moeda principal (ISO 4217).
  final String currency;
  final bool archived;
}

/// Ativo do catálogo (`assets`).
class Asset {
  const Asset({
    required this.id,
    required this.symbol,
    required this.market,
    required this.assetClass,
    required this.name,
    required this.currency,
    required this.country,
    this.priceSource = PriceSource.manual,
    this.isin,
    this.sector,
    this.segment,
    this.liquidity,
    this.notes,
  });

  final String id;
  final String symbol;
  final Market market;
  final AssetClass assetClass;
  final String name;
  final String currency;
  final String country;
  final PriceSource priceSource;
  final String? isin;
  final String? sector;
  final String? segment;
  final Liquidity? liquidity;
  final String? notes;

  /// Chave natural: símbolo + mercado + classe.
  String get naturalKey =>
      '${symbol.trim().toUpperCase()}|${market.code}|${assetClass.code}';
}

/// Características de um título de renda fixa (1:1 com o ativo).
class FixedIncomeTerms {
  const FixedIncomeTerms({
    required this.assetId,
    required this.product,
    required this.indexer,
    required this.rate,
    required this.dayCount,
    required this.issueDate,
    required this.maturityDate,
    required this.liquidity,
    required this.taxRegime,
    this.id,
    this.issuer,
    this.spread,
    this.graceUntil,
    this.costsNotes,
  });

  /// Nulo antes de gravar.
  final String? id;
  final String assetId;
  final FixedIncomeProduct product;
  final String? issuer;
  final Indexer indexer;

  /// Percentual do indexador (110 = 110% do CDI) ou taxa prefixada (% a.a.).
  final Decimal rate;

  /// Taxa adicional em % a.a. (IPCA + 6 → 6).
  final Decimal? spread;
  final DayCount dayCount;
  final LocalDate issueDate;
  final LocalDate maturityDate;
  final LocalDate? graceUntil;
  final Liquidity liquidity;
  final TaxRegime taxRegime;
  final String? costsNotes;
}

/// Dados de uma operação, antes ou depois de gravada (SPEC §7).
///
/// Valores são não negativos, exceto `quantity` e `grossAmount` do ajuste
/// manual, que podem ser negativos (ver [OperationValidator]).
class OperationDraft {
  OperationDraft({
    required this.accountId,
    required this.type,
    required this.tradeDate,
    required this.currency,
    this.assetId,
    this.settlementDate,
    this.quantity,
    this.unitPrice,
    this.grossAmount,
    Decimal? fees,
    Decimal? taxes,
    this.fxRate,
    this.ratioFrom,
    this.ratioTo,
    this.transferGroupId,
    this.relatedOperationId,
    this.justification,
    this.notes,
    this.origin = OperationOrigin.manual,
  }) : fees = fees ?? _zero,
       taxes = taxes ?? _zero;

  static final _zero = Decimal.zero;

  final String accountId;
  final String? assetId;
  final OperationType type;
  final LocalDate tradeDate;
  final LocalDate? settlementDate;
  final Decimal? quantity;
  final Decimal? unitPrice;
  final Decimal? grossAmount;
  final Decimal fees;
  final Decimal taxes;
  final String currency;
  final Decimal? fxRate;
  final Decimal? ratioFrom;
  final Decimal? ratioTo;
  final String? transferGroupId;
  final String? relatedOperationId;
  final String? justification;
  final String? notes;
  final OperationOrigin origin;

  /// Valor bruto: o informado ou quantidade × preço; zero se nenhum.
  Decimal get amount {
    if (grossAmount != null) return grossAmount!;
    if (quantity != null && unitPrice != null) return quantity! * unitPrice!;
    return Decimal.zero;
  }

  /// Custos e impostos somados.
  Decimal get charges => fees + taxes;
}

/// Operação gravada.
class Operation extends OperationDraft {
  Operation({
    required this.id,
    required super.accountId,
    required super.type,
    required super.tradeDate,
    required super.currency,
    super.assetId,
    super.settlementDate,
    super.quantity,
    super.unitPrice,
    super.grossAmount,
    super.fees,
    super.taxes,
    super.fxRate,
    super.ratioFrom,
    super.ratioTo,
    super.transferGroupId,
    super.relatedOperationId,
    super.justification,
    super.notes,
    super.origin,
  });

  /// UUID v7: em operações do mesmo dia, a ordem dos ids é a ordem de
  /// criação.
  final String id;

  /// Ordem de processamento: data da operação e, no mesmo dia, criação.
  static int chronological(Operation a, Operation b) {
    final byDate = a.tradeDate.compareTo(b.tradeDate);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  }
}

/// Preço unitário ou saldo informado pelo usuário.
class ManualValuation {
  const ManualValuation({
    required this.id,
    required this.assetId,
    required this.refDate,
    required this.kind,
    required this.value,
    required this.currency,
    this.accountId,
    this.notes,
  });

  final String id;
  final String assetId;

  /// Obrigatório para saldo; nulo para preço unitário (vale em todas as
  /// contas).
  final String? accountId;
  final LocalDate refDate;
  final ValuationKind kind;
  final Decimal value;
  final String currency;
  final String? notes;
}

/// Compra que registra uma posição que o usuário já tinha (saldo inicial do
/// cadastro rápido, M-01). Conta como aporte na data informada (M-12); os
/// proventos anteriores a ela não são sugeridos (F8).
abstract final class InitialBalance {
  /// Nota gravada na compra.
  static const note = 'Saldo inicial (posição informada pela corretora)';

  static bool isInitial(OperationDraft op) =>
      op.type == OperationType.buy && op.notes == note;
}
