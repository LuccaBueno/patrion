import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/data/repositories/market_repository.dart';
import 'package:patrion/domain/finance/business_calendar.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';

import '../helpers/app_harness.dart';
import '../helpers/portfolio_fixture.dart';

/// Painel com a evolução patrimonial em destaque (M-09).
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
        sector: 'Petróleo',
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

  /// O texto com a chave [key] contém [text].
  Finder textOf(String key, String text) => find.byWidgetPredicate(
    (w) => w is Text && w.key == Key(key) && (w.data ?? '').contains(text),
  );

  testWidgets('evolução em destaque: patrimônio acima do aplicado, título em '
      'forma de resposta, comparação com o CDI em R\$ e em %, valores do '
      'último dia iguais aos da Carteira', (tester) async {
    await tester.runAsync(seed);
    final app = AppHarness(tester, f.t);
    await app.run(size: const Size(1280, 2000), () async {
      await app.pumpUntil(find.byKey(const Key('wealth-title')));
      // Faixa: patrimônio 150 × 44 = 6.600 (como na Carteira); aplicado
      // 3.000 + 1.500; ganho 2.100 (46,67%); no ano, 6.000 → 6.600.
      expect(inKey('stat-equity', r'R$ 6.600,00'), findsOneWidget);
      expect(inKey('stat-applied', r'R$ 4.500,00'), findsOneWidget);
      expect(inKey('stat-gain', r'+R$ 2.100,00 (+46,67%)'), findsOneWidget);
      expect(inKey('stat-ytd', '+10,00%'), findsOneWidget);

      // 1 ano: de 6.000 a 6.600, sem aportes: o ganho no período.
      expect(
        textOf('wealth-title', r'Ganho de R$ 600,00 no período (em 1 ano)'),
        findsOneWidget,
      );
      expect(
        textOf('wealth-subtitle', r'R$ 0,00 de aportes líquidos'),
        findsOneWidget,
      );
      LineChart chart() => tester.widget<LineChart>(
        find.descendant(
          of: find.byKey(const Key('wealth')),
          matching: find.byType(LineChart),
        ),
      );
      // Patrimônio (área) e aplicado (degraus); o último ponto = Carteira.
      expect(chart().data.lineBarsData, hasLength(2));
      expect(chart().data.lineBarsData.first.spots.last.y, 6600);
      expect(chart().data.lineBarsData[1].isStepLineChart, isTrue);
      expect(chart().data.lineBarsData[1].spots.last.y, 4500);

      // Tudo: desde a primeira compra, com o aporte de 2025.
      await app.tap(find.byKey(const Key('wealth-period-Tudo')));
      // Tudo: o mesmo ganho total do cartão (M-12), não o crescimento.
      expect(
        textOf(
          'wealth-title',
          r'Ganho de R$ 2.100,00 desde 10/01/2024, início dos registros',
        ),
        findsOneWidget,
      );
      expect(chart().data.lineBarsData.first.spots.first.y, 3000);
      final bar = chart().data.lineBarsData.first;
      final tip = chart().data.lineTouchData.touchTooltipData
          .getTooltipItems([LineBarSpot(bar, 0, bar.spots.last)])
          .single!
          .text;
      expect(tip, contains(r'Patrimônio R$ 6.600,00'));
      expect(tip, contains(r'Aplicado R$ 4.500,00'));
      expect(tip, contains(r'Ganho +R$ 2.100,00 (+46,67%)'));

      // Comparar com o CDI (padrão ao ligar): linha simulada, rotulada.
      await app.tap(find.byKey(const Key('compare-toggle')));
      expect(chart().data.lineBarsData, hasLength(3));
      expect(find.text('CDI (simulação)'), findsOneWidget);
      expect(find.textContaining('simulação hipotética'), findsOneWidget);
      final withCdi = chart().data.lineTouchData.touchTooltipData
          .getTooltipItems([
            LineBarSpot(bar, 0, chart().data.lineBarsData.first.spots.last),
          ])
          .single!
          .text;
      expect(withCdi, contains('CDI R\$'));
      expect(withCdi, contains('· carteira'));
      // Sem dados do Ibovespa: a caixa fica desabilitada, com o motivo.
      final ibov = tester.widget<Checkbox>(
        find.byKey(const Key('compare-ibov')),
      );
      expect(ibov.onChanged, isNull);

      // Em %: TWR da carteira contra o CDI, os dois a partir de 0%.
      await app.tap(find.text('%'));
      expect(textOf('wealth-title', 'Sua carteira rendeu'), findsOneWidget);
      expect(textOf('wealth-subtitle', 'CDI +'), findsOneWidget);
      final pct = chart().data.lineBarsData;
      expect(pct.first.spots.first.y, 0);
      expect(pct.last.spots.first.y, 0);
      expect(find.text('Carteira (TWR)'), findsOneWidget);
    });
  });

  testWidgets('sem operações com data antiga, o gráfico explica por que o '
      'histórico é curto', (tester) async {
    await tester.runAsync(() async {
      await seed();
      // Só o saldo de hoje: apaga o histórico de compras.
      for (final o in await f.repos.operations.all()) {
        await f.operations.delete(o.id);
      }
      await f.add(
        f.draft(OperationType.buy, '2026-10-16', qty: '10', price: '44'),
      );
    });
    final app = AppHarness(tester, f.t);
    await app.run(size: const Size(1280, 2000), () async {
      await app.pumpUntil(find.byKey(const Key('wealth-title')));
      expect(
        find.textContaining('registre as compras com as datas reais'),
        findsOneWidget,
      );
    });
  });

  testWidgets('faixa compacta de câmbio e indicadores no rodapé; o clique '
      'leva a Fontes de dados', (tester) async {
    await tester.runAsync(() async {
      await seed();
      await MarketRepository(f.t.db).saveFx([
        FxRate(
          base: 'USD',
          quote: 'BRL',
          refDate: LocalDate(2026, 10, 16),
          kind: FxKind.ptaxClose,
          source: 'bcb_ptax',
          collectedAt: '2026-10-17T12:00:00.000Z',
          ask: Decimal.parse('5.4321'),
        ),
      ]);
    });
    final app = AppHarness(tester, f.t);
    await app.run(size: const Size(1280, 3000), () async {
      await app.pumpUntil(find.byKey(const Key('market-strip')));
      expect(find.byKey(const Key('market-overview')), findsNothing);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('strip-USD')))
            .textSpan!
            .toPlainText(),
        r'USD R$ 5,4321',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('strip-CDI')))
            .textSpan!
            .toPlainText(),
        // 0,04% ao dia útil: 1,0004^252 − 1.
        'CDI 10,60% a.a.',
      );
      await app.tap(find.byKey(const Key('market-strip')));
      expect(find.byKey(const Key('market-overview')), findsOneWidget);
    });
  });
}
