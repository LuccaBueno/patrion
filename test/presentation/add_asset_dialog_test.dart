import 'dart:io';

import 'package:archive/archive.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/portfolio/quick_add_service.dart';
import 'package:patrion/core/config/app_paths.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_http.dart';
import '../helpers/test_database.dart';

/// Adição rápida pelo ticker (M-01).
void main() {
  late TestDb t;
  late Directory dirs;

  setUp(() async {
    t = await TestDb.open();
    dirs = Directory.systemTemp.createTempSync('patrion_add_');
  });
  tearDown(() async {
    await t.close();
    dirs.deleteSync(recursive: true);
  });

  AppPaths paths() => AppPaths(
    dataDir: '${dirs.path}${Platform.pathSeparator}dados',
    cacheDir: '${dirs.path}${Platform.pathSeparator}cache',
  );

  /// B3 e brapi de mentira, com respostas reais gravadas.
  FakeHttpAdapter market() {
    final zip = ZipEncoder().encodeBytes(
      Archive()..addFile(
        ArchiveFile.bytes(
          'COTAHIST.TXT',
          File(fixture('cotahist_d21102026_catalogo.txt')).readAsBytesSync(),
        ),
      ),
    );
    return FakeHttpAdapter()
      ..on('COTAHIST_D', FakeReply(200, zip))
      ..on(
        'search=BBAS3',
        FakeReply.text(
          File(fixture('brapi_list_bbas3.json')).readAsStringSync(),
        ),
      )
      ..on(
        '/api/quote/list',
        FakeReply.text(
          File(fixture('brapi_list_empty.json')).readAsStringSync(),
        ),
      );
  }

  testWidgets('"bbas3", 100 e 25,00 cria o ativo com nome e classe e '
      'registra a compra, numa tela só', (tester) async {
    final app = AppHarness(tester, t);
    final http = market();
    await app.run(
      location: '/carteira',
      paths: paths(),
      marketHttp: fakeMarketHttp(http),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        // Primeira vez: o padrão é a posição que já tenho.
        expect(find.byKey(const Key('add-initial-note')), findsOneWidget);
        await app.tap(find.text('Nova compra'));
        await app.type(find.byKey(const Key('add-ticker')), 'bbas3');
        expect(find.text('BBAS3'), findsOneWidget, reason: 'maiúsculas');
        // Sair do campo dispara a consulta.
        await tester.tap(find.byKey(const Key('add-quantity')));
        await app.pumpUntil(find.byKey(const Key('add-found')));
        expect(find.text('BCO BRASIL S.A.'), findsOneWidget);
        expect(find.text('Ação'), findsOneWidget);
        await app.type(find.byKey(const Key('add-quantity')), '100');
        await app.type(find.byKey(const Key('add-price')), '25,00');
        await app.type(
          find.byKey(const Key('add-institution')),
          'Corretora Teste',
        );
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('compra de 100 registrado'));

        final assets = await tester.runAsync(t.db.select(t.db.assets).get);
        final bbas = assets!.single;
        expect(bbas.symbol, 'BBAS3');
        expect(bbas.name, 'BCO BRASIL S.A.');
        expect(bbas.assetClass, AssetClass.stockBr.code);
        expect(bbas.isin, 'BRBBASACNOR3');
        expect(bbas.sector, 'Financeiro');
        expect(bbas.priceSource, PriceSource.market.code);
        final ops = await tester.runAsync(t.db.select(t.db.operations).get);
        expect(ops!.single.type, OperationType.buy.code);
        expect(ops.single.quantity, Decimal.fromInt(100));
        expect(ops.single.unitPrice, Decimal.fromInt(25));
        expect(ops.single.notes, isNull);
        // Só os códigos foram às fontes (regra 8).
        expect(
          http.urls.where((u) => u.contains('brapi')),
          everyElement(isNot(contains('100'))),
        );
      },
    );
  });

  testWidgets('ticker inexistente avisa e permite o cadastro manual; ativo já '
      'cadastrado só registra a compra', (tester) async {
    final app = AppHarness(tester, t);
    await app.run(
      location: '/carteira',
      paths: paths(),
      marketHttp: fakeMarketHttp(market()),
      () async {
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        await app.type(find.byKey(const Key('add-ticker')), 'xpto3');
        await tester.tap(find.byKey(const Key('add-quantity')));
        await app.pumpUntil(find.byKey(const Key('add-not-found')));
        expect(find.textContaining('não encontrado'), findsOneWidget);
        await app.type(find.byKey(const Key('add-name')), 'Empresa XPTO');
        await app.choose(find.byKey(const Key('add-class')), 'Ação');
        await app.type(find.byKey(const Key('add-quantity')), '10');
        await app.type(find.byKey(const Key('add-price')), '5');
        await app.type(find.byKey(const Key('add-institution')), 'Banco');
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('saldo inicial de 10'));
        final asset = (await tester.runAsync(t.db.select(t.db.assets).get))!
            .single;
        expect(asset.name, 'Empresa XPTO');
        expect(asset.priceSource, PriceSource.manual.code);
        final op = (await tester.runAsync(t.db.select(t.db.operations).get))!
            .single;
        expect(op.notes, QuickAddService.initialBalanceNote);

        // De novo, o mesmo ticker: só a compra.
        await app.tap(find.byKey(const Key('portfolio-add-asset')));
        expect(find.byKey(const Key('add-initial-note')), findsNothing);
        await app.type(find.byKey(const Key('add-ticker')), 'XPTO3');
        await tester.tap(find.byKey(const Key('add-quantity')));
        await app.settle();
        expect(find.byKey(const Key('add-existing')), findsOneWidget);
        expect(find.byKey(const Key('add-name')), findsNothing);
        await app.type(find.byKey(const Key('add-quantity')), '5');
        await app.type(find.byKey(const Key('add-price')), '6');
        await app.tap(find.text('Salvar'));
        await app.pumpUntil(find.textContaining('compra de 5'));
        expect(
          await tester.runAsync(t.db.select(t.db.assets).get),
          hasLength(1),
        );
        expect(
          await tester.runAsync(t.db.select(t.db.operations).get),
          hasLength(2),
        );
      },
    );
  });

  testWidgets('sem internet e sem dados baixados: cadastro manual', (
    tester,
  ) async {
    final app = AppHarness(tester, t);
    await app.run(location: '/carteira', paths: paths(), () async {
      await app.tap(find.byKey(const Key('portfolio-add-asset')));
      await app.type(find.byKey(const Key('add-ticker')), 'PETR4');
      await tester.tap(find.byKey(const Key('add-quantity')));
      await app.pumpUntil(find.byKey(const Key('add-not-found')));
      expect(find.textContaining('Sem conexão'), findsOneWidget);
      expect(find.byKey(const Key('add-name')), findsOneWidget);
    });
  });
}
