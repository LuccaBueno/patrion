import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../finance/business_calendar.dart';
import '../portfolio/codes.dart';
import '../portfolio/entities.dart';
import 'market_data.dart';

/// Preço de mercado de um ativo, com a origem (regra 2): fonte, data de
/// referência, tipo e atraso declarado.
class MarketPrice {
  const MarketPrice({
    required this.assetId,
    required this.price,
    required this.currency,
    required this.refDate,
    required this.source,
    required this.dataType,
    required this.collectedAt,
    this.refAt,
    this.delayNote,
    this.previousClose,
    this.previousMonthClose,
  });

  final String assetId;

  /// Preço unitário.
  final Decimal price;
  final String currency;
  final LocalDate refDate;

  /// Instante do preço, quando o provedor informa (cotações).
  final DateTime? refAt;
  final String source;
  final MarketDataType dataType;
  final String collectedAt;
  final String? delayNote;

  /// Último fechamento antes da data do preço (variação do dia, M-05).
  final PriceReference? previousClose;

  /// Último fechamento do mês anterior ao do preço (variação no mês).
  final PriceReference? previousMonthClose;

  /// Variação desde o fechamento anterior; nula sem esse fechamento.
  PriceChange? get dayChange => PriceChange.of(price, refDate, previousClose);

  /// Variação desde o fechamento do mês anterior.
  PriceChange? get monthChange =>
      PriceChange.of(price, refDate, previousMonthClose);

  MarketPrice withReferences({
    PriceReference? previousClose,
    PriceReference? previousMonthClose,
  }) => MarketPrice(
    assetId: assetId,
    price: price,
    currency: currency,
    refDate: refDate,
    source: source,
    dataType: dataType,
    collectedAt: collectedAt,
    refAt: refAt,
    delayNote: delayNote,
    previousClose: previousClose,
    previousMonthClose: previousMonthClose,
  );
}

/// Preço de referência (um fechamento guardado), com fonte e data.
class PriceReference {
  const PriceReference({
    required this.price,
    required this.refDate,
    required this.source,
  });

  final Decimal price;
  final LocalDate refDate;
  final String source;
}

/// Variação de um preço contra uma referência (`docs/FORMULAS.md` §2.4).
class PriceChange {
  const PriceChange({
    required this.from,
    required this.to,
    required this.toDate,
  });

  final PriceReference from;
  final Decimal to;
  final LocalDate toDate;

  static PriceChange? of(Decimal to, LocalDate toDate, PriceReference? from) {
    if (from == null || from.price <= Decimal.zero) return null;
    return PriceChange(from: from, to: to, toDate: toDate);
  }

  /// Diferença por unidade.
  Decimal get perUnit => to - from.price;

  /// Fração (0,01 = 1%).
  Decimal get fraction => DecimalMath.divide(perUnit, from.price);
}

/// Regras dos preços de mercado (`docs/FORMULAS.md` §2.1).
abstract final class MarketPricing {
  /// Classes que o app sabe cotar automaticamente (DECISIONS D-35). Renda
  /// fixa privada, produtos bancários e caixa ficam com preço informado.
  static bool hasAutomaticSource(AssetClass c) => switch (c) {
    AssetClass.fixedIncome ||
    AssetClass.bankProduct ||
    AssetClass.cash => false,
    _ => true,
  };

  /// Fonte de preço sugerida para um ativo novo da classe [c].
  static PriceSource defaultSource(AssetClass c) =>
      hasAutomaticSource(c) ? PriceSource.market : PriceSource.manual;

  /// Escolhe o preço de mercado de um ativo entre as cotações e os
  /// fechamentos guardados: vale o de data mais recente; na mesma data, a
  /// cotação (mais nova que o fechamento do dia anterior só quando a data
  /// é a mesma, então vale o instante).
  static MarketPrice? best(Iterable<MarketPrice> candidates) {
    MarketPrice? best;
    for (final c in candidates) {
      if (best == null) {
        best = c;
        continue;
      }
      final byDate = c.refDate.compareTo(best.refDate);
      if (byDate > 0 ||
          (byDate == 0 &&
              c.refAt != null &&
              (best.refAt == null || c.refAt!.isAfter(best.refAt!)))) {
        best = c;
      }
    }
    return best;
  }

  /// Liga a [price] os fechamentos de referência tirados de [closes] (do
  /// mesmo ativo, preço bruto): o último antes da data do preço e o último
  /// do mês anterior. Sem fechamento guardado, a referência fica nula
  /// (regra 1: a variação aparece como indisponível).
  static MarketPrice withReferences(
    MarketPrice price,
    Iterable<PriceBar> closes,
  ) {
    final monthEnd = LocalDate(
      price.refDate.year,
      price.refDate.month,
      1,
    ).addDays(-1);
    PriceBar? previous;
    PriceBar? month;
    for (final c in closes) {
      if (c.refDate.isBefore(price.refDate) &&
          (previous == null || c.refDate.isAfter(previous.refDate))) {
        previous = c;
      }
      if (!c.refDate.isAfter(monthEnd) &&
          (month == null || c.refDate.isAfter(month.refDate))) {
        month = c;
      }
    }
    PriceReference? ref(PriceBar? b) => b == null
        ? null
        : PriceReference(
            price: unitClose(b),
            refDate: b.refDate,
            source: b.source,
          );
    return price.withReferences(
      previousClose: ref(previous),
      previousMonthClose: ref(month),
    );
  }

  /// Preço unitário de um fechamento do COTAHIST: o preço é por lote de
  /// `quoteFactor` ações.
  static Decimal unitClose(PriceBar bar) {
    final factor = bar.quoteFactor;
    if (factor == null || factor == Decimal.one || factor <= Decimal.zero) {
      return bar.close;
    }
    return DecimalMath.divide(bar.close, factor);
  }

  /// O preço está desatualizado: a data de referência é anterior ao último
  /// dia útil completo antes de [today] (no mercado de cripto, que não
  /// fecha, anterior a ontem).
  static bool isStale(
    MarketPrice price,
    LocalDate today, {
    String? market,
    BusinessCalendar? calendar,
  }) {
    if (market == Market.crypto.code) {
      return price.refDate.isBefore(today.addDays(-1));
    }
    final cal = calendar ?? BusinessCalendar.brazil;
    var previous = today.addDays(-1);
    while (!cal.isBusinessDay(previous)) {
      previous = previous.addDays(-1);
    }
    return price.refDate.isBefore(previous);
  }

  /// Nomes possíveis no Tesouro Transparente para um título cadastrado,
  /// pelo produto e pelo nome ou código do ativo ("Juros Semestrais",
  /// "NTN-B", "Renda+", "Educa+").
  static List<String> treasuryTitles(Asset asset, FixedIncomeTerms terms) {
    final text = '${asset.symbol} ${asset.name}'.toUpperCase();
    final semiannual =
        text.contains('SEMESTR') ||
        text.contains('NTN-F') ||
        (text.contains('NTN-B') && !text.contains('PRINCIPAL'));
    if (text.contains('RENDA+')) {
      return const ['Tesouro Renda+ Aposentadoria Extra'];
    }
    if (text.contains('EDUCA+')) return const ['Tesouro Educa+'];
    return switch (terms.product) {
      FixedIncomeProduct.tesouroSelic => const ['Tesouro Selic'],
      FixedIncomeProduct.tesouroPrefixado =>
        semiannual
            ? const ['Tesouro Prefixado com Juros Semestrais']
            : const ['Tesouro Prefixado'],
      FixedIncomeProduct.tesouroIpca =>
        semiannual
            ? const ['Tesouro IPCA+ com Juros Semestrais']
            : const ['Tesouro IPCA+'],
      _ => const [],
    };
  }

  /// Preço de um título do Tesouro: o PU de venda da manhã (o que o Tesouro
  /// paga no resgate antecipado), ou o PU base se não houver.
  static MarketPrice? treasuryPrice(
    Asset asset,
    FixedIncomeTerms terms,
    Iterable<TreasuryPrice> latest,
  ) {
    final titles = treasuryTitles(asset, terms);
    final matches = [
      for (final t in latest)
        if (titles.contains(t.title) && t.maturity == terms.maturityDate) t,
    ];
    if (matches.length != 1) return null;
    final t = matches.single;
    final pu = t.sellPu ?? t.basePu;
    if (pu == null || pu <= Decimal.zero) return null;
    return MarketPrice(
      assetId: asset.id,
      price: pu,
      currency: 'BRL',
      refDate: t.refDate,
      source: t.source,
      dataType: MarketDataType.close,
      collectedAt: t.collectedAt,
      delayNote: 'preço de resgate da manhã do dia útil',
    );
  }
}
