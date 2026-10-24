import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/application/portfolio/portfolio_query.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/presentation/providers.dart';
import 'package:patrion/presentation/widgets/common.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Números e rótulos coerentes (M-12), no cenário da carteira real: a
/// posição lançada num dia pelo preço médio da corretora (já com ganho) e
/// uma compra no dia seguinte, com dois dias de histórico.
void main() {
  late PortfolioFixture f;

  setUp(() async => f = await PortfolioFixture.open());
  tearDown(() => f.t.close());

  /// PETR4: 100 cotas a R$ 20 em 22/10/2026 (fechamento de R$ 24) e 10 a
  /// R$ 25 em 23/10 (fechamento de R$ 25), com R$ 5 de dividendos em 23/10.
  /// CDI publicado até 22/10; IPCA até 09/2026.
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
      f.draft(OperationType.buy, '2026-10-22', qty: '100', price: '20'),
    );
    await f.add(
      f.draft(OperationType.buy, '2026-10-23', qty: '10', price: '25'),
    );
    await f.add(f.draft(OperationType.dividend, '2026-10-23', gross: '5'));
    PriceBar bar(String date, String close) => PriceBar(
      symbol: 'PETR4',
      market: 'B3',
      refDate: LocalDate.parse(date),
      close: Decimal.parse(close),
      currency: 'BRL',
      source: 'b3_cotahist',
      dataType: MarketDataType.close,
      collectedAt: '2026-10-23T21:00:00.000Z',
    );
    final repo = MarketRepository(f.t.db);
    await repo.savePrices([bar('2026-10-22', '24'), bar('2026-10-23', '25')]);
    await repo.saveIndicators([
      for (final d in ['2026-10-21', '2026-10-22'])
        IndicatorPoint(
          series: IndicatorSeries.cdi,
          refDate: LocalDate.parse(d),
          value: Decimal.parse('0.05'),
          source: 'bcb_sgs',
          collectedAt: '2026-10-23T12:00:00.000Z',
        ),
      IndicatorPoint(
        series: IndicatorSeries.ipca,
        refDate: LocalDate(2026, 9, 1),
        value: Decimal.parse('0.4'),
        source: 'ibge_sidra',
        collectedAt: '2026-10-23T12:00:00.000Z',
      ),
    ]);
  }

  /// Hoje é 23/10/2026, à noite.
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

  Finder inKey(String key, String text) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.textContaining(text),
  );

  /// O motivo do "indisponível" dentro de [key].
  String reasonIn(WidgetTester tester, String key) => tester
      .widget<Tooltip>(
        find.ancestor(
          of: inKey(key, 'indisponível'),
          matching: find.byType(Tooltip),
        ),
      )
      .message!;

  testWidgets('o ganho é um só: cartão, título do gráfico em "Tudo" e '
      'Carteira; aporte não é ganho; datas reais de início', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    // Patrimônio 110 × 25 = 2.750; aplicado 2.000 + 250 = 2.250; ganho
    // total = 2.750 − 2.250 + 5 = 505 (22,44% de 2.250).
    const gain = r'+R$ 505,00 (+22,44%)';
    await app.run(size: const Size(1280, 2400), overrides: today, () async {
      await app.pumpUntil(find.byKey(const Key('wealth-title')));
      expect(inKey('stat-equity', r'R$ 2.750,00'), findsOneWidget);
      expect(inKey('stat-applied', r'R$ 2.250,00'), findsOneWidget);
      expect(inKey('stat-gain', gain), findsOneWidget);
      // O gráfico em "Tudo" (padrão com pouco histórico) diz o mesmo
      // ganho, não o crescimento de 2.400 para 2.750 (que inclui o aporte).
      final title = tester
          .widget<Text>(find.byKey(const Key('wealth-title')))
          .data!;
      expect(
        title,
        r'Ganho de R$ 505,00 desde 22/10/2026, início dos registros',
      );
      // Total aplicado em degraus, com o degrau entre os dois dias.
      final chart = tester.widget<LineChart>(
        find.descendant(
          of: find.byKey(const Key('wealth')),
          matching: find.byType(LineChart),
        ),
      );
      final applied = chart.data.lineBarsData[1];
      expect(applied.isStepLineChart, isTrue);
      expect(applied.lineChartStepData.stepDirection, 0.5);
      expect(applied.spots.map((s) => s.y), [2000, 2250]);
      // Rentabilidade no ano: desde o início real dos dados.
      expect(
        inKey('stat-ytd', 'desde 22/10/2026, início dos registros'),
        findsOneWidget,
      );
      expect(inKey('stat-ytd', '31/12/2025'), findsNothing);
      // Aportes: o saldo inicial conta, e o texto diz isso.
      expect(
        tester
            .widget<InfoIcon>(find.byKey(const Key('dash-contributions-info')))
            .message,
        contains(r'em 12 meses R$ 2.250,00'),
      );
      expect(
        inKey('dash-contributions', 'inclusive o saldo inicial'),
        findsOneWidget,
      );
      // Altas e baixas: a data do fechamento de referência.
      expect(find.byKey(Key('mover-ref-${f.petr}')), findsOneWidget);
      expect(inKey('dash-movers', 'fechamento de 22/10/2026'), findsOneWidget);
      // TIR com 1 dia: indisponível, com o motivo.
      expect(reasonIn(tester, 'stat-mwr'), contains('30 dias'));

      // A Carteira mostra o mesmo ganho total.
      await app.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Carteira'),
        ),
      );
      await app.pumpUntil(find.byKey(const Key('portfolio-gain-BRL')));
      expect(inKey('portfolio-totals-BRL', gain), findsOneWidget);
    });
  });

  testWidgets('Rentabilidade de 2 dias: CDI e IPCA ainda não publicados e '
      'TIR curta dizem o motivo', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(
      location: '/painel/rentabilidade',
      overrides: today,
      () async {
        await app.pumpUntil(find.byKey(const Key('returns-table')));
        // Nenhum dia do CDI publicado depois de 22/10: não é 0,00%.
        expect(inKey('returns-cdi', '0,00%'), findsNothing);
        expect(find.byKey(const Key('returns-2026-cdi')), findsNothing);
        expect(
          reasonIn(tester, 'returns-cdi'),
          contains('depois de 22/10/2026 ainda não foi publicado'),
        );
        expect(
          reasonIn(tester, 'returns-real'),
          contains('IPCA de 10/2026 ainda não foi publicado'),
        );
        expect(reasonIn(tester, 'returns-mwr'), contains('30 dias'));
        expect(
          inKey('returns-twr', '22/10/2026 (início dos registros)'),
          findsOneWidget,
        );
      },
    );
  });
}
