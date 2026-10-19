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
}

/// Regras dos preços de mercado (`docs/FORMULAS.md` §2.1).
abstract final class MarketPricing {
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
