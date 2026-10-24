import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../core/time/instant_format.dart';
import '../../core/time/local_date.dart';
import '../../domain/market/market_data.dart';
import '../../domain/portfolio/codes.dart';
import '../db/app_database.dart';

/// Dados de mercado (`mkt_`, `docs/BANCO.md` §6). Não são dados do usuário:
/// são gravados por chave natural, sem HLC, e podem ser apagados e baixados
/// de novo.
class MarketRepository {
  const MarketRepository(this._db);

  final AppDatabase _db;

  static String? _s(Decimal? v) => v?.toString();
  static Decimal? _d(String? v) => v == null ? null : Decimal.tryParse(v);

  // -- Gravar -----------------------------------------------------------------

  Future<void> savePrices(Iterable<PriceBar> bars) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.mktPrices, [
      for (final p in bars)
        MktPricesCompanion.insert(
          symbol: p.symbol,
          market: p.market,
          refDate: '${p.refDate}',
          source: p.source,
          dataType: p.dataType.code,
          open: Value(_s(p.open)),
          high: Value(_s(p.high)),
          low: Value(_s(p.low)),
          close: '${p.close}',
          volume: Value(_s(p.volume)),
          currency: p.currency,
          quoteFactor: Value(_s(p.quoteFactor)),
          collectedAt: p.collectedAt,
        ),
    ]);
  });

  Future<void> saveQuote(MarketQuote q) => _db
      .into(_db.mktQuotes)
      .insertOnConflictUpdate(
        MktQuotesCompanion.insert(
          symbol: q.symbol,
          market: q.market,
          source: q.source,
          price: '${q.price}',
          currency: q.currency,
          refAt: formatInstant(q.refAt),
          delayNote: Value(q.delayNote),
          dataType: q.dataType.code,
          collectedAt: q.collectedAt,
        ),
      );

  /// Substitui os eventos de [source] para o ativo (a fonte manda a lista
  /// inteira).
  Future<void> replaceEvents(
    String symbol,
    String market,
    String source,
    Iterable<CorporateEvent> events,
  ) => _db.transaction(() async {
    await (_db.delete(_db.mktCorporateEvents)..where(
          (t) =>
              t.symbol.equals(symbol) &
              t.market.equals(market) &
              t.source.equals(source),
        ))
        .go();
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.mktCorporateEvents, [
        for (final e in events)
          MktCorporateEventsCompanion.insert(
            symbol: e.symbol,
            market: e.market,
            eventKind: e.kind.code,
            exDate: '${e.exDate}',
            source: e.source,
            seq: '${e.seq}',
            comDate: Value(e.comDate?.toString()),
            paymentDate: Value(e.paymentDate?.toString()),
            factor: Value(_s(e.factor)),
            amount: Value(_s(e.amount)),
            currency: Value(e.currency),
            status: e.status.code,
            rawLabel: Value(e.rawLabel),
            isin: Value(e.isin),
            collectedAt: e.collectedAt,
          ),
      ]);
    });
  });

  Future<void> saveIndicators(Iterable<IndicatorPoint> points) =>
      _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.mktIndicators, [
          for (final p in points)
            MktIndicatorsCompanion.insert(
              seriesCode: p.series.code,
              refDate: '${p.refDate}',
              source: p.source,
              value: '${p.value}',
              unit: p.series.unit.code,
              collectedAt: p.collectedAt,
            ),
        ]);
      });

  Future<void> saveFx(Iterable<FxRate> rates) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.mktFxRates, [
      for (final r in rates)
        MktFxRatesCompanion.insert(
          base: r.base,
          quote: r.quote,
          refDate: '${r.refDate}',
          kind: r.kind.code,
          source: r.source,
          bid: Value(_s(r.bid)),
          ask: Value(_s(r.ask)),
          refAt: Value(r.refAt == null ? null : formatInstant(r.refAt!)),
          collectedAt: r.collectedAt,
        ),
    ]);
  });

  Future<void> saveTreasury(Iterable<TreasuryPrice> prices) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.mktTreasuryPrices, [
      for (final t in prices)
        MktTreasuryPricesCompanion.insert(
          title: t.title,
          maturityDate: '${t.maturity}',
          refDate: '${t.refDate}',
          source: t.source,
          buyRate: Value(_s(t.buyRate)),
          sellRate: Value(_s(t.sellRate)),
          buyPu: Value(_s(t.buyPu)),
          sellPu: Value(_s(t.sellPu)),
          basePu: Value(_s(t.basePu)),
          collectedAt: t.collectedAt,
        ),
    ]);
  });

  Future<void> saveFundReports(Iterable<FundReport> reports) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.mktFundQuotas, [
      for (final r in reports)
        MktFundQuotasCompanion.insert(
          cnpj: r.cnpj,
          refDate: '${r.refDate}',
          kind: r.kind.code,
          source: r.source,
          quota: Value(_s(r.quota)),
          nav: Value(_s(r.nav)),
          holders: Value(r.holders?.toString()),
          isin: Value(r.isin),
          name: Value(r.name),
          collectedAt: r.collectedAt,
        ),
    ]);
  });

  Future<void> saveInstrument({
    required String symbol,
    required String market,
    required String source,
    required String collectedAt,
    String? isin,
    String? name,
    String? sourceId,
  }) => _db
      .into(_db.mktInstruments)
      .insertOnConflictUpdate(
        MktInstrumentsCompanion.insert(
          symbol: symbol,
          market: market,
          source: source,
          isin: Value(isin),
          name: Value(name),
          sourceId: Value(sourceId),
          collectedAt: collectedAt,
        ),
      );

  // -- Ler --------------------------------------------------------------------

  /// Cotações de todas as fontes para o ativo, da mais recente para a mais
  /// antiga.
  Future<List<MarketQuote>> quotes(String symbol, String market) async {
    final rows =
        await (_db.select(_db.mktQuotes)
              ..where((t) => t.symbol.equals(symbol) & t.market.equals(market))
              ..orderBy([(t) => OrderingTerm.desc(t.refAt)]))
            .get();
    return rows.map(_quote).toList();
  }

  /// Todas as cotações guardadas (para a avaliação da carteira).
  Future<List<MarketQuote>> allQuotes() async =>
      (await _db.select(_db.mktQuotes).get()).map(_quote).toList();

  /// Último fechamento de cada ativo, de qualquer fonte (preço bruto).
  Future<List<PriceBar>> latestCloses() async {
    final rows = await _db
        .customSelect(
          'SELECT p.* FROM mkt_prices p JOIN (SELECT symbol, market, '
          'MAX(ref_date) AS ref_date FROM mkt_prices WHERE data_type = ? '
          'GROUP BY symbol, market) last ON p.symbol = last.symbol AND '
          'p.market = last.market AND p.ref_date = last.ref_date WHERE '
          'p.data_type = ?',
          variables: [
            Variable<String>(MarketDataType.close.code),
            Variable<String>(MarketDataType.close.code),
          ],
          readsFrom: {_db.mktPrices},
        )
        .get();
    return [for (final r in rows) _price(_db.mktPrices.map(r.data))];
  }

  /// Fechamentos de todos os ativos a partir de [from] (variação do dia e
  /// do mês).
  Future<List<PriceBar>> closesSince(LocalDate from) async {
    final rows =
        await (_db.select(_db.mktPrices)..where(
              (t) =>
                  t.dataType.equals(MarketDataType.close.code) &
                  t.refDate.isBiggerOrEqualValue('$from'),
            ))
            .get();
    return rows.map(_price).toList();
  }

  Future<List<PriceBar>> prices(
    String symbol,
    String market, {
    LocalDate? from,
    LocalDate? to,
  }) async {
    final q = _db.select(_db.mktPrices)
      ..where(
        (t) =>
            t.symbol.equals(symbol) &
            t.market.equals(market) &
            t.dataType.equals(MarketDataType.close.code),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.refDate)]);
    if (from != null) q.where((t) => t.refDate.isBiggerOrEqualValue('$from'));
    if (to != null) q.where((t) => t.refDate.isSmallerOrEqualValue('$to'));
    return (await q.get()).map(_price).toList();
  }

  /// Primeira e última data de preço guardadas (de qualquer fonte).
  Future<(LocalDate, LocalDate, int)?> priceRange(
    String symbol,
    String market,
  ) async {
    final row = await _db
        .customSelect(
          'SELECT MIN(ref_date) AS a, MAX(ref_date) AS b, COUNT(*) AS n FROM '
          'mkt_prices WHERE symbol = ? AND market = ? AND data_type = ?',
          variables: [
            Variable<String>(symbol),
            Variable<String>(market),
            Variable<String>(MarketDataType.close.code),
          ],
          readsFrom: {_db.mktPrices},
        )
        .getSingle();
    final a = row.read<String?>('a');
    final b = row.read<String?>('b');
    if (a == null || b == null) return null;
    return (LocalDate.parse(a), LocalDate.parse(b), row.read<int>('n'));
  }

  Future<List<CorporateEvent>> events(String symbol, String market) async {
    final rows =
        await (_db.select(_db.mktCorporateEvents)
              ..where((t) => t.symbol.equals(symbol) & t.market.equals(market))
              ..orderBy([(t) => OrderingTerm.desc(t.exDate)]))
            .get();
    return [
      for (final r in rows)
        CorporateEvent(
          symbol: r.symbol,
          market: r.market,
          kind: byCode(CorporateEventKind.values, r.eventKind),
          exDate: LocalDate.parse(r.exDate),
          comDate: r.comDate == null ? null : LocalDate.parse(r.comDate!),
          paymentDate: r.paymentDate == null
              ? null
              : LocalDate.parse(r.paymentDate!),
          factor: _d(r.factor),
          amount: _d(r.amount),
          currency: r.currency,
          status: byCode(CorporateEventStatus.values, r.status),
          rawLabel: r.rawLabel,
          isin: r.isin,
          source: r.source,
          seq: int.tryParse(r.seq) ?? 0,
          collectedAt: r.collectedAt,
        ),
    ];
  }

  /// Valores do indicador desde [from], do mais antigo para o mais recente.
  /// Se mais de uma fonte tem a mesma data, fica a coleta mais recente.
  Future<List<IndicatorPoint>> indicator(
    IndicatorSeries series, {
    LocalDate? from,
  }) async {
    final q = _db.select(_db.mktIndicators)
      ..where((t) => t.seriesCode.equals(series.code))
      ..orderBy([
        (t) => OrderingTerm.asc(t.refDate),
        (t) => OrderingTerm.asc(t.collectedAt),
      ]);
    if (from != null) q.where((t) => t.refDate.isBiggerOrEqualValue('$from'));
    final byDate = <String, MktIndicatorRow>{};
    for (final r in await q.get()) {
      byDate[r.refDate] = r;
    }
    return [
      for (final r in byDate.values)
        IndicatorPoint(
          series: series,
          refDate: LocalDate.parse(r.refDate),
          value: Decimal.parse(r.value),
          source: r.source,
          collectedAt: r.collectedAt,
        ),
    ];
  }

  Future<IndicatorPoint?> latestIndicator(IndicatorSeries series) async {
    final row =
        await (_db.select(_db.mktIndicators)
              ..where((t) => t.seriesCode.equals(series.code))
              ..orderBy([
                (t) => OrderingTerm.desc(t.refDate),
                (t) => OrderingTerm.desc(t.collectedAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null
        ? null
        : IndicatorPoint(
            series: series,
            refDate: LocalDate.parse(row.refDate),
            value: Decimal.parse(row.value),
            source: row.source,
            collectedAt: row.collectedAt,
          );
  }

  /// Câmbio mais recente da moeda contra o real (PTAX antes da referência
  /// do BCE na mesma data).
  Future<FxRate?> latestFx(String currency) async {
    final rows =
        await (_db.select(_db.mktFxRates)
              ..where((t) => t.base.equals(currency) & t.quote.equals('BRL'))
              ..orderBy([(t) => OrderingTerm.desc(t.refDate)])
              ..limit(4))
            .get();
    if (rows.isEmpty) return null;
    final newest = rows.first.refDate;
    final sameDay = rows.where((r) => r.refDate == newest).toList()
      ..sort((a, b) => a.kind == FxKind.ptaxClose.code ? -1 : 1);
    return _fx(sameDay.first);
  }

  /// Câmbio diário da moeda contra o real (média de compra e venda), em
  /// ordem; na mesma data, a PTAX antes da referência do BCE.
  Future<List<(LocalDate, Decimal)>> fxHistory(String currency) async {
    final rows =
        await (_db.select(_db.mktFxRates)
              ..where((t) => t.base.equals(currency) & t.quote.equals('BRL'))
              ..orderBy([(t) => OrderingTerm.asc(t.refDate)]))
            .get();
    final byDate = <String, FxRate>{};
    for (final r in rows) {
      final rate = _fx(r);
      final current = byDate[r.refDate];
      if (current == null ||
          (current.kind != FxKind.ptaxClose && rate.kind == FxKind.ptaxClose)) {
        byDate[r.refDate] = rate;
      }
    }
    return [
      for (final r in byDate.values)
        if (r.mid != null) (r.refDate, r.mid!),
    ];
  }

  /// Moedas com câmbio contra o real guardado.
  Future<List<String>> fxCurrencies() async {
    final rows = await _db
        .customSelect(
          "SELECT DISTINCT base FROM mkt_fx_rates WHERE quote = 'BRL' "
          'ORDER BY base',
          readsFrom: {_db.mktFxRates},
        )
        .get();
    return [for (final r in rows) r.read<String>('base')];
  }

  Future<DateTime?> lastFxDate(String currency) async {
    final rate = await latestFx(currency);
    return rate == null
        ? null
        : DateTime.utc(rate.refDate.year, rate.refDate.month, rate.refDate.day);
  }

  /// Preço mais recente de cada título do Tesouro (título + vencimento).
  Future<List<TreasuryPrice>> latestTreasury() async {
    final rows = await _db
        .customSelect(
          'SELECT t.* FROM mkt_treasury_prices t JOIN (SELECT title, '
          'maturity_date, MAX(ref_date) AS ref_date FROM mkt_treasury_prices '
          'GROUP BY title, maturity_date) last ON t.title = last.title AND '
          't.maturity_date = last.maturity_date AND t.ref_date = '
          'last.ref_date',
          readsFrom: {_db.mktTreasuryPrices},
        )
        .get();
    return [
      for (final r in rows)
        () {
          final t = _db.mktTreasuryPrices.map(r.data);
          return TreasuryPrice(
            title: t.title,
            maturity: LocalDate.parse(t.maturityDate),
            refDate: LocalDate.parse(t.refDate),
            buyRate: _d(t.buyRate),
            sellRate: _d(t.sellRate),
            buyPu: _d(t.buyPu),
            sellPu: _d(t.sellPu),
            basePu: _d(t.basePu),
            source: t.source,
            collectedAt: t.collectedAt,
          );
        }(),
    ];
  }

  Future<LocalDate?> lastTreasuryDate() async {
    final row = await _db
        .customSelect(
          'SELECT MAX(ref_date) AS d FROM mkt_treasury_prices',
          readsFrom: {_db.mktTreasuryPrices},
        )
        .getSingle();
    final d = row.read<String?>('d');
    return d == null ? null : LocalDate.parse(d);
  }

  /// Informe de FII mais recente pelo ISIN.
  Future<FundReport?> latestFiiReport(String isin) async {
    final row =
        await (_db.select(_db.mktFundQuotas)
              ..where(
                (t) =>
                    t.isin.equals(isin) &
                    t.kind.equals(FundReportKind.fiiMonthly.code),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.refDate)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return FundReport(
      cnpj: row.cnpj,
      refDate: LocalDate.parse(row.refDate),
      kind: FundReportKind.fiiMonthly,
      quota: _d(row.quota),
      nav: _d(row.nav),
      holders: int.tryParse(row.holders ?? ''),
      isin: row.isin,
      name: row.name,
      source: row.source,
      collectedAt: row.collectedAt,
    );
  }

  /// ISIN conhecido do ativo, de qualquer fonte.
  Future<String?> isinOf(String symbol, String market) async {
    final rows =
        await (_db.select(_db.mktInstruments)..where(
              (t) =>
                  t.symbol.equals(symbol) &
                  t.market.equals(market) &
                  t.isin.isNotNull(),
            ))
            .get();
    return rows.isEmpty ? null : rows.first.isin;
  }

  /// Avisa quando qualquer dado de mercado muda (telas recalculam).
  Stream<void> watchChanges() =>
      _db.tableUpdates(TableUpdateQuery.onAllTables(marketTables(_db)));

  /// Resumo do conteúdo das tabelas de mercado (registros e última coleta
  /// de cada uma): muda quando algum dado muda, não quando a atualização
  /// regrava o que já estava guardado (M-10).
  Future<String> contentVersion() async {
    final parts = <String>[];
    for (final t in marketTables(_db)) {
      final collected = t.columnsByName.containsKey('collected_at')
          ? 'MAX(collected_at)'
          : 'NULL';
      final row = await _db
          .customSelect(
            'SELECT COUNT(*) AS n, $collected AS c '
            'FROM "${t.actualTableName}"',
            readsFrom: {t},
          )
          .getSingle();
      parts.add(
        '${t.actualTableName}:${row.read<int>('n')}:'
        '${row.readNullable<String>('c')}',
      );
    }
    return parts.join('|');
  }

  /// Registros por tabela de mercado (tela Fontes de dados e save).
  Future<Map<String, int>> counts() async {
    final result = <String, int>{};
    for (final t in marketTables(_db)) {
      final row = await _db
          .customSelect(
            'SELECT COUNT(*) AS n FROM "${t.actualTableName}"',
            readsFrom: {t},
          )
          .getSingle();
      result[t.actualTableName] = row.read<int>('n');
    }
    return result;
  }

  /// Tabelas `mkt_` do banco.
  static List<TableInfo<Table, dynamic>> marketTables(AppDatabase db) => [
    for (final t in db.allTables)
      if (t.actualTableName.startsWith('mkt_')) t,
  ];

  // -- Conversões -------------------------------------------------------------

  static MarketQuote _quote(MktQuoteRow r) => MarketQuote(
    symbol: r.symbol,
    market: r.market,
    price: Decimal.parse(r.price),
    currency: r.currency,
    refAt: parseInstant(r.refAt),
    source: r.source,
    dataType: byCode(MarketDataType.values, r.dataType),
    collectedAt: r.collectedAt,
    delayNote: r.delayNote,
  );

  static PriceBar _price(MktPriceRow r) => PriceBar(
    symbol: r.symbol,
    market: r.market,
    refDate: LocalDate.parse(r.refDate),
    open: _d(r.open),
    high: _d(r.high),
    low: _d(r.low),
    close: Decimal.parse(r.close),
    volume: _d(r.volume),
    currency: r.currency,
    quoteFactor: _d(r.quoteFactor),
    source: r.source,
    dataType: byCode(MarketDataType.values, r.dataType),
    collectedAt: r.collectedAt,
  );

  static FxRate _fx(MktFxRateRow r) => FxRate(
    base: r.base,
    quote: r.quote,
    refDate: LocalDate.parse(r.refDate),
    kind: byCode(FxKind.values, r.kind),
    bid: _d(r.bid),
    ask: _d(r.ask),
    refAt: r.refAt == null ? null : parseInstant(r.refAt!),
    source: r.source,
    collectedAt: r.collectedAt,
  );
}
