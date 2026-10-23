import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/passive_income_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/dashboard_metrics.dart';
import '../../../domain/portfolio/operation_type.dart';
import '../../../domain/portfolio/passive_income.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';
import '../dashboard/dashboard_charts.dart';
import '../performance/returns_tab.dart';

/// Renda passiva da carteira real (F8, parte 4; SPEC §12.7;
/// `docs/FORMULAS.md` §12): recebido, anunciado e projetado, por mês, ano e
/// ativo, o calendário dos próximos pagamentos e o lançamento dos proventos
/// pagos que a B3 publicou.
class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(passiveIncomeProvider);
    final snap = ref.watch(portfolioSnapshotProvider).value;
    return PageScaffold(
      title: 'Renda passiva',
      subtitle:
          'Proventos da carteira real: dividendos, JCP, rendimentos e '
          'juros',
      child: AsyncBody(
        value: income,
        builder: (o) => snap == null
            ? const Center(child: CircularProgressIndicator())
            : _Body(overview: o, snap: snap),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.overview, required this.snap});

  final PassiveIncomeOverview overview;
  final PortfolioSnapshot snap;

  String _name(String id) => snap.assets[id]?.symbol ?? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = overview.totals;
    final m = overview.match;
    final brl = snap.summary.byCurrency['BRL'];
    final announced = m.announced.fold(Decimal.zero, (a, x) => a + x.gross);
    final projected = DecimalMath.roundHalfUp(
      t.monthlyAverage * Decimal.fromInt(12),
    );
    final months = DashboardMetrics.monthly(
      snap.operations,
      currency: 'BRL',
      asOf: snap.asOf,
      months: 24,
    );
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (m.suggestions.isNotEmpty || m.skipped.isNotEmpty) ...[
          _PendingCard(overview: overview, snap: snap),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            StatCard(
              key: const Key('income-12m'),
              label: 'Recebido em 12 meses',
              value: Fmt.money(t.last12m, 'BRL'),
              note: 'Líquido · bruto ${Fmt.money(t.last12mGross, 'BRL')}',
            ),
            StatCard(
              key: const Key('income-avg'),
              label: 'Média mensal',
              value: Fmt.money(
                DecimalMath.roundHalfUp(t.monthlyAverage),
                'BRL',
              ),
              note: 'Dos últimos 12 meses',
            ),
            StatCard(
              key: const Key('income-yield'),
              label: 'Renda sobre o patrimônio',
              value: brl == null || brl.marketValue <= Decimal.zero
                  ? null
                  : Fmt.percent(
                      DecimalMath.divide(t.last12m, brl.marketValue),
                      signed: false,
                    ),
              info:
                  'Proventos líquidos dos últimos 12 meses ÷ valor de '
                  'mercado das posições em reais hoje.',
              unavailableReason: 'Sem posições com preço em reais.',
              note: brl == null || brl.invested <= Decimal.zero
                  ? '12 meses ÷ patrimônio de hoje'
                  : 'Sobre o custo: ${Fmt.percent(DecimalMath.divide(t.last12m, brl.invested), signed: false)}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ThreeColumns(
          received: t.last12m,
          announced: announced,
          projected: projected,
        ),
        const SizedBox(height: 16),
        DashCard(
          key: const Key('income-months'),
          title: 'Proventos por mês',
          subtitle:
              'Líquidos, pela data de pagamento registrada, nos últimos '
              '24 meses',
          child: MonthlyBars(
            months: months,
            currency: 'BRL',
            series: [
              BarSeries(
                'Proventos',
                (m) => m.income,
                colorOf: (c) => Theme.of(c).colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _calendar(context, m.announced),
        const SizedBox(height: 16),
        _byYear(context, t),
        const SizedBox(height: 16),
        _byAsset(context, t),
        const SizedBox(height: 12),
        ...notesOf(context, [
          'Recebido: as operações de provento registradas (líquidas de impostos '
              'e custos). Anunciado: proventos publicados pela B3 com pagamento '
              'futuro, brutos, pela quantidade na data-com (ou a de hoje, se '
              'ela ainda não chegou). Projetado: a média mensal dos últimos 12 '
              'meses × 12, hipotético; não é previsão.',
          if (overview.eventsCollectedAt != null)
            'Proventos da B3 consultados em '
                '${_date(overview.eventsCollectedAt!)} (renovados a cada 30 '
                'dias; em Fontes de dados, "Baixar histórico completo" '
                'consulta de novo).',
          for (final MapEntry(key: c, value: o)
              in overview.otherCurrencies.entries)
            if (o.total > Decimal.zero)
              'Proventos em $c ficam fora dos totais em reais: '
                  '${Fmt.money(o.last12m, c)} em 12 meses.',
        ]),
        if (t.total == Decimal.zero && m.suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nenhum provento registrado ainda.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  static String _date(String iso) {
    final parsed = DateTime.tryParse(iso);
    return parsed == null
        ? iso
        : Fmt.date(LocalDate.fromDateTime(parsed.toLocal()));
  }

  Widget _calendar(BuildContext context, List<AnnouncedIncome> items) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    return DashCard(
      key: const Key('income-calendar'),
      title: 'Próximos pagamentos',
      subtitle: 'Anunciados pela B3; valores brutos estimados pela quantidade',
      child: items.isEmpty
          ? Text(
              'Nenhum pagamento anunciado para os ativos da carteira.',
              style: small?.copyWith(color: muted),
            )
          : _table(
              context,
              [
                'Pagamento',
                'Ativo',
                'Tipo',
                'Data-com',
                'Por cota',
                'Quantidade',
                'Total estimado',
              ],
              [
                for (final a in items)
                  [
                    Fmt.date(a.event.paymentDate!),
                    _name(a.assetId),
                    IncomeEventMatch.typeOf(a.event.kind)!.label,
                    Fmt.date(a.event.comDate!),
                    perShare(a.event.amount!),
                    Fmt.number(a.quantity),
                    Fmt.money(a.gross, 'BRL'),
                  ],
              ],
              rightFrom: 4,
            ),
    );
  }

  Widget _byYear(BuildContext context, IncomeTotals t) {
    final years = t.byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    return DashCard(
      key: const Key('income-years'),
      title: 'Por ano',
      subtitle: 'Líquido, por tipo',
      child: years.isEmpty
          ? const UnavailableText(tooltip: 'Nenhum provento registrado.')
          : _table(
              context,
              [
                'Ano',
                for (final type in IncomeTotals.types) type.label,
                'Total',
              ],
              [
                for (final y in years)
                  [
                    '$y',
                    for (final type in IncomeTotals.types)
                      Fmt.money(t.byYear[y]![type] ?? Decimal.zero, 'BRL'),
                    Fmt.money(
                      t.byYear[y]!.values.fold(Decimal.zero, (a, v) => a + v),
                      'BRL',
                    ),
                  ],
              ],
              rightFrom: 1,
              keyPrefix: 'income-year',
            ),
    );
  }

  Widget _byAsset(BuildContext context, IncomeTotals t) {
    final ids = t.byAsset.keys.toList()
      ..sort((a, b) => t.byAsset[b]!.compareTo(t.byAsset[a]!));
    return DashCard(
      key: const Key('income-assets'),
      title: 'Por ativo',
      subtitle: 'Líquido, nos últimos 12 meses e desde o início',
      child: ids.isEmpty
          ? const UnavailableText(tooltip: 'Nenhum provento registrado.')
          : _table(
              context,
              ['Ativo', '12 meses', 'Desde o início', '% do total'],
              [
                for (final id in ids)
                  [
                    _name(id),
                    Fmt.money(t.byAsset12m[id] ?? Decimal.zero, 'BRL'),
                    Fmt.money(t.byAsset[id]!, 'BRL'),
                    Fmt.percent(
                      DecimalMath.divide(t.byAsset[id]!, t.total),
                      signed: false,
                    ),
                  ],
              ],
              rightFrom: 1,
              keyPrefix: 'income-asset',
            ),
    );
  }

  /// Tabela simples: cabeçalho e linhas de texto; colunas a partir de
  /// [rightFrom] alinhadas à direita. Com [keyPrefix], cada célula tem a
  /// chave `prefixo-primeira coluna-índice`.
  static Widget _table(
    BuildContext context,
    List<String> head,
    List<List<String>> rows, {
    required int rightFrom,
    String? keyPrefix,
  }) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    Widget cell(String t, int i, {TextStyle? style, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        t,
        key: key,
        style: style ?? small,
        textAlign: i >= rightFrom ? TextAlign.right : null,
      ),
    );
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      children: [
        TableRow(
          children: [
            for (final (i, h) in head.indexed)
              cell(
                h,
                i,
                style: small?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        for (final r in rows)
          TableRow(
            children: [
              for (final (i, c) in r.indexed)
                cell(
                  c,
                  i,
                  key: keyPrefix == null ? null : Key('$keyPrefix-${r[0]}-$i'),
                ),
            ],
          ),
      ],
    );
  }
}

/// Recebido, anunciado e projetado, separados (SPEC §12.7).
class _ThreeColumns extends StatelessWidget {
  const _ThreeColumns({
    required this.received,
    required this.announced,
    required this.projected,
  });

  final Decimal received;
  final Decimal announced;
  final Decimal projected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    Widget column(String label, Decimal value, String note, Key key) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: muted),
              ),
              const SizedBox(height: 4),
              Text(
                Fmt.money(value, 'BRL'),
                key: key,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                note,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        );
    return DashCard(
      title: 'Recebido, anunciado e projetado',
      subtitle: 'Cada um é uma coisa diferente: só o recebido já entrou',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          column(
            'Recebido',
            received,
            'Últimos 12 meses, líquido (registrado)',
            const Key('income-received'),
          ),
          column(
            'Anunciado',
            announced,
            'A receber, bruto (B3)',
            const Key('income-announced'),
          ),
          column(
            'Projetado (hipotético)',
            projected,
            'Próximos 12 meses pela média mensal; não é previsão',
            const Key('income-projected'),
          ),
        ],
      ),
    );
  }
}

/// Proventos pagos que a B3 publicou e não estão registrados.
class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.overview, required this.snap});

  final PassiveIncomeOverview overview;
  final PortfolioSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final m = overview.match;
    final total = m.suggestions.fold(Decimal.zero, (a, s) => a + s.gross);
    // Os não sugeridos, por ativo: quantos e até que saldo inicial.
    final skipped = <String, List<IncomeSkip>>{};
    for (final s in m.skipped) {
      (skipped[s.assetId] ??= []).add(s);
    }
    return Card(
      key: const Key('income-pending'),
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.suggestions.isEmpty
                        ? 'Proventos da B3 não sugeridos'
                        : '${m.suggestions.length} '
                              '${m.suggestions.length == 1 ? 'provento pago não registrado' : 'proventos pagos não registrados'}'
                              ' (${Fmt.money(total, 'BRL')}, bruto)',
                    key: const Key('income-pending-title'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (m.suggestions.isNotEmpty)
                  FilledButton.icon(
                    key: const Key('income-review'),
                    onPressed: () => _review(context, ref),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Revisar e lançar'),
                  ),
              ],
            ),
            if (m.suggestions.isNotEmpty)
              Text(
                'A B3 publicou proventos já pagos dos seus ativos que não '
                'estão nas operações. A quantidade é a que você tinha na '
                'data-com, pelas operações registradas. Nada é gravado sem a '
                'sua confirmação.',
                style: theme.textTheme.bodySmall,
              ),
            for (final MapEntry(key: id, value: list) in skipped.entries)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${snap.assets[id]?.symbol ?? id}: ${list.length} '
                  '${list.length == 1 ? 'provento' : 'proventos'} com data-com '
                  'antes do saldo inicial de ${Fmt.date(list.first.initialBalanceDate)} '
                  '${list.length == 1 ? 'não foi sugerido' : 'não foram sugeridos'}'
                  ' (de ${Fmt.date(list.first.event.comDate!)} a '
                  '${Fmt.date(list.last.event.comDate!)}). O saldo inicial é a '
                  'primeira notícia da posição: a quantidade nessas datas não é '
                  'conhecida. Para recebê-los aqui, registre as compras com as '
                  'datas reais (Operações) ou lance os proventos manualmente.',
                  key: Key('income-skipped-${snap.assets[id]?.symbol ?? id}'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(List<IncomeSuggestion>, Decimal)>(
      context: context,
      builder: (context) =>
          _ReviewDialog(items: overview.match.suggestions, snap: snap),
    );
    if (result == null || result.$1.isEmpty || !context.mounted) return;
    try {
      final n = await ref
          .read(passiveIncomeServiceProvider)
          .launch(result.$1, jcpWithholding: result.$2, assets: snap.assets);
      if (context.mounted) {
        showInfo(
          context,
          n == 1 ? '1 provento lançado.' : '$n proventos lançados.',
        );
      }
    } on Object catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

/// Prévia: cada provento com a conta, a quantidade e o valor; escolher quais
/// gravar e a alíquota do IR do JCP.
class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.items, required this.snap});

  final List<IncomeSuggestion> items;
  final PortfolioSnapshot snap;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late final _chosen = List<bool>.filled(widget.items.length, true);
  final _formKey = GlobalKey<FormState>();
  final _jcp = TextEditingController(
    text: Fmt.number(
      PassiveIncomeService.defaultJcpWithholding * Decimal.fromInt(100),
    ),
  );

  @override
  void dispose() {
    _jcp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final hasJcp = widget.items.any((s) => s.type == OperationType.jcp);
    final count = _chosen.where((c) => c).length;
    final total = [
      for (final (i, s) in widget.items.indexed)
        if (_chosen[i]) s.gross,
    ].fold(Decimal.zero, (a, v) => a + v);
    return AlertDialog(
      title: const Text('Lançar proventos pagos'),
      content: SizedBox(
        width: 860,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cada provento vira uma operação comum na data de pagamento, '
                'com o valor bruto da B3 e a nota "Lançado dos proventos da '
                'B3"; dá para editar ou excluir depois em Operações.',
                style: small,
              ),
              if (hasJcp) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 260,
                    child: DecimalField(
                      controller: _jcp,
                      label: 'IR retido no JCP',
                      suffix: '%',
                      required: true,
                      helper: 'Confira no informe da corretora',
                      fieldKey: const Key('income-jcp-rate'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final (i, s) in widget.items.indexed)
                        CheckboxListTile(
                          key: Key('income-item-$i'),
                          dense: true,
                          value: _chosen[i],
                          onChanged: (v) => setState(() => _chosen[i] = v!),
                          title: Text(
                            '${Fmt.date(s.paymentDate)} · '
                            '${widget.snap.assets[s.assetId]?.symbol ?? s.assetId} · '
                            '${s.type.label} · ${Fmt.money(s.gross, 'BRL')}',
                          ),
                          subtitle: Text(
                            '${widget.snap.accountLabel(s.accountId)} · '
                            '${Fmt.number(s.quantity)} × '
                            '${perShare(s.event.amount!)} · data-com '
                            '${Fmt.date(s.event.comDate!)}',
                            style: small,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('income-launch'),
          onPressed: count == 0
              ? null
              : () {
                  if (!_formKey.currentState!.validate()) return;
                  final rate = hasJcp
                      ? DecimalMath.divide(
                          decimalOf(_jcp)!,
                          Decimal.fromInt(100),
                        )
                      : Decimal.zero;
                  Navigator.pop(context, (
                    [
                      for (final (i, s) in widget.items.indexed)
                        if (_chosen[i]) s,
                    ],
                    rate,
                  ));
                },
          child: Text(
            count == 1
                ? 'Lançar 1 provento (${Fmt.money(total, 'BRL')})'
                : 'Lançar $count proventos (${Fmt.money(total, 'BRL')})',
          ),
        ),
      ],
    );
  }
}

/// Valor por cota com todas as casas publicadas pela B3 (`R$ 0,674061`).
String perShare(Decimal v) => 'R\$ ${Fmt.number(v, maxDecimals: 8)}';
