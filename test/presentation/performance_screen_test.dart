import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/settings/portfolio_preferences.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/shared_settings_repository.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/fonts.dart';
import '../helpers/portfolio_fixture.dart';

/// Desempenho → Rentabilidade (F8, parte 1).
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  /// PETR4 com cotação automática: 100 cotas em 10/01/2024 e 50 em
  /// 10/03/2025, a R$ 30. Fechamento de R$ 30 até maio de 2025, R$ 40 até
  /// maio de 2026 e R$ 44 depois; CDI de 0,04% ao dia útil.
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
      f.draft(OperationType.buy, '2024-01-10', qty: '100', price: '30'),
    );
    await f.add(
      f.draft(OperationType.buy, '2025-03-10', qty: '50', price: '30'),
    );
    final cal = BusinessCalendar.brazil;
    final bars = <PriceBar>[];
    final cdi = <IndicatorPoint>[];
    for (
      var d = LocalDate(2024, 1, 2);
      !d.isAfter(LocalDate(2026, 10, 16));
      d = d.addDays(1)
    ) {
      if (!cal.isBusinessDay(d)) continue;
      final close = d.isBefore(LocalDate(2025, 6, 1))
          ? '30'
          : d.isBefore(LocalDate(2026, 6, 1))
          ? '40'
          : '44';
      bars.add(
        PriceBar(
          symbol: 'PETR4',
          market: 'B3',
          refDate: d,
          close: Decimal.parse(close),
          currency: 'BRL',
          source: 'b3_cotahist',
          dataType: MarketDataType.close,
          collectedAt: '2026-10-17T12:00:00.000Z',
        ),
      );
      cdi.add(
        IndicatorPoint(
          series: IndicatorSeries.cdi,
          refDate: d,
          value: Decimal.parse('0.04'),
          source: 'bcb_sgs',
          collectedAt: '2026-10-17T12:00:00.000Z',
        ),
      );
    }
    final repo = MarketRepository(f.t.db);
    await repo.savePrices(bars);
    await repo.saveIndicators(cdi);
  }

  Finder inKey(String key, String text) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.textContaining(text),
  );

  String cellText(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  String cellOf(WidgetTester tester, String key) => cellText(tester, key);

  testWidgets('tabela mês a mês, períodos, CDI e período personalizado', (
    tester,
  ) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/desempenho',
      size: const Size(1280, 900),
      () async {
        await app.pumpUntil(find.byKey(const Key('returns-table')));
        // Mês a mês: a alta de 30 para 40 em junho de 2025 e de 40 para 44
        // em junho de 2026; os outros meses ficam em 0%.
        expect(cellText(tester, 'returns-2025-6'), '+33,33%');
        expect(cellText(tester, 'returns-2025-5'), '0,00%');
        expect(cellText(tester, 'returns-2025-total'), '+33,33%');
        expect(cellText(tester, 'returns-2026-6'), '+10,00%');
        expect(cellText(tester, 'returns-2026-acc'), '+46,67%');
        expect(cellText(tester, 'returns-2024-total'), '0,00%');
        expect(find.text('2024*'), findsOneWidget, reason: 'ano parcial');
        // CDI de 2025: 0,04% em cada dia útil do ano.
        expect(cellText(tester, 'returns-2025-cdi'), startsWith('+10,'));
        expect(cellText(tester, 'returns-2025-ofcdi'), endsWith('%'));

        // 1 ano (padrão): 40 → 44, sem aportes; sem IPCA, retorno real
        // indisponível; TWR igual à TIR sem aportes no período.
        expect(inKey('returns-twr', 'em 1 ano'), findsOneWidget);
        expect(inKey('returns-twr', '+10,00%'), findsOneWidget);
        expect(inKey('returns-cdi', '% do CDI'), findsOneWidget);
        expect(inKey('returns-real', 'indisponível'), findsOneWidget);
        expect(find.byKey(const Key('returns-cagr')), findsNothing);
        // Períodos que os dados não sustentam não aparecem.
        expect(find.byKey(const Key('perf-period-3A')), findsNothing);
        expect(find.byKey(const Key('perf-period-10A')), findsNothing);

        // Tudo: acumulado de 46,67% em mais de um ano, com CAGR.
        await app.tap(find.byKey(const Key('perf-period-Tudo')));
        expect(inKey('returns-twr', '+46,67%'), findsOneWidget);
        expect(inKey('returns-twr', 'de 10/01/2024'), findsOneWidget);
        expect(find.byKey(const Key('returns-cagr')), findsOneWidget);

        // Personalizado: maio e junho de 2025.
        await app.tap(find.byKey(const Key('perf-period-Personalizado')));
        await tester.enterText(
          find.byKey(const Key('perf-custom-from')),
          '01/05/2025',
        );
        await tester.enterText(
          find.byKey(const Key('perf-custom-to')),
          '30/06/2025',
        );
        await app.tap(find.text('Salvar'));
        expect(find.text('01/05/2025 a 30/06/2025'), findsOneWidget);
        expect(inKey('returns-twr', '+33,33%'), findsOneWidget);
        expect(
          inKey('returns-twr', 'de 30/04/2025 a 30/06/2025'),
          findsOneWidget,
        );
        expect(inKey('returns-mwr', '+33,33% no período'), findsOneWidget);
      },
    );
  });

  testWidgets('na janela de 1280 px, a tabela cabe sem cortar textos', (
    tester,
  ) async {
    final hasFont = await tester.runAsync(loadSegoeUi);
    if (hasFont != true) {
      markTestSkipped('Segoe UI indisponível (fora do Windows)');
      return;
    }
    await tester.runAsync(seed);
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final app = AppHarness(tester, f.t);
      await app.run(
        location: '/desempenho',
        size: const Size(1264, 681),
        () async {
          await app.pumpUntil(find.byKey(const Key('returns-table')));
          final table = tester.getRect(find.byKey(const Key('returns-table')));
          expect(table.right, lessThanOrEqualTo(1264));
          final paragraphs = tester
              .renderObjectList<RenderParagraph>(
                find.descendant(
                  of: find.byKey(const Key('returns-table')),
                  matching: find.byType(RichText),
                ),
              )
              .toList();
          expect(paragraphs, isNotEmpty);
          for (final p in paragraphs) {
            // Só as células (uma linha); a legenda do cartão quebra linha.
            if (p.maxLines != 1 || p.text.toPlainText().isEmpty) continue;
            // Inteira dentro do cartão e, no máximo, um pouco reduzida.
            final left = p.localToGlobal(Offset.zero);
            final right = p.localToGlobal(Offset(p.size.width, 0));
            final text = p.text.toPlainText();
            expect(right.dx, lessThanOrEqualTo(table.right), reason: text);
            expect(
              (right.dx - left.dx) / p.size.width,
              greaterThanOrEqualTo(0.85),
              reason: text,
            );
          }
        },
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('benchmarks: CDI contra a carteira no mesmo período; os '
      'indisponíveis com o motivo', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/desempenho',
      size: const Size(1280, 1400),
      () async {
        await app.pumpUntil(find.byKey(const Key('returns-table')));
        await app.tap(find.byKey(const Key('perf-tab-benchmarks')));
        await app.pumpUntil(find.byKey(const Key('bench-table')));
        // 1 ano: carteira +10,00%; CDI de 0,04% ao dia útil, ~+10,5%.
        expect(cellOf(tester, 'bench-carteira-acc'), '+10,00%');
        expect(cellOf(tester, 'bench-cdi-acc'), startsWith('+10,'));
        expect(cellOf(tester, 'bench-cdi-diff'), endsWith('p.p.'));
        for (final (index, reason) in [
          ('ibovespa', 'Sem dados guardados'),
          ('ima', 'ANBIMA'),
          ('idka', 'ANBIMA'),
          ('sp500', 'ative o Yahoo'),
        ]) {
          expect(
            find.byKey(Key('bench-$index-unavailable')),
            findsOneWidget,
            reason: index,
          );
          expect(cellOf(tester, 'bench-$index-reason'), contains(reason));
        }
        // Gráfico em base 100: a carteira e o CDI (o Ibovespa não tem dados).
        final chart = tester.widget<LineChart>(
          find.descendant(
            of: find.byKey(const Key('bench-chart')),
            matching: find.byType(LineChart),
          ),
        );
        expect(chart.data.lineBarsData, hasLength(2));
        expect(chart.data.lineBarsData.first.spots.first.y, 100);
        expect(chart.data.lineBarsData.first.spots.last.y, closeTo(110, 1e-9));
        expect(find.byKey(const Key('bench-show-ibovespa')), findsNothing);
        expect(
          find.descendant(
            of: find.byKey(const Key('bench-legend')),
            matching: find.text('CDI'),
          ),
          findsOneWidget,
        );
        // Desmarcar o CDI tira a linha.
        await app.tap(find.byKey(const Key('bench-show-cdi')));
        expect(
          tester
              .widget<LineChart>(
                find.descendant(
                  of: find.byKey(const Key('bench-chart')),
                  matching: find.byType(LineChart),
                ),
              )
              .data
              .lineBarsData,
          hasLength(1),
        );
      },
    );
  });

  testWidgets('risco: volatilidade, Sharpe com CDI, beta indisponível sem '
      'Ibovespa, concentração e alocação-alvo', (tester) async {
    await tester.runAsync(() async {
      await seed();
      await PortfolioPreferences(SharedSettingsRepository(f.t.db, f.t.sync))
          .setTargets({
            AssetClass.stockBr: Decimal.parse('0.8'),
            AssetClass.fii: Decimal.parse('0.2'),
          });
    });
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/desempenho',
      size: const Size(1280, 2400),
      () async {
        await app.pumpUntil(find.byKey(const Key('returns-table')));
        await app.tap(find.byKey(const Key('perf-tab-risk')));
        await app.pumpUntil(find.byKey(const Key('risk-assets')));
        // 1 ano: um salto de 40 para 44 (sem queda), com o CDI guardado.
        expect(inKey('risk-vol', 'a.a.'), findsOneWidget);
        expect(inKey('risk-dd', 'Sem queda no período'), findsOneWidget);
        expect(inKey('risk-sharpe', 'indisponível'), findsNothing);
        expect(inKey('risk-beta', 'indisponível'), findsOneWidget);
        expect(cellOf(tester, 'risk-vol-PETR4'), endsWith('a.a.'));
        // Um ativo só: concentração total.
        expect(inKey('risk-largest', '100,00%'), findsOneWidget);
        expect(inKey('risk-largest', 'PETR4'), findsOneWidget);
        expect(inKey('risk-hhi', '1'), findsWidgets);
        expect(cellOf(tester, 'risk-fx-BRL'), '100,00%');
        expect(
          cellOf(tester, 'risk-liquidity-Diária (padrão da classe)'),
          '100,00%',
        );
        // Alvo 80% em ações e 20% em FIIs; hoje tudo em ações (R$ 6.600).
        expect(cellOf(tester, 'target-now-stock_br'), '100,00%');
        expect(cellOf(tester, 'target-diff-stock_br'), '+20,00 p.p.');
        expect(cellOf(tester, 'target-gap-stock_br'), r'−R$ 1.320,00');
        expect(cellOf(tester, 'target-gap-fii'), r'+R$ 1.320,00');

        // Soma diferente de 100%: não grava.
        await app.tap(find.byKey(const Key('risk-targets-edit')));
        await tester.enterText(
          find.byKey(const Key('target-field-stock_br')),
          '90',
        );
        await app.tap(find.text('Salvar'));
        expect(find.textContaining('está em 110,00%'), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(find.byKey(const Key('target-field-fii')), '10');
        await app.tap(find.text('Salvar'));
        expect(find.byType(AlertDialog), findsNothing);
        await app.pumpUntil(find.text(r'−R$ 660,00'));
        expect(cellOf(tester, 'target-gap-stock_br'), r'−R$ 660,00');
      },
    );
  });

  testWidgets('sem operações: indisponível com o motivo', (tester) async {
    final app = AppHarness(tester, f.t);
    await app.run(location: '/desempenho', () async {
      await app.pumpUntil(find.byKey(const Key('returns-unavailable')));
      expect(find.textContaining('datas reais'), findsOneWidget);
    });
  });
}
