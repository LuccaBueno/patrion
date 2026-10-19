import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/data/repositories/provider_state_repository.dart';
import 'package:patrion/domain/market/market_data.dart';

import '../../helpers/test_database.dart';

Decimal d(String s) => Decimal.parse(s);

/// Cache dos dados de mercado (`mkt_`) e estado dos provedores.
void main() {
  late TestDb t;
  late MarketRepository repo;

  setUp(() async {
    t = await TestDb.open();
    repo = MarketRepository(t.db);
  });

  tearDown(() => t.close());

  PriceBar bar(String symbol, String date, String close, {String? factor}) =>
      PriceBar(
        symbol: symbol,
        market: 'B3',
        refDate: LocalDate.parse(date),
        close: d(close),
        open: d(close),
        currency: 'BRL',
        source: 'b3_cotahist',
        dataType: MarketDataType.close,
        collectedAt: '2026-10-17T12:00:00.000Z',
        quoteFactor: factor == null ? null : d(factor),
      );

  test(
    'preços: valores exatos, o mesmo dia é regravado, sem duplicar',
    () async {
      await repo.savePrices([
        bar('PETR4', '2026-10-15', '59.10'),
        bar('PETR4', '2026-10-16', '59.68'),
        bar('VALE3', '2026-10-16', '61.234567', factor: '1'),
      ]);
      await repo.savePrices([bar('PETR4', '2026-10-16', '59.69')]);
      final petr = await repo.prices('PETR4', 'B3');
      expect([for (final p in petr) p.close], [d('59.10'), d('59.69')]);
      expect(petr.first.open, d('59.10'));
      expect(petr.first.source, 'b3_cotahist');
      final latest = await repo.latestCloses();
      expect(
        {for (final p in latest) p.symbol: p.close},
        {'PETR4': d('59.69'), 'VALE3': d('61.234567')},
      );
      final range = await repo.priceRange('PETR4', 'B3');
      expect(range, (LocalDate(2026, 10, 15), LocalDate(2026, 10, 16), 2));
      expect(await repo.priceRange('ITUB4', 'B3'), isNull);
    },
  );

  test(
    'câmbio: na mesma data, a PTAX vem antes da referência do BCE',
    () async {
      FxRate rate(String date, FxKind kind, String ask) => FxRate(
        base: 'EUR',
        quote: 'BRL',
        refDate: LocalDate.parse(date),
        kind: kind,
        ask: d(ask),
        source: kind == FxKind.ptaxClose ? 'bcb_ptax' : 'frankfurter',
        collectedAt: '2026-10-17T12:00:00.000Z',
      );
      await repo.saveFx([
        rate('2026-10-15', FxKind.ptaxClose, '6.30'),
        rate('2026-10-16', FxKind.reference, '6.33'),
        rate('2026-10-16', FxKind.ptaxClose, '6.32'),
      ]);
      final latest = (await repo.latestFx('EUR'))!;
      expect(latest.kind, FxKind.ptaxClose);
      expect(latest.mid, d('6.32'));
      expect(await repo.fxCurrencies(), ['EUR']);
      expect(await repo.latestFx('USD'), isNull);
    },
  );

  test(
    'indicadores: do mais antigo ao mais recente, uma linha por data',
    () async {
      IndicatorPoint p(String date, String v, String source, String at) =>
          IndicatorPoint(
            series: IndicatorSeries.ipca,
            refDate: LocalDate.parse(date),
            value: d(v),
            source: source,
            collectedAt: at,
          );
      await repo.saveIndicators([
        p('2026-08-01', '-0.11', 'bcb_sgs', '2026-10-01T12:00:00.000Z'),
        p('2026-09-01', '0.48', 'bcb_sgs', '2026-10-10T12:00:00.000Z'),
        p('2026-09-01', '0.48', 'ibge_sidra', '2026-10-11T12:00:00.000Z'),
      ]);
      final series = await repo.indicator(IndicatorSeries.ipca);
      expect([for (final x in series) x.value], [d('-0.11'), d('0.48')]);
      expect(series.last.source, 'ibge_sidra');
      expect(
        (await repo.latestIndicator(IndicatorSeries.ipca))!.refDate,
        LocalDate(2026, 9, 1),
      );
    },
  );

  test('Tesouro: o preço mais recente de cada título', () async {
    TreasuryPrice tp(String date, String pu) => TreasuryPrice(
      title: 'Tesouro Selic',
      maturity: LocalDate(2031, 3, 1),
      refDate: LocalDate.parse(date),
      sellPu: d(pu),
      source: 'tesouro',
      collectedAt: '2026-10-17T12:00:00.000Z',
    );
    await repo.saveTreasury([
      tp('2026-10-15', '17800.10'),
      tp('2026-10-16', '17806.45'),
    ]);
    final latest = await repo.latestTreasury();
    expect(latest.single.sellPu, d('17806.45'));
    expect(await repo.lastTreasuryDate(), LocalDate(2026, 10, 16));
  });

  test('cotação: uma por fonte; avisa as telas quando muda', () async {
    final changes = <void>[];
    final sub = repo.watchChanges().listen(changes.add);
    MarketQuote q(String source, String price) => MarketQuote(
      symbol: 'PETR4',
      market: 'B3',
      price: d(price),
      currency: 'BRL',
      refAt: DateTime.utc(2026, 10, 16, 18),
      source: source,
      dataType: MarketDataType.intraday,
      collectedAt: '2026-10-17T12:00:00.000Z',
    );
    await repo.saveQuote(q('brapi', '59.60'));
    await repo.saveQuote(q('brapi', '59.68'));
    await repo.saveQuote(q('yahoo', '59.70'));
    await pumpEventQueue();
    final quotes = await repo.quotes('PETR4', 'B3');
    expect(quotes, hasLength(2));
    expect(quotes.firstWhere((x) => x.source == 'brapi').price, d('59.68'));
    expect(changes, isNotEmpty);
    await sub.cancel();
  });

  group('estado dos provedores', () {
    late ProviderStateRepository states;
    setUp(() => states = ProviderStateRepository(t.db));

    test('padrão do catálogo: Yahoo desligado, os outros ligados', () async {
      expect(await states.isEnabled('yahoo'), isFalse);
      expect(await states.isEnabled('bcb_sgs'), isTrue);
      await states.setEnabled('yahoo', true);
      expect(await states.isEnabled('yahoo'), isTrue);
    });

    test(
      'sucesso e erro: "falhando" só se o erro for depois do sucesso',
      () async {
        await states.recordSuccess('brapi', DateTime.utc(2026, 10, 16, 10));
        await states.recordError(
          'brapi',
          DateTime.utc(2026, 10, 16, 11),
          'Chave inválida.',
        );
        var s = await states.of('brapi');
        expect(s.failing, isTrue);
        expect(s.lastError, 'Chave inválida.');
        await states.recordSuccess('brapi', DateTime.utc(2026, 10, 16, 12));
        s = await states.of('brapi');
        expect(s.failing, isFalse);
        expect(s.enabled, isTrue);
      },
    );

    test('cota mensal recomeça no mês seguinte', () async {
      expect(await states.addQuota('brapi', DateTime.utc(2026, 10, 1)), 1);
      expect(await states.addQuota('brapi', DateTime.utc(2026, 10, 31)), 2);
      expect(await states.addQuota('brapi', DateTime.utc(2026, 11, 1)), 1);
      expect((await states.of('brapi')).quotaPeriod, '2026-11');
    });
  });
}
