import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_http.dart';
import '../helpers/portfolio_fixture.dart';

/// Tela "Fontes de dados", chaves de API, atualização e funcionamento sem
/// internet (SPEC §3, §5 e F6).
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  Future<void> useMarketPrice() async {
    final petr = (await f.repos.assets.all()).firstWhere((a) => a.id == f.petr);
    await f.registry.updateAsset(
      Asset(
        id: petr.id,
        symbol: petr.symbol,
        market: petr.market,
        assetClass: petr.assetClass,
        name: petr.name,
        currency: petr.currency,
        country: petr.country,
        priceSource: PriceSource.market,
      ),
    );
  }

  Future<void> seed() async {
    await f.add(
      f.draft(OperationType.deposit, '2026-01-02', asset: null, gross: '10000'),
    );
    await f.add(
      f.draft(OperationType.buy, '2026-01-05', qty: '100', price: '30'),
    );
  }

  testWidgets('lista os provedores com o que é enviado, licença e limites; '
      'o Yahoo vem desligado', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/fontes', () async {
      expect(find.text('Fontes de dados'), findsWidgets);
      expect(find.text('Banco Central — SGS'), findsOneWidget);
      expect(find.textContaining('Envia: Só o código da série'), findsWidgets);
      await tester.scrollUntilVisible(
        find.byKey(const Key('provider-yahoo')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final yahoo = tester.widget<Switch>(
        find.byKey(const Key('provider-switch-yahoo')),
      );
      expect(yahoo.value, isFalse);
      expect(find.textContaining('Desligado por padrão'), findsOneWidget);
    });
  });

  testWidgets('a chave digitada fica só no cofre: some da tela e não aparece '
      'em nenhum texto', (tester) async {
    final app = AppHarness(tester, f.t);
    const secret = 'chave-de-teste-123';
    await app.run(location: '/fontes', () async {
      final field = find.byKey(const Key('key-field-brapi'));
      await tester.scrollUntilVisible(
        field,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await app.type(field, secret);
      await app.tap(find.byKey(const Key('key-save-brapi')));
      expect(app.keys.read('brapi'), secret);
      expect(find.text('Chave cadastrada neste computador'), findsOneWidget);
      expect(find.textContaining(secret), findsNothing);
      // Apagar pede confirmação (depois que o aviso some).
      await tester.pump(const Duration(seconds: 6));
      await app.settle();
      final delete = find.byKey(const Key('key-delete-brapi'));
      await tester.runAsync(
        () => Scrollable.ensureVisible(tester.element(delete), alignment: 0.5),
      );
      await app.settle();
      await app.tap(delete);
      await app.tap(find.text('Apagar').last);
      expect(app.keys.read('brapi'), isNull);
    });
  });

  testWidgets('sem internet: "Atualizar agora" avisa e a carteira mostra a '
      'última cotação guardada, com fonte e data', (tester) async {
    await tester.runAsync(() async {
      await seed();
      await useMarketPrice();
      await MarketRepository(f.t.db).savePrices([
        PriceBar(
          symbol: 'PETR4',
          market: 'B3',
          refDate: LocalDate(2026, 10, 16),
          close: Decimal.parse('35.50'),
          currency: 'BRL',
          source: 'b3_cotahist',
          dataType: MarketDataType.close,
          collectedAt: '2026-10-17T12:00:00.000Z',
        ),
      ]);
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/fontes', () async {
      await app.press(find.byKey(const Key('market-refresh')));
      await app.pumpUntil(find.textContaining('Sem conexão'));
      await app.settle();
      await app.tap(find.text('Carteira').first);
      expect(find.text(r'R$ 3.550,00'), findsOneWidget);
      expect(
        find.textContaining('B3 — Séries históricas (COTAHIST) · 16/10/2026'),
        findsOneWidget,
      );
    });
  });

  testWidgets('com a brapi respondendo, a cotação aparece com fonte e data', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await seed();
      await useMarketPrice();
    });
    final http = FakeHttpAdapter()
      ..on('brapi.dev', FakeReply.file(fixture('brapi_petr4.json')));
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/carteira/ativo/${f.petr}',
      marketHttp: fakeMarketHttp(http),
      () async {
        await app.press(find.byKey(const Key('asset-refresh')));
        await app.pumpUntil(find.text(r'R$ 59,68'));
        await app.settle();
        expect(find.text('brapi'), findsWidgets);
        expect(find.text('intradiário'), findsOneWidget);
        // Só o ticker foi à brapi; nenhuma requisição levou valores.
        final brapiUrls = http.urls.where((u) => u.contains('brapi.dev'));
        expect(brapiUrls.single, contains('/api/quote/PETR4'));
        expect(http.urls.any((u) => u.contains('3000')), isFalse);
      },
    );
  });

  testWidgets('ativos antigos com preço informado podem passar para a '
      'cotação automática', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/fontes', () async {
      expect(find.byKey(const Key('manual-assets')), findsOneWidget);
      await app.tap(find.byKey(const Key('manual-assets-apply')));
      await app.tap(find.text('Usar cotações').last);
      await app.pumpUntil(find.textContaining('Pronto.'));
      final petr = await tester.runAsync(
        () async =>
            (await f.repos.assets.all()).firstWhere((a) => a.id == f.petr),
      );
      expect(petr!.priceSource, PriceSource.market);
      // O CDB (renda fixa privada) continua com preço informado.
      final cdb = await tester.runAsync(
        () async =>
            (await f.repos.assets.all()).firstWhere((a) => a.id == f.cdb),
      );
      expect(cdb!.priceSource, PriceSource.manual);
    });
  });
}
