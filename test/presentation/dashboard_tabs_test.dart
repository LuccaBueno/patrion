import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/application/settings/appearance_service.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/device_settings_repository.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/presentation/format/formatters.dart';
import 'package:patrion/presentation/providers.dart';

import '../helpers/app_harness.dart';
import '../helpers/fonts.dart';
import '../helpers/portfolio_fixture.dart';

/// Painel único com abas e o olho (M-11).
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() async {
    Fmt.hideMoney = false;
    await f.t.close();
  });

  /// PETR4 com cotação: 100 cotas a R$ 20 em 01/10/2025, fechamentos de
  /// R$ 20,37 subindo 1 centavo por pregão; um CDB de R$ 1.000 em
  /// 05/01/2026 com saldo de R$ 1.083,17; R$ 37,40 de dividendos.
  Future<void> seed() async {
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
    await f.add(
      f.draft(OperationType.buy, '2025-10-01', qty: '100', price: '20'),
    );
    await f.add(
      f.draft(
        OperationType.contribution,
        '2026-01-05',
        asset: f.cdb,
        gross: '1000',
      ),
    );
    await f.valuations.setBalance(
      assetId: f.cdb,
      accountId: f.account,
      refDate: LocalDate(2026, 10, 20),
      balance: Decimal.parse('1083.17'),
    );
    await f.add(f.draft(OperationType.dividend, '2026-08-14', gross: '37.4'));
    final bars = <PriceBar>[];
    final cdi = <IndicatorPoint>[];
    var close = Decimal.parse('20.37');
    for (
      var d = LocalDate(2025, 9, 1);
      !d.isAfter(LocalDate(2026, 10, 23));
      d = d.addDays(1)
    ) {
      if (!BusinessCalendar.brazil.isBusinessDay(d)) continue;
      close += Decimal.parse('0.01');
      bars.add(
        PriceBar(
          symbol: 'PETR4',
          market: 'B3',
          refDate: d,
          close: close,
          currency: 'BRL',
          source: 'b3_cotahist',
          dataType: MarketDataType.close,
          collectedAt: '2026-10-23T21:00:00.000Z',
        ),
      );
      cdi.add(
        IndicatorPoint(
          series: IndicatorSeries.cdi,
          refDate: d,
          value: Decimal.parse('0.05'),
          source: 'bcb_sgs',
          collectedAt: '2026-10-23T21:00:00.000Z',
        ),
      );
    }
    final repo = MarketRepository(f.t.db);
    await repo.savePrices(bars);
    await repo.saveIndicators(cdi);
  }

  final today = [
    portfolioQueryProvider.overrideWith(
      (ref) => PortfolioQuery(
        ref.watch(portfolioRepositoriesProvider),
        market: ref.watch(marketRepositoryProvider),
        preferences: ref.watch(portfolioPreferencesProvider),
        wallClock: Clock.fixed(DateTime(2026, 10, 23, 21)),
      ),
    ),
  ];

  /// Textos visíveis dentro de [root] (Text e RichText).
  List<String> texts(WidgetTester tester, Finder root) => [
    for (final p in tester.renderObjectList<RenderParagraph>(
      find.descendant(of: root, matching: find.byType(RichText)),
    ))
      p.text.toPlainText(),
  ];

  final money = RegExp(r'R\$ \d[\d.]*,\d\d');

  testWidgets('abas Visão geral, Rentabilidade, Comparação e Risco; o '
      'endereço antigo do Desempenho abre a Rentabilidade', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(location: '/desempenho', overrides: today, () async {
      await app.pumpUntil(find.byKey(const Key('returns-table')));
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 0, reason: 'Painel selecionado');
      expect(find.text('Desempenho'), findsNothing);
      for (final (tab, content) in [
        ('perf-tab-benchmarks', 'bench-table'),
        ('perf-tab-risk', 'risk-assets'),
        ('painel-tab-overview', 'wealth'),
        ('perf-tab-returns', 'returns-table'),
      ]) {
        await app.tap(find.byKey(Key(tab)));
        await app.pumpUntil(find.byKey(Key(content)));
      }
      // O período escolhido vale nas três abas.
      await app.tap(find.byKey(const Key('perf-period-Tudo')));
      await app.tap(find.byKey(const Key('perf-tab-risk')));
      await app.pumpUntil(find.byKey(const Key('risk-assets')));
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('perf-period-Tudo')))
            .selected,
        isTrue,
      );
    });
  });

  testWidgets('Visão geral em 1280 × 800: cabe em até 2 telas e nenhum valor '
      'aparece duas vezes', (tester) async {
    // Com a fonte real do Windows: a fonte de teste é mais larga e alta.
    final hasFont = await tester.runAsync(loadSegoeUi);
    if (hasFont != true) {
      markTestSkipped('Segoe UI indisponível (fora do Windows)');
      return;
    }
    await tester.runAsync(seed);
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final app = AppHarness(tester, f.t);
    // A área do app numa janela de 1280 × 800 (sem bordas e título).
    try {
      await app.run(size: const Size(1264, 761), overrides: today, () async {
        await app.pumpUntil(find.byKey(const Key('wealth-title')));
        final list = find.byKey(const Key('dashboard-list'));
        final position = tester
            .state<ScrollableState>(
              find.descendant(of: list, matching: find.byType(Scrollable)),
            )
            .position;
        // A lista é preguiçosa: rola até o fim para medir de verdade.
        final seen = <String>[];
        for (var i = 0; i < 10; i++) {
          seen.addAll(texts(tester, list));
          position.jumpTo(position.maxScrollExtent);
          await tester.pump();
          await app.settle();
        }
        seen.addAll(texts(tester, list));
        expect(
          position.maxScrollExtent,
          lessThanOrEqualTo(position.viewportDimension),
          reason: 'conteúdo de até 2 telas',
        );

        // Cada valor em reais aparece uma vez (o título do gráfico em "Tudo"
        // repete o ganho total de propósito, M-12; aqui o padrão é 1 ano).
        position.jumpTo(0);
        await app.settle();
        final values = <String, int>{};
        for (var offset = 0.0; ; offset += position.viewportDimension / 2) {
          position.jumpTo(offset.clamp(0, position.maxScrollExtent));
          await app.settle();
          for (final t in texts(tester, list)) {
            for (final m in money.allMatches(t)) {
              values[m[0]!] = 0;
            }
          }
          if (offset >= position.maxScrollExtent) break;
        }
        // Contagem por bloco: um valor pode ser visto em duas rolagens, mas
        // só pode existir em um widget.
        position.jumpTo(0);
        await app.settle();
        final perWidget = <String, Set<int>>{};
        void collect() {
          for (final p in tester.renderObjectList<RenderParagraph>(
            find.descendant(of: list, matching: find.byType(RichText)),
          )) {
            for (final m in money.allMatches(p.text.toPlainText())) {
              (perWidget[m[0]!] ??= {}).add(identityHashCode(p));
            }
          }
        }

        for (var offset = 0.0; ; offset += 200) {
          position.jumpTo(offset.clamp(0, position.maxScrollExtent));
          await app.settle();
          collect();
          if (offset >= position.maxScrollExtent) break;
        }
        expect(values, isNotEmpty);
        for (final MapEntry(:key, :value) in perWidget.entries) {
          expect(value, hasLength(1), reason: '$key aparece mais de uma vez');
        }
      });
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('o olho oculta os valores em reais em todo o app e fica '
      'lembrado', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(size: const Size(1280, 2000), overrides: today, () async {
      await app.pumpUntil(find.byKey(const Key('wealth-title')));
      final root = find.byType(MaterialApp);
      expect(texts(tester, root).where(money.hasMatch), isNotEmpty);

      await app.tap(find.byKey(const Key('hide-values')));
      await app.settle();
      expect(texts(tester, root).where(money.hasMatch), isEmpty);
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-equity')),
          matching: find.text('R\$ ${Fmt.hidden}'),
        ),
        findsOneWidget,
      );
      // Lembrado neste PC.
      final saved = await tester.runAsync(
        () =>
            DeviceSettingsRepository(f.t.db)
                .get(AppearanceService.hideValuesKey),
      );
      expect(saved, 'true');

      // Também nas outras telas.
      for (final screen in ['Carteira', 'Renda passiva', 'Operações']) {
        await app.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text(screen),
          ),
        );
        await app.settle();
        expect(
          texts(tester, root).where(money.hasMatch),
          isEmpty,
          reason: screen,
        );
      }

      // Mostrar de novo.
      await app.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Painel'),
        ),
      );
      await app.tap(find.byKey(const Key('hide-values')));
      await app.settle();
      expect(texts(tester, root).where(money.hasMatch), isNotEmpty);
    });
  });
}
