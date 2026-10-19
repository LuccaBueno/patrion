import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/sync/invsave_codec.dart';

import '../../helpers/sync_pc.dart';

/// Pasta `market/` do save (SPEC §10.1; DECISIONS D-36): o outro PC recebe
/// os dados de mercado já baixados e funciona sem internet.
void main() {
  late Directory tmp;
  late SyncPc a;
  late SyncPc b;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('patrion_market_save');
    a = await SyncPc.open('PC-A', tmp);
    b = await SyncPc.open('PC-B', tmp);
  });

  tearDown(() async {
    await a.close();
    await b.close();
    await tmp.delete(recursive: true);
  });

  PriceBar bar(String date, String close, String collected) => PriceBar(
    symbol: 'PETR4',
    market: 'B3',
    refDate: LocalDate.parse(date),
    close: Decimal.parse(close),
    currency: 'BRL',
    source: 'b3_cotahist',
    dataType: MarketDataType.close,
    collectedAt: collected,
  );

  FxRate usd(String date, String ask) => FxRate(
    base: 'USD',
    quote: 'BRL',
    refDate: LocalDate.parse(date),
    kind: FxKind.ptaxClose,
    bid: Decimal.parse(ask),
    ask: Decimal.parse(ask),
    source: 'bcb_ptax',
    collectedAt: '2026-10-17T12:00:00.000Z',
  );

  test('o save leva preços e câmbio; o outro PC passa a tê-los', () async {
    final marketA = MarketRepository(a.t.db);
    await marketA.savePrices([
      bar('2026-10-15', '59.10', '2026-10-16T12:00:00.000Z'),
      bar('2026-10-16', '59.68', '2026-10-17T12:00:00.000Z'),
    ]);
    await marketA.saveFx([usd('2026-10-16', '5.41')]);

    final bytes = await a.export();
    final manifest = InvsaveCodec.decode(bytes).manifest;
    expect(manifest.marketIncluded, isTrue);
    expect(manifest.marketCounts, {'mkt_prices': 2, 'mkt_fx_rates': 1});

    final preview = await b.preview(bytes);
    expect(preview.marketRecords, 3);
    await b.save.apply(preview);

    final marketB = MarketRepository(b.t.db);
    final prices = await marketB.prices('PETR4', 'B3');
    expect(
      [for (final p in prices) p.close],
      [Decimal.parse('59.10'), Decimal.parse('59.68')],
    );
    expect(prices.last.source, 'b3_cotahist');
    expect(prices.last.collectedAt, '2026-10-17T12:00:00.000Z');
    expect((await marketB.latestFx('USD'))!.ask, Decimal.parse('5.41'));

    // Importar de novo não muda nada.
    await b.import(bytes);
    expect(await marketB.prices('PETR4', 'B3'), hasLength(2));
  });

  test('um dado que já existe só é trocado por uma coleta mais nova', () async {
    await MarketRepository(a.t.db).savePrices([
      bar('2026-10-15', '59.10', '2026-10-16T12:00:00.000Z'),
      bar('2026-10-16', '59.68', '2026-10-16T21:00:00.000Z'),
    ]);
    final marketB = MarketRepository(b.t.db);
    await marketB.savePrices([
      // Coleta mais nova em B: fica.
      bar('2026-10-15', '59.11', '2026-10-17T09:00:00.000Z'),
      // Coleta mais antiga em B: é trocada.
      bar('2026-10-16', '59.00', '2026-10-16T18:00:00.000Z'),
    ]);
    await b.import(await a.export());
    final prices = await marketB.prices('PETR4', 'B3');
    expect(
      [for (final p in prices) p.close],
      [Decimal.parse('59.11'), Decimal.parse('59.68')],
    );
  });

  test('sem a opção, o save não leva dados de mercado (formato 1)', () async {
    await MarketRepository(a.t.db).saveFx([usd('2026-10-16', '5.41')]);
    a.tick();
    final export = await a.save.buildExport(includeMarket: false);
    final manifest = InvsaveCodec.decode(export.bytes).manifest;
    expect(manifest.marketIncluded, isFalse);
    expect(manifest.formatVersion, 1);
    expect(export.marketRecords, 0);
    await b.import(export.bytes);
    expect(await MarketRepository(b.t.db).latestFx('USD'), isNull);
  });

  test('o save com senha leva os dados de mercado cifrados', () async {
    await MarketRepository(a.t.db).saveFx([usd('2026-10-16', '5.41')]);
    final bytes = await a.export(password: 'senha-do-arquivo');
    final preview = await b.preview(bytes, password: 'senha-do-arquivo');
    expect(preview.marketRecords, 1);
    await b.save.apply(preview);
    expect(
      (await MarketRepository(b.t.db).latestFx('USD'))!.source,
      'bcb_ptax',
    );
  });
}
