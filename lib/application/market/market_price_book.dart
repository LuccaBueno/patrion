import '../../core/time/local_date.dart';
import '../../data/repositories/market_repository.dart';
import '../../domain/market/market_data.dart';
import '../../domain/market/market_price.dart';
import '../../domain/portfolio/codes.dart';
import '../../domain/portfolio/entities.dart';

/// Monta o preço de mercado de cada ativo a partir do que está guardado:
/// cotações, último fechamento (preço bruto) e Tesouro. Não acessa a rede.
abstract final class MarketPriceBook {
  static Future<Map<String, MarketPrice>> load(
    MarketRepository repo, {
    required Iterable<Asset> assets,
    required Map<String, FixedIncomeTerms> termsByAsset,
    LocalDate? asOf,
  }) async {
    final quotes = await repo.allQuotes();
    final closes = await repo.latestCloses();
    // 45 dias cobrem o fechamento anterior e o do fim do mês anterior.
    final recent = asOf == null
        ? const <PriceBar>[]
        : await repo.closesSince(asOf.addDays(-45));
    final hasTreasury = assets.any((a) => a.assetClass == AssetClass.treasury);
    final treasury = hasTreasury
        ? await repo.latestTreasury()
        : const <TreasuryPrice>[];
    return build(
      assets: assets,
      termsByAsset: termsByAsset,
      quotes: quotes,
      closes: closes,
      treasury: treasury,
      recent: recent,
    );
  }

  static Map<String, MarketPrice> build({
    required Iterable<Asset> assets,
    required Map<String, FixedIncomeTerms> termsByAsset,
    required Iterable<MarketQuote> quotes,
    required Iterable<PriceBar> closes,
    required Iterable<TreasuryPrice> treasury,
    Iterable<PriceBar> recent = const [],
  }) {
    final quotesByKey = <(String, String), List<MarketQuote>>{};
    for (final q in quotes) {
      (quotesByKey[(q.symbol.toUpperCase(), q.market)] ??= []).add(q);
    }
    final closesByKey = <(String, String), List<PriceBar>>{};
    for (final c in closes) {
      (closesByKey[(c.symbol.toUpperCase(), c.market)] ??= []).add(c);
    }
    final recentByKey = <(String, String), List<PriceBar>>{};
    for (final c in recent) {
      (recentByKey[(c.symbol.toUpperCase(), c.market)] ??= []).add(c);
    }
    final result = <String, MarketPrice>{};
    for (final a in assets) {
      if (a.assetClass == AssetClass.treasury) {
        final terms = termsByAsset[a.id];
        if (terms == null) continue;
        final price = MarketPricing.treasuryPrice(a, terms, treasury);
        if (price != null) result[a.id] = price;
        continue;
      }
      final key = (a.symbol.toUpperCase(), a.market.code);
      final candidates = <MarketPrice>[
        for (final q in quotesByKey[key] ?? const <MarketQuote>[])
          MarketPrice(
            assetId: a.id,
            price: q.price,
            currency: q.currency,
            refDate: LocalDate.fromDateTime(
              q.refAt.toUtc().subtract(const Duration(hours: 3)),
            ),
            refAt: q.refAt,
            source: q.source,
            dataType: q.dataType,
            collectedAt: q.collectedAt,
            delayNote: q.delayNote,
          ),
        for (final c in closesByKey[key] ?? const <PriceBar>[])
          MarketPrice(
            assetId: a.id,
            price: MarketPricing.unitClose(c),
            currency: c.currency,
            refDate: c.refDate,
            source: c.source,
            dataType: c.dataType,
            collectedAt: c.collectedAt,
          ),
      ];
      final best = MarketPricing.best(candidates);
      if (best != null) {
        result[a.id] = MarketPricing.withReferences(
          best,
          recentByKey[key] ?? const [],
        );
      }
    }
    return result;
  }
}
