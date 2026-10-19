import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/presentation/widgets/common.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Área útil de uma janela de 1280 px no Windows (sem as bordas).
const _window1280 = Size(1264, 681);

/// Carrega a Segoe UI do Windows, a fonte que o app usa de verdade. Com a
/// fonte de teste padrão (cada letra é um quadrado), a largura não confere.
Future<bool> _loadSegoeUi() async {
  const dir = r'C:\Windows\Fonts';
  final files = [
    'segoeui.ttf',
    'seguisb.ttf',
    'segoeuib.ttf',
  ].map((f) => File(p.join(dir, f))).where((f) => f.existsSync()).toList();
  if (files.isEmpty) return false;
  final loader = FontLoader('Segoe UI');
  for (final f in files) {
    final bytes = f.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  return true;
}

void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  testWidgets(
    'na janela de 1280 px, a coluna "Resultado" aparece sem rolar para o lado',
    (tester) async {
      final hasFont = await tester.runAsync(_loadSegoeUi);
      if (hasFont != true) {
        markTestSkipped('Segoe UI indisponível (fora do Windows)');
        return;
      }
      await tester.runAsync(() async {
        await f.add(
          f.draft(
            OperationType.deposit,
            '2024-01-02',
            asset: null,
            gross: '9000000',
          ),
        );
        // Valores grandes, conta com nome longo e resultado negativo com
        // percentual: o pior caso realista de largura.
        await f.add(
          f.draft(
            OperationType.buy,
            '2024-01-10',
            account: f.account2,
            qty: '123456',
            price: '38.27',
            fees: '12.5',
          ),
        );
        await f.add(
          f.draft(
            OperationType.contribution,
            '2024-01-10',
            asset: f.cdb,
            gross: '1250000',
          ),
        );
        await f.valuations.setUnitPrice(
          assetId: f.petr,
          refDate: LocalDate(2024, 5, 31),
          price: dec('31.84'),
        );
        await f.valuations.setBalance(
          assetId: f.cdb,
          accountId: f.account,
          refDate: LocalDate(2024, 5, 31),
          balance: dec('1387654.32'),
        );
        // PETR4 com cotação da brapi (com hora) antiga: a nota mais larga
        // embaixo do valor e o ícone de desatualizado no preço atual.
        final petr = (await f.repos.assets.all()).firstWhere(
          (a) => a.id == f.petr,
        );
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
        await MarketRepository(f.t.db).saveQuote(
          MarketQuote(
            symbol: 'PETR4',
            market: 'B3',
            price: dec('31.84'),
            currency: 'BRL',
            refAt: DateTime.utc(2024, 6, 3, 20, 29),
            source: 'brapi',
            dataType: MarketDataType.intraday,
            collectedAt: '2024-06-03T20:31:00.000Z',
          ),
        );
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        final app = AppHarness(tester, f.t);
        await app.run(location: '/carteira', size: _window1280, () async {
          final visible = tester.getRect(find.byType(TableCard));
          final header = tester.getRect(find.text('Resultado'));
          expect(header.right, lessThanOrEqualTo(visible.right));
          final cells = find.byWidgetPredicate(
            (w) => w is PnlText,
            description: 'célula de resultado',
          );
          expect(cells, findsNWidgets(2));
          for (final element in cells.evaluate()) {
            final box = element.renderObject! as RenderBox;
            final right = box.localToGlobal(Offset(box.size.width, 0)).dx;
            expect(right, lessThanOrEqualTo(visible.right));
          }
          // Preço médio e atual lado a lado: o PETR4 com a cotação, com a
          // fonte e a data no tooltip; o CDB, avaliado por saldo, sem preço
          // unitário.
          expect(find.text('Preço médio /\nAtual'), findsOneWidget);
          expect(find.text(r'R$ 38,27'), findsOneWidget);
          final current = find.byKey(const Key('current-price'));
          expect(tester.widget<Text>(current).data, r'R$ 31,84');
          final tip = tester.widget<Tooltip>(
            find.ancestor(of: current, matching: find.byType(Tooltip)).first,
          );
          expect(tip.message, contains('brapi'));
          expect(tip.message, contains('03/06/2024'));
          expect(tip.message, contains('Desatualizado'));
          expect(find.byIcon(Icons.history), findsWidgets);
          expect(find.text('indisponível'), findsOneWidget);
          final price = tester.getRect(current);
          expect(price.right, lessThanOrEqualTo(visible.right));
        });
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
