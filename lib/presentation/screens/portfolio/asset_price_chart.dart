import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/price_series.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/date_axis.dart';

/// Fechamentos e eventos guardados de um ativo (símbolo, mercado),
/// recarregados quando os dados de mercado mudam.
typedef AssetPriceData = ({
  List<PricePoint> closes,
  List<CorporateEvent> events,
  String? source,
});

final assetPriceDataProvider =
    StreamProvider.family<AssetPriceData, (String, String)>((ref, key) {
      final repo = ref.watch(marketRepositoryProvider);
      final (symbol, market) = key;
      final controller = StreamController<AssetPriceData>();
      Future<void> emit() async {
        final bars = await repo.prices(symbol, market);
        final events = await repo.events(symbol, market);
        if (!controller.isClosed) {
          controller.add((
            closes: PriceSeries.closes(bars),
            events: events,
            source: bars.isEmpty ? null : bars.last.source,
          ));
        }
      }

      unawaited(emit());
      final sub = repo.watchChanges().listen((_) => unawaited(emit()));
      ref.onDispose(() {
        unawaited(sub.cancel());
        unawaited(controller.close());
      });
      return controller.stream;
    });

/// Períodos de mercado do gráfico (não "desde a minha compra").
enum MarketPeriod {
  month('1M', 31, 'em 1 mês'),
  sixMonths('6M', 183, 'em 6 meses'),
  year('1A', 366, 'em 1 ano'),
  fiveYears('5A', 1827, 'em 5 anos'),
  tenYears('10A', 3653, 'em 10 anos'),
  all('Tudo', null, null);

  const MarketPeriod(this.label, this.days, this.phrase);

  final String label;
  final int? days;

  /// "em 1 ano"; nulo em "Tudo" (vira "desde dd/mm/aaaa").
  final String? phrase;

  LocalDate? startFrom(LocalDate today) =>
      days == null ? null : today.addDays(-days!);

  /// O histórico começa até dez dias depois do início do período (feriados
  /// e fins de semana no começo não contam como falta).
  bool coveredBy(LocalDate firstClose, LocalDate today) {
    final start = startFrom(today);
    return start == null || !firstClose.isAfter(start.addDays(10));
  }
}

/// Gráfico grande da cotação do ativo (M-07): só o desempenho de mercado,
/// sem nada da carteira (preço médio, compras e vendas ficam fora). Nunca
/// inventa pontos: sem histórico, "indisponível" com o motivo (regra 1).
class AssetPriceChart extends ConsumerStatefulWidget {
  const AssetPriceChart({
    required this.symbol,
    required this.market,
    required this.currency,
    required this.today,
    required this.height,
    this.onDownload,
    super.key,
  });

  final String symbol;
  final String market;
  final String currency;
  final LocalDate today;
  final double height;

  /// Baixa o histórico completo (nulo quando não há fonte).
  final VoidCallback? onDownload;

  @override
  ConsumerState<AssetPriceChart> createState() => _AssetPriceChartState();
}

class _AssetPriceChartState extends ConsumerState<AssetPriceChart> {
  MarketPeriod _period = MarketPeriod.year;
  bool _adjusted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final data = ref
        .watch(assetPriceDataProvider((widget.symbol, widget.market)))
        .value;
    final backfill = ref.watch(historyBackfillProvider).progress;
    final closes = data?.closes ?? const <PricePoint>[];
    final events = data?.events ?? const <CorporateEvent>[];
    final first = closes.isEmpty ? null : closes.first.date;

    // Período escolhido sem dados: volta para o maior período coberto.
    var period = _period;
    if (first != null && !period.coveredBy(first, widget.today)) {
      period = MarketPeriod.values.lastWhere(
        (p) => p.coveredBy(first, widget.today) && p != MarketPeriod.all,
        orElse: () => MarketPeriod.all,
      );
    }
    final series = _adjusted ? PriceSeries.adjusted(closes, events) : closes;
    final visible = PriceSeries.since(series, period.startFrom(widget.today));
    final summary = PriceSeries.summary(visible);
    final from = visible.isEmpty ? null : visible.first.date;
    final to = visible.isEmpty ? null : visible.last.date;
    bool inRange(LocalDate d) =>
        from != null && d.isAfter(from) && !d.isAfter(to!);
    final jumps = [
      for (final j in PriceSeries.suspectJumps(closes, events))
        if (inRange(j.to.date)) j,
    ];
    final quantityEvents = [
      for (final e in events)
        if (e.kind.changesQuantity &&
            e.status != CorporateEventStatus.suspect &&
            inRange(e.exDate))
          e,
    ];

    final header = Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _adjusted ? 'Cotação ajustada por proventos' : 'Cotação',
              style: theme.textTheme.titleMedium,
            ),
            if (summary != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  PnlText(
                    key: const Key('period-change'),
                    value: summary.change,
                    text: Fmt.percent(summary.change),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    singleLine: true,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    period.phrase ?? 'desde ${Fmt.date(summary.first.date)}',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            if (summary != null)
              Text(
                'Máx. ${Fmt.money(summary.high.price, widget.currency)} '
                '(${Fmt.date(summary.high.date)}) · Mín. '
                '${Fmt.money(summary.low.price, widget.currency)} '
                '(${Fmt.date(summary.low.date)})',
                key: const Key('period-high-low'),
                style: muted,
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<MarketPeriod>(
              key: const Key('market-periods'),
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                for (final p in MarketPeriod.values)
                  ButtonSegment(
                    value: p,
                    label: Text(p.label, key: Key('period-${p.label}')),
                    enabled:
                        first != null &&
                        closes.length > 1 &&
                        p.coveredBy(first, widget.today),
                    tooltip: first == null || p.coveredBy(first, widget.today)
                        ? null
                        : 'Histórico disponível desde '
                              '${Fmt.monthYear(first)}',
                  ),
              ],
              selected: {period},
              onSelectionChanged: (s) => setState(() => _period = s.single),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message:
                      'Calculado pelo Patrion a partir dos fechamentos e dos '
                      'proventos e eventos da B3: cada preço antes de uma '
                      'data ex é multiplicado por (1 − provento ÷ fechamento '
                      'da data com) ou dividido pelo fator do desdobramento. '
                      'Mostra o retorno total, sem quedas falsas nas datas '
                      'ex. Não é o preço negociado.',
                  child: Text('Preço ajustado por proventos', style: muted),
                ),
                const SizedBox(width: 4),
                Switch(
                  key: const Key('adjusted-switch'),
                  value: _adjusted,
                  onChanged: closes.length < 2
                      ? null
                      : (v) => setState(() => _adjusted = v),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    Widget body;
    if (data == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (visible.length < 2) {
      final reason = backfill != null
          ? 'Baixando o histórico de cotações em segundo plano…'
          : closes.isEmpty
          ? 'Nenhum fechamento guardado para este ativo.'
          : 'Menos de dois fechamentos guardados neste período.';
      body = Center(
        key: const Key('asset-chart-unavailable'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UnavailableText(tooltip: reason),
            const SizedBox(height: 4),
            Text(reason, style: muted, textAlign: TextAlign.center),
            if (widget.onDownload != null && backfill == null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: widget.onDownload,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Baixar histórico'),
              ),
            ],
          ],
        ),
      );
    } else {
      body = _PriceLine(
        key: ValueKey('${period.label}-$_adjusted'),
        points: visible,
        currency: widget.currency,
        adjusted: _adjusted,
      );
    }

    final source = data?.source;
    return Column(
      key: const Key('asset-price-chart'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 12),
        SizedBox(height: widget.height, child: body),
        const SizedBox(height: 6),
        if (jumps.isNotEmpty)
          _Notice(
            key: const Key('suspect-jumps'),
            icon: Icons.warning_amber_outlined,
            text:
                '${jumps.length == 1 ? 'Salto' : 'Saltos'} sem evento '
                'registrado na B3: '
                '${jumps.take(3).map((j) => '${Fmt.percent(j.change)} em ${Fmt.date(j.to.date)}').join(', ')}'
                '${jumps.length > 3 ? ' e mais ${jumps.length - 3}' : ''}. Pode '
                'ser um desdobramento ou grupamento que a fonte não listou; o '
                'preço ajustado não corrige esse salto.',
          ),
        if (!_adjusted && quantityEvents.isNotEmpty)
          _Notice(
            key: const Key('quantity-events'),
            icon: Icons.info_outline,
            text:
                '${quantityEvents.take(3).map((e) => '${e.kind.label} em ${Fmt.date(e.exDate)}').join(', ')}: '
                'a mudança de preço nessa data não é ganho nem perda. Ligue '
                '"Preço ajustado" para ver a série comparável.',
          ),
        Text(
          _adjusted
              ? 'Preço calculado (tipo: calculado), a partir dos fechamentos '
                    'publicados e dos proventos e eventos da B3. Só o '
                    'desempenho do ativo no mercado: nada da sua carteira.'
              : 'Fechamentos diários publicados'
                    '${source == null ? '' : ' (${ProviderCatalog.shortNameOf(source)})'}'
                    ', sem ajuste. Só o desempenho do ativo no mercado: nada '
                    'da sua carteira.',
          style: muted,
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// A linha do gráfico, com eixo de valores sem começar em zero e tooltip
/// com data, preço e variação desde o início do período.
class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.points,
    required this.currency,
    required this.adjusted,
    super.key,
  });

  final List<PricePoint> points;
  final String currency;
  final bool adjusted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = SemanticColors.of(context);
    final axis = DateAxis(points.first.date, points.last.date);
    final start = points.first.price;
    // Conversão para desenho apenas (regra 6, exceção).
    final x = axis.x;
    final spots = [
      for (final p in points) FlSpot(x(p.date), p.price.toDouble()),
    ];
    var minY = spots.first.y;
    var maxY = spots.first.y;
    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }
    final pad = maxY == minY ? maxY * 0.05 : (maxY - minY) * 0.08;
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final up = points.last.price >= start;
    final lineColor = scheme.primary;

    return LineChart(
      LineChartData(
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY - pad,
        maxY: maxY + pad,
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
              reservedSize: 76,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  Fmt.money(Decimal.parse(v.toStringAsFixed(2)), currency),
                  style: small,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
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
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: scheme.surface,
                      ),
                ),
              ),
          ],
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (touched) => [
              for (final t in touched)
                () {
                  final p = points[t.spotIndex];
                  final pct = DecimalMath.divide(p.price, start) - Decimal.one;
                  return LineTooltipItem(
                    '${Fmt.date(p.date)}\n'
                    '${Fmt.money(p.price, currency)}'
                    '${adjusted ? ' (ajustado)' : ''}\n'
                    '${Fmt.percent(pct)} desde ${Fmt.date(points.first.date)}',
                    TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                  );
                }(),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: lineColor,
            barWidth: 2,
            isCurved: false,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (up ? colors.gain : colors.loss).withValues(alpha: 0.10),
                  (up ? colors.gain : colors.loss).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
