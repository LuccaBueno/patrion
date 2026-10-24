import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/risk_service.dart';
import '../../../application/portfolio/wealth_service.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/risk.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';
import 'returns_tab.dart';

/// Agrupamentos da concentração.
enum ConcentrationBy {
  asset('Ativo'),
  assetClass('Classe'),
  sector('Setor'),
  country('País'),
  currency('Moeda');

  const ConcentrationBy(this.label);

  final String label;
}

/// Desempenho → Risco (F8, parte 3; `docs/FORMULAS.md` §11): volatilidade,
/// drawdown, Sharpe e beta no período; concentração, exposição cambial,
/// liquidez e alocação-alvo na posição de hoje.
class RiskTab extends ConsumerStatefulWidget {
  const RiskTab({
    required this.overview,
    required this.assets,
    required this.from,
    required this.to,
    super.key,
  });

  final WealthOverview overview;
  final Map<String, Asset> assets;
  final LocalDate from;
  final LocalDate to;

  @override
  ConsumerState<RiskTab> createState() => _RiskTabState();
}

class _RiskTabState extends ConsumerState<RiskTab> {
  var _by = ConcentrationBy.asset;

  String _name(String id) => widget.assets[id]?.symbol ?? id;

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(riskReportProvider((widget.from, widget.to)));
    final targets = ref.watch(allocationTargetsProvider).value ?? const {};
    final values = widget.overview.currentValues;
    final total = values.values.fold(Decimal.zero, (a, v) => a + v);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Recalculando, fica com o resultado anterior (M-10).
        switch (report) {
          AsyncValue(hasError: true, :final error?) => MessageCard(
            icon: Icons.error_outline,
            title: 'Não foi possível calcular o risco',
            message: errorMessage(error),
          ),
          AsyncValue(hasValue: true, :final value?) => _PeriodRisk(
            report: value,
            name: _name,
          ),
          _ => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
        const SizedBox(height: 16),
        Text('Posição de hoje', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (total <= Decimal.zero)
          const MessageCard(
            icon: Icons.info_outline,
            title: 'Sem posições com preço',
            message:
                'A concentração, a exposição e a alocação usam o valor de '
                'cada ativo na Carteira; nenhum tem preço agora.',
          )
        else ...[
          _concentration(context, values),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _shares(
                context,
                id: 'risk-fx',
                title: 'Exposição cambial',
                subtitle: 'Parte do patrimônio em cada moeda',
                values: _group(values, (a) => a.currency),
              ),
              _shares(
                context,
                id: 'risk-liquidity',
                title: 'Liquidez',
                subtitle:
                    'Pela liquidez do cadastro; sem ela, a da classe (bolsa, '
                    'cripto, Tesouro e caixa: diária)',
                values: _group(values, _liquidity),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TargetsCard(
            current: {
              for (final MapEntry(:key, :value) in _group(
                values,
                (a) => a.assetClass.code,
              ).entries)
                AssetClass.values.firstWhere((c) => c.code == key): value,
            },
            total: total,
            targets: targets,
          ),
        ],
        const SizedBox(height: 12),
        ...notesOf(context, [
          'Volatilidade, drawdown, Sharpe, beta e correlação usam o período '
              'escolhido: a carteira pelo índice do TWR (dia a dia), cada ativo '
              'pelo preço ajustado por proventos e eventos. A posição de hoje '
              'usa os valores da Carteira em reais; ativos sem preço ficam de '
              'fora. São medidas do passado: não são previsão nem '
              'recomendação.',
        ]),
      ],
    );
  }

  Map<String, Decimal> _group(
    Map<String, Decimal> values,
    String Function(Asset a) key,
  ) {
    final result = <String, Decimal>{};
    for (final MapEntry(key: id, :value) in values.entries) {
      final a = widget.assets[id];
      final k = a == null ? '?' : key(a);
      result[k] = (result[k] ?? Decimal.zero) + value;
    }
    return result;
  }

  /// Liquidez do cadastro; sem ela, a padrão da classe quando a classe tem
  /// uma (negociada em bolsa, cripto, Tesouro e caixa: diária).
  static String _liquidity(Asset a) {
    if (a.liquidity case final l?) return l.label;
    return switch (a.assetClass) {
      AssetClass.fixedIncome || AssetClass.bankProduct => 'Não informada',
      _ => 'Diária (padrão da classe)',
    };
  }

  Widget _concentration(BuildContext context, Map<String, Decimal> values) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final grouped = switch (_by) {
      ConcentrationBy.asset => {
        for (final MapEntry(:key, :value) in values.entries) _name(key): value,
      },
      ConcentrationBy.assetClass => _group(values, (a) => a.assetClass.label),
      ConcentrationBy.sector => _group(
        values,
        (a) => a.sector ?? 'Sem setor informado',
      ),
      ConcentrationBy.country => _group(values, (a) => a.country),
      ConcentrationBy.currency => _group(values, (a) => a.currency),
    };
    final c = Concentration.of(grouped);
    return Card(
      key: const Key('risk-concentration'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Concentração', style: theme.textTheme.titleMedium),
                SegmentedButton<ConcentrationBy>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    for (final b in ConcentrationBy.values)
                      ButtonSegment(
                        value: b,
                        label: Text(b.label, key: Key('risk-by-${b.name}')),
                      ),
                  ],
                  selected: {_by},
                  onSelectionChanged: (s) => setState(() => _by = s.single),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (c == null)
              const UnavailableText()
            else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatCard(
                    key: const Key('risk-largest'),
                    label: 'Maior posição',
                    value: Fmt.percent(c.largestWeight, signed: false),
                    note: c.largest,
                  ),
                  StatCard(
                    key: const Key('risk-top5'),
                    label: c.count > 5 ? 'Cinco maiores' : 'Todas (${c.count})',
                    value: Fmt.percent(c.top5, signed: false),
                    note: 'Soma dos pesos',
                  ),
                  StatCard(
                    key: const Key('risk-hhi'),
                    label: 'Índice HHI',
                    value: Fmt.number(DecimalMath.roundHalfUp(c.hhi, scale: 3)),
                    info:
                        'Herfindahl-Hirschman: soma dos pesos ao quadrado. '
                        'Vai de 1 ÷ n (tudo igual) a 1 (tudo num só); acima '
                        'de 0,25 a distribuição é considerada concentrada.',
                    note:
                        'Equivale a ${Fmt.number(DecimalMath.roundHalfUp(c.effective, scale: 1))} '
                        'posições de mesmo tamanho',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                [
                  for (final e
                      in (grouped.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .take(8))
                    '${e.key} ${_share(e.value, grouped)}',
                ].join(' · '),
                style: muted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _share(Decimal v, Map<String, Decimal> all) {
    final total = all.values.fold(Decimal.zero, (a, x) => a + x);
    return Fmt.percent(DecimalMath.divide(v, total), signed: false);
  }

  Widget _shares(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required Map<String, Decimal> values,
  }) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final sorted = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SizedBox(
      width: 380,
      child: Card(
        key: Key(id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              for (final e in sorted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        Fmt.money(e.value, 'BRL'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _share(e.value, values),
                          key: Key('$id-${e.key}'),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartões do período e as tabelas por ativo e de correlação.
class _PeriodRisk extends StatelessWidget {
  const _PeriodRisk({required this.report, required this.name});

  final RiskReport report;
  final String Function(String id) name;

  static const _short =
      'Precisa de pelo menos 12 meses de dados diários no período.';

  @override
  Widget build(BuildContext context) {
    final dd = report.drawdown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            StatCard(
              key: const Key('risk-vol'),
              label: 'Volatilidade',
              value: report.volatility == null
                  ? null
                  : '${Fmt.percent(report.volatility!, signed: false)} a.a.',
              info:
                  'Desvio padrão dos retornos diários do TWR, anualizado. '
                  'Mede quanto a carteira oscila, para cima e para baixo.',
              unavailableReason: 'Precisa de pelo menos 20 dias no período.',
              note: 'Da carteira, no período',
            ),
            StatCard(
              key: const Key('risk-dd'),
              label: 'Queda máxima (drawdown)',
              value: dd == null ? null : Fmt.percent(dd.depth),
              pnl: dd?.depth,
              info:
                  'Maior queda do TWR de um pico até o fundo seguinte, no '
                  'período.',
              unavailableReason: 'Sem dados suficientes no período.',
              note: dd == null || dd.depth == Decimal.zero
                  ? 'Sem queda no período'
                  : _ddNote(dd),
            ),
            StatCard(
              key: const Key('risk-sharpe'),
              label: 'Índice de Sharpe',
              value: report.sharpe == null ? null : Fmt.fixed2(report.sharpe!),
              info:
                  'Retorno acima do CDI por unidade de volatilidade, '
                  'anualizado. Acima de 1 costuma ser considerado bom; '
                  'negativo, abaixo do CDI.',
              unavailableReason: '$_short Também precisa do CDI guardado.',
              note: 'Contra o CDI',
            ),
            StatCard(
              key: const Key('risk-beta'),
              label: 'Beta',
              value: report.beta == null ? null : Fmt.fixed2(report.beta!),
              info:
                  'Quanto a carteira tende a se mover quando o Ibovespa se '
                  'move 1%: 1 = igual, 0,5 = metade, acima de 1 = mais.',
              unavailableReason: '$_short Também precisa do Ibovespa guardado.',
              note: 'Contra o Ibovespa',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _assetsTable(context),
        if (report.correlated.length >= 2) ...[
          const SizedBox(height: 16),
          _correlationTable(context),
        ],
      ],
    );
  }

  static String _ddNote(Drawdown dd) =>
      'De ${Fmt.date(dd.peak)} a ${Fmt.date(dd.trough)}; '
      '${dd.recovery == null ? 'não recuperada até o fim do período' : 'recuperada em ${Fmt.date(dd.recovery!)}'}';

  Widget _assetsTable(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    final head = small?.copyWith(color: muted, fontWeight: FontWeight.w600);
    final colors = SemanticColors.of(context);
    Widget cell(String t, {TextStyle? style, Key? key, bool right = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            t,
            key: key,
            style: style ?? small,
            textAlign: right ? TextAlign.right : null,
          ),
        );
    return Card(
      key: const Key('risk-assets'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Por ativo', style: theme.textTheme.titleMedium),
            Text(
              'Pelo preço ajustado por proventos e eventos, no período.',
              style: small?.copyWith(color: muted),
            ),
            const SizedBox(height: 8),
            if (report.assets.isEmpty)
              const UnavailableText(
                tooltip:
                    'Nenhum ativo com posição tem cotação automática e '
                    'histórico.',
              )
            else
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(3),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                children: [
                  TableRow(
                    children: [
                      cell('Ativo', style: head),
                      cell('Volatilidade', style: head, right: true),
                      cell('Queda máxima', style: head, right: true),
                      cell('Pico → fundo (recuperação)', style: head),
                    ],
                  ),
                  for (final a in report.assets)
                    TableRow(
                      children: [
                        cell(
                          name(a.assetId),
                          style: small?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        cell(
                          a.volatility == null
                              ? '—'
                              : '${Fmt.percent(a.volatility!, signed: false)} a.a.',
                          key: Key('risk-vol-${name(a.assetId)}'),
                          right: true,
                        ),
                        cell(
                          a.drawdown == null
                              ? '—'
                              : Fmt.percent(a.drawdown!.depth),
                          key: Key('risk-dd-${name(a.assetId)}'),
                          style:
                              a.drawdown != null &&
                                  a.drawdown!.depth < Decimal.zero
                              ? small?.copyWith(color: colors.loss)
                              : null,
                          right: true,
                        ),
                        cell(
                          a.drawdown == null
                              ? (a.firstDate == null
                                    ? 'Sem fechamentos no período'
                                    : 'Poucos dados no período')
                              : a.drawdown!.depth == Decimal.zero
                              ? 'Sem queda'
                              : _ddNote(a.drawdown!),
                          style: small?.copyWith(color: muted),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _correlationTable(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    final head = small?.copyWith(color: muted, fontWeight: FontWeight.w600);
    final ids = report.correlated;
    Widget cell(String t, {TextStyle? style, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        t,
        key: key,
        style: style ?? small,
        textAlign: TextAlign.right,
      ),
    );
    return Card(
      key: const Key('risk-correlation'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correlação entre os ativos',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              'Dos retornos diários nas datas em comum (pelo menos 60). De −1 '
              '(movem-se em sentidos opostos) a 1 (juntos); perto de 0, sem '
              'relação. Em negrito, 0,7 ou mais. '
              '${ids.length == RiskReport.maxCorrelated ? 'Os ${RiskReport.maxCorrelated} maiores ativos.' : ''}',
              style: small?.copyWith(color: muted),
            ),
            const SizedBox(height: 8),
            Table(
              defaultColumnWidth: const FlexColumnWidth(),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
              children: [
                TableRow(
                  children: [
                    cell(''),
                    for (final b in ids) cell(name(b), style: head),
                  ],
                ),
                for (final a in ids)
                  TableRow(
                    children: [
                      cell(name(a), style: head),
                      for (final b in ids)
                        _corr(
                          report.correlation(a, b),
                          small,
                          muted,
                          a == b,
                          Key('risk-corr-${name(a)}-${name(b)}'),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _corr(
    Decimal? v,
    TextStyle? small,
    Color muted,
    bool diagonal,
    Key key,
  ) {
    final text = v == null ? '—' : Fmt.fixed2(v);
    final strong = v != null && !diagonal && v.abs() >= Decimal.parse('0.7');
    return Tooltip(
      message: v == null ? 'Menos de 60 retornos em comum no período.' : '',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          text,
          key: key,
          textAlign: TextAlign.right,
          style: diagonal
              ? small?.copyWith(color: muted)
              : strong
              ? small?.copyWith(fontWeight: FontWeight.w700)
              : small,
        ),
      ),
    );
  }
}

/// Alocação-alvo por classe: atual, alvo e a diferença (informação, não
/// recomendação).
class _TargetsCard extends ConsumerWidget {
  const _TargetsCard({
    required this.current,
    required this.total,
    required this.targets,
  });

  final Map<AssetClass, Decimal> current;
  final Decimal total;
  final Map<AssetClass, Decimal> targets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    final head = small?.copyWith(color: muted, fontWeight: FontWeight.w600);
    final classes = [
      for (final c in AssetClass.values)
        if (current.containsKey(c) || targets.containsKey(c)) c,
    ];
    Widget cell(String t, {TextStyle? style, Key? key, bool right = true}) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            t,
            key: key,
            style: style ?? small,
            textAlign: right ? TextAlign.right : null,
          ),
        );
    return Card(
      key: const Key('risk-targets'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alocação-alvo por classe',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        targets.isEmpty
                            ? 'Defina quanto quer em cada classe para ver a '
                                  'distância até o alvo. Vale em todos os '
                                  'computadores.'
                            : 'Diferença entre o alvo e a posição de hoje. '
                                  'É informação, não recomendação.',
                        style: small?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('risk-targets-edit'),
                  onPressed: () => _edit(context, ref),
                  icon: const Icon(Icons.tune),
                  label: const Text('Definir alvos'),
                ),
              ],
            ),
            if (targets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Table(
                columnWidths: const {0: FlexColumnWidth(2)},
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                children: [
                  TableRow(
                    children: [
                      cell('Classe', style: head, right: false),
                      cell('Hoje', style: head),
                      cell('Alvo', style: head),
                      cell('Diferença', style: head),
                      cell('Para chegar ao alvo', style: head),
                    ],
                  ),
                  for (final c in classes) _row(c, cell, small),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  TableRow _row(
    AssetClass c,
    Widget Function(String, {TextStyle? style, Key? key, bool right}) cell,
    TextStyle? small,
  ) {
    final value = current[c] ?? Decimal.zero;
    final weight = DecimalMath.divide(value, total);
    final target = targets[c] ?? Decimal.zero;
    final gap = DecimalMath.roundHalfUp(total * target - value);
    return TableRow(
      children: [
        cell(c.label, right: false),
        cell(
          Fmt.percent(weight, signed: false),
          key: Key('target-now-${c.code}'),
        ),
        cell(Fmt.percent(target, signed: false)),
        cell(
          '${Fmt.signedNumber((weight - target) * Decimal.fromInt(100))} p.p.',
          key: Key('target-diff-${c.code}'),
        ),
        cell(
          gap == Decimal.zero
              ? 'no alvo'
              : gap > Decimal.zero
              ? '+${Fmt.money(gap, 'BRL')}'
              : '−${Fmt.money(-gap, 'BRL')}',
          key: Key('target-gap-${c.code}'),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final saved = await showDialog<Map<AssetClass, Decimal>>(
      context: context,
      builder: (context) => _TargetsDialog(
        classes: [
          for (final c in AssetClass.values)
            if (current.containsKey(c) || targets.containsKey(c)) c,
        ],
        targets: targets,
      ),
    );
    if (saved == null) return;
    await ref.read(portfolioPreferencesProvider).setTargets(saved);
  }
}

/// Diálogo dos alvos; os campos são descartados junto com ele (depois da
/// animação de fechamento).
class _TargetsDialog extends StatefulWidget {
  const _TargetsDialog({required this.classes, required this.targets});

  final List<AssetClass> classes;
  final Map<AssetClass, Decimal> targets;

  @override
  State<_TargetsDialog> createState() => _TargetsDialogState();
}

class _TargetsDialogState extends State<_TargetsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = {
    for (final c in widget.classes)
      c: TextEditingController(
        text: widget.targets[c] == null
            ? ''
            : Fmt.number(
                widget.targets[c]! * Decimal.fromInt(100),
                maxDecimals: 2,
              ),
      ),
  };

  @override
  void dispose() {
    for (final t in _controllers.values) {
      t.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final result = <AssetClass, Decimal>{
      for (final MapEntry(key: c, value: t) in _controllers.entries)
        if (decimalOf(t) case final v? when v > Decimal.zero)
          c: DecimalMath.divide(v, Decimal.fromInt(100)),
    };
    final sum = result.values.fold(Decimal.zero, (a, v) => a + v);
    if (result.isNotEmpty && sum != Decimal.one) {
      showInfo(
        context,
        'A soma dos alvos precisa ser 100% (está em '
        '${Fmt.percent(sum, signed: false)}).',
      );
      return;
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Alocação-alvo por classe',
      formKey: _formKey,
      width: 420,
      onSave: _save,
      children: [
        Text(
          'Em % do patrimônio. Deixe em branco as classes sem alvo; a soma '
          'precisa ser 100%. Para apagar os alvos, esvazie todos.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        for (final c in widget.classes)
          DecimalField(
            controller: _controllers[c]!,
            label: c.label,
            suffix: '%',
            fieldKey: Key('target-field-${c.code}'),
          ),
      ],
    );
  }
}
