import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/wealth_service.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/benchmark.dart';
import '../../../domain/finance/benchmark_comparison.dart';
import '../../../domain/finance/returns.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/portfolio/performance_report.dart';
import '../../format/labels.dart';
import '../../format/formatters.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/date_axis.dart';
import '../dashboard/dashboard_charts.dart';
import '../dashboard/wealth_chart.dart';
import 'returns_tab.dart';

/// Como mostrar cada índice (SPEC §12.5: fonte, moeda e metodologia).
extension BenchmarkIndexText on BenchmarkIndex {
  String get label => switch (this) {
    BenchmarkIndex.cdi => 'CDI',
    BenchmarkIndex.selic => 'Selic',
    BenchmarkIndex.ipca => 'IPCA',
    BenchmarkIndex.igpm => 'IGP-M',
    BenchmarkIndex.ibovespa => 'Ibovespa',
    BenchmarkIndex.ifix => 'IFIX',
    BenchmarkIndex.btc => 'Bitcoin',
    BenchmarkIndex.sp500 => 'S&P 500',
    BenchmarkIndex.nasdaq => 'Nasdaq',
    BenchmarkIndex.ima => 'IMA (ANBIMA)',
    BenchmarkIndex.idka => 'IDkA (ANBIMA)',
  };

  String get source => switch (this) {
    BenchmarkIndex.cdi => 'Banco Central (SGS 12)',
    BenchmarkIndex.selic => 'Banco Central (SGS 11)',
    BenchmarkIndex.ipca => 'Banco Central (SGS 433) ou IBGE',
    BenchmarkIndex.igpm => 'Banco Central (SGS 189)',
    BenchmarkIndex.ibovespa || BenchmarkIndex.ifix => 'B3',
    BenchmarkIndex.btc => 'Binance (BTC/USDT) × PTAX',
    BenchmarkIndex.sp500 || BenchmarkIndex.nasdaq => 'Yahoo × PTAX',
    BenchmarkIndex.ima || BenchmarkIndex.idka => 'ANBIMA',
  };

  String get currency => inUsd ? r'US$ → R$' : r'R$';

  String get methodology => switch (this) {
    BenchmarkIndex.cdi =>
      'Taxa diária publicada, acumulada dia útil a dia útil.',
    BenchmarkIndex.selic =>
      'Selic efetiva diária publicada, acumulada dia útil a dia útil.',
    BenchmarkIndex.ipca || BenchmarkIndex.igpm =>
      'Variação mensal publicada, distribuída pelos dias do mês; para no '
          'último mês publicado.',
    BenchmarkIndex.ibovespa =>
      'Pontos de fechamento. Índice de retorno total: considera os '
          'proventos reinvestidos.',
    BenchmarkIndex.ifix =>
      'Pontos de fechamento. Índice de retorno total: considera os '
          'rendimentos reinvestidos.',
    BenchmarkIndex.btc =>
      'Fechamento diário do par BTC/USDT na Binance (00h UTC), convertido '
          'para reais pela PTAX do dia (calculado pelo app; o USDT é tratado '
          'como dólar). Preço de uma corretora, não um índice.',
    BenchmarkIndex.sp500 || BenchmarkIndex.nasdaq =>
      'Pontos de fechamento, sem dividendos (índice de preço), convertidos '
          'para reais pela PTAX do dia (calculado pelo app). Fonte não '
          'oficial.',
    BenchmarkIndex.ima ||
    BenchmarkIndex.idka => 'Índices de renda fixa da ANBIMA.',
  };
}

/// Desempenho → Benchmarks (F8, parte 2; `docs/FORMULAS.md` §3.5): a
/// carteira contra cada índice no período escolhido.
class BenchmarksTab extends ConsumerStatefulWidget {
  const BenchmarksTab({
    required this.overview,
    required this.period,
    required this.from,
    required this.to,
    super.key,
  });

  final WealthOverview overview;
  final PerformancePeriod period;
  final LocalDate from;
  final LocalDate to;

  @override
  ConsumerState<BenchmarksTab> createState() => _BenchmarksTabState();
}

class _BenchmarksTabState extends ConsumerState<BenchmarksTab> {
  /// Índices no gráfico (no máximo [_maxBenchmarksShown]).
  final _shown = <BenchmarkIndex>{BenchmarkIndex.cdi, BenchmarkIndex.ibovespa};

  @override
  Widget build(BuildContext context) {
    final o = widget.overview;
    final states = ref.watch(providerStatesProvider).value ?? const [];
    bool enabled(String code) =>
        states.where((s) => s.info.code == code).firstOrNull?.enabled ??
        ProviderCatalog.all
            .where((p) => p.code == code)
            .firstOrNull
            ?.defaultEnabled ??
        true;

    // O intervalo efetivo da carteira (o último ponto até o início).
    final perf = PeriodPerformance.compute(
      o.series,
      from: widget.from,
      to: widget.to,
    );
    final from = perf?.from ?? widget.from;
    final to = perf?.to ?? widget.to;
    final rows = <BenchmarkIndex, BenchmarkComparison>{};
    final reasons = <BenchmarkIndex, String>{};
    for (final b in BenchmarkIndex.values) {
      final s = b.series;
      final levels = s == null ? null : o.indices[s];
      if (s == null) {
        reasons[b] =
            'A ANBIMA só publica os últimos 5 dias úteis de '
            'graça, e o histórico é pago.';
        continue;
      }
      if (levels == null || levels.isEmpty) {
        reasons[b] =
            (b == BenchmarkIndex.sp500 || b == BenchmarkIndex.nasdaq) &&
                !enabled(ProviderCatalog.yahoo.code)
            ? 'Fonte desligada: ative o Yahoo (não oficial) em Configurações '
                  '→ Fontes de dados e atualize.'
            : 'Sem dados guardados. Use "Atualizar agora" em Configurações → '
                  'Fontes de dados.';
        continue;
      }
      if (b.inUsd && o.usdToBrl.isEmpty) {
        reasons[b] = 'Falta a PTAX do dólar para converter para reais.';
        continue;
      }
      final c = BenchmarkComparison.compute(
        b,
        levels: levels,
        series: o.series,
        from: from,
        to: to,
        usdToBrl: o.usdToBrl,
      );
      if (c == null) {
        final first = (b.inUsd ? levels.inBrl(o.usdToBrl) : levels).first;
        reasons[b] = first == null
            ? 'Sem dados no período.'
            : 'Dados guardados só desde ${Fmt.date(first)}, depois do início '
                  'do período.';
      } else {
        rows[b] = c;
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (perf != null)
          _ChartCard(
            overview: o,
            from: from,
            to: to,
            rows: rows,
            shown: [
              for (final b in BenchmarkIndex.values)
                if (_shown.contains(b) && rows.containsKey(b)) b,
            ],
            onToggle: (b) => setState(() {
              if (_shown.remove(b)) return;
              // Os escolhidos sem dados no período não contam.
              _shown.removeWhere((s) => !rows.containsKey(s));
              if (_shown.length < _maxBenchmarksShown) _shown.add(b);
            }),
            canAdd: _shown.where(rows.containsKey).length < _maxBenchmarksShown,
          ),
        const SizedBox(height: 16),
        _Table(perf: perf, rows: rows, reasons: reasons),
        const SizedBox(height: 12),
        ...notesOf(context, [
          'Cada índice é comparado com a carteira no mesmo intervalo: do fim de '
              '${Fmt.date(from)} até o último dia com dado do índice. A carteira '
              'usa o TWR (proventos como retorno). Índices em dólar são '
              'convertidos para reais pela PTAX do dia, e o retorno em dólar '
              'aparece embaixo. Comparação histórica, não é previsão nem '
              'recomendação.',
        ]),
      ],
    );
  }
}

/// Índices no gráfico ao mesmo tempo: acima disso as linhas de referência,
/// todas em cinza, ficam difíceis de distinguir.
const _maxBenchmarksShown = 4;

/// Linha de referência de cada índice: sempre o mesmo tom e o mesmo
/// tracejado, qualquer que seja a posição na lista (a cor segue o índice).
(Color, List<int>) _style(BuildContext context, BenchmarkIndex b) {
  final scheme = Theme.of(context).colorScheme;
  final strong = scheme.onSurface.withValues(alpha: 0.8);
  final mid = scheme.onSurfaceVariant;
  final light = scheme.outline;
  return switch (b) {
    BenchmarkIndex.cdi => (mid, const [5, 3]),
    BenchmarkIndex.selic => (light, const [8, 2, 2, 2]),
    BenchmarkIndex.ipca => (light, const [10, 4]),
    BenchmarkIndex.igpm => (mid, const [6, 6]),
    BenchmarkIndex.ibovespa => (strong, const [2, 3]),
    BenchmarkIndex.ifix => (strong, const [1, 2]),
    BenchmarkIndex.btc => (mid, const [12, 3, 3, 3]),
    BenchmarkIndex.sp500 => (strong, const [4, 2]),
    BenchmarkIndex.nasdaq => (light, const [3, 6]),
    BenchmarkIndex.ima || BenchmarkIndex.idka => (light, const [2, 2]),
  };
}

/// Gráfico em base 100: a carteira (TWR) e os índices escolhidos.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.overview,
    required this.from,
    required this.to,
    required this.rows,
    required this.shown,
    required this.onToggle,
    required this.canAdd,
  });

  final WealthOverview overview;
  final LocalDate from;
  final LocalDate to;
  final Map<BenchmarkIndex, BenchmarkComparison> rows;
  final List<BenchmarkIndex> shown;
  final ValueChanged<BenchmarkIndex> onToggle;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final axis = DateAxis(from, to);
    final carteira = IndexLevels.normalize(
      overview.series.twrIndex(),
      from,
      to,
    );
    final lines = <BenchmarkIndex, List<(LocalDate, Decimal)>>{
      for (final b in shown)
        b:
            (b.inUsd
                    ? overview.indices[b.series]!.inBrl(overview.usdToBrl)
                    : overview.indices[b.series]!)
                .normalized(from, rows[b]!.to),
    };
    // Em double só para desenhar (regra 6, exceção).
    List<FlSpot> spots(List<(LocalDate, Decimal)> s) => [
      for (final (d, v) in s) FlSpot(axis.x(d), v.toDouble()),
    ];
    final all = [...spots(carteira), for (final l in lines.values) ...spots(l)];
    var minY = all.map((s) => s.y).fold(100.0, (a, b) => a < b ? a : b);
    var maxY = all.map((s) => s.y).fold(100.0, (a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.06 + 0.5;
    minY -= pad;
    maxY += pad;

    String tooltip(double x) {
      final d = axis.dateAt(x);
      String at(String name, List<(LocalDate, Decimal)> s) {
        final v = IndexLevels.levelIn(s, d);
        if (v == null) return '$name: sem dado';
        final r = DecimalMath.divide(v, Decimal.fromInt(100)) - Decimal.one;
        return '$name ${Fmt.percent(r)}';
      }

      return [
        Fmt.date(d),
        at('Carteira', carteira),
        for (final MapEntry(:key, :value) in lines.entries)
          at(key.label, value),
        'desde ${Fmt.date(from)}',
      ].join('\n');
    }

    final bars = [
      LineChartBarData(
        spots: spots(carteira),
        color: scheme.primary,
        barWidth: 2,
        dotData: const FlDotData(show: false),
      ),
      for (final MapEntry(:key, :value) in lines.entries)
        LineChartBarData(
          spots: spots(value),
          color: _style(context, key).$1,
          barWidth: 1.2,
          dashArray: _style(context, key).$2,
          dotData: const FlDotData(show: false),
        ),
    ];

    final best = rows.values.where((c) => c.difference != null).toList();
    final beaten = best
        .where((c) => c.difference! > Decimal.zero)
        .map((c) => c.index.label)
        .toList();
    return Card(
      key: const Key('bench-chart'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carteira × índices', style: muted),
            Text(
              best.isEmpty
                  ? 'Sem índices para comparar no período'
                  : beaten.isEmpty
                  ? 'A carteira ficou abaixo de todos os índices no período'
                  : 'A carteira superou ${beaten.length} de ${best.length} '
                        'índices no período',
              key: const Key('bench-title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Base 100 no fim de ${Fmt.date(from)}. Até $_maxBenchmarksShown índices '
              'por vez.',
              style: muted,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final b in BenchmarkIndex.values)
                  if (rows.containsKey(b))
                    FilterChip(
                      key: Key('bench-show-${b.name}'),
                      label: Text(b.label),
                      selected: shown.contains(b),
                      onSelected: shown.contains(b) || canAdd
                          ? (_) => onToggle(b)
                          : null,
                      tooltip: shown.contains(b) || canAdd
                          ? null
                          : 'Até $_maxBenchmarksShown índices no gráfico; desmarque um.',
                    ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: axis.x(from),
                  maxX: axis.x(to),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 100,
                        color: scheme.outline,
                        strokeWidth: 0.8,
                      ),
                    ],
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        maxIncluded: false,
                        minIncluded: false,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            compact(v),
                            style: small,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: axis.interval,
                        minIncluded: false,
                        maxIncluded: false,
                        getTitlesWidget: (v, meta) => SideTitleWidget(
                          meta: meta,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                          child: Text(axis.label(v), style: small),
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      maxContentWidth: 260,
                      getTooltipColor: (_) => scheme.inverseSurface,
                      getTooltipItems: (touched) => [
                        for (final (i, t) in touched.indexed)
                          i == 0
                              ? LineTooltipItem(
                                  tooltip(t.x),
                                  TextStyle(
                                    color: scheme.onInverseSurface,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                )
                              : null,
                      ],
                    ),
                  ),
                  lineBarsData: bars,
                ),
                duration: Duration.zero,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              key: const Key('bench-legend'),
              spacing: 16,
              runSpacing: 4,
              children: [
                _legend(context, 'Carteira (TWR)', scheme.primary, null),
                for (final b in lines.keys)
                  _legend(
                    context,
                    b.label,
                    _style(context, b).$1,
                    _style(context, b).$2,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(
    BuildContext context,
    String label,
    Color color,
    List<int>? dash,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(
        size: const Size(22, 10),
        painter: SwatchPainter(color, dash),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

/// Tabela com todos os índices: fonte, moeda, período, retornos e a
/// diferença para a carteira.
class _Table extends StatelessWidget {
  const _Table({required this.perf, required this.rows, required this.reasons});

  final PeriodPerformance? perf;
  final Map<BenchmarkIndex, BenchmarkComparison> rows;
  final Map<BenchmarkIndex, String> reasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final small = theme.textTheme.bodySmall;
    final head = small?.copyWith(color: muted, fontWeight: FontWeight.w600);
    final colors = SemanticColors.of(context);

    Widget text(String t, {TextStyle? style, TextAlign? align, Key? key}) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(t, key: key, style: style ?? small, textAlign: align),
        );
    Widget pct(Decimal? v, {Key? key, String? sub}) {
      if (v == null) return text('—', align: TextAlign.right);
      final color = v > Decimal.zero
          ? colors.gain
          : v < Decimal.zero
          ? colors.loss
          : muted;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Fmt.percent(v),
              key: key,
              style: small?.copyWith(color: color),
            ),
            if (sub != null)
              Text(
                sub,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
          ],
        ),
      );
    }

    Widget name(String label, String info) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: small?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: info,
            child: Icon(
              Icons.info_outline,
              size: 14,
              color: muted,
              semanticLabel: 'Metodologia',
            ),
          ),
        ],
      ),
    );

    final p = perf;
    return Card(
      key: const Key('bench-table'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Índices no período', style: theme.textTheme.titleMedium),
            Text(
              'Retorno acumulado, ao ano (em intervalos de mais de um ano) e a '
              'diferença da carteira para cada índice, em pontos percentuais.',
              style: small?.copyWith(color: muted),
            ),
            const SizedBox(height: 8),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(1.9),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(1.9),
                4: FlexColumnWidth(1.1),
                5: FlexColumnWidth(1.1),
                6: FlexColumnWidth(1.3),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
              children: [
                TableRow(
                  children: [
                    text('Índice', style: head),
                    text('Fonte', style: head),
                    text('Moeda', style: head),
                    text('Período', style: head),
                    text('Acumulado', style: head, align: TextAlign.right),
                    text('Ao ano', style: head, align: TextAlign.right),
                    text(
                      'Carteira − índice',
                      style: head,
                      align: TextAlign.right,
                    ),
                  ],
                ),
                if (p != null)
                  TableRow(
                    key: const ValueKey('bench-row-carteira'),
                    children: [
                      name('Carteira (TWR)', ReturnMethod.twr.description),
                      text('Operações e fechamentos guardados'),
                      text(r'R$'),
                      text('${Fmt.date(p.from)} a ${Fmt.date(p.to)}'),
                      pct(p.twr, key: const Key('bench-carteira-acc')),
                      pct(p.cagr),
                      text('—', align: TextAlign.right),
                    ],
                  ),
                for (final b in BenchmarkIndex.values)
                  if (rows[b] case final c?)
                    TableRow(
                      key: ValueKey('bench-row-${b.name}'),
                      children: [
                        name(b.label, b.methodology),
                        text(b.source),
                        text(b.currency),
                        text('${Fmt.date(c.from)} a ${Fmt.date(c.to)}'),
                        pct(
                          c.value,
                          key: Key('bench-${b.name}-acc'),
                          sub: c.original == null
                              ? null
                              : 'em US\$ ${Fmt.percent(c.original!)}',
                        ),
                        pct(c.annual),
                        c.difference == null
                            ? text('—', align: TextAlign.right)
                            : text(
                                pointsDiff(c.difference!),
                                key: Key('bench-${b.name}-diff'),
                                align: TextAlign.right,
                              ),
                      ],
                    )
                  else
                    TableRow(
                      key: ValueKey('bench-row-${b.name}'),
                      children: [
                        name(b.label, b.methodology),
                        text(b.source),
                        text(b.currency),
                        // Sem coluna mesclada na tabela: o motivo fica embaixo
                        // de "indisponível", na coluna mais larga.
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'indisponível',
                                key: Key('bench-${b.name}-unavailable'),
                                style: small?.copyWith(
                                  color: muted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                reasons[b] ?? '',
                                key: Key('bench-${b.name}-reason'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
