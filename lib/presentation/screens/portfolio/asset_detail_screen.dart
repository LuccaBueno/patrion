import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/market/market_data_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/market_price.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/finance/returns.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../../domain/portfolio/portfolio_valuation.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../format/sync_labels.dart';
import '../../format/performance_format.dart';
import '../../providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import '../operations/operation_dialogs.dart';
import '../operations/operations_screen.dart';
import '../registry/registry_dialogs.dart';
import 'asset_price_chart.dart';
import 'trade_dialog.dart';

/// Página do ativo em tela cheia (M-07; SPEC §16): cabeçalho com a posição,
/// gráfico grande só com o desempenho de mercado, cartões com os números da
/// carteira e abas de operações, proventos e dados do ativo.
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
    return AsyncBody(
      value: snapshot,
      builder: (snap) {
        final asset = snap.assets[assetId];
        if (asset == null) {
          return PageScaffold(
            title: 'Ativo',
            child: Align(
              alignment: Alignment.topLeft,
              child: MessageCard(
                icon: Icons.search_off,
                title: 'Ativo não encontrado',
                message: 'Ele pode ter sido excluído.',
                action: TextButton(
                  onPressed: () => context.go(Routes.portfolio),
                  child: const Text('Voltar para a carteira'),
                ),
              ),
            ),
          );
        }
        final all = Holdings.build(
          snap.valued,
          toBrl: {
            for (final MapEntry(:key, :value) in fx.entries)
              if (value.mid != null) key: value.mid!,
          },
        );
        final holding = all.where((h) => h.assetId == assetId).firstOrNull;
        return _AssetPage(snap: snap, asset: asset, holding: holding, all: all);
      },
    );
  }
}

class _AssetPage extends ConsumerWidget {
  const _AssetPage({
    required this.snap,
    required this.asset,
    required this.holding,
    required this.all,
  });

  final PortfolioSnapshot snap;
  final Asset asset;
  final Holding? holding;
  final List<Holding> all;

  bool get _hasMarketChart =>
      asset.priceSource == PriceSource.market &&
      asset.assetClass != AssetClass.cash &&
      asset.assetClass != AssetClass.treasury;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height;
    final service = ref.watch(marketDataServiceProvider);
    final canDownload = _hasMarketChart && service.hasHistorySource(asset);
    return Padding(
      key: const Key('asset-page'),
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixo: Voltar, Comprar e Vender sempre à vista.
          _Header(snap: snap, asset: asset, holding: holding),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: _hasMarketChart
                          ? AssetPriceChart(
                              key: ValueKey(asset.id),
                              symbol: asset.symbol.toUpperCase(),
                              market: asset.market.code,
                              currency: asset.currency,
                              today: snap.asOf,
                              // ~45% da altura da janela (M-07).
                              height: (height * 0.45).clamp(240.0, 560.0),
                              onDownload: canDownload
                                  ? () => _downloadHistory(context, ref, asset)
                                  : null,
                            )
                          : _NoMarketChart(asset: asset),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardsGrid(
                    snap: snap,
                    asset: asset,
                    holding: holding,
                    all: all,
                  ),
                  const SizedBox(height: 16),
                  _Tabs(snap: snap, asset: asset),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baixa o histórico completo do ativo em segundo plano (M-08).
void _downloadHistory(BuildContext context, WidgetRef ref, Asset asset) {
  final controller = ref.read(historyBackfillProvider.notifier);
  unawaited(() async {
    final result = await controller.redo(asset.symbol.toUpperCase());
    if (context.mounted) showInfo(context, MarketLabels.result(result));
  }());
}

class _NoMarketChart extends StatelessWidget {
  const _NoMarketChart({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cotação', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            const UnavailableText(),
            Text(
              asset.priceSource == PriceSource.market
                  ? 'Sem gráfico de cotação para esta classe de ativo.'
                  : 'Este ativo usa preço ou saldo informado por você: não '
                        'há histórico de mercado.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ticker, nome, classe e corretoras; à direita, o valor da posição, o
/// lucro e a variação do dia, com Comprar e Vender.
class _Header extends ConsumerWidget {
  const _Header({
    required this.snap,
    required this.asset,
    required this.holding,
  });

  final PortfolioSnapshot snap;
  final Asset asset;
  final Holding? holding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final h = holding;
    final c = asset.currency;
    final brokers = <String>{
      for (final v in h?.positions ?? const <ValuedPosition>[])
        if (v.position.isOpen)
          snap.institutionOfAccount(v.position.accountId)?.name ?? '?',
    }.toList()..sort();
    final value = h?.marketValue;
    final profit = h?.profit;
    final appreciation = h?.appreciation;
    final day = h?.marketPrice?.dayChange;
    final dayAmount = h?.dayChangeAmount;
    final busy = ref.watch(marketRefreshProvider).busy;

    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: const Key('asset-back'),
          tooltip: 'Voltar para a Carteira',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.portfolio),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                asset.symbol,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                [
                  asset.name,
                  asset.assetClass.singular,
                  if (brokers.isNotEmpty) brokers.join(', '),
                ].join(' · '),
                key: const Key('asset-subtitle'),
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final numbers = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Valor da posição',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        if (h == null || !h.isOpen)
          Text('—', style: theme.textTheme.headlineSmall)
        else if (value == null)
          const UnavailableText(
            tooltip: 'Sem cotação ou saldo para todas as contas.',
          )
        else
          SelectableText(
            Fmt.money(value, c),
            key: const Key('header-value'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (profit != null)
              Tooltip(
                message:
                    'Lucro = não realizado (valor da posição − total '
                    'aplicado) + realizado nas vendas. Valorização = '
                    '(cotação − preço médio) ÷ preço médio.',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lucro ', style: TextStyle(color: muted)),
                    PnlText(
                      key: const Key('header-profit'),
                      value: profit,
                      text:
                          '${Fmt.signedMoney(profit, c)}'
                          '${appreciation == null ? '' : ' (${Fmt.percent(appreciation)})'}',
                      singleLine: true,
                    ),
                  ],
                ),
              ),
            if (day != null && dayAmount != null)
              Tooltip(
                message:
                    'Desde o fechamento de ${Fmt.date(day.from.refDate)} '
                    '(${ProviderCatalog.shortNameOf(day.from.source)})',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hoje ', style: TextStyle(color: muted)),
                    PnlText(
                      key: const Key('header-day'),
                      value: day.perUnit,
                      text:
                          '${Fmt.signedMoney(dayAmount, c)} '
                          '(${Fmt.percent(day.fraction)})',
                      singleLine: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          key: const Key('asset-buy'),
          onPressed: () => showTradeDialog(context, snap, asset, sell: false),
          icon: const Icon(Icons.add_shopping_cart, size: 18),
          label: const Text('Comprar'),
        ),
        OutlinedButton.icon(
          key: const Key('asset-sell'),
          onPressed: (h?.quantity ?? Decimal.zero) > Decimal.zero
              ? () => showTradeDialog(context, snap, asset, sell: true)
              : null,
          icon: const Icon(Icons.sell_outlined, size: 18),
          label: const Text('Vender'),
        ),
        PopupMenuButton<String>(
          key: const Key('asset-more'),
          tooltip: 'Mais ações',
          onSelected: (v) => switch (v) {
            'edit' => showAssetDialog(
              context,
              initial: asset,
              terms: snap.fixedIncome[asset.id],
            ),
            'price' => showValuationDialog(context, snap, asset),
            'operation' => showOperationEditor(
              context,
              snap,
              assetId: asset.id,
            ),
            _ => _refresh(context, ref),
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar ativo')),
            const PopupMenuItem(
              value: 'price',
              key: Key('inform-price'),
              child: Text('Informar preço ou saldo'),
            ),
            PopupMenuItem(
              value: 'operation',
              enabled: snap.accounts.isNotEmpty,
              child: const Text('Outra operação'),
            ),
            if (asset.assetClass != AssetClass.cash)
              PopupMenuItem(
                value: 'refresh',
                enabled: !busy,
                child: const Text('Atualizar este ativo'),
              ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: numbers),
              const SizedBox(height: 8),
              actions,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.55,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [numbers, const SizedBox(height: 8), actions],
              ),
            ),
          ],
        );
      },
    );
  }

  void _refresh(BuildContext context, WidgetRef ref) {
    unawaited(() async {
      final result = await ref
          .read(marketRefreshProvider.notifier)
          .run('Atualização de ${asset.symbol}', (s) => s.refreshAsset(asset));
      if (context.mounted) showInfo(context, MarketLabels.result(result));
    }());
  }
}

/// Cartões com os números da carteira, em grade larga.
class _CardsGrid extends StatelessWidget {
  const _CardsGrid({
    required this.snap,
    required this.asset,
    required this.holding,
    required this.all,
  });

  final PortfolioSnapshot snap;
  final Asset asset;
  final Holding? holding;
  final List<Holding> all;

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final c = asset.currency;
    final note = h?.priced == null
        ? null
        : MarketLabels.valuation(h!.priced!, snap.asOf);
    final share = h == null ? null : Holdings.shareOf(h, all);
    final unrealized = h?.unrealizedPnl;
    final cost = h?.totalCost ?? Decimal.zero;
    final unrealizedPct = unrealized == null || cost <= Decimal.zero
        ? null
        : DecimalMath.divide(unrealized, cost);
    final current =
        h?.unitPrice ??
        (asset.priceSource == PriceSource.market
            ? snap.marketPrices[asset.id]?.price
            : null);
    final noPosition = h == null || !h.isOpen;
    final cards = <Widget>[
      _NumberCard(
        'Total aplicado',
        noPosition ? const Text('—') : Text(Fmt.money(h.totalCost, c)),
        note: 'Preço médio × quantidade',
      ),
      _NumberCard(
        'Preço médio',
        h?.averagePrice == null
            ? const Text('—')
            : Text(Fmt.money(h!.averagePrice!, c)),
        note: (h?.quantity ?? Decimal.zero) > Decimal.zero
            ? '${Fmt.number(h!.quantity)} '
                  '${h.quantity == Decimal.one ? 'cota' : 'cotas'}'
            : null,
      ),
      _NumberCard(
        'Cotação atual',
        current == null
            ? null
            : Tooltip(
                message: note?.message ?? '',
                child: Text(
                  Fmt.money(current, c),
                  key: const Key('card-price'),
                ),
              ),
        note: note?.short,
        unavailable: asset.priceSource == PriceSource.market
            ? 'Sem cotação guardada. Use "Atualizar este ativo".'
            : 'O ativo usa preço ou saldo informado.',
      ),
      _NumberCard(
        'Lucro não realizado',
        noPosition
            ? const Text('—')
            : unrealized == null
            ? null
            : PnlText(
                value: unrealized,
                text:
                    '${Fmt.signedMoney(unrealized, c)}'
                    '${unrealizedPct == null ? '' : ' (${Fmt.percent(unrealizedPct)})'}',
              ),
        note: 'Valor da posição − total aplicado',
        unavailable: 'Precisa do valor da posição.',
      ),
      _NumberCard(
        'Lucro realizado',
        PnlText(
          value: h?.realizedPnl ?? Decimal.zero,
          text: Fmt.signedMoney(h?.realizedPnl ?? Decimal.zero, c),
        ),
        note: 'Vendas, líquidas de custos',
      ),
      _NumberCard(
        'Proventos recebidos',
        Text(Fmt.money(h?.incomeNet ?? Decimal.zero, c)),
        note: 'Líquidos, todas as corretoras',
      ),
      _NumberCard(
        '% da carteira',
        noPosition
            ? const Text('—')
            : share == null
            ? null
            : Text(Fmt.percent(share, signed: false)),
        note: 'Pelo valor das posições em $c',
        unavailable: 'Precisa do valor da posição.',
      ),
      _BrokersCard(snap: snap, asset: asset, holding: h),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard(this.label, this.value, {this.note, this.unavailable});

  final String label;

  /// Nulo mostra "indisponível" com [unavailable] no tooltip.
  final Widget? value;
  final String? note;
  final String? unavailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      key: Key('card-$label'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 2),
            DefaultTextStyle.merge(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              child: value ?? UnavailableText(tooltip: unavailable),
            ),
            Text(
              note ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quebra por corretora: quantidade, preço médio e valor em cada uma.
class _BrokersCard extends StatelessWidget {
  const _BrokersCard({
    required this.snap,
    required this.asset,
    required this.holding,
  });

  final PortfolioSnapshot snap;
  final Asset asset;
  final Holding? holding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final c = asset.currency;
    final open = [
      for (final v in holding?.positions ?? const <ValuedPosition>[])
        if (v.position.isOpen) v,
    ];
    return Card(
      key: const Key('card-Por corretora'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por corretora',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 2),
            if (open.isEmpty) Text('—', style: theme.textTheme.titleLarge),
            for (final v in open)
              Tooltip(
                message:
                    '${snap.accountLabel(v.position.accountId)}: '
                    '${Fmt.number(v.position.quantity)} × preço médio '
                    '${v.position.averagePrice == null ? '—' : Fmt.money(v.position.averagePrice!, c)}',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        snap.institutionOfAccount(v.position.accountId)?.name ??
                            '?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${Fmt.number(v.position.quantity)} · '
                        '${v.marketValue == null ? 'indisponível' : Fmt.money(v.marketValue!, c)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Abas inferiores: operações, proventos por mês e dados do ativo.
class _Tabs extends StatefulWidget {
  const _Tabs({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> with SingleTickerProviderStateMixin {
  late final _controller = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    final asset = widget.asset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(key: Key('tab-operations'), text: 'Operações'),
            Tab(key: Key('tab-income'), text: 'Proventos'),
            Tab(key: Key('tab-data'), text: 'Dados do ativo'),
          ],
        ),
        const SizedBox(height: 12),
        switch (_controller.index) {
          0 => SizedBox(
            height: 480,
            child: OperationsTable(snap: snap, assetId: asset.id),
          ),
          1 => _IncomeByMonth(snap: snap, asset: asset),
          _ => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AssetDataCard(asset: asset),
              if (asset.assetClass != AssetClass.cash)
                _MarketCard(snap: snap, asset: asset),
              if (snap.fixedIncome[asset.id] != null)
                _TermsCard(terms: snap.fixedIncome[asset.id]!),
              _PerformanceCard(snap: snap, asset: asset),
              _ValuationsCard(snap: snap, asset: asset),
            ],
          ),
        },
      ],
    );
  }
}

/// Proventos recebidos do ativo, por mês (operações de proventos).
class _IncomeByMonth extends StatelessWidget {
  const _IncomeByMonth({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final byMonth = <LocalDate, List<Operation>>{};
    for (final o in snap.operations) {
      if (o.assetId != asset.id || !o.type.isIncome) continue;
      final key = LocalDate(o.tradeDate.year, o.tradeDate.month, 1);
      (byMonth[key] ??= []).add(o);
    }
    final months = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    if (months.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Nenhum provento registrado. Registre dividendos, JCP e rendimentos '
          'em "Outra operação" ou em Operações.',
          style: muted,
        ),
      );
    }
    final c = asset.currency;
    var total = Decimal.zero;
    for (final ops in byMonth.values) {
      for (final o in ops) {
        total += o.amount;
      }
    }
    return Card(
      key: const Key('income-by-month'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total recebido: ${Fmt.money(total, c)} (bruto)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final m in months)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 90, child: Text(Fmt.monthShort(m))),
                    Expanded(
                      child: Text(
                        {for (final o in byMonth[m]!) o.type.label}.join(', '),
                        style: muted,
                      ),
                    ),
                    Text(
                      Fmt.money(
                        byMonth[m]!.fold(Decimal.zero, (s, o) => s + o.amount),
                        c,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Setor, segmento, ISIN e as demais características do cadastro.
class _AssetDataCard extends StatelessWidget {
  const _AssetDataCard({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: const Key('asset-data'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cadastro', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric('Classe', asset.assetClass.label),
                _Metric('Mercado', asset.market.label),
                _Metric('Moeda', asset.currency),
                _Metric('Setor', asset.sector ?? '—'),
                _Metric('Segmento', asset.segment ?? '—'),
                _Metric('ISIN', asset.isin ?? '—'),
                _Metric(
                  'Fonte do preço',
                  asset.priceSource == PriceSource.market
                      ? 'Cotação automática'
                      : 'Informado por você',
                ),
                if (asset.notes != null) _Metric('Observações', asset.notes),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Desempenho do ativo em todas as contas: resultado em dinheiro e TIR
/// (MWR) líquida, sem proventos e bruta (SPEC §9).
class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final p = snap.assetPerformance(asset.id);
    if (p == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final c = asset.currency;
    final reason = p.gap?.label;
    String? money(Decimal? v) => v == null ? null : Fmt.signedMoney(v, c);
    return Card(
      key: const Key('asset-performance'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Desempenho', style: theme.textTheme.titleMedium),
                const SizedBox(width: 4),
                Tooltip(
                  message: ReturnMethod.mwr.description,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                    semanticLabel: 'Sobre a métrica',
                  ),
                ),
              ],
            ),
            Text(
              p.net == null
                  ? 'Todas as contas. ${reason ?? ''}'
                  : 'Todas as contas, ${p.net!.range}. TIR (MWR): '
                        'ponderada pelo dinheiro, com o valor de mercado como '
                        'fluxo final.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric('Resultado total', money(p.totalResult), reason),
                _Metric(
                  'Resultado sem proventos',
                  money(p.resultWithoutIncome),
                  reason,
                ),
                _Metric('TIR líquida, com proventos', p.net?.text, reason),
                _Metric('TIR sem proventos', p.netWithoutIncome?.text, reason),
                _Metric('TIR bruta (antes de custos)', p.gross?.text, reason),
                _Metric('Aplicado', Fmt.money(p.invested, c)),
                _Metric('Vendas e resgates', Fmt.money(p.returned, c)),
                _Metric('Custos e impostos', Fmt.money(p.costs, c)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, [this.unavailableReason]);

  final String label;

  /// Nulo mostra "indisponível".
  final String? value;

  /// Motivo mostrado no tooltip de "indisponível".
  final String? unavailableReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (value == null)
          UnavailableText(tooltip: unavailableReason)
        else
          SelectableText(value!, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard({required this.terms});

  final FixedIncomeTerms terms;

  @override
  Widget build(BuildContext context) {
    final rate = terms.indexer == Indexer.pre
        ? '${Fmt.number(terms.rate)}% a.a.'
        : '${Fmt.number(terms.rate)}% do ${terms.indexer.label}'
              '${terms.spread == null ? '' : ' + ${Fmt.number(terms.spread!)}% a.a.'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características do título',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric('Produto', terms.product.label),
                _Metric('Emissor', terms.issuer ?? '—'),
                _Metric('Taxa', rate),
                _Metric('Emissão', Fmt.date(terms.issueDate)),
                _Metric('Vencimento', Fmt.date(terms.maturityDate)),
                _Metric(
                  'Carência',
                  terms.graceUntil == null ? '—' : Fmt.date(terms.graceUntil!),
                ),
                _Metric('Liquidez', terms.liquidity.label),
                _Metric('Base', terms.dayCount.label),
                _Metric('Tributação', terms.taxRegime.label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValuationsCard extends ConsumerWidget {
  const _ValuationsCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final valuations = snap.valuations
        .where((v) => v.assetId == asset.id)
        .take(20)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preços e saldos informados',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              'Fonte: informado por você. Num ativo com preço de mercado, vale o '
              'mais recente entre o informado e a cotação (na mesma data, o '
              'informado).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (valuations.isEmpty)
              Text(
                'Nenhum valor informado: o valor de mercado fica '
                'indisponível.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            for (final v in valuations)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  v.kind == ValuationKind.balance
                      ? Icons.account_balance_wallet_outlined
                      : Icons.sell_outlined,
                  size: 20,
                ),
                title: Text(
                  '${Fmt.money(v.value, v.currency)} em ${Fmt.date(v.refDate)}',
                ),
                subtitle: Text(
                  v.kind == ValuationKind.balance
                      ? 'Saldo · ${snap.accountLabel(v.accountId!)}'
                      : 'Preço unitário',
                ),
                trailing: IconButton(
                  tooltip: 'Excluir valor',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final ok = await confirm(
                      context,
                      title: 'Excluir este valor?',
                      message: 'O valor de mercado passa a usar o anterior.',
                    );
                    if (!ok) return;
                    try {
                      await ref.read(valuationServiceProvider).delete(v.id);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dados de mercado guardados de um ativo.
typedef _AssetMarketData = ({
  List<MarketQuote> quotes,
  (LocalDate, LocalDate, int)? range,
  int events,
  String? isin,
});

final _assetMarketProvider =
    StreamProvider.family<_AssetMarketData, (String, String)>((ref, key) {
      final repo = ref.watch(marketRepositoryProvider);
      final (symbol, market) = key;
      Future<_AssetMarketData> load() async => (
        quotes: await repo.quotes(symbol, market),
        range: await repo.priceRange(symbol, market),
        events: (await repo.events(symbol, market)).length,
        isin: await repo.isinOf(symbol, market),
      );
      final controller = StreamController<_AssetMarketData>();
      Future<void> emit() async {
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      }

      unawaited(emit());
      final sub = repo.watchChanges().listen((_) => unawaited(emit()));
      ref.onDispose(() {
        unawaited(sub.cancel());
        unawaited(controller.close());
      });
      return controller.stream;
    });

/// Cotação usada, fonte e data, histórico guardado e atualização deste
/// ativo (SPEC §5: atualizar um ativo; regra 2).
class _MarketCard extends ConsumerWidget {
  const _MarketCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    String task,
    Future<RefreshResult> Function(MarketDataService s) job,
  ) async {
    final result = await ref
        .read(marketRefreshProvider.notifier)
        .run(task, job);
    if (context.mounted) showInfo(context, MarketLabels.result(result));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final busy = ref.watch(marketRefreshProvider).busy;
    final backfilling = ref.watch(historyBackfillProvider).running;
    final data = ref
        .watch(
          _assetMarketProvider((asset.symbol.toUpperCase(), asset.market.code)),
        )
        .value;
    final used =
        snap.valued
            .map((v) => v.marketPrice)
            .whereType<MarketPrice>()
            .where((p) => p.assetId == asset.id)
            .firstOrNull ??
        (asset.priceSource == PriceSource.market
            ? snap.marketPrices[asset.id]
            : null);
    final manual = asset.priceSource != PriceSource.market;
    final stale =
        used != null &&
        MarketPricing.isStale(used, snap.asOf, market: asset.market.code);
    final range = data?.range;
    return Card(
      key: const Key('asset-market'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dados de mercado', style: theme.textTheme.titleMedium),
            if (manual)
              Text(
                'Este ativo usa preço informado por você. Para usar cotações '
                'automáticas, escolha "preço de mercado" em Editar.',
                style: muted,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric(
                  'Preço de mercado usado',
                  used == null ? null : Fmt.money(used.price, used.currency),
                  manual
                      ? 'O ativo usa preço informado.'
                      : 'Sem cotação guardada para este ativo.',
                ),
                if (used != null) ...[
                  _Metric('Fonte', ProviderCatalog.nameOf(used.source)),
                  _Metric(
                    'Data de referência',
                    stale
                        ? '${MarketLabels.refOf(used)} (desatualizado)'
                        : MarketLabels.refOf(used),
                  ),
                  _Metric('Tipo', used.dataType.label),
                  _Metric('Coleta', SyncLabels.instant(used.collectedAt)),
                  if (used.delayNote != null) _Metric('Atraso', used.delayNote),
                ],
                _Metric(
                  'Histórico guardado',
                  range == null
                      ? 'nenhum'
                      : '${range.$3} pregões, de ${Fmt.date(range.$1)} a '
                            '${Fmt.date(range.$2)}',
                ),
                if (data != null && data.events > 0)
                  _Metric('Proventos e eventos', '${data.events} guardados'),
                if (asset.isin == null && data?.isin != null)
                  _Metric('ISIN (da fonte)', data!.isin),
              ],
            ),
            if (data != null && data.quotes.length > 1) ...[
              const SizedBox(height: 8),
              Text('Cotações guardadas por fonte', style: muted),
              for (final q in data.quotes)
                Text(
                  '${ProviderCatalog.nameOf(q.source)}: '
                  '${Fmt.money(q.price, q.currency)} · '
                  '${SyncLabels.instant(formatInstant(q.refAt))}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('asset-refresh'),
                  onPressed: busy
                      ? null
                      : () => _run(
                          context,
                          ref,
                          'Atualização de ${asset.symbol}',
                          (s) => s.refreshAsset(asset),
                        ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Atualizar este ativo'),
                ),
                OutlinedButton.icon(
                  key: const Key('asset-history'),
                  onPressed:
                      backfilling ||
                          asset.priceSource != PriceSource.market ||
                          !ref
                              .watch(marketDataServiceProvider)
                              .hasHistorySource(asset)
                      ? null
                      : () => _downloadHistory(context, ref, asset),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Baixar histórico completo'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'O histórico é o preço publicado pela fonte, sem ajuste (o '
              'gráfico calcula o ajustado). É baixado em segundo plano desde o '
              'ano escolhido em Fontes de dados; na B3, do COTAHIST. "Baixar '
              'histórico completo" lê de novo todos os anos deste ativo.',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}
