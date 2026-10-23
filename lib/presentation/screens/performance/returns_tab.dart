import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../application/portfolio/wealth_service.dart';
import '../../../core/money/decimal_math.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/finance/returns.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/portfolio/performance_report.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/stat_card.dart';

/// Desempenho → Rentabilidade (F8, parte 1; `docs/FORMULAS.md` §3.4).
class ReturnsTab extends StatefulWidget {
  const ReturnsTab({required this.overview, required this.names, super.key});

  final WealthOverview overview;

  /// Código de cada ativo, para as notas.
  final Map<String, String> names;

  @override
  State<ReturnsTab> createState() => _ReturnsTabState();
}

class _ReturnsTabState extends State<ReturnsTab> {
  PerformancePeriod? _period;
  (LocalDate, LocalDate)? _custom;

  @override
  Widget build(BuildContext context) {
    final o = widget.overview;
    final series = o.series;
    final today = o.asOf;
    final available = PerformancePeriod.available(series, today);
    if (available.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: MessageCard(
          key: Key('returns-unavailable'),
          icon: Icons.query_stats,
          title: 'Rentabilidade indisponível',
          message:
              'A rentabilidade precisa de pelo menos dois dias de carteira '
              'com preço. Ela começa na data das operações registradas: '
              'registre as compras com as datas reais (ou aproximadas) e '
              'aguarde o histórico de cotações (Configurações → Fontes de '
              'dados).',
        ),
      );
    }
    var period =
        _period ??
        (available.contains(PerformancePeriod.y1)
            ? PerformancePeriod.y1
            : PerformancePeriod.all);
    if (!available.contains(period)) period = PerformancePeriod.all;
    final first = series.points.first.date;
    final (from, to) = switch (period) {
      PerformancePeriod.all => (first, today),
      PerformancePeriod.custom when _custom != null => (
        _custom!.$1.addDays(-1),
        _custom!.$2,
      ),
      PerformancePeriod.custom => (first, today),
      _ => (period.baseDate(today)!, today),
    };
    final cdi = o.indices[IndicatorSeries.cdi];
    final perf = PeriodPerformance.compute(
      series,
      from: from,
      to: to,
      cdi: cdi,
      ipca: o.indices[IndicatorSeries.ipca],
    );
    final rows = ReturnTable.build(series, cdi: cdi).reversed.toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _periodBar(context, available, period),
        const SizedBox(height: 12),
        if (perf == null)
          const MessageCard(
            key: Key('returns-period-unavailable'),
            icon: Icons.info_outline,
            title: 'Sem dados neste período',
            message:
                'O período escolhido tem menos de dois dias de carteira com '
                'preço. Escolha outro período.',
          )
        else
          _Figures(perf: perf, period: period),
        const SizedBox(height: 16),
        _MonthTable(rows: rows),
        const SizedBox(height: 12),
        ..._notes(context),
      ],
    );
  }

  Widget _periodBar(
    BuildContext context,
    List<PerformancePeriod> available,
    PerformancePeriod selected,
  ) {
    return Wrap(
      key: const Key('returns-periods'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in available)
          ChoiceChip(
            key: Key('returns-period-${p.label}'),
            label: Text(
              p == PerformancePeriod.custom && _custom != null
                  ? '${Fmt.date(_custom!.$1)} a ${Fmt.date(_custom!.$2)}'
                  : p.label,
            ),
            selected: p == selected,
            onSelected: (_) async {
              if (p == PerformancePeriod.custom) {
                final range = await _pickRange(context);
                if (range == null) return;
                setState(() {
                  _custom = range;
                  _period = p;
                });
              } else {
                setState(() => _period = p);
              }
            },
          ),
      ],
    );
  }

  Future<(LocalDate, LocalDate)?> _pickRange(BuildContext context) {
    final series = widget.overview.series;
    final start = TextEditingController(
      text: Fmt.date(_custom?.$1 ?? series.points.first.date),
    );
    final end = TextEditingController(
      text: Fmt.date(_custom?.$2 ?? widget.overview.asOf),
    );
    final formKey = GlobalKey<FormState>();
    return showDialog<(LocalDate, LocalDate)>(
      context: context,
      builder: (context) => FormDialog(
        title: 'Período personalizado',
        formKey: formKey,
        width: 420,
        onSave: () {
          if (!formKey.currentState!.validate()) return;
          Navigator.pop(context, (dateOf(start)!, dateOf(end)!));
        },
        children: [
          DateField(
            controller: start,
            label: 'De',
            fieldKey: const Key('returns-custom-from'),
          ),
          TextFormField(
            key: const Key('returns-custom-to'),
            controller: end,
            decoration: const InputDecoration(
              labelText: 'Até *',
              hintText: 'dd/mm/aaaa',
            ),
            validator: (text) {
              final LocalDate a;
              final LocalDate b;
              try {
                a = Fmt.parseDate(start.text);
                b = Fmt.parseDate(text ?? '');
              } on FormatException {
                return 'Data inválida';
              }
              return b.isAfter(a) ? null : 'Escolha uma data depois do início';
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _notes(BuildContext context) {
    final theme = Theme.of(context);
    final series = widget.overview.series;
    String name(String id) => widget.names[id] ?? id;
    final notes = [
      'TWR (ponderado pelo tempo): mede o desempenho dos ativos, sem o efeito '
          'de quando você aportou ou resgatou. Os proventos contam como '
          'retorno. Calculado com os fechamentos guardados, dia a dia, desde '
          'a primeira operação (${Fmt.date(series.points.first.date)}).',
      if (series.entries.isNotEmpty)
        'Sem preço antes da data e fora do cálculo até lá: '
            '${series.entries.entries.map((e) => '${name(e.key)} '
                '(desde ${Fmt.date(e.value)})').join(', ')}.',
      if (series.excluded.isNotEmpty)
        'Fora do cálculo, sem nenhum preço ou saldo: '
            '${series.excluded.map(name).join(', ')}.',
    ];
    return [
      for (final n in notes)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            n,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ];
  }
}

/// Cartões do período: TWR, CDI, retorno real, CAGR e TIR.
class _Figures extends StatelessWidget {
  const _Figures({required this.perf, required this.period});

  final PeriodPerformance perf;
  final PerformancePeriod period;

  @override
  Widget build(BuildContext context) {
    final range = 'de ${Fmt.date(perf.from)} a ${Fmt.date(perf.to)}';
    final ofCdi = perf.ofCdi;
    final cdi = perf.cdi;
    final ipca = perf.ipca;
    final mwr = perf.mwr;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StatCard(
          key: const Key('returns-twr'),
          label: 'Rentabilidade ${period.phrase}',
          value: Fmt.percent(perf.twr),
          pnl: perf.twr,
          info: ReturnMethod.twr.description,
          note: 'TWR $range',
        ),
        StatCard(
          key: const Key('returns-cdi'),
          label: 'CDI no período',
          value: cdi == null ? null : Fmt.percent(cdi),
          unavailableReason:
              'Sem CDI guardado para todo o período. Atualize os indicadores '
              'em Configurações → Fontes de dados.',
          note: cdi == null
              ? 'Mesmo intervalo da carteira'
              : [
                  if (ofCdi != null) 'Carteira: ${percentOfCdi(ofCdi)}',
                  'diferença ${pointsDiff(perf.twr - cdi)}',
                ].join(' · '),
        ),
        StatCard(
          key: const Key('returns-real'),
          label: 'Retorno real',
          value: perf.real == null ? null : Fmt.percent(perf.real!),
          pnl: perf.real,
          info:
              'Rentabilidade descontada a inflação: (1 + TWR) ÷ (1 + IPCA) '
              '− 1.',
          unavailableReason:
              'Sem IPCA guardado para o início do período. Atualize os '
              'indicadores em Configurações → Fontes de dados.',
          note: ipca == null
              ? 'Descontado o IPCA'
              : 'Descontado o IPCA de ${Fmt.percent(ipca)}'
                    '${perf.ipcaUntil != null && perf.ipcaUntil!.isBefore(perf.to) ? ' (publicado até ${Fmt.monthYear(perf.ipcaUntil!)})' : ''}',
        ),
        if (perf.cagr != null)
          StatCard(
            key: const Key('returns-cagr'),
            label: 'Taxa anual equivalente',
            value: '${Fmt.percent(perf.cagr!)} a.a.',
            pnl: perf.cagr,
            info: ReturnMethod.cagr.description,
            note: 'CAGR do TWR em ${_years(perf.days)}',
          ),
        StatCard(
          key: const Key('returns-mwr'),
          label: 'TIR no período',
          value: mwr == null ? null : _mwrText(mwr.rate, perf.days),
          pnl: mwr?.rate,
          info: ReturnMethod.mwr.description,
          unavailableReason:
              'Os fluxos do período não têm uma taxa que os equilibre.',
          note: mwr != null && mwr.multipleSignChanges
              ? 'MWR; os fluxos mudam de sinal mais de uma vez'
              : 'MWR: considera quando cada aporte entrou',
        ),
      ],
    );
  }

  /// Ao ano; em menos de um ano, o equivalente do período (anualizar prazos
  /// curtos exagera o resultado, como na página do ativo).
  static String _mwrText(Decimal rate, int days) => days < 365
      ? '${Fmt.percent(Returns.deannualize(rate, days))} no período'
      : '${Fmt.percent(rate)} a.a.';

  static String _years(int days) {
    final years = DecimalMath.roundHalfUp(
      DecimalMath.divide(Decimal.fromInt(days), Decimal.fromInt(365)),
      scale: 1,
    );
    return '${Fmt.number(years)} anos';
  }
}

/// `110%` do CDI.
String percentOfCdi(Decimal fraction) =>
    '${Fmt.number(DecimalMath.roundHalfUp(fraction * Decimal.fromInt(100), scale: 0))}% do CDI';

/// `+1,23 p.p.`
String pointsDiff(Decimal fraction) =>
    '${Fmt.signedNumber(fraction * Decimal.fromInt(100))} p.p.';

/// Tabela mês × ano (o ano mais recente em cima).
class _MonthTable extends StatelessWidget {
  const _MonthTable({required this.rows});

  final List<ReturnTableRow> rows;

  static const _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = SemanticColors.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final small = theme.textTheme.bodySmall;
    final head = small?.copyWith(color: muted, fontWeight: FontWeight.w600);

    // Numa janela estreita, o texto diminui um pouco em vez de ser cortado.
    Widget cell(String text, {TextStyle? style, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          text,
          key: key,
          textAlign: TextAlign.right,
          maxLines: 1,
          softWrap: false,
          style: style ?? small,
        ),
      ),
    );
    Widget pct(Decimal? v, {Key? key, bool bold = false}) {
      if (v == null) return cell('', key: key);
      final rounded = DecimalMath.roundHalfUp(v * Decimal.fromInt(100));
      final color = rounded > Decimal.zero
          ? colors.gain
          : rounded < Decimal.zero
          ? colors.loss
          : muted;
      return cell(
        Fmt.percent(v),
        key: key,
        style: small?.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.w600 : null,
        ),
      );
    }

    return Card(
      key: const Key('returns-table'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rentabilidade mês a mês', style: theme.textTheme.titleMedium),
            Text(
              'TWR da carteira em cada mês, no ano e acumulado desde o início; '
              'o CDI do mesmo intervalo do ano. * Ano parcial.',
              style: small?.copyWith(color: muted),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth < 900
                        ? 900
                        : constraints.maxWidth,
                  ),
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FixedColumnWidth(52),
                      13: FlexColumnWidth(1.2),
                      14: FlexColumnWidth(1.5),
                      15: FlexColumnWidth(1.1),
                      16: FlexColumnWidth(1.1),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.4),
                      ),
                    ),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Ano', style: head),
                          ),
                          for (final m in _months) cell(m, style: head),
                          cell('Ano', style: head),
                          cell('Acumulado', style: head),
                          cell('CDI', style: head),
                          cell('% CDI', style: head),
                        ],
                      ),
                      for (final r in rows)
                        TableRow(
                          key: ValueKey('returns-row-${r.year}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                r.partial ? '${r.year}*' : '${r.year}',
                                style: small?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            for (var i = 0; i < 12; i++)
                              pct(
                                r.months[i],
                                key: Key('returns-${r.year}-${i + 1}'),
                              ),
                            pct(
                              r.total,
                              key: Key('returns-${r.year}-total'),
                              bold: true,
                            ),
                            pct(
                              r.accumulated,
                              key: Key('returns-${r.year}-acc'),
                            ),
                            r.cdi == null
                                ? cell(
                                    '—',
                                    style: small?.copyWith(color: muted),
                                  )
                                : cell(
                                    Fmt.percent(r.cdi!),
                                    key: Key('returns-${r.year}-cdi'),
                                  ),
                            cell(
                              r.ofCdi == null
                                  ? '—'
                                  : '${Fmt.number(DecimalMath.roundHalfUp(r.ofCdi! * Decimal.fromInt(100), scale: 0))}%',
                              key: Key('returns-${r.year}-ofcdi'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
