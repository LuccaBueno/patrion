import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/config/app_info.dart';
import '../../../domain/finance/returns.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/market_indicators.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/portfolio/portfolio_summary.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../format/performance_format.dart';
import '../../providers.dart';
import '../market/data_sources_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';
import 'dashboard_charts.dart';
import '../../../domain/portfolio/dashboard_metrics.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../../core/money/decimal_math.dart';
import '../sync/sync_screen.dart';
import '../updates/update_widgets.dart';
import '../portfolio/add_asset_dialog.dart';
import '../../router/app_router.dart';
import '../../../application/portfolio/wealth_service.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/wealth_history.dart';
import 'market_strip.dart';
import 'wealth_chart.dart';

/// Dashboard da carteira real (SPEC §8).
///
/// Mostra só o que os dados sustentam hoje: totais, resultado, TIR (MWR),
/// proventos, alocação, maiores posições e vencimentos. TWR, rentabilidade
/// por período, evolução e benchmarks dependem do histórico de cotações
/// (F6).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return AsyncBody(
      value: snapshot,
      builder: (snap) =>
          snap.summary.isEmpty ? _Welcome(snap: snap) : _Dashboard(snap: snap),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.snap});

  final PortfolioSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, message, label, route) = snap.accounts.isEmpty
        ? (
            'Nenhum investimento registrado',
            'Adicione as ações, FIIs, ETFs e BDRs que você já tem: digite o '
                'ticker, a quantidade e o preço médio da corretora. Renda '
                'fixa, cripto e internacional ficam em Configurações → Corretoras e '
                'ativos.',
            'Corretoras e ativos',
            Routes.registry,
          )
        : (
            'Nenhuma operação registrada',
            'Adicione um ativo pelo ticker ou registre compras, aportes, '
                'depósitos e proventos em Operações.',
            'Ir para Operações',
            Routes.operations,
          );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppInfo.name.toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: SemanticColors.of(context).brandAccent,
              letterSpacing: 6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(AppInfo.subtitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 32),
          const UpdateReminder(),
          MessageCard(
            icon: Icons.info_outline,
            title: title,
            message: message,
            action: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('welcome-add-asset'),
                  onPressed: () => showAddAssetDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar ativo'),
                ),
                OutlinedButton(
                  onPressed: () => context.go(route),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends ConsumerStatefulWidget {
  const _Dashboard({required this.snap});

  final PortfolioSnapshot snap;

  @override
  ConsumerState<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<_Dashboard> {
  String? _currency;

  @override
  Widget build(BuildContext context) {
    final summary = widget.snap.summary;
    final currencies = summary.currencies();
    final currency = currencies.contains(_currency)
        ? _currency!
        : currencies.first;
    final totals = summary.byCurrency[currency]!;
    final performance = widget.snap.performance(currency);
    final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
    final holdings = Holdings.build(
      widget.snap.valued,
      toBrl: {
        for (final MapEntry(:key, :value) in fx.entries)
          if (value.mid != null) key: value.mid!,
      },
    );
    final day = DashboardMetrics.dayChange(holdings, currency);
    final total = performance.totalResult;
    // Resultado total sobre o dinheiro aplicado (FORMULAS §3.1).
    final totalFraction = total == null || performance.invested <= Decimal.zero
        ? null
        : DecimalMath.divide(total, performance.invested);
    final months = DashboardMetrics.monthly(
      widget.snap.operations,
      currency: currency,
      asOf: widget.snap.asOf,
    );
    final theme = Theme.of(context);
    final wealth = ref.watch(wealthOverviewProvider);
    final overview = wealth.value;
    final height = MediaQuery.sizeOf(context).height;
    final contributions12m = months.fold(Decimal.zero, (a, m) => a + m.buys);
    final income12m = months.fold(Decimal.zero, (a, m) => a + m.income);

    return PageScaffold(
      title: 'Painel',
      subtitle: summary.lastValuationDate == null
          ? 'Carteira real · nenhum preço informado ainda'
          : 'Carteira real · preços e saldos até '
                '${Fmt.date(summary.lastValuationDate!)}',
      actions: [
        const RefreshButton(),
        if (currencies.length > 1)
          SegmentedButton<String>(
            segments: [
              for (final c in currencies)
                ButtonSegment(value: c, label: Text(c)),
            ],
            selected: {currency},
            onSelectionChanged: (s) => setState(() => _currency = s.single),
          ),
      ],
      child: ListView(
        key: const Key('dashboard-list'),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const RefreshStatusBanner(),
          const QuotaWarningBanner(),
          if (currencies.length > 1 || currencies.first != 'BRL')
            _ConsolidatedCard(summary: summary, fx: fx),
          const SyncReminder(),
          const UpdateReminder(),
          ..._warnings(context, summary),
          // Faixa de números (M-09): quanto tenho, quanto coloquei, quanto
          // rendeu e a rentabilidade no ano.
          _HeroRow(
            children: [
              StatCard(
                key: const Key('stat-equity'),
                big: true,
                label: 'Patrimônio',
                value: Fmt.money(totals.equity, currency),
                note: totals.isPartial
                    ? 'Parcial: ${totals.unpricedCount} '
                          '${totals.unpricedCount == 1 ? 'posição sem preço' : 'posições sem preço'} '
                          '(custo de ${Fmt.money(totals.unpricedCost, currency)} '
                          'fora do total)'
                    : summary.trackCash
                    ? 'Valor de mercado + caixa'
                    : 'Valor de mercado das posições',
                footer: _DayChange(day: day, currency: currency),
              ),
              StatCard(
                key: const Key('stat-applied'),
                big: true,
                label: 'Total aplicado',
                value: overview == null || currency != 'BRL'
                    ? null
                    : Fmt.money(
                        _last(overview)?.invested ?? Decimal.zero,
                        'BRL',
                      ),
                unavailableReason: currency != 'BRL'
                    ? 'A evolução e o aplicado são calculados em reais.'
                    : 'Calculando…',
                info:
                    'Aportes acumulados (compras com custos) menos resgates '
                    '(vendas, líquidas de custos), dos ativos com preço.',
                note: 'Aportes − resgates',
              ),
              StatCard(
                key: const Key('stat-gain'),
                big: true,
                label: 'Ganho',
                pnl: _last(overview)?.gain,
                value: _last(overview) == null || currency != 'BRL'
                    ? null
                    : '${Fmt.signedMoney(_last(overview)!.gain, 'BRL')}'
                          '${_last(overview)!.gainFraction == null ? '' : ' (${Fmt.percent(_last(overview)!.gainFraction!)})'}',
                unavailableReason: currency != 'BRL'
                    ? 'A evolução e o ganho são calculados em reais.'
                    : 'Calculando…',
                info:
                    'Patrimônio das posições − total aplicado. Os proventos '
                    'recebidos ficam de fora (estão em Proventos).',
                note: 'Patrimônio − aplicado',
              ),
              StatCard(
                key: const Key('stat-ytd'),
                big: true,
                label: 'Rentabilidade no ano',
                pnl: _ytd(overview, widget.snap.asOf),
                value: _ytd(overview, widget.snap.asOf) == null
                    ? null
                    : Fmt.percent(_ytd(overview, widget.snap.asOf)!),
                unavailableReason: overview == null
                    ? 'Calculando…'
                    : 'Sem histórico de preços suficiente neste ano.',
                info: ReturnMethod.twr.description,
                note:
                    'TWR desde 31/12/${widget.snap.asOf.year - 1}, com '
                    'proventos',
              ),
            ],
          ),
          const SizedBox(height: 16),
          WealthChartCard(
            key: const Key('wealth'),
            overview: currency == 'BRL' ? overview : null,
            assets: widget.snap.assets,
            // Cerca de metade da altura da janela (M-09).
            height: (height * 0.42).clamp(260.0, 520.0),
          ),
          const SizedBox(height: 16),
          _ChartsGrid(
            children: [
              DistributionCard(
                currency: currency,
                total: totals.marketValue,
                views: [
                  DistributionView(
                    'Ativo',
                    _slices([
                      for (final h in holdings)
                        if (h.currency == currency && h.marketValue != null)
                          (h.asset?.symbol ?? '?', h.marketValue!),
                    ]),
                  ),
                  DistributionView(
                    'Classe',
                    summary.allocation(
                      currency,
                      (v) => v.asset?.assetClass.label ?? '?',
                    ),
                  ),
                  DistributionView(
                    'Setor',
                    summary.allocation(
                      currency,
                      (v) => v.asset?.sector ?? 'Sem setor informado',
                      includeCash: false,
                    ),
                    subtitle: 'Por setor do cadastro do ativo',
                  ),
                  DistributionView(
                    'Corretora',
                    summary.allocation(
                      currency,
                      (v) =>
                          widget.snap
                              .institutionOfAccount(v.position.accountId)
                              ?.name ??
                          '?',
                      includeCash: false,
                    ),
                  ),
                ],
              ),
              DashCard(
                key: const Key('dash-contributions'),
                title:
                    'Você aportou ${Fmt.money(contributions12m, currency)} em '
                    '12 meses',
                subtitle:
                    'No mês ${Fmt.money(months.last.buys, currency)} · no ano '
                    '${Fmt.money(DashboardMetrics.investedInYear(widget.snap.operations, currency: currency, asOf: widget.snap.asOf), currency)}'
                    ' · compras com custos; o saldo inicial não conta',
                child: MonthlyBars(
                  months: months,
                  currency: currency,
                  series: [
                    BarSeries(
                      'Compras e aportes',
                      (m) => m.buys,
                      colorOf: (c) => SemanticColors.of(c).gain,
                    ),
                    BarSeries(
                      'Vendas e resgates',
                      (m) => m.sells,
                      colorOf: (c) => Theme.of(c).colorScheme.outline,
                    ),
                  ],
                ),
              ),
              DashCard(
                key: const Key('dash-income'),
                title:
                    'Você recebeu ${Fmt.money(income12m, currency)} de '
                    'proventos em 12 meses',
                subtitle: 'Líquidos, por mês de pagamento registrado',
                child: MonthlyBars(
                  months: months,
                  currency: currency,
                  series: [
                    BarSeries(
                      'Proventos',
                      (m) => m.income,
                      colorOf: (c) => Theme.of(c).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              _MoversCard(holdings: holdings, currency: currency),
            ],
          ),
          const SizedBox(height: 24),
          Text('Mais números', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(
                key: const Key('stat-total-result'),
                label: 'Resultado total',
                pnl: performance.totalResult,
                value: performance.totalResult == null
                    ? null
                    : Fmt.signedMoney(performance.totalResult!, currency),
                unavailableReason: performance.gap?.label,
                note: totalFraction == null
                    ? 'Realizado + não realizado + proventos, líquido de '
                          'custos e impostos'
                    : '${Fmt.percent(totalFraction)} sobre o aplicado '
                          '(${Fmt.money(performance.invested, currency)}); '
                          'realizado + não realizado + proventos',
              ),
              StatCard(
                key: const Key('stat-invested'),
                label: 'Valor investido',
                value: Fmt.money(totals.invested, currency),
                note: 'Custo das posições abertas, com custos de compra',
              ),
              StatCard(
                key: const Key('stat-market'),
                label: 'Valor de mercado',
                value: Fmt.money(totals.marketValue, currency),
                note: 'Só posições com preço, cotação ou saldo',
              ),
              if (summary.trackCash)
                StatCard(
                  key: const Key('stat-cash'),
                  label: 'Caixa',
                  value: Fmt.money(totals.cash, currency),
                  note: 'Depósitos, vendas e proventos menos compras e saídas',
                ),
              StatCard(
                key: const Key('stat-unrealized'),
                label: 'Resultado não realizado',
                pnl: totals.unrealizedPnl,
                value: Fmt.signedMoney(totals.unrealizedPnl, currency),
                info: ReturnMethod.simple.description,
                note: totals.simpleReturn == null
                    ? 'Valor de mercado − custo, sem proventos'
                    : '${Fmt.percent(totals.simpleReturn!)} sobre o custo '
                          '(retorno simples, sem proventos)',
              ),
              StatCard(
                key: const Key('stat-mwr'),
                label: 'Rentabilidade (TIR)',
                pnl: performance.net?.annual,
                value: performance.net?.text,
                info: ReturnMethod.mwr.description,
                unavailableReason: performance.gap?.label,
                note: performance.net == null
                    ? 'Ponderada pelo dinheiro (MWR), dos investimentos'
                    : 'MWR dos investimentos ${performance.net!.range}, '
                          'líquida de custos, com proventos; sem o caixa',
              ),
              StatCard(
                key: const Key('stat-realized'),
                label: 'Lucro realizado',
                pnl: totals.realizedPnl,
                value: Fmt.signedMoney(totals.realizedPnl, currency),
                note: 'Vendas, resgates e vencimentos, líquidos de custos',
              ),
              StatCard(
                key: const Key('stat-income'),
                label: 'Proventos recebidos',
                value: Fmt.money(totals.incomeNet, currency),
                note:
                    'Líquidos · bruto ${Fmt.money(totals.incomeGross, currency)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TopPositionsCard(snap: widget.snap, currency: currency),
          if (summary.upcomingMaturities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MaturitiesCard(items: summary.upcomingMaturities),
          ],
          const SizedBox(height: 16),
          const MarketStrip(),
        ],
      ),
    );
  }

  static WealthPoint? _last(WealthOverview? o) =>
      o == null || o.series.isEmpty ? null : o.series.points.last;

  /// TWR do ano corrente (desde o último dia do ano anterior).
  static Decimal? _ytd(WealthOverview? o, LocalDate today) =>
      o?.series.twrBetween(LocalDate(today.year - 1, 12, 31), today);

  List<Widget> _warnings(BuildContext context, PortfolioSummary summary) {
    final snap = widget.snap;
    final widgets = <Widget>[];
    if (summary.negativeCashAccounts.isNotEmpty) {
      final names = summary.negativeCashAccounts
          .map(snap.accountLabel)
          .join(', ');
      widgets.add(
        _Warning(
          'Caixa negativo em $names. Registre os depósitos (ou o saldo '
          'inicial como depósito) para o caixa e o patrimônio ficarem '
          'corretos.',
        ),
      );
    }
    if (summary.issues.isNotEmpty) {
      widgets.add(
        _Warning(
          '${summary.issues.length} '
          '${summary.issues.length == 1 ? 'operação inconsistente' : 'operações inconsistentes'} '
          '(por exemplo, venda maior que a posição ou transferência sem uma '
          'das pontas). Confira em Operações.',
        ),
      );
    }
    return widgets;
  }
}

class _Warning extends StatelessWidget {
  const _Warning(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.warning_amber_outlined,
            color: theme.colorScheme.error,
            semanticLabel: 'Aviso',
          ),
          title: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}

class _TopPositionsCard extends StatelessWidget {
  const _TopPositionsCard({required this.snap, required this.currency});

  final PortfolioSnapshot snap;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = snap.summary.topPositions(currency);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Maiores posições',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/carteira'),
                  child: const Text('Ver carteira'),
                ),
              ],
            ),
            if (top.isEmpty)
              const UnavailableText(
                tooltip: 'Informe preços ou saldos para ordenar as posições.',
              ),
            for (final v in top)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () =>
                    context.go('/carteira/ativo/${v.position.assetId}'),
                title: Text(v.asset?.symbol ?? '?'),
                subtitle: Text(snap.accountLabel(v.position.accountId)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Fmt.money(v.marketValue!, currency)),
                    if (v.unrealizedPnl != null)
                      PnlText(
                        value: v.unrealizedPnl!,
                        text: v.simpleReturn == null
                            ? Fmt.signedMoney(v.unrealizedPnl!, currency)
                            : Fmt.percent(v.simpleReturn!),
                        style: theme.textTheme.bodySmall,
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

class _MaturitiesCard extends StatelessWidget {
  const _MaturitiesCard({required this.items});

  final List<UpcomingMaturity> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vencimentos nos próximos 90 dias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final m in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.event_outlined),
                onTap: () => context.go('/carteira/ativo/${m.asset.id}'),
                title: Text('${m.asset.symbol} — ${m.asset.name}'),
                trailing: Text(
                  '${Fmt.date(m.maturityDate)} · '
                  '${m.daysLeft == 0 ? 'hoje' : 'em ${m.daysLeft} dias'}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Patrimônio de todas as moedas em reais, pelo câmbio mais recente
/// guardado (`docs/FORMULAS.md` §2.3). Sem o câmbio de alguma moeda, fica
/// indisponível.
class _ConsolidatedCard extends StatelessWidget {
  const _ConsolidatedCard({required this.summary, required this.fx});

  final PortfolioSummary summary;
  final Map<String, FxRate> fx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final total = ConsolidatedEquity.build(summary.byCurrency, fx);
    final missing = [
      for (final c in summary.byCurrency.keys)
        if (c != 'BRL' && fx[c]?.mid == null) c,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('stat-consolidated'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patrimônio total em reais',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (total == null)
                UnavailableText(
                  tooltip:
                      'Falta o câmbio de ${missing.join(', ')}. Atualize os '
                      'dados de mercado com internet.',
                )
              else
                Text(
                  Fmt.money(total.equity, 'BRL'),
                  style: theme.textTheme.titleLarge,
                ),
              const SizedBox(height: 4),
              Text(
                total == null
                    ? 'Cada moeda continua com seus próprios totais abaixo.'
                    : [
                        if (total.partial) 'Parcial (há posições sem preço).',
                        for (final MapEntry(key: c, value: r)
                            in total.rates.entries)
                          '$c a ${MarketLabels.fx(r.mid!)} '
                              '(${MarketLabels.fxKind(r.kind)} de '
                              '${Fmt.date(r.refDate)}, '
                              '${ProviderCatalog.nameOf(r.source)})',
                        'Os totais por moeda estão abaixo.',
                      ].join(' · '),
                style: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Destaques do topo (M-04): patrimônio, resultado total e variação do dia,
/// lado a lado (um embaixo do outro em janelas estreitas).
class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) return Column(children: children);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, c) in children.indexed) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: c),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Cartões de gráfico em duas colunas (uma em janelas estreitas).
class _ChartsGrid extends StatelessWidget {
  const _ChartsGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in children)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < children.length; i += 2)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + 2 < children.length ? 16 : 0,
                ),
                // Sem IntrinsicHeight: a medição intrínseca subestima alguns
                // cartões (texto que quebra linha) e corta o conteúdo.
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: children[i]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: i + 1 < children.length
                          ? children[i + 1]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Fatias de uma distribuição por chave, do maior valor para o menor.
List<AllocationSlice<String?>> _slices(List<(String, Decimal)> values) {
  final total = values.fold(Decimal.zero, (a, v) => a + v.$2);
  if (total <= Decimal.zero) return const [];
  return [
    for (final (key, value) in values)
      if (value > Decimal.zero)
        AllocationSlice<String?>(key, value, DecimalMath.divide(value, total)),
  ]..sort((a, b) => b.value.compareTo(a.value));
}

/// Maiores altas e baixas da carteira, no dia ou no mês (M-04).
class _MoversCard extends StatefulWidget {
  const _MoversCard({required this.holdings, required this.currency});

  final List<Holding> holdings;
  final String currency;

  @override
  State<_MoversCard> createState() => _MoversCardState();
}

class _MoversCardState extends State<_MoversCard> {
  bool _month = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final movers = DashboardMetrics.movers([
      for (final h in widget.holdings)
        if (h.currency == widget.currency) h,
    ], month: _month);
    final ups = movers.where((m) => m.change.perUnit > Decimal.zero).take(3);
    final downs = movers.reversed
        .where((m) => m.change.perUnit < Decimal.zero)
        .take(3);

    Widget column(String title, Iterable<Mover> list) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          if (list.isEmpty) Text('Nenhuma', style: muted),
          // Linhas simples (sem ListTile): a altura entra certa na grade.
          for (final m in list)
            InkWell(
              onTap: () => context.go(Routes.asset(m.holding.assetId)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.holding.asset?.symbol ?? '?'),
                          Text(
                            'desde ${Fmt.date(m.change.from.refDate)} · '
                            '${Fmt.money(m.change.to, widget.currency)}',
                            style: muted,
                          ),
                        ],
                      ),
                    ),
                    PnlText(
                      value: m.change.perUnit,
                      text: Fmt.percent(m.change.fraction),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return DashCard(
      key: const Key('dash-movers'),
      title: 'Maiores altas e baixas',
      subtitle: _month
          ? 'Cotação atual contra o fechamento do mês anterior'
          : 'Cotação atual contra o fechamento anterior',
      trailing: SegmentedButton<bool>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: false, label: Text('Dia')),
          ButtonSegment(value: true, label: Text('Mês')),
        ],
        selected: {_month},
        onSelectionChanged: (s) => setState(() => _month = s.single),
      ),
      child: movers.isEmpty
          ? Text(
              'Indisponível: nenhum ativo com cotação de mercado e o '
              'fechamento de referência guardado. Use "Atualizar agora".',
              style: muted,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                column('Altas', ups),
                const SizedBox(width: 24),
                column('Baixas', downs),
              ],
            ),
    );
  }
}

/// Variação do dia embaixo do patrimônio.
class _DayChange extends StatelessWidget {
  const _DayChange({required this.day, required this.currency});

  final PortfolioDayChange? day;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final d = day;
    if (d == null) {
      return Text(
        'Variação do dia indisponível: nenhum ativo com cotação e o '
        'fechamento anterior guardado.',
        key: const Key('stat-day'),
        style: muted,
      );
    }
    return Tooltip(
      message:
          'Cotação atual × fechamento de ${Fmt.date(d.since)}'
          '${d.partial ? ' · parcial: ${d.missing} ${d.missing == 1 ? 'ativo' : 'ativos'} sem a variação' : ''}',
      child: Row(
        key: const Key('stat-day'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hoje ', style: muted),
          Flexible(
            child: PnlText(
              value: d.amount,
              text:
                  '${Fmt.signedMoney(d.amount, currency)} '
                  '(${d.fraction == null ? '—' : Fmt.percent(d.fraction!)})'
                  '${d.partial ? ' · parcial' : ''}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
