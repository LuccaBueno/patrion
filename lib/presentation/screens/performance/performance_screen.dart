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

/// Desempenho da carteira real (F8): rentabilidade e benchmarks, no mesmo
/// período, escolhido acima das abas.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  PerformancePeriod? _period;
  (LocalDate, LocalDate)? _custom;

  static const _tabs = [
    Tab(key: Key('perf-tab-returns'), text: 'Rentabilidade'),
    Tab(key: Key('perf-tab-benchmarks'), text: 'Benchmarks'),
  ];

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(wealthOverviewProvider);
    final assets = ref.watch(portfolioSnapshotProvider).value?.assets;
    final names = {
      for (final a in assets?.values ?? const <Asset>[]) a.id: a.symbol,
    };
    return PageScaffold(
      title: 'Desempenho',
      subtitle: 'Carteira real: rentabilidade, comparações e risco',
      child: AsyncBody(
        value: overview,
        builder: (o) => _body(context, o, names),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WealthOverview o,
    Map<String, String> names,
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
        _period ??
        (available.contains(PerformancePeriod.y1)
            ? PerformancePeriod.y1
            : PerformancePeriod.all);
    if (!available.contains(period)) period = PerformancePeriod.all;
    final first = o.series.points.first.date;
    final (from, to) = switch (period) {
      PerformancePeriod.custom when _custom != null => (
        _custom!.$1.addDays(-1),
        _custom!.$2,
      ),
      PerformancePeriod.all || PerformancePeriod.custom => (first, today),
      _ => (period.baseDate(today)!, today),
    };
    return DefaultTabController(
      length: _tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs,
            ),
          ),
          const SizedBox(height: 12),
          _periodBar(context, o, available, period),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                ReturnsTab(
                  overview: o,
                  names: names,
                  period: period,
                  from: from,
                  to: to,
                ),
                BenchmarksTab(overview: o, period: period, from: from, to: to),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodBar(
    BuildContext context,
    WealthOverview o,
    List<PerformancePeriod> available,
    PerformancePeriod selected,
  ) {
    return Wrap(
      key: const Key('perf-periods'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in available)
          ChoiceChip(
            key: Key('perf-period-${p.label}'),
            label: Text(
              p == PerformancePeriod.custom && _custom != null
                  ? '${Fmt.date(_custom!.$1)} a ${Fmt.date(_custom!.$2)}'
                  : p.label,
            ),
            selected: p == selected,
            onSelected: (_) async {
              if (p == PerformancePeriod.custom) {
                final range = await _pickRange(context, o);
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

  Future<(LocalDate, LocalDate)?> _pickRange(
    BuildContext context,
    WealthOverview o,
  ) {
    final start = TextEditingController(
      text: Fmt.date(_custom?.$1 ?? o.series.points.first.date),
    );
    final end = TextEditingController(text: Fmt.date(_custom?.$2 ?? o.asOf));
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
}
