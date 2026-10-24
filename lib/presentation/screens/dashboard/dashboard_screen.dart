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
import '../../../domain/portfolio/performance_report.dart';
import 'market_strip.dart';
import 'wealth_chart.dart';
import '../performance/performance_tabs.dart';

/// Abas do Painel (M-11): a Visão geral e as antigas abas do Desempenho.
enum DashboardTab {
  overview('Visão geral', 'visao-geral', 'painel-tab-overview'),
  returns('Rentabilidade', 'rentabilidade', 'perf-tab-returns'),
  benchmarks('Comparação', 'comparacao', 'perf-tab-benchmarks'),
  risk('Risco', 'risco', 'perf-tab-risk');

  const DashboardTab(this.label, this.path, this.key);

  final String label;
  final String path;

  /// Chave do botão da aba (testes).
  final String key;

  String get route =>
      this == overview ? Routes.dashboard : Routes.dashboardTab(path);

  static DashboardTab ofPath(String path) =>
      values.firstWhere((t) => t.path == path, orElse: () => overview);
}

/// Painel da carteira real (SPEC §8 e §16; M-11): Visão geral, com um
/// número grande e poucos blocos, e as abas de rentabilidade, comparação
/// com índices e risco.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({this.tab = DashboardTab.overview, super.key});

  final DashboardTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return AsyncBody(
      value: snapshot,
      builder: (snap) => snap.summary.isEmpty
          ? _Welcome(snap: snap)
          : _Dashboard(snap: snap, tab: tab),
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
  const _Dashboard({required this.snap, required this.tab});

  final PortfolioSnapshot snap;
  final DashboardTab tab;

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
    final performanceTab = switch (widget.tab) {
      DashboardTab.overview => null,
      DashboardTab.returns => PerformanceTab.returns,
      DashboardTab.benchmarks => PerformanceTab.benchmarks,
      DashboardTab.risk => PerformanceTab.risk,
    };
    return PageScaffold(
      title: 'Painel',
      actions: [
        const RefreshButton(),
        if (currencies.length > 1 && performanceTab == null)
          SegmentedButton<String>(
            segments: [
              for (final c in currencies)
                ButtonSegment(value: c, label: Text(c)),
            ],
            selected: {currency},
            onSelectionChanged: (s) => setState(() => _currency = s.single),
          ),
      ],
      child: DefaultTabController(
        length: DashboardTab.values.length,
        initialIndex: widget.tab.index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                key: const Key('painel-tabs'),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                onTap: (i) {
                  final t = DashboardTab.values[i];
                  if (t != widget.tab) context.go(t.route);
                },
                tabs: [
                  for (final t in DashboardTab.values)
                    Tab(key: Key(t.key), text: t.label),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: performanceTab == null
                  ? _overview(context, currency)
                  : PerformanceTabView(tab: performanceTab),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview(BuildContext context, String currency) {
    final snap = widget.snap;
    final summary = snap.summary;
    final currencies = summary.currencies();
    final totals = summary.byCurrency[currency]!;
    final performance = snap.performance(currency);
    final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
    final holdings = Holdings.build(
      snap.valued,
      toBrl: {
        for (final MapEntry(:key, :value) in fx.entries)
          if (value.mid != null) key: value.mid!,
      },
    );
    final day = DashboardMetrics.dayChange(holdings, currency);
    // TIR só com 30 dias de histórico (M-12): em poucos dias, a taxa anual
    // dos fluxos não tem significado.
    final mwrSpan = snap.operations.isEmpty
        ? 0
        : snap.asOf.daysSince(snap.operations.last.tradeDate);
    final mwrShort = mwrSpan < PeriodPerformance.minMwrDays;
    final mwr = mwrShort ? null : performance.net;
    final mwrReason = mwrShort
        ? PerformanceReasons.mwrTooShort(mwrSpan, PeriodPerformance.minMwrDays)
        : performance.gap?.label ?? PerformanceReasons.mwrNoSolution;
    // Uma definição de ganho no app inteiro (M-12; FORMULAS §3.1).
    final priced = snap.pricedPerformance(currency);
    final applied = priced.invested - priced.returned;
    final total = priced.totalResult;
    final totalFraction = total == null || priced.invested <= Decimal.zero
        ? null
        : DecimalMath.divide(total, priced.invested);
    final partial = snap.unpricedAssets.isNotEmpty;
    final months = DashboardMetrics.monthly(
      snap.operations,
      currency: currency,
      asOf: snap.asOf,
    );
    final overview = ref.watch(wealthOverviewProvider).value;
    final height = MediaQuery.sizeOf(context).height;
    final contributions12m = months.fold(Decimal.zero, (a, m) => a + m.buys);
    final income12m = months.fold(Decimal.zero, (a, m) => a + m.income);
    final contributedMonths = months.where((m) => m.buys > Decimal.zero).length;
    final ytd = _ytd(overview, snap.asOf);
    final twelve = Decimal.fromInt(12);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return ListView(
      key: const Key('dashboard-list'),
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        const RefreshStatusBanner(),
        const QuotaWarningBanner(),
        if (currencies.length > 1 || currencies.first != 'BRL')
          _ConsolidatedCard(summary: summary, fx: fx),
        const SyncReminder(),
        const UpdateReminder(),
        ..._warnings(context, summary),
        // Topo (M-11): um número grande, o olho e uma linha com o ganho, o
        // dia e o aplicado.
        _Hero(
          equity: Fmt.money(totals.equity, currency),
          equityInfo: [
            summary.lastValuationDate == null
                ? 'Carteira real; nenhum preço informado ainda.'
                : 'Carteira real, com preços e saldos até '
                      '${Fmt.date(summary.lastValuationDate!)}.',
            if (summary.trackCash)
              'Valor de mercado das posições + caixa '
                  '(${Fmt.money(totals.cash, currency)}).'
            else
              'Valor de mercado das posições.',
            'Custo das posições abertas (valor investido): '
                '${Fmt.money(totals.invested, currency)}.',
            'Resultado não realizado: '
                '${Fmt.signedMoney(totals.unrealizedPnl, currency)}'
                '${totals.simpleReturn == null ? '' : ' (${Fmt.percent(totals.simpleReturn!)} sobre o custo, sem proventos)'}.',
          ].join('\n'),
          partialNote: totals.isPartial
              ? 'Parcial: ${totals.unpricedCount} '
                    '${totals.unpricedCount == 1 ? 'posição sem preço' : 'posições sem preço'} '
                    '(custo de ${Fmt.money(totals.unpricedCost, currency)} '
                    'fora do total)'
              : null,
          figures: [
            _Figure(
              key: const Key('stat-gain'),
              label: 'Ganho total',
              info:
                  '$totalGainInfo\nRealizado '
                  '${Fmt.signedMoney(totals.realizedPnl, currency)} · não '
                  'realizado ${Fmt.signedMoney(totals.unrealizedPnl, currency)} '
                  '· proventos ${Fmt.money(totals.incomeNet, currency)}.',
              child: total == null
                  ? UnavailableText(tooltip: priced.gap?.label ?? _gainReason)
                  : PnlText(
                      value: total,
                      text:
                          '${Fmt.signedMoney(total, currency)}'
                          '${totalFraction == null ? '' : ' (${Fmt.percent(totalFraction)})'}'
                          '${partial ? ' · parcial' : ''}',
                    ),
            ),
            _DayChange(day: day, currency: currency),
            _Figure(
              key: const Key('stat-applied'),
              label: 'Total aplicado',
              info:
                  '$totalAppliedInfo'
                  '${partial ? ' Parcial: sem as posições sem preço.' : ''}',
              child: Text(Fmt.money(applied, currency)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Três números pequenos, que não se repetem no resto da tela.
        _Row(
          children: [
            StatCard(
              key: const Key('stat-realized'),
              label: 'Lucro realizado',
              pnl: totals.realizedPnl,
              value: Fmt.signedMoney(totals.realizedPnl, currency),
              info:
                  'Vendas, resgates e vencimentos, líquidos de custos e '
                  'impostos, desde o início. Já está dentro do ganho total.',
              note: 'Desde o início',
            ),
            StatCard(
              key: const Key('stat-income'),
              label: 'Proventos (12 meses)',
              value: Fmt.money(income12m, currency),
              info:
                  'Dividendos, JCP, rendimentos e juros registrados nos '
                  'últimos 12 meses, líquidos. Desde o início: '
                  '${Fmt.money(totals.incomeNet, currency)} (bruto '
                  '${Fmt.money(totals.incomeGross, currency)}).',
              note: 'Líquidos, registrados',
            ),
            StatCard(
              key: const Key('stat-mwr'),
              label: 'Rentabilidade (TIR a.a.)',
              pnl: mwr?.annual,
              value: mwr?.text,
              info:
                  '${ReturnMethod.mwr.description}\n\nNo ano: '
                  '${ReturnMethod.twr.description}',
              unavailableReason: mwrReason,
              note: mwr == null ? 'MWR' : 'MWR ${mwr.range}',
              footer: KeyedSubtree(
                key: const Key('stat-ytd'),
                child: Text(
                  ytd == null
                      ? 'No ano: indisponível'
                      : 'No ano ${Fmt.percent(ytd)}, '
                            '${sinceLabel(LocalDate(snap.asOf.year - 1, 12, 31), _first(overview))}',
                  style: muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WealthChartCard(
          key: const Key('wealth'),
          overview: currency == 'BRL' ? overview : null,
          assets: snap.assets,
          // A Visão geral cabe em até 2 telas em 1280 × 800 (M-11).
          height: (height * 0.27).clamp(190.0, 420.0),
        ),
        const SizedBox(height: 12),
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
                        snap.institutionOfAccount(v.position.accountId)?.name ??
                        '?',
                    includeCash: false,
                  ),
                ),
              ],
            ),
            DashCard(
              key: const Key('dash-contributions'),
              title: contributedMonths == 0
                  ? 'Nenhum aporte nos últimos 12 meses'
                  : 'Você aportou em $contributedMonths dos últimos 12 meses',
              subtitle:
                  'Média de '
                  '${Fmt.money(DecimalMath.divide(contributions12m, twelve), currency)} '
                  'por mês · inclusive o saldo inicial',
              trailing: InfoIcon(
                key: const Key('dash-contributions-info'),
                message:
                    'No mês ${Fmt.money(months.last.buys, currency)} · no ano '
                    '${Fmt.money(DashboardMetrics.investedInYear(snap.operations, currency: currency, asOf: snap.asOf), currency)} '
                    '· em 12 meses ${Fmt.money(contributions12m, currency)}.\n'
                    'Compras, aportes e reinvestimentos com custos; o saldo '
                    'inicial conta na data informada. Vendas e resgates em '
                    'cinza.',
              ),
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
              title: income12m <= Decimal.zero
                  ? 'Nenhum provento nos últimos 12 meses'
                  : 'Você recebe em média '
                        '${Fmt.money(DecimalMath.divide(income12m, twelve), currency)} '
                        'por mês',
              subtitle: 'Líquidos, por mês de pagamento registrado',
              trailing: const InfoIcon(
                message:
                    'Média dos últimos 12 meses; o total está em "Proventos '
                    '(12 meses)". Anunciados e projeção em Renda passiva.',
              ),
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
        if (summary.upcomingMaturities.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MaturitiesCard(items: summary.upcomingMaturities),
        ],
        const SizedBox(height: 12),
        const MarketStrip(),
      ],
    );
  }

  static const _gainReason = 'Sem o valor de todas as posições.';

  /// Primeiro dia da evolução (início dos registros).
  static LocalDate? _first(WealthOverview? o) =>
      o == null || o.series.isEmpty ? null : o.series.points.first.date;

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
            // Linhas simples, sem ListTile: a Visão geral cabe em 2 telas.
            for (final m in items)
              InkWell(
                onTap: () => context.go('/carteira/ativo/${m.asset.id}'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${m.asset.symbol} — ${m.asset.name}'),
                      ),
                      Text(
                        '${Fmt.date(m.maturityDate)} · '
                        '${m.daysLeft == 0 ? 'hoje' : 'em ${m.daysLeft} dias'}',
                      ),
                    ],
                  ),
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
                padding: const EdgeInsets.symmetric(vertical: 4),
                // A data do fechamento de referência à vista (M-12); a
                // cotação, no tooltip.
                child: Tooltip(
                  message:
                      'Cotação ${Fmt.money(m.change.to, widget.currency)} '
                      'contra o fechamento de '
                      '${Fmt.money(m.change.from.price, widget.currency)} em '
                      '${Fmt.date(m.change.from.refDate)}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(m.holding.asset?.symbol ?? '?')),
                          PnlText(
                            value: m.change.perUnit,
                            text: Fmt.percent(m.change.fraction),
                          ),
                        ],
                      ),
                      Text(
                        'fechamento de ${Fmt.date(m.change.from.refDate)}',
                        key: Key('mover-ref-${m.holding.assetId}'),
                        style: muted,
                      ),
                    ],
                  ),
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

/// Variação do dia, no topo ao lado do ganho total.
class _DayChange extends StatelessWidget {
  const _DayChange({required this.day, required this.currency});

  final PortfolioDayChange? day;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final d = day;
    if (d == null) {
      return const _Figure(
        key: Key('stat-day'),
        label: 'Hoje',
        child: UnavailableText(
          tooltip:
              'Nenhum ativo com cotação e o fechamento anterior guardado. '
              'Use "Atualizar agora".',
        ),
      );
    }
    return Tooltip(
      message:
          'Cotação atual × fechamento de ${Fmt.date(d.since)}'
          '${d.partial ? ' · parcial: ${d.missing} ${d.missing == 1 ? 'ativo' : 'ativos'} sem a variação' : ''}',
      child: _Figure(
        key: const Key('stat-day'),
        label: 'Hoje',
        child: PnlText(
          value: d.amount,
          text:
              '${Fmt.signedMoney(d.amount, currency)} '
              '(${d.fraction == null ? '—' : Fmt.percent(d.fraction!)})'
              '${d.partial ? ' · parcial' : ''}',
        ),
      ),
    );
  }
}

/// Topo da Visão geral (M-11, estilo Nubank): o patrimônio em número grande,
/// o olho que oculta os valores e, numa linha, os números de apoio.
class _Hero extends ConsumerWidget {
  const _Hero({
    required this.equity,
    required this.equityInfo,
    required this.figures,
    this.partialNote,
  });

  final String equity;
  final String equityInfo;
  final String? partialNote;
  final List<Widget> figures;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hidden = ref.watch(hideValuesProvider).value ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Patrimônio',
              style: theme.textTheme.titleSmall?.copyWith(color: muted),
            ),
            const SizedBox(width: 4),
            InfoIcon(key: const Key('stat-equity-info'), message: equityInfo),
            const SizedBox(width: 4),
            IconButton(
              key: const Key('hide-values'),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 28),
              tooltip: hidden
                  ? 'Mostrar os valores'
                  : 'Ocultar os valores em todo o app',
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: muted,
              ),
              onPressed: () =>
                  ref.read(appearanceServiceProvider).setHideValues(!hidden),
            ),
          ],
        ),
        Column(
          key: const Key('stat-equity'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                equity,
                maxLines: 1,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (partialNote != null)
              Text(
                partialNote!,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 32, runSpacing: 8, children: figures),
      ],
    );
  }
}

/// Um número de apoio do topo: rótulo, valor e a explicação no (i).
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.child,
    this.info,
    super.key,
  });

  final String label;
  final Widget child;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        DefaultTextStyle.merge(
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
        if (info != null) ...[
          const SizedBox(width: 4),
          InfoIcon(message: info!),
        ],
      ],
    );
  }
}

/// Cartões lado a lado, com a mesma largura (um embaixo do outro em
/// janelas estreitas).
class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        // Sem IntrinsicHeight: a medição intrínseca do cartão (com o valor
        // num FittedBox) sai bem maior que o conteúdo.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, c) in children.indexed) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: c),
            ],
          ],
        );
      },
    );
  }
}
