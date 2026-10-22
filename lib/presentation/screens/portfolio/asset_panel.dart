import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/market_price.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import 'trade_dialog.dart';

/// Fechamentos guardados de um ativo (símbolo, mercado), recarregados quando
/// os dados de mercado mudam.
final assetClosesProvider =
    StreamProvider.family<List<PriceBar>, (String, String)>((ref, key) {
      final repo = ref.watch(marketRepositoryProvider);
      final (symbol, market) = key;
      final controller = StreamController<List<PriceBar>>();
      Future<void> emit() async {
        final bars = await repo.prices(symbol, market);
        if (!controller.isClosed) controller.add(bars);
      }

      unawaited(emit());
      final sub = repo.watchChanges().listen((_) => unawaited(emit()));
      ref.onDispose(() {
        unawaited(sub.cancel());
        unawaited(controller.close());
      });
      return controller.stream;
    });

/// Painel de detalhes de um ativo, aberto sobre a lista da Carteira (M-05):
/// lucro, total aplicado, variação do dia, gráfico da cotação com a linha
/// do preço médio, proventos, operações e compra e venda.
class AssetPanel extends StatelessWidget {
  const AssetPanel({
    required this.snap,
    required this.holding,
    required this.all,
    required this.onClose,
    super.key,
  });

  final PortfolioSnapshot snap;
  final Holding holding;
  final List<Holding> all;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = holding.asset;
    final c = holding.currency;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final value = holding.marketValue;
    final profit = holding.profit;
    final share = Holdings.shareOf(holding, all);
    final market = holding.marketPrice;
    final day = market?.dayChange;
    final note = holding.priced == null
        ? null
        : MarketLabels.valuation(holding.priced!, snap.asOf);
    final ops = [
      for (final o in snap.operations)
        if (o.assetId == holding.assetId) o,
    ];
    return Material(
      key: const Key('asset-panel'),
      elevation: 8,
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset?.symbol ?? '?',
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      [?asset?.name, ?asset?.assetClass.singular].join(' · '),
                      style: muted,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('asset-panel-close'),
                tooltip: 'Fechar',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (asset != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('panel-buy'),
                  onPressed: () =>
                      showTradeDialog(context, snap, asset, sell: false),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Comprar'),
                ),
                OutlinedButton.icon(
                  key: const Key('panel-sell'),
                  onPressed: holding.quantity > Decimal.zero
                      ? () => showTradeDialog(context, snap, asset, sell: true)
                      : null,
                  icon: const Icon(Icons.sell_outlined, size: 18),
                  label: const Text('Vender'),
                ),
                TextButton(
                  onPressed: () => context.go(Routes.asset(asset.id)),
                  child: const Text('Página do ativo'),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _Metric(
                'Valor da posição',
                value == null ? null : Text(Fmt.money(value, c)),
                big: true,
                unavailable: 'Sem cotação ou saldo para todas as contas.',
              ),
              _Metric(
                'Lucro em R\$',
                profit == null
                    ? null
                    : PnlText(value: profit, text: Fmt.signedMoney(profit, c)),
                big: true,
                note: profit == null
                    ? null
                    : 'Não realizado ${Fmt.signedMoney(holding.unrealizedPnl!, c)}'
                          ' + realizado ${Fmt.signedMoney(holding.realizedPnl, c)}',
                unavailable: 'Precisa do valor da posição.',
              ),
              _Metric(
                'Total aplicado',
                Text(Fmt.money(holding.totalCost, c)),
                note: 'Preço médio × quantidade',
              ),
              _Metric(
                'Preço médio',
                holding.averagePrice == null
                    ? const Text('—')
                    : Text(Fmt.money(holding.averagePrice!, c)),
                note: holding.quantity > Decimal.zero
                    ? '${Fmt.number(holding.quantity)} cotas'
                    : null,
              ),
              _Metric(
                'Cotação atual',
                holding.unitPrice == null
                    ? null
                    : Tooltip(
                        message: note?.message ?? '',
                        child: Text(Fmt.money(holding.unitPrice!, c)),
                      ),
                note: note?.short,
                unavailable: 'Sem cotação guardada.',
              ),
              _Metric(
                'Variação do dia',
                day == null
                    ? null
                    : PnlText(
                        value: day.perUnit,
                        text:
                            '${Fmt.signedMoney(holding.dayChangeAmount!, c)} '
                            '(${Fmt.percent(day.fraction)})',
                      ),
                note: day == null
                    ? null
                    : 'Desde o fechamento de ${Fmt.date(day.from.refDate)} '
                          '(${ProviderCatalog.shortNameOf(day.from.source)})',
                unavailable: market == null
                    ? 'Sem cotação de mercado para este ativo.'
                    : 'Sem o fechamento anterior a '
                          '${Fmt.date(market.refDate)} guardado.',
              ),
              _Metric(
                '% da carteira',
                share == null ? null : Text(Fmt.percent(share, signed: false)),
                note: 'Pelo valor das posições em $c',
                unavailable: 'Precisa do valor da posição.',
              ),
              _Metric(
                'Proventos recebidos',
                Text(Fmt.money(holding.incomeNet, c)),
                note: 'Líquidos, todas as contas',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (asset != null)
            PriceChart(
              key: ValueKey(asset.id),
              symbol: asset.symbol.toUpperCase(),
              market: asset.market.code,
              currency: c,
              average: holding.averagePrice,
              current: market,
              today: snap.asOf,
              canDownload:
                  asset.priceSource == PriceSource.market &&
                  asset.assetClass != AssetClass.treasury &&
                  asset.assetClass != AssetClass.cash,
              onDownload: () => _download(context, asset),
            ),
          const SizedBox(height: 20),
          Text('Operações', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          if (ops.isEmpty) Text('Nenhuma operação.', style: muted),
          for (final o in ops.take(15))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${Fmt.date(o.tradeDate)} · ${o.type.label}'
                '${o.quantity == null ? '' : ' · ${Fmt.number(o.quantity!)}'}'
                '${o.unitPrice == null ? '' : ' × ${Fmt.money(o.unitPrice!, o.currency)}'}',
              ),
              subtitle: Text(snap.accountLabel(o.accountId)),
              trailing: Text(Fmt.money(o.amount, o.currency)),
            ),
          if (ops.length > 15)
            Text(
              'Mais ${ops.length - 15} na página do ativo e em Operações.',
              style: muted,
            ),
        ],
      ),
    );
  }

  static void _download(BuildContext context, Asset asset) {
    final container = ProviderScope.containerOf(context);
    unawaited(() async {
      final result = await container
          .read(marketRefreshProvider.notifier)
          .run('Histórico de ${asset.symbol}', (s) => s.downloadHistory(asset));
      if (context.mounted) showInfo(context, MarketLabels.result(result));
    }());
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
    this.label,
    this.value, {
    this.note,
    this.big = false,
    this.unavailable,
  });

  final String label;

  /// Nulo mostra "indisponível" com [unavailable] no tooltip.
  final Widget? value;
  final String? note;
  final bool big;
  final String? unavailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          DefaultTextStyle.merge(
            style:
                (big ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)
                    ?.copyWith(fontWeight: big ? FontWeight.w600 : null),
            child: value ?? UnavailableText(tooltip: unavailable),
          ),
          if (note != null)
            Text(
              note!,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
        ],
      ),
    );
  }
}

/// Períodos do gráfico da cotação.
enum ChartPeriod {
  week('1S', 7),
  month('1M', 31),
  sixMonths('6M', 183),
  year('1A', 366),
  fiveYears('5A', 1827),
  all('Tudo', null);

  const ChartPeriod(this.label, this.days);

  final String label;
  final int? days;
}

/// Gráfico da cotação (fechamentos guardados e a cotação atual), com uma
/// linha horizontal no preço médio. Sem pontos suficientes, mostra
/// "indisponível" com o motivo: nunca inventa pontos (regra 1).
class PriceChart extends ConsumerStatefulWidget {
  const PriceChart({
    required this.symbol,
    required this.market,
    required this.currency,
    required this.average,
    required this.current,
    required this.today,
    required this.canDownload,
    required this.onDownload,
    super.key,
  });

  final String symbol;
  final String market;
  final String currency;
  final Decimal? average;
  final MarketPrice? current;
  final LocalDate today;
  final bool canDownload;
  final VoidCallback onDownload;

  @override
  ConsumerState<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends ConsumerState<PriceChart> {
  ChartPeriod _period = ChartPeriod.sixMonths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bars = ref
        .watch(assetClosesProvider((widget.symbol, widget.market)))
        .value;
    final days = _period.days;
    final from = days == null ? null : widget.today.addDays(-days);
    final points = <(LocalDate, Decimal)>[
      for (final b in bars ?? const <PriceBar>[])
        if (from == null || !b.refDate.isBefore(from))
          (b.refDate, MarketPricing.unitClose(b)),
    ];
    final current = widget.current;
    if (current != null &&
        (points.isEmpty || current.refDate.isAfter(points.last.$1))) {
      points.add((current.refDate, current.price));
    }
    final busy = ref.watch(marketRefreshProvider).busy;

    return Column(
      key: const Key('price-chart'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Cotação', style: theme.textTheme.titleMedium),
            ),
            SegmentedButton<ChartPeriod>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                for (final p in ChartPeriod.values)
                  ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.single),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (bars == null)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (points.length < 2)
          Container(
            key: const Key('price-chart-unavailable'),
            height: 160,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const UnavailableText(),
                const SizedBox(height: 4),
                Text(
                  bars.isEmpty
                      ? 'Nenhum histórico de cotações guardado para este ativo.'
                      : 'Menos de dois fechamentos guardados neste período.',
                  style: muted,
                  textAlign: TextAlign.center,
                ),
                if (widget.canDownload) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: busy ? null : widget.onDownload,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Baixar histórico'),
                  ),
                ],
              ],
            ),
          )
        else
          SizedBox(height: 220, child: _chart(context, points)),
        const SizedBox(height: 4),
        Text(
          'Fechamentos guardados (preço publicado, sem ajuste por proventos)'
          '${current == null ? '' : ' e a cotação atual'}. A linha tracejada é '
          'o preço médio.',
          style: muted,
        ),
      ],
    );
  }

  Widget _chart(BuildContext context, List<(LocalDate, Decimal)> points) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final epoch = points.first.$1;
    // Conversão para desenho apenas (regra 6, exceção).
    double x(LocalDate d) => d.daysSince(epoch).toDouble();
    final spots = [for (final (d, p) in points) FlSpot(x(d), p.toDouble())];
    final average = widget.average?.toDouble();
    var minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    var maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (average != null) {
      if (average < minY) minY = average;
      if (average > maxY) maxY = average;
    }
    final pad = (maxY - minY) == 0 ? maxY * 0.05 : (maxY - minY) * 0.08;
    String money(double v) =>
        Fmt.money(Decimal.parse(v.toStringAsFixed(2)), widget.currency);
    final lastX = spots.last.x;
    final small = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        minX: 0,
        maxX: lastX,
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
              reservedSize: 72,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(money(v), style: small),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: lastX <= 0 ? 1 : lastX / 3,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(Fmt.date(epoch.addDays(v.round())), style: small),
              ),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (average != null)
              HorizontalLine(
                y: average,
                color: scheme.tertiary,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: small?.copyWith(color: scheme.tertiary),
                  labelResolver: (_) =>
                      'Preço médio ${Fmt.money(widget.average!, widget.currency)}',
                ),
              ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (touched) => [
              for (final t in touched)
                LineTooltipItem(
                  '${Fmt.date(epoch.addDays(t.x.round()))}\n'
                  '${Fmt.money(points[t.spotIndex].$2, widget.currency)}',
                  TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: scheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
