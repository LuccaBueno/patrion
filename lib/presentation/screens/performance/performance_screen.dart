import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/portfolio/entities.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'returns_tab.dart';

/// Desempenho da carteira real (F8): rentabilidade por período e mês a mês.
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(wealthOverviewProvider);
    final assets = ref.watch(portfolioSnapshotProvider).value?.assets;
    final names = {
      for (final a in assets?.values ?? const <Asset>[]) a.id: a.symbol,
    };
    const tabs = [Tab(key: Key('perf-tab-returns'), text: 'Rentabilidade')];
    return PageScaffold(
      title: 'Desempenho',
      subtitle: 'Carteira real: rentabilidade, comparações e risco',
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  AsyncBody(
                    value: overview,
                    builder: (o) => ReturnsTab(overview: o, names: names),
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
