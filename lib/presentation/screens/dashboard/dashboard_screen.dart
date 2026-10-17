import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/config/app_info.dart';
import '../../../domain/portfolio/portfolio_summary.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Dashboard inicial da carteira real (SPEC §8, F3).
///
/// Mostra só o que os dados sustentam hoje: totais, resultado, proventos,
/// alocação, maiores posições e vencimentos. Rentabilidade por período,
/// evolução e benchmarks dependem do motor financeiro (F4) e dos dados de
/// mercado (F6).
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
            'Comece cadastrando a instituição e a conta onde ficam seus '
                'investimentos. Depois registre as operações.',
            'Ir para Cadastros',
            '/cadastros',
          )
        : (
            'Nenhuma operação registrada',
            'Registre compras, aportes, depósitos e proventos para ver a '
                'carteira aqui.',
            'Ir para Operações',
            '/operacoes',
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
          MessageCard(
            icon: Icons.info_outline,
            title: title,
            message: message,
            action: FilledButton(
              onPressed: () => context.go(route),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard({required this.snap});

  final PortfolioSnapshot snap;

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  String? _currency;

  @override
  Widget build(BuildContext context) {
    final summary = widget.snap.summary;
    final currencies = summary.currencies();
    final currency = currencies.contains(_currency)
        ? _currency!
        : currencies.first;
    final totals = summary.byCurrency[currency]!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return PageScaffold(
      title: 'Início',
      subtitle: summary.lastValuationDate == null
          ? 'Carteira real · nenhum preço informado ainda'
          : 'Carteira real · preços e saldos informados até '
                '${Fmt.date(summary.lastValuationDate!)}',
      actions: [
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
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (currencies.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Cada moeda tem seus próprios totais: a conversão para BRL '
                'chega com as cotações de câmbio.',
                style: muted,
              ),
            ),
          ..._warnings(context, summary),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                key: const Key('stat-equity'),
                label: 'Patrimônio',
                value: Fmt.money(totals.equity, currency),
                note: totals.isPartial
                    ? 'Parcial: ${totals.unpricedCount} '
                          '${totals.unpricedCount == 1 ? 'posição sem preço' : 'posições sem preço'} '
                          '(custo de ${Fmt.money(totals.unpricedCost, currency)} '
                          'fora do total)'
                    : 'Valor de mercado + caixa',
              ),
              _StatCard(
                key: const Key('stat-invested'),
                label: 'Valor investido',
                value: Fmt.money(totals.invested, currency),
                note: 'Custo das posições abertas, com custos de compra',
              ),
              _StatCard(
                key: const Key('stat-market'),
                label: 'Valor de mercado',
                value: Fmt.money(totals.marketValue, currency),
                note: 'Só posições com preço ou saldo informado',
              ),
              _StatCard(
                key: const Key('stat-cash'),
                label: 'Caixa',
                value: Fmt.money(totals.cash, currency),
                note: 'Depósitos, vendas e proventos menos compras e saídas',
              ),
              _StatCard(
                key: const Key('stat-unrealized'),
                label: 'Resultado não realizado',
                pnl: totals.unrealizedPnl,
                value:
                    '${Fmt.signedMoney(totals.unrealizedPnl, currency)}'
                    '${totals.simpleReturn == null ? '' : ' (${Fmt.percent(totals.simpleReturn!)})'}',
                note: 'Retorno simples sobre o custo, sem proventos',
              ),
              _StatCard(
                key: const Key('stat-realized'),
                label: 'Lucro realizado',
                pnl: totals.realizedPnl,
                value: Fmt.signedMoney(totals.realizedPnl, currency),
                note: 'Vendas, resgates e vencimentos, líquidos de custos',
              ),
              _StatCard(
                key: const Key('stat-income'),
                label: 'Proventos recebidos',
                value: Fmt.money(totals.incomeNet, currency),
                note:
                    'Líquidos · bruto ${Fmt.money(totals.incomeGross, currency)}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final children = [
                _AllocationCard(
                  title: 'Alocação por classe',
                  slices: summary.allocation(
                    currency,
                    (v) => v.asset?.assetClass.label ?? '?',
                  ),
                  currency: currency,
                ),
                _AllocationCard(
                  title: 'Alocação por instituição',
                  slices: summary.allocation(
                    currency,
                    (v) =>
                        widget.snap
                            .institutionOfAccount(v.position.accountId)
                            ?.name ??
                        '?',
                    includeCash: false,
                  ),
                  currency: currency,
                ),
              ];
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: children[0]),
                        const SizedBox(width: 16),
                        Expanded(child: children[1]),
                      ],
                    )
                  : Column(children: children);
            },
          ),
          const SizedBox(height: 16),
          _TopPositionsCard(snap: widget.snap, currency: currency),
          if (summary.upcomingMaturities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MaturitiesCard(items: summary.upcomingMaturities),
          ],
          const SizedBox(height: 16),
          Text(
            'Rentabilidade por período, evolução patrimonial e comparação '
            'com benchmarks aparecem quando o motor financeiro e as cotações '
            'automáticas estiverem prontos.',
            style: muted,
          ),
        ],
      ),
    );
  }

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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.note,
    this.pnl,
    super.key,
  });

  final String label;
  final String value;
  final String note;

  /// Quando informado, o valor é mostrado como ganho ou perda.
  final Decimal? pnl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge;
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (pnl == null)
                SelectableText(value, style: style)
              else
                PnlText(value: pnl!, text: value, style: style),
              const SizedBox(height: 4),
              Text(
                note,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({
    required this.title,
    required this.slices,
    required this.currency,
  });

  final String title;
  final List<AllocationSlice<String?>> slices;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(
              'Pelo valor de mercado; posições sem preço ficam fora.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (slices.isEmpty)
              const UnavailableText(
                tooltip: 'Informe preços ou saldos para ver a alocação.',
              ),
            for (final s in slices)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.key ?? 'Caixa')),
                        Text(
                          '${Fmt.percent(s.fraction, signed: false)} · '
                          '${Fmt.money(s.value, currency)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        // Conversão para desenho apenas (regra 6, exceção).
                        value: s.fraction.toDouble(),
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
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
