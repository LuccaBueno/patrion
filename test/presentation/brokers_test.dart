import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/portfolio/operation_service.dart';
import 'package:patrion/application/portfolio/quick_add_service.dart';
import 'package:patrion/application/portfolio/registry_service.dart';
import 'package:patrion/application/portfolio/valuation_service.dart';
import 'package:patrion/application/settings/portfolio_view_preferences.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/data/repositories/portfolio_repositories.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';

import '../helpers/app_harness.dart';
import '../helpers/test_database.dart';

/// Corretora escolhida na hora e a Carteira separada por corretora (M-06).
void main() {
  late TestDb t;
  late PortfolioRepositories repos;
  final ids = <String, String>{};

  setUp(() async {
    t = await TestDb.open();
    repos = PortfolioRepositories(t.db, t.sync);
    ids.clear();
  });
  tearDown(() => t.close());

  Asset asset(String symbol) => Asset(
    id: '',
    symbol: symbol,
    market: Market.b3,
    assetClass: AssetClass.stockBr,
    name: 'Empresa $symbol',
    currency: 'BRL',
    country: 'BR',
  );

  /// Banco vazio: BBAS3 na "Nubank" e PETR4 na "xp", só pelo nome da
  /// corretora (sem passar por Cadastros); preços informados.
  Future<void> seed() async {
    final registry = RegistryService(repos);
    final quick = QuickAddService(repos, registry, OperationService(repos));
    for (final (symbol, broker, qty, price) in [
      ('BBAS3', 'Nubank', '100', '25'),
      ('PETR4', 'xp', '10', '30'),
    ]) {
      final r = await quick.add(
        QuickAddInput(
          newAsset: asset(symbol),
          brokerName: broker,
          quantity: Decimal.parse(qty),
          price: Decimal.parse(price),
          date: LocalDate(2026, 1, 5),
        ),
      );
      ids[symbol] = r.assetId;
    }
    final valuations = ValuationService(repos);
    for (final (symbol, price) in [('BBAS3', '24'), ('PETR4', '40')]) {
      await valuations.setUnitPrice(
        assetId: ids[symbol]!,
        refDate: LocalDate(2026, 10, 16),
        price: Decimal.parse(price),
      );
    }
  }

  Finder rows(String symbol) => find.byKey(Key('holding-$symbol'));

  testWidgets('corretora pelo nome; mesmo ticker em duas corretoras numa '
      'linha, com a quebra na página; filtro lembrado; agrupar com '
      'subtotais; corretora nova; transferência mantém o preço médio', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final institutions = await tester.runAsync(repos.institutions.all);
    // "xp" virou a instituição XP? Não: o nome fica como digitado.
    expect(institutions!.map((i) => i.name), unorderedEquals(['Nubank', 'xp']));
    final accounts = await tester.runAsync(repos.accounts.all);
    expect(accounts!.map((a) => a.name).toSet(), {'Principal'});

    final app = AppHarness(tester, t);
    await app.run(
      location: '/carteira',
      size: const Size(1280, 1600),
      () async {
        // Comprar BBAS3 na xp pela página do ativo: a corretora vem com a
        // do ativo e aceita outra.
        await app.tap(rows('BBAS3'));
        await app.tap(find.byKey(const Key('asset-buy')));
        final broker = find.byKey(const Key('trade-broker'));
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: broker,
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          'Nubank',
        );
        await app.type(broker, 'XP');
        await app.type(find.byKey(const Key('trade-quantity')), '50');
        await app.type(find.byKey(const Key('trade-price')), '26');
        await app.tap(find.text('Salvar'));
        // Quebra por corretora na página: quantidade, PM e valor.
        expect(
          find.descendant(
            of: find.byKey(const Key('broker-row-Nubank')),
            matching: find.text(r'100 cotas · PM R$ 25,00'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('broker-row-xp')),
            matching: find.text(r'50 cotas · PM R$ 26,00'),
          ),
          findsOneWidget,
        );
        expect(find.text(r'R$ 1.200,00'), findsWidgets);

        // Na Carteira, uma linha só para o BBAS3.
        await app.tap(find.byKey(const Key('asset-back')));
        expect(rows('BBAS3'), findsOneWidget);
        expect(
          find.descendant(of: rows('BBAS3'), matching: find.text('150 cotas')),
          findsOneWidget,
        );

        // Filtro "xp": o que está lá (50 BBAS3 e o PETR4).
        await app.tap(find.byKey(const Key('broker-xp')));
        expect(
          find.descendant(of: rows('BBAS3'), matching: find.text('50 cotas')),
          findsOneWidget,
        );
        expect(rows('PETR4'), findsOneWidget);
        await app.tap(find.byKey(const Key('broker-Nubank')));
        expect(rows('PETR4'), findsNothing);
        expect(
          find.descendant(of: rows('BBAS3'), matching: find.text('100 cotas')),
          findsOneWidget,
        );
        // Lembrado entre aberturas (configuração deste PC).
        final saved = await tester.runAsync(
          () =>
              DeviceSettingsRepository(t.db)
                  .get(PortfolioViewPreferences.brokerKey),
        );
        final nubank = institutions.firstWhere((i) => i.name == 'Nubank');
        expect(saved, '"${nubank.id}"');

        // Todas, agrupadas: subtotais por corretora.
        await app.tap(find.byKey(const Key('broker-all')));
        await app.tap(find.byKey(const Key('group-by-broker')));
        expect(find.byKey(const Key('group-title-Nubank')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('group-total-Nubank'))).data,
          r'R$ 2.400,00',
        );
        // 50 × 24 + 10 × 40.
        expect(
          tester.widget<Text>(find.byKey(const Key('group-total-xp'))).data,
          r'R$ 1.600,00',
        );
        await app.tap(find.byKey(const Key('group-by-broker')));

        // Corretora nova digitada na compra: cria "Rico · Principal".
        await app.tap(rows('PETR4'));
        await app.tap(find.byKey(const Key('asset-buy')));
        await app.type(find.byKey(const Key('trade-broker')), 'Rico');
        expect(find.textContaining('Nova: cria "Rico · Principal"'), findsOne);
        await app.type(find.byKey(const Key('trade-quantity')), '5');
        await app.type(find.byKey(const Key('trade-price')), '41');
        await app.tap(find.text('Salvar'));
        expect(find.byKey(const Key('broker-row-Rico')), findsOneWidget);
        await app.tap(find.byKey(const Key('asset-back')));

        // Transferência de custódia: as 100 BBAS3 da Nubank para a xp,
        // com o mesmo custo: PM (2.500 + 1.300) ÷ 150.
        await app.tap(rows('BBAS3'));
        await app.tap(find.byKey(const Key('custody-transfer')));
        await app.type(find.byKey(const Key('custody-to')), 'xp');
        await app.tap(find.text('Salvar'));
        expect(find.byKey(const Key('broker-row-Nubank')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('broker-row-xp')),
            matching: find.text(r'150 cotas · PM R$ 25,33'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
