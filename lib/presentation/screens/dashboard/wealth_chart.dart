import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../application/portfolio/wealth_service.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/benchmark.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/wealth_history.dart';
import '../../format/formatters.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/date_axis.dart';
import 'dashboard_charts.dart';

/// Períodos da evolução patrimonial.
enum WealthPeriod {
  sixMonths('6M', 183, 'em 6 meses'),
  year('1A', 366, 'em 1 ano'),
  fiveYears('5A', 1827, 'em 5 anos'),
  all('Tudo', null, null);

  const WealthPeriod(this.label, this.days, this.phrase);

  final String label;
  final int? days;
  final String? phrase;
}

/// Mostrar valores em reais ou a rentabilidade em %.
enum WealthMode { money, percent }

/// Evolução patrimonial em destaque (M-09; SPEC §8): patrimônio dia a dia
/// (área), total aplicado (degraus), marcadores de aporte e, opcionalmente,
/// a comparação com CDI, Ibovespa e IPCA (simulação hipotética, regra 3).
class WealthChartCard extends StatefulWidget {
  const WealthChartCard({
    required this.overview,
    required this.height,
    this.assets = const {},
    super.key,
  });

  /// Nulo enquanto calcula.
  final WealthOverview? overview;
  final double height;

  /// Cadastro dos ativos (nomes nas notas).
  final Map<String, Asset> assets;

  @override
  State<WealthChartCard> createState() => _WealthChartCardState();
}

class _WealthChartCardState extends State<WealthChartCard> {
  WealthPeriod? _period;
  bool _compare = false;
  final _indices = <IndicatorSeries>{IndicatorSeries.cdi};
  WealthMode _mode = WealthMode.money;

  static const _indexNames = {
    IndicatorSeries.cdi: 'CDI',
    IndicatorSeries.ibovespa: 'Ibovespa',
    IndicatorSeries.ipca: 'IPCA',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final overview = widget.overview;
    final all = overview?.series.points ?? const <WealthPoint>[];
    final today = overview?.asOf;
    final span = all.length < 2 ? 0 : all.last.date.daysSince(all.first.date);
    // Padrão: 1 ano, ou tudo se o histórico for mais curto.
    final period =
        _period ?? (span >= 366 ? WealthPeriod.year : WealthPeriod.all);
    final from = period.days == null || today == null
        ? null
        : today.addDays(-period.days!);
    final visible = [
      for (final p in all)
        if (from == null || !p.date.isBefore(from)) p,
    ];
    // O período começa no último ponto antes do início (a base).
    final baseIndex = from == null
        ? 0
        : all.lastIndexWhere((p) => p.date.isBefore(from));
    final window = baseIndex < 0 || from == null
        ? visible
        : [all[baseIndex], ...visible];

    // Simulações nos índices: a série inteira, mostrada no período.
    final sims = <IndicatorSeries, List<BenchmarkPoint>>{};
    final unavailable = <IndicatorSeries, String>{};
    for (final s in WealthOverview.compared) {
      final levels = overview?.indices[s];
      if (levels == null || levels.isEmpty) {
        unavailable[s] =
            'Sem dados de ${_indexNames[s]} guardados. Use "Atualizar agora" '
            'em Fontes de dados.';
        continue;
      }
      final sim = overview!.benchmarks[s];
      if (sim == null) {
        unavailable[s] =
            '${_indexNames[s]} guardado só desde '
            '${Fmt.date(levels.first!)}, depois do início da carteira.';
        continue;
      }
      sims[s] = sim;
    }
    final shownIndices = _compare
        ? [
            for (final s in WealthOverview.compared)
              if (_indices.contains(s) && sims.containsKey(s)) s,
          ]
        : const <IndicatorSeries>[];

    final twr = overview?.series.twrIndex() ?? const <(LocalDate, Decimal)>[];
    final header = _Header(
      period: period,
      window: window,
      mode: _mode,
      twr: twr,
      sims: {for (final s in shownIndices) s: sims[s]!},
      names: _indexNames,
      onPeriod: (p) => setState(() => _period = p),
      periodEnabled: (p) =>
          p.days == null || (span >= (p.days! * 0.5) && all.length > 1),
    );

    final controls = Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilterChip(
          key: const Key('compare-toggle'),
          label: const Text('Comparar com'),
          selected: _compare,
          onSelected: (v) => setState(() => _compare = v),
        ),
        if (_compare) ...[
          for (final s in WealthOverview.compared)
            Tooltip(
              message:
                  unavailable[s] ??
                  'Simulação: os mesmos aportes e resgates, nas mesmas datas, '
                      'aplicados no ${_indexNames[s]}.',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    key: Key('compare-${s.code}'),
                    value: _indices.contains(s) && sims.containsKey(s),
                    onChanged: sims.containsKey(s)
                        ? (v) => setState(
                            () => v == true
                                ? _indices.add(s)
                                : _indices.remove(s),
                          )
                        : null,
                  ),
                  Text(_indexNames[s]!),
                ],
              ),
            ),
          SegmentedButton<WealthMode>(
            key: const Key('wealth-mode'),
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            segments: const [
              ButtonSegment(value: WealthMode.money, label: Text('R\$')),
              ButtonSegment(value: WealthMode.percent, label: Text('%')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.single),
          ),
          Tooltip(
            message:
                'Em %: a rentabilidade da carteira pelo método TWR '
                '(ponderada pelo tempo), que mede o desempenho dos ativos sem '
                'o efeito do tamanho e da data dos aportes; os proventos '
                'contam como retorno. Carteira e índices começam em 0% no '
                'início do período.\nEm R\$: quanto você teria se os mesmos '
                'aportes e resgates, nas mesmas datas, tivessem ido para o '
                'índice.',
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
              semanticLabel: 'Sobre a comparação',
            ),
          ),
        ],
      ],
    );

    Widget body;
    if (overview == null) {
      // Texto parado (sem animação): o cálculo leva um instante.
      body = const Center(
        key: Key('wealth-loading'),
        child: Text('Calculando a evolução…'),
      );
    } else if (window.length < 2) {
      body = Center(
        key: const Key('wealth-unavailable'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UnavailableText(),
            const SizedBox(height: 4),
            Text(
              all.isEmpty
                  ? 'Registre compras para ver a evolução do patrimônio.'
                  : 'Menos de dois dias com dados neste período.',
              style: muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      body = _WealthLine(
        key: ValueKey('${period.label}-${_mode.name}-$shownIndices'),
        window: window,
        mode: _compare ? _mode : WealthMode.money,
        twr: twr,
        sims: {for (final s in shownIndices) s: sims[s]!},
        names: _indexNames,
      );
    }

    final ipcaLast = overview?.indices[IndicatorSeries.ipca]?.last;
    final notes = <String>[
      if (span < 90 && all.isNotEmpty)
        'A evolução começa na data das operações registradas '
            '(${Fmt.date(all.first.date)}). Posições lançadas como saldo '
            'inicial com a data de hoje fazem o gráfico começar hoje; para '
            'ver anos de evolução, registre as compras com as datas reais '
            '(ou aproximadas).',
      if (overview != null && overview.series.entries.isNotEmpty)
        'Sem preço antes da data e fora do patrimônio e do aplicado até lá: '
            '${overview.series.entries.entries.map((e) => '${_name(e.key)} '
                '(desde ${Fmt.date(e.value)})').join(', ')}.',
      if (overview != null && overview.series.excluded.isNotEmpty)
        'Fora da evolução, sem nenhum preço ou saldo: '
            '${overview.series.excluded.map(_name).join(', ')}.',
      if (all.isNotEmpty && all.last.missing.isNotEmpty)
        'Hoje sem preço (fora do patrimônio): '
            '${all.last.missing.map(_name).join(', ')}.',
      if (shownIndices.isNotEmpty)
        'Linhas dos índices: simulação hipotética, com os mesmos aportes e '
            'resgates nas mesmas datas; não é previsão nem recomendação. Os '
            'proventos não entram nas linhas em R\$.',
      if (shownIndices.contains(IndicatorSeries.ipca) && ipcaLast != null)
        'IPCA até ${Fmt.monthYear(ipcaLast)} (meses seguintes ainda sem '
            'publicação: a linha fica parada).',
    ];

    return Card(
      key: const Key('wealth-card'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 8),
            controls,
            const SizedBox(height: 8),
            SizedBox(height: widget.height, child: body),
            const SizedBox(height: 6),
            _Legend(
              mode: _compare ? _mode : WealthMode.money,
              indices: shownIndices,
              names: _indexNames,
            ),
            for (final n in notes)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(n, style: muted),
              ),
          ],
        ),
      ),
    );
  }

  String _name(String assetId) => widget.assets[assetId]?.symbol ?? assetId;
}

/// Título em forma de resposta e o seletor de período.
class _Header extends StatelessWidget {
  const _Header({
    required this.period,
    required this.window,
    required this.mode,
    required this.twr,
    required this.sims,
    required this.names,
    required this.onPeriod,
    required this.periodEnabled,
  });

  final WealthPeriod period;
  final List<WealthPoint> window;
  final WealthMode mode;
  final List<(LocalDate, Decimal)> twr;
  final Map<IndicatorSeries, List<BenchmarkPoint>> sims;
  final Map<IndicatorSeries, String> names;
  final ValueChanged<WealthPeriod> onPeriod;
  final bool Function(WealthPeriod) periodEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    String? title;
    String? subtitle;
    if (window.length >= 2) {
      final a = window.first;
      final b = window.last;
      final phrase = period.phrase ?? 'desde ${Fmt.date(a.date)}';
      final change = b.value - a.value;
      final added = b.invested - a.invested;
      final gain = change - added;
      if (mode == WealthMode.percent && sims.isNotEmpty) {
        final r = _twrBetween(twr, a.date, b.date);
        title = r == null
            ? 'Rentabilidade $phrase indisponível'
            : 'Sua carteira rendeu ${Fmt.percent(r)} $phrase';
        subtitle = [
          for (final MapEntry(:key, :value) in sims.entries)
            if (_cumulativeBetween(value, a.date, b.date) case final c?)
              '${names[key]} ${Fmt.percent(c)}',
        ].join(' · ');
      } else {
        title =
            'Seu patrimônio ${change >= Decimal.zero ? 'cresceu' : 'caiu'} '
            '${Fmt.money(change.abs(), 'BRL')} $phrase';
        subtitle =
            '${gain >= Decimal.zero ? 'Ganho' : 'Perda'} de '
            '${Fmt.money(gain.abs(), 'BRL')} e '
            '${added >= Decimal.zero ? 'aportes líquidos' : 'resgates líquidos'} '
            'de ${Fmt.money(added.abs(), 'BRL')} no período';
      }
    }
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Evolução patrimonial', style: muted),
            Text(
              title ?? 'Evolução patrimonial',
              key: const Key('wealth-title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty)
              Text(subtitle, key: const Key('wealth-subtitle'), style: muted),
          ],
        ),
        SegmentedButton<WealthPeriod>(
          key: const Key('wealth-periods'),
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: [
            for (final p in WealthPeriod.values)
              ButtonSegment(
                value: p,
                label: Text(p.label, key: Key('wealth-period-${p.label}')),
                enabled: periodEnabled(p),
                tooltip: periodEnabled(p)
                    ? null
                    : 'A carteira tem menos histórico que este período.',
              ),
          ],
          selected: {period},
          onSelectionChanged: (s) => onPeriod(s.single),
        ),
      ],
    );
  }
}

Decimal? _twrBetween(List<(LocalDate, Decimal)> twr, LocalDate a, LocalDate b) {
  Decimal? start;
  Decimal? end;
  for (final (d, v) in twr) {
    if (d == a) start = v;
    if (d == b) end = v;
  }
  if (start == null || end == null || start == Decimal.zero) return null;
  return DecimalMath.divide(end, start) - Decimal.one;
}

Decimal? _cumulativeBetween(
  List<BenchmarkPoint> sim,
  LocalDate a,
  LocalDate b,
) {
  BenchmarkPoint? start;
  BenchmarkPoint? end;
  for (final p in sim) {
    if (p.date == a) start = p;
    if (p.date == b) end = p;
  }
  if (start == null || end == null) return null;
  return DecimalMath.divide(
        Decimal.one + end.cumulative,
        Decimal.one + start.cumulative,
      ) -
      Decimal.one;
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.mode,
    required this.indices,
    required this.names,
  });

  final WealthMode mode;
  final List<IndicatorSeries> indices;
  final Map<IndicatorSeries, String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget item(Color color, String label, {List<int>? dash}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(22, 3),
          painter: _SwatchPainter(color, dash),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        item(
          scheme.primary,
          mode == WealthMode.percent ? 'Carteira (TWR)' : 'Patrimônio',
        ),
        if (mode == WealthMode.money)
          item(_investedColor(context), 'Total aplicado (aportes − resgates)'),
        if (mode == WealthMode.money)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _investedColor(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Aporte', style: theme.textTheme.bodySmall),
            ],
          ),
        for (final s in indices)
          item(
            _indexColor(context, s),
            mode == WealthMode.percent ? names[s]! : '${names[s]} (simulação)',
            dash: _indexDash(s),
          ),
      ],
    );
  }
}

Color _investedColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

/// Referências em tons de cinza (nunca a cor da carteira nem verde/vermelho),
/// cada uma com um tracejado: CDI, Ibovespa e IPCA, nessa ordem.
Color _indexColor(BuildContext context, IndicatorSeries s) {
  final scheme = Theme.of(context).colorScheme;
  return switch (s) {
    IndicatorSeries.ibovespa => scheme.onSurface.withValues(alpha: 0.8),
    IndicatorSeries.ipca => scheme.outline,
    _ => scheme.onSurfaceVariant,
  };
}

List<int> _indexDash(IndicatorSeries s) => switch (s) {
  IndicatorSeries.ibovespa => const [2, 3],
  IndicatorSeries.ipca => const [10, 4],
  _ => const [5, 3],
};

/// O gráfico em si.
class _WealthLine extends StatelessWidget {
  const _WealthLine({
    required this.window,
    required this.mode,
    required this.twr,
    required this.sims,
    required this.names,
    super.key,
  });

  final List<WealthPoint> window;
  final WealthMode mode;
  final List<(LocalDate, Decimal)> twr;
  final Map<IndicatorSeries, List<BenchmarkPoint>> sims;
  final Map<IndicatorSeries, String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final axis = DateAxis(window.first.date, window.last.date);
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final start = window.first.date;
    final end = window.last.date;
    final percent = mode == WealthMode.percent;

    // Séries em double só para desenhar (regra 6, exceção).
    final twrByDate = {for (final (d, v) in twr) d: v};
    final twrStart = twrByDate[start];
    List<FlSpot> portfolio;
    if (percent && twrStart != null && twrStart != Decimal.zero) {
      portfolio = [
        for (final p in window)
          if (twrByDate[p.date] case final v?)
            FlSpot(
              axis.x(p.date),
              ((DecimalMath.divide(v, twrStart) - Decimal.one) *
                      Decimal.fromInt(100))
                  .toDouble(),
            ),
      ];
    } else {
      portfolio = [
        for (final p in window) FlSpot(axis.x(p.date), p.value.toDouble()),
      ];
    }
    final invested = [
      for (final p in window) FlSpot(axis.x(p.date), p.invested.toDouble()),
    ];
    final indexLines = <IndicatorSeries, List<FlSpot>>{};
    final simByDate = <IndicatorSeries, Map<LocalDate, BenchmarkPoint>>{};
    for (final MapEntry(:key, :value) in sims.entries) {
      final byDate = {for (final b in value) b.date: b};
      simByDate[key] = byDate;
      final base = byDate[start];
      indexLines[key] = [
        for (final p in window)
          if (byDate[p.date] case final b?)
            FlSpot(
              axis.x(p.date),
              percent
                  ? (base == null
                        ? 0
                        : ((DecimalMath.divide(
                                        Decimal.one + b.cumulative,
                                        Decimal.one + base.cumulative,
                                      ) -
                                      Decimal.one) *
                                  Decimal.fromInt(100))
                              .toDouble())
                  : b.value.toDouble(),
            ),
      ];
    }

    var minY = double.infinity;
    var maxY = -double.infinity;
    for (final line in [
      portfolio,
      if (!percent) invested,
      ...indexLines.values,
    ]) {
      for (final s in line) {
        if (s.y < minY) minY = s.y;
        if (s.y > maxY) maxY = s.y;
      }
    }
    final pad = maxY == minY ? (maxY.abs() * 0.05 + 1) : (maxY - minY) * 0.06;

    final byX = {for (final p in window) axis.x(p.date): p};
    String tooltip(double x) {
      final p = byX[x];
      if (p == null) return '';
      final lines = <String>[Fmt.date(p.date)];
      if (percent) {
        final v = twrByDate[p.date];
        final r = v == null || twrStart == null
            ? null
            : DecimalMath.divide(v, twrStart) - Decimal.one;
        lines.add('Carteira ${r == null ? '—' : Fmt.percent(r)}');
        for (final MapEntry(:key, :value) in simByDate.entries) {
          final b = value[p.date];
          final base = value[start];
          if (b == null || base == null) continue;
          final c =
              DecimalMath.divide(
                Decimal.one + b.cumulative,
                Decimal.one + base.cumulative,
              ) -
              Decimal.one;
          final diff = r == null
              ? ''
              : ' (${Fmt.signedNumber((r - c) * Decimal.fromInt(100))} p.p.)';
          lines.add('${names[key]} ${Fmt.percent(c)}$diff');
        }
      } else {
        lines
          ..add('Patrimônio ${Fmt.money(p.value, 'BRL')}')
          ..add('Aplicado ${Fmt.money(p.invested, 'BRL')}')
          ..add(
            'Ganho ${Fmt.signedMoney(p.gain, 'BRL')}'
            '${p.gainFraction == null ? '' : ' (${Fmt.percent(p.gainFraction!)})'}',
          );
        if (p.buys > Decimal.zero) {
          lines.add('Aporte no dia ${Fmt.money(p.buys, 'BRL')}');
        }
        for (final MapEntry(:key, :value) in simByDate.entries) {
          final b = value[p.date];
          if (b == null) continue;
          lines.add(
            '${names[key]} ${Fmt.money(b.value, 'BRL')} · carteira '
            '${Fmt.signedMoney(p.value - b.value, 'BRL')}',
          );
        }
      }
      return lines.join('\n');
    }

    final buyDays = {
      for (final p in window)
        if (p.buys > Decimal.zero && p.date != start) axis.x(p.date),
    };
    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: portfolio,
        color: scheme.primary,
        barWidth: 2.2,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: !percent,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withValues(alpha: 0.22),
              scheme.primary.withValues(alpha: 0.04),
            ],
          ),
        ),
      ),
      if (!percent)
        LineChartBarData(
          spots: invested,
          color: _investedColor(context),
          barWidth: 1.4,
          isStepLineChart: true,
          lineChartStepData: const LineChartStepData(stepDirection: 0),
          dotData: FlDotData(
            checkToShowDot: (spot, _) => buyDays.contains(spot.x),
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 2.6,
              color: _investedColor(context),
              strokeWidth: 0,
            ),
          ),
        ),
      for (final s in indexLines.keys)
        LineChartBarData(
          spots: indexLines[s]!,
          color: _indexColor(context, s),
          barWidth: 1.2,
          dashArray: _indexDash(s),
          dotData: const FlDotData(show: false),
        ),
    ];

    return LineChart(
      LineChartData(
        minX: axis.x(start),
        maxX: axis.x(end),
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (percent)
              HorizontalLine(y: 0, color: scheme.outline, strokeWidth: 0.8),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 74,
              maxIncluded: false,
              minIncluded: false,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  percent ? '${compact(v)}%' : 'R\$ ${compact(v)}',
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
          getTouchedSpotIndicator: (bar, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: scheme.outline, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (spot, p, bar, index) => FlDotCirclePainter(
                    radius: 3,
                    color: bar.color ?? scheme.primary,
                    strokeWidth: 1.5,
                    strokeColor: scheme.surface,
                  ),
                ),
              ),
          ],
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 280,
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
        lineBarsData: lineBars,
      ),
      // Sem animação entre períodos: anos de pontos.
      duration: Duration.zero,
    );
  }
}

/// Distribuição em uma rosca, com seletor (M-09).
enum DistributionBy {
  asset('Ativo'),
  assetClass('Classe'),
  sector('Setor'),
  broker('Corretora');

  const DistributionBy(this.label);

  final String label;
}

/// Cor de ganho e perda, para os números da faixa.
Color gainColor(BuildContext context, Decimal v) {
  final c = SemanticColors.of(context);
  return v > Decimal.zero
      ? c.gain
      : v < Decimal.zero
      ? c.loss
      : Theme.of(context).colorScheme.onSurfaceVariant;
}

/// Amostra da linha na legenda (contínua ou tracejada).
class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.color, this.dash);

  final Color color;
  final List<int>? dash;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dash == null ? 3 : 2;
    final y = size.height / 2;
    final d = dash;
    if (d == null) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final len = d[i % d.length].toDouble();
      if (i.isEven) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + len).clamp(0, size.width), y),
          paint,
        );
      }
      x += len;
      i++;
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.color != color || old.dash != dash;
}
