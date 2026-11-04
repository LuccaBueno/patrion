import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/errors/app_error.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_http.dart';
import '../helpers/portfolio_fixture.dart';

/// Criptomoedas no "Adicionar ativo" e tipos de custódia (M-13). A data é a
/// do relógio falso: 17/10/2026.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  /// Candles de 10 a 16/10/2026, de R$ 400.000 a R$ 406.000.
  String klines() => jsonEncode([
    for (var d = 10; d <= 16; d++)
      [
        DateTime.utc(2026, 10, d).millisecondsSinceEpoch,
        '400000.00',
        '410000.00',
        '390000.00',
        '${400000 + (d - 10) * 1000}.00',
        '1.5',
        DateTime.utc(2026, 10, d, 23, 59, 59).millisecondsSinceEpoch,
        '600000.00',
      ],
  ]);

  /// Binance e CoinGecko de mentira, nas formas reais das respostas.
  FakeHttpAdapter market() => FakeHttpAdapter()
    ..on(
      '/api/v3/exchangeInfo',
      FakeReply.text(
        '{"symbols":[{"symbol":"BTCBRL","baseAsset":"BTC",'
        '"status":"TRADING"}]}',
      ),
    )
    ..on(
      '/api/v3/search',
      FakeReply.text(
        '{"coins":[{"id":"bitcoin","name":"Bitcoin","symbol":"BTC",'
        '"market_cap_rank":1}]}',
      ),
    )
    ..on(
      '/api/v3/ticker/24hr',
      FakeReply.text(
        '{"symbol":"BTCBRL","lastPrice":"438456.00",'
        '"closeTime":${DateTime.utc(2026, 10, 17, 11).millisecondsSinceEpoch}}',
      ),
    )
    ..on('/api/v3/klines', FakeReply.text(klines()));

  Future<void> pick(AppHarness app, Key field, String option) async {
    await app.tap(find.byKey(field));
    await app.tap(find.text(option).last);
  }

  testWidgets('"btc", 0,02111111 e R\$ 8.500,00 em "Carteira própria": ativo '
      'cripto, autocustódia, cotação, histórico e a unidade certa', (
    tester,
  ) async {
    final app = AppHarness(tester, f.t);
    final http = market();
    await app.run(
      location: '/carteira',
      marketHttp: fakeMarketHttp(http),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        await app.type(find.byKey(const Key('add-ticker')), 'btc');
        await app.tap(find.byKey(const Key('add-quantity')));
        await app.pumpUntil(find.byKey(const Key('add-found')));
        expect(find.textContaining('Binance'), findsWidgets);
        await app.type(find.byKey(const Key('add-quantity')), '0,02111111');
        await app.type(find.byKey(const Key('add-total')), '8.500,00');
        await app.type(find.byKey(const Key('add-date')), '10/10/2026');
        expect(find.byKey(const Key('add-price')), findsNothing);
        // 8.500 ÷ 0,02111111, antes de salvar.
        expect(
          find.text(r'Preço unitário calculado: R$ 402.631,60'),
          findsOneWidget,
        );
        await app.type(find.byKey(const Key('add-broker')), 'Carteira própria');
        await pick(app, const Key('custody-kind'), 'Autocustódia');
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('0,02111111 BTC registrado'));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await app.pumpUntil(find.text('0,02111111 BTC'));

        final btc = (await tester.runAsync(f.repos.assets.all))!
            .firstWhere((a) => a.symbol == 'BTC');
        expect(btc.market, Market.crypto);
        expect(btc.assetClass, AssetClass.crypto);
        expect(btc.name, 'Bitcoin');
        expect(btc.priceSource, PriceSource.market);

        final op = (await tester.runAsync(f.repos.operations.all))!.single;
        expect(op.quantity.toString(), '0.02111111', reason: 'sem arredondar');
        expect(op.grossAmount, dec('8500'), reason: 'o total exato');
        expect(op.unitPrice!.round(scale: 2), dec('402631.6'));

        final account = (await tester.runAsync(f.repos.accounts.all))!
            .firstWhere((a) => a.id == op.accountId);
        expect(account.kind, AccountKind.cryptoWallet);
        final custodian = (await tester.runAsync(f.repos.institutions.all))!
            .firstWhere((i) => i.id == account.institutionId);
        expect(custodian.name, 'Carteira própria');
        expect(custodian.kind, InstitutionKind.other);

        // Só o par vai para as fontes (regra 8).
        final urls = http.requests.map((r) => r.uri.toString()).join(' ');
        expect(urls, contains('symbol=BTCBRL'));
        expect(urls, isNot(contains('8500')));
        expect(urls, isNot(contains('0.02111111')));

        // Cotação e histórico guardados, desde antes do ano da carteira.
        final repo = MarketRepository(f.t.db);
        final range = await tester.runAsync(
          () => repo.priceRange('BTC', 'CRYPTO'),
        );
        expect(range, isNotNull);
        final klineCall = http.requests
            .map((r) => r.uri)
            .firstWhere((u) => u.path.endsWith('/klines'));
        expect(
          int.parse(klineCall.queryParameters['startTime']!),
          DateTime.utc(2017).millisecondsSinceEpoch,
          reason: 'desde a listagem do par, não do ano inicial da B3',
        );

        // Na página do ativo e em Operações, a mesma quantidade.
        await app.tap(find.byKey(const Key('holding-BTC')));
        expect(find.textContaining('0,02111111 BTC'), findsWidgets);
        expect(find.textContaining('cota'), findsNothing);
      },
    );
  });

  testWidgets('digitar um custodiante novo não perde o campo quando o tipo '
      'aparece', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/carteira',
      marketHttp: fakeMarketHttp(market()),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        final broker = find.byKey(const Key('add-broker'));
        final editable = find.descendant(
          of: broker,
          matching: find.byType(EditableText),
        );
        await tester.ensureVisible(broker);
        await tester.tap(broker);
        await app.settle();
        final before = tester.state(editable);
        expect(find.byKey(const Key('custody-kind')), findsNothing);
        await tester.enterText(broker, 'C');
        await app.settle();
        expect(find.byKey(const Key('custody-kind')), findsOneWidget);
        // O mesmo campo: num novo, o resto do que se digita se perderia.
        expect(identical(tester.state(editable), before), isTrue);
      },
    );
  });

  testWidgets('ticker da B3 não passa pelas fontes de cripto', (tester) async {
    final app = AppHarness(tester, f.t);
    final http = market();
    await app.run(
      location: '/carteira',
      marketHttp: fakeMarketHttp(http),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        await app.type(find.byKey(const Key('add-ticker')), 'bbas3');
        await tester.tap(find.byKey(const Key('add-quantity')));
        await app.pumpUntil(find.byKey(const Key('add-not-found')));
        expect(find.byKey(const Key('add-use-total')), findsNothing);
        expect(
          http.requests.where((r) => r.uri.host.contains('binance')),
          isEmpty,
        );
      },
    );
  });

  testWidgets('mais de 8 casas é recusado, sem arredondar', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/carteira',
      marketHttp: fakeMarketHttp(market()),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        await app.type(find.byKey(const Key('add-ticker')), 'btc');
        await app.tap(find.byKey(const Key('add-quantity')));
        await app.pumpUntil(find.byKey(const Key('add-found')));
        await app.type(find.byKey(const Key('add-quantity')), '0.021111119');
        await app.type(find.byKey(const Key('add-total')), '100');
        await app.type(find.byKey(const Key('add-broker')), 'Binance');
        await app.tap(find.text('Salvar'));
        expect(find.text('Até 8 casas'), findsOneWidget);
        expect(await tester.runAsync(f.repos.operations.all), isEmpty);
      },
    );
  });

  group('BTC já cadastrado no mercado errado', () {
    late String btc;

    /// O cadastro da versão anterior: classe cripto, mercado B3.
    Future<void> seed() async {
      btc = await f.repos.assets.create(
        const Asset(
          id: '',
          symbol: 'BTC',
          market: Market.b3,
          assetClass: AssetClass.crypto,
          name: 'bitcoin',
          currency: 'BRL',
          country: 'BR',
          priceSource: PriceSource.market,
        ),
      );
      await f.add(
        f.draft(
          OperationType.buy,
          '2026-10-10',
          asset: btc,
          qty: '0.02111111',
          price: '400000',
        ),
      );
    }

    testWidgets('"Dados do ativo" mostra o motivo e o botão corrige, sem '
        'perder a operação', (tester) async {
      await tester.runAsync(seed);
      final app = AppHarness(tester, f.t);
      await app.run(
        location: '/carteira',
        size: const Size(1280, 1600),
        marketHttp: fakeMarketHttp(market()),
        () async {
          await app.tap(find.byKey(const Key('holding-BTC')));
          await app.tap(find.byKey(const Key('tab-data')));
          await tester.ensureVisible(find.byKey(const Key('crypto-fix')));
          await app.settle();
          expect(
            find.textContaining('cadastrada no mercado B3'),
            findsOneWidget,
          );
          await app.tap(find.byKey(const Key('crypto-fix')));
          await app.pumpUntil(find.textContaining('R\$ 438.456,00'));
          expect(find.byKey(const Key('crypto-fix')), findsNothing);

          final a = (await tester.runAsync(() => f.repos.assets.byId(btc)))!;
          expect(a.market, Market.crypto);
          expect(a.priceSource, PriceSource.market);
          expect(a.name, 'bitcoin', reason: 'o nome é do usuário');
          final ops = (await tester.runAsync(f.repos.operations.all))!;
          expect(ops.single.assetId, btc);
          expect(ops.single.quantity.toString(), '0.02111111');
        },
      );
    });
  });

  testWidgets('comprar cripto: valor total com custos; vender: total '
      'recebido; a corretora de ações não é sugerida primeiro', (tester) async {
    late String btc;
    await tester.runAsync(() async {
      final exchange = await f.registry.accountForBroker(
        'Binance',
        kind: CustodyKind.exchange,
      );
      btc = await f.registry.createAsset(
        const Asset(
          id: '',
          symbol: 'BTC',
          market: Market.crypto,
          assetClass: AssetClass.crypto,
          name: 'Bitcoin',
          currency: 'BRL',
          country: 'BR',
          priceSource: PriceSource.market,
        ),
      );
      await f.add(
        f.draft(
          OperationType.buy,
          '2026-10-10',
          asset: btc,
          account: exchange,
          qty: '0.1',
          price: '400000',
        ),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/carteira',
      marketHttp: fakeMarketHttp(market()),
      () async {
        await app.tap(find.byKey(const Key('holding-BTC')));
        await app.tap(find.byKey(const Key('asset-buy')));
        await app.type(find.byKey(const Key('trade-quantity')), '0,01');
        await app.type(find.byKey(const Key('trade-total')), '4010');
        await app.type(find.byKey(const Key('trade-fees')), '10');
        await app.type(find.byKey(const Key('trade-date')), '11/10/2026');
        // (4.010 − 10) ÷ 0,01.
        expect(
          find.text(r'Preço unitário calculado: R$ 400.000,00'),
          findsOneWidget,
        );
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('0,01 BTC registrada'));

        await app.tap(find.byKey(const Key('asset-sell')));
        expect(find.text('Informar valor total recebido'), findsOneWidget);
        await app.type(find.byKey(const Key('trade-quantity')), '0,01');
        await app.type(find.byKey(const Key('trade-total')), '4490');
        await app.type(find.byKey(const Key('trade-fees')), '10');
        await app.type(find.byKey(const Key('trade-date')), '12/10/2026');
        // (4.490 + 10) ÷ 0,01.
        expect(
          find.text(r'Preço unitário calculado: R$ 450.000,00'),
          findsOneWidget,
        );
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('Venda de 0,01 BTC'));

        final ops = (await tester.runAsync(f.repos.operations.all))!;
        final buy = ops.firstWhere((o) => o.tradeDate.day == 11);
        expect(buy.grossAmount, dec('4000'));
        final sell = ops.firstWhere((o) => o.type == OperationType.sell);
        expect(sell.grossAmount, dec('4500'));
      },
    );
  });

  testWidgets('o tipo aparece ao agrupar na Carteira e no Painel, que passa a '
      'ser "Por custodiante"', (tester) async {
    await tester.runAsync(() async {
      final wallet = await f.registry.accountForBroker(
        'Ledger',
        kind: CustodyKind.selfCustody,
      );
      final btc = await f.registry.createAsset(
        const Asset(
          id: '',
          symbol: 'BTC',
          market: Market.crypto,
          assetClass: AssetClass.crypto,
          name: 'Bitcoin',
          currency: 'BRL',
          country: 'BR',
          priceSource: PriceSource.market,
        ),
      );
      await MarketRepository(f.t.db).saveQuote(
        MarketQuote(
          symbol: 'BTC',
          market: 'CRYPTO',
          price: dec('430000'),
          currency: 'BRL',
          refAt: DateTime.utc(2026, 10, 17, 11),
          source: 'binance',
          dataType: MarketDataType.intraday,
          collectedAt: '2026-10-17T11:00:00.000Z',
        ),
      );
      await f.add(
        f.draft(
          OperationType.buy,
          '2026-10-10',
          asset: btc,
          account: wallet,
          qty: '0.1',
          price: '400000',
        ),
      );
      await f.add(
        f.draft(OperationType.buy, '2026-10-10', qty: '10', price: '30'),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      await app.tap(find.byKey(const Key('group-by-broker')));
      expect(find.text('Agrupar por custodiante'), findsOneWidget);
      final kind = tester.widget<Text>(
        find.byKey(const Key('group-kind-Ledger')),
      );
      expect(kind.data, 'Autocustódia');
      expect(
        tester
            .widget<Text>(find.byKey(const Key('group-kind-Corretora Exemplo')))
            .data,
        'Corretora',
      );
    });
    await app.run(size: const Size(1280, 2000), () async {
      await app.tap(find.byKey(const Key('dist-Custodiante')));
      expect(find.text('Por custodiante'), findsOneWidget);
      expect(find.textContaining('Ledger (Autocustódia)'), findsWidgets);
    });
  });

  testWidgets('cadastro completo: escolher a classe Cripto muda o mercado', (
    tester,
  ) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/carteira', () async {
      await app.tap(find.byKey(const Key('portfolio-add-asset')));
      await app.tap(find.byKey(const Key('add-full-form')));
      await app.choose(find.byKey(const Key('asset-class')), 'Cripto');
      await app.type(find.byKey(const Key('asset-symbol')), 'ETH');
      await app.type(find.byKey(const Key('asset-name')), 'Ethereum');
      await app.tap(find.text('Salvar'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await app.settle();
      final eth = (await tester.runAsync(f.repos.assets.all))!
          .firstWhere((a) => a.symbol == 'ETH');
      expect(eth.market, Market.crypto);
      expect(eth.priceSource, PriceSource.market);
    });
  });

  test('cripto em mercado de bolsa é recusada', () async {
    await expectLater(
      f.registry.createAsset(
        const Asset(
          id: '',
          symbol: 'BTC',
          market: Market.b3,
          assetClass: AssetClass.crypto,
          name: 'Bitcoin',
          currency: 'BRL',
          country: 'BR',
        ),
      ),
      throwsA(isA<DataError>()),
    );
  });
}
