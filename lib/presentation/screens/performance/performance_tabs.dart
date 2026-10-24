import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/wealth_service.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/performance_report.dart';
import '../../format/formatters.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'benchmarks_tab.dart';
import 'returns_tab.dart';
import 'risk_tab.dart';

/// Abas de desempenho do Painel (F8; M-11): rentabilidade, comparação com
/// índices e risco, no mesmo período.
enum PerformanceTab { returns, benchmarks, risk }

/// Período escolhido, o mesmo nas três abas (nulo = o padrão).
class PerformanceSelection {
  const PerformanceSelection({this.period, this.custom});

  final PerformancePeriod? period;

  /// Primeiro e último dia do período personalizado.
  final (LocalDate, LocalDate)? custom;
}

class PerformanceSelectionController extends Notifier<PerformanceSelection> {
  @override
  PerformanceSelection build() => const PerformanceSelection();

  void choose(PerformancePeriod period, {(LocalDate, LocalDate)? custom}) =>
      state = PerformanceSelection(
        period: period,
        custom: custom ?? state.custom,
      );
}

final performanceSelectionProvider =
    NotifierProvider<PerformanceSelectionController, PerformanceSelection>(
      PerformanceSelectionController.new,
    );

/// Uma aba de desempenho: o seletor de período e o conteúdo da aba.
class PerformanceTabView extends ConsumerWidget {
  const PerformanceTabView({required this.tab, super.key});

  final PerformanceTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(wealthOverviewProvider);
    final assets = ref.watch(portfolioSnapshotProvider).value?.assets;
    final selection = ref.watch(performanceSelectionProvider);
    return AsyncBody(
      value: overview,
      builder: (o) => _body(context, ref, o, selection, assets ?? const {}),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    WealthOverview o,
    PerformanceSelection selection,
    Map<String, Asset> assets,
  ) {
    final today = o.asOf;
    final available = PerformancePeriod.available(o.series, today);
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
        selection.period ??
        (available.contains(PerformancePeriod.y1)
            ? PerformancePeriod.y1
            : PerformancePeriod.all);
    if (!available.contains(period)) period = PerformancePeriod.all;
    final custom = selection.custom;
    final first = o.series.points.first.date;
    final (from, to) = switch (period) {
      PerformancePeriod.custom when custom != null => (
        custom.$1.addDays(-1),
        custom.$2,
      ),
      PerformancePeriod.all || PerformancePeriod.custom => (first, today),
      _ => (period.baseDate(today)!, today),
    };
    final names = {for (final a in assets.values) a.id: a.symbol};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodBar(overview: o, available: available, selected: period),
        const SizedBox(height: 12),
        Expanded(
          child: switch (tab) {
            PerformanceTab.returns => ReturnsTab(
              overview: o,
              names: names,
              period: period,
              from: from,
              to: to,
            ),
            PerformanceTab.benchmarks => BenchmarksTab(
              overview: o,
              period: period,
              from: from,
              to: to,
            ),
            PerformanceTab.risk => RiskTab(
              overview: o,
              assets: assets,
              from: from,
              to: to,
            ),
          },
        ),
      ],
    );
  }
}

class _PeriodBar extends ConsumerWidget {
  const _PeriodBar({
    required this.overview,
    required this.available,
    required this.selected,
  });

  final WealthOverview overview;
  final List<PerformancePeriod> available;
  final PerformancePeriod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = ref.watch(performanceSelectionProvider).custom;
    final controller = ref.read(performanceSelectionProvider.notifier);
    return Wrap(
      key: const Key('perf-periods'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in available)
          ChoiceChip(
            key: Key('perf-period-${p.label}'),
            label: Text(
              p == PerformancePeriod.custom && custom != null
                  ? '${Fmt.date(custom.$1)} a ${Fmt.date(custom.$2)}'
                  : p.label,
            ),
            selected: p == selected,
            onSelected: (_) async {
              if (p == PerformancePeriod.custom) {
                final range = await _pickRange(context, overview, custom);
                if (range == null) return;
                controller.choose(p, custom: range);
              } else {
                controller.choose(p);
              }
            },
          ),
      ],
    );
  }
}

Future<(LocalDate, LocalDate)?> _pickRange(
  BuildContext context,
  WealthOverview o,
  (LocalDate, LocalDate)? current,
) {
  final start = TextEditingController(
    text: Fmt.date(current?.$1 ?? o.series.points.first.date),
  );
  final end = TextEditingController(text: Fmt.date(current?.$2 ?? o.asOf));
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
          fieldKey: const Key('perf-custom-from'),
        ),
        TextFormField(
          key: const Key('perf-custom-to'),
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
