import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/portfolio/dashboard_metrics.dart';
import '../../../domain/portfolio/portfolio_summary.dart';
import '../../format/formatters.dart';
import '../../widgets/common.dart';

/// Cores das séries, em ordem fixa (nunca reaproveitadas em ciclo): a
/// paleta categórica validada do guia de visualização, com os tons do tema
/// escuro (DECISIONS D-46). Passou de 7 fatias, o resto vira "Outros".
abstract final class ChartColors {
  static const _light = [
    Color(0xFF2A78D6),
    Color(0xFFEB6834),
    Color(0xFF1BAF7A),
    Color(0xFFEDA100),
    Color(0xFFE87BA4),
    Color(0xFF008300),
    Color(0xFF6250D6),
  ];
  static const _dark = [
    Color(0xFF3987E5),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFFD55181),
    Color(0xFF008300),
    Color(0xFF9085E9),
  ];

  static const maxSlices = 7;

  static Color of(BuildContext context, int i) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return (dark ? _dark : _light)[i % maxSlices];
  }

  /// "Outros": cinza neutro, fora da paleta.
  static Color other(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
}

/// Cartão com título, subtítulo e conteúdo.
class DashCard extends StatelessWidget {
  const DashCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Distribuição em rosca, com a legenda (nome, % e valor) ao lado: a cor
/// nunca é o único indicador.
class DonutCard extends StatelessWidget {
  const DonutCard({
    required this.title,
    required this.slices,
    required this.currency,
    this.subtitle,
    this.trailing,
    this.center,
    this.header,
    this.size = 132,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<AllocationSlice<String?>> slices;
  final String currency;
  final Widget? trailing;

  /// Conteúdo acima da rosca (o seletor da distribuição).
  final Widget? header;

  /// Texto no meio da rosca (o total, por exemplo).
  final String? center;

  /// Diâmetro da rosca.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Até 7 fatias; o resto vira "Outros".
    final shown = slices.take(ChartColors.maxSlices - 1).toList();
    final rest = slices.skip(ChartColors.maxSlices - 1).toList();
    final items = <(String, Decimal, Decimal, Color)>[
      for (final (i, s) in shown.indexed)
        (s.key ?? 'Caixa', s.value, s.fraction, ChartColors.of(context, i)),
      if (rest.length == 1)
        (
          rest.single.key ?? 'Caixa',
          rest.single.value,
          rest.single.fraction,
          ChartColors.of(context, ChartColors.maxSlices - 1),
        )
      else if (rest.isNotEmpty)
        (
          'Outros (${rest.length})',
          rest.fold(Decimal.zero, (a, s) => a + s.value),
          rest.fold(Decimal.zero, (a, s) => a + s.fraction),
          ChartColors.other(context),
        ),
    ];
    final Widget content = items.isEmpty
        ? const SizedBox(
            height: 140,
            child: Center(
              child: UnavailableText(
                tooltip: 'Informe preços ou saldos para ver a distribuição.',
              ),
            ),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: size / 2 - 22,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                        sections: [
                          for (final (_, _, f, color) in items)
                            PieChartSectionData(
                              // Conversão para desenho apenas (regra 6).
                              value: f.toDouble(),
                              color: color,
                              radius: 20,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    if (center != null)
                      SizedBox(
                        width: size - 56,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            center!,
                            key: const Key('donut-center'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (final (label, value, f, color) in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              Fmt.percent(f, signed: false),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 104,
                              child: Text(
                                Fmt.money(value, currency),
                                textAlign: TextAlign.end,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
    return DashCard(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      child: header == null
          ? content
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header!, const SizedBox(height: 12), content],
            ),
    );
  }
}

/// Uma série de barras por mês.
class BarSeries {
  const BarSeries(this.label, this.valueOf, {this.colorOf});

  final String label;
  final Decimal Function(MonthFlow) valueOf;

  /// Cor da série (padrão: a paleta, na ordem das séries).
  final Color Function(BuildContext)? colorOf;

  Color color(BuildContext context, int i) =>
      colorOf?.call(context) ?? ChartColors.of(context, i);
}

/// Barras por mês (últimos 12), uma ou mais séries lado a lado, com legenda
/// e o valor de cada barra no tooltip.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({
    required this.months,
    required this.series,
    required this.currency,
    super.key,
  });

  final List<MonthFlow> months;
  final List<BarSeries> series;
  final String currency;

  static const _names = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static String monthLabel(MonthFlow m) =>
      '${_names[m.month - 1]}/${(m.year % 100).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    // Conversão para desenho apenas (regra 6).
    var maxY = 0.0;
    for (final m in months) {
      for (final s in series) {
        final v = s.valueOf(m).toDouble();
        if (v > maxY) maxY = v;
      }
    }
    final width = series.length == 1 ? 14.0 : 8.0;
    if (maxY <= 0) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('Nada registrado nos últimos 12 meses.', style: small),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (series.length > 1)
          Wrap(
            spacing: 16,
            children: [
              for (final (i, s) in series.indexed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color(context, i),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(s.label, style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: BarChart(
            BarChartData(
              maxY: maxY <= 0 ? 1 : maxY * 1.1,
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    maxIncluded: false,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        Fmt.hideMoney ? Fmt.hidden : compact(v),
                        style: small,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        (months.length - 1 - v.toInt()) % 2 == 1 ||
                                v.toInt() >= months.length
                            ? ''
                            : monthLabel(months[v.toInt()]),
                        style: small,
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  getTooltipItem: (group, _, rod, rodIndex) => BarTooltipItem(
                    '${monthLabel(months[group.x])} · '
                    '${series[rodIndex].label}\n'
                    '${Fmt.money(series[rodIndex].valueOf(months[group.x]), currency)}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                  ),
                ),
              ),
              barGroups: [
                for (final (x, m) in months.indexed)
                  BarChartGroupData(
                    x: x,
                    barsSpace: 2,
                    barRods: [
                      for (final (i, s) in series.indexed)
                        BarChartRodData(
                          toY: s.valueOf(m).toDouble(),
                          width: width,
                          color: s.color(context, i),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Rótulo curto do eixo: "20 mil", "1,5 mi".
String compact(double v) {
  final abs = v.abs();
  String one(double x) {
    final rounded = (x * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1).replaceAll('.', ',');
  }

  if (abs >= 1e6) return '${one(v / 1e6)} mi';
  if (abs >= 1e3) return '${one(v / 1e3)} mil';
  return one(v);
}

/// Uma visão da distribuição (por ativo, classe, setor ou corretora).
class DistributionView {
  const DistributionView(this.label, this.slices, {this.subtitle});

  final String label;
  final List<AllocationSlice<String?>> slices;
  final String? subtitle;
}

/// Distribuição numa rosca só, com seletor, o total no centro e a lista de
/// percentuais ao lado (M-09).
class DistributionCard extends StatefulWidget {
  const DistributionCard({
    required this.views,
    required this.total,
    required this.currency,
    super.key,
  });

  final List<DistributionView> views;
  final Decimal total;
  final String currency;

  @override
  State<DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<DistributionCard> {
  var _index = 0;

  static String _plural(String label, int n) {
    final word = label.toLowerCase();
    if (n == 1) return word;
    return switch (word) {
      'setor' => 'setores',
      'classe' => 'classes',
      _ => '${word}s',
    };
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.views[_index];
    final top = view.slices.isEmpty ? null : view.slices.first;
    return DonutCard(
      key: const Key('distribution'),
      title: top == null
          ? 'Distribuição'
          : '${top.key ?? 'Caixa'} é ${Fmt.percent(top.fraction, signed: false)} '
                'do patrimônio',
      subtitle: view.subtitle ?? 'Por ${view.label.toLowerCase()}',
      currency: widget.currency,
      slices: view.slices,
      size: 112,
      // A contagem, não o total: o patrimônio já está no topo (M-11).
      center:
          '${view.slices.length} ${_plural(view.label, view.slices.length)}',
      header: SegmentedButton<int>(
        key: const Key('distribution-by'),
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: [
          for (final (i, v) in widget.views.indexed)
            ButtonSegment(
              value: i,
              label: Text(v.label, key: Key('dist-${v.label}')),
            ),
        ],
        selected: {_index},
        onSelectionChanged: (s) => setState(() => _index = s.single),
      ),
    );
  }
}
