import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Histórico guardado de um ativo: primeiro e último fechamento e dias.
typedef HistoryCoverage = ({Asset asset, (LocalDate, LocalDate, int)? range});

/// Ativos com preço de mercado e o histórico guardado de cada um,
/// recalculado quando os dados de mercado mudam.
final historyCoverageProvider = StreamProvider<List<HistoryCoverage>>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  final service = ref.watch(marketDataServiceProvider);
  final assets = ref.watch(portfolioSnapshotProvider).value?.assets.values;
  final controller = StreamController<List<HistoryCoverage>>();
  Future<void> emit() async {
    final list = <HistoryCoverage>[
      for (final a in assets ?? const <Asset>[])
        if (a.priceSource == PriceSource.market &&
            a.assetClass != AssetClass.cash &&
            a.assetClass != AssetClass.treasury &&
            service.hasHistorySource(a))
          (
            asset: a,
            range: await repo.priceRange(a.symbol.toUpperCase(), a.market.code),
          ),
    ]..sort((a, b) => a.asset.symbol.compareTo(b.asset.symbol));
    if (!controller.isClosed) controller.add(list);
  }

  unawaited(emit());
  final sub = repo.watchChanges().listen((_) => unawaited(emit()));
  ref.onDispose(() {
    unawaited(sub.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Andamento discreto do histórico completo no rodapé do menu (M-08).
class HistoryBackfillIndicator extends ConsumerWidget {
  const HistoryBackfillIndicator({required this.extended, super.key});

  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(historyBackfillProvider).progress;
    if (progress == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final label = progress.symbols.isEmpty
        ? 'Preparando o histórico…'
        : progress.label;
    final steps = progress.total == 0
        ? null
        : (progress.done + (progress.percent ?? 0) / 100) / progress.total;
    final bar = LinearProgressIndicator(value: steps, minHeight: 3);
    return Tooltip(
      message:
          '$label\nO histórico de cotações é baixado em segundo plano; pode '
          'continuar usando o app. Se fechar, ele continua na próxima '
          'abertura.',
      child: Padding(
        key: const Key('history-backfill-indicator'),
        padding: const EdgeInsets.only(bottom: 8),
        child: extended
            ? SizedBox(
                width: 196,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    bar,
                  ],
                ),
              )
            : SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_download_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: 'Baixando histórico',
                    ),
                    const SizedBox(height: 4),
                    bar,
                  ],
                ),
              ),
      ),
    );
  }
}

/// Fontes de dados → histórico por ativo: desde quando há fechamentos e o
/// botão "Baixar histórico completo" (M-08).
class HistoryCoverageCard extends ConsumerWidget {
  const HistoryCoverageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final list = ref.watch(historyCoverageProvider).value;
    final backfill = ref.watch(historyBackfillProvider);
    final progress = backfill.progress;
    return Card(
      key: const Key('history-coverage'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico de cotações', style: theme.textTheme.titleMedium),
            Text(
              'Fechamentos diários desde o ano escolhido acima (ou desde a '
              'listagem do ativo), baixados em segundo plano ao adicionar um '
              'ativo e ao abrir o app. Na B3, um arquivo anual do COTAHIST '
              'serve a todos os ativos e é apagado depois de lido.',
              style: muted,
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text(
                progress.symbols.isEmpty
                    ? 'Preparando o histórico…'
                    : progress.label,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.total == 0
                    ? null
                    : (progress.done + (progress.percent ?? 0) / 100) /
                          progress.total,
              ),
            ] else if (backfill.lastResult case final r?
                when r.failures.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Último histórico: ${MarketLabels.result(r)} Tenta de novo '
                'na próxima abertura ou pelo botão.',
                style: muted,
              ),
            ],
            const SizedBox(height: 8),
            if (list == null)
              const LinearProgressIndicator()
            else if (list.isEmpty)
              Text('Nenhum ativo com preço de mercado.', style: muted)
            else
              for (final c in list)
                ListTile(
                  key: Key('history-${c.asset.symbol}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.asset.symbol),
                  subtitle: Text(
                    c.range == null
                        ? 'Nenhum fechamento guardado'
                        : 'Desde ${Fmt.date(c.range!.$1)} · até '
                              '${Fmt.date(c.range!.$2)} · ${c.range!.$3} '
                              'pregões',
                  ),
                  trailing: TextButton(
                    key: Key('history-redo-${c.asset.symbol}'),
                    onPressed: progress != null
                        ? null
                        : () => _redo(context, ref, c.asset),
                    child: const Text('Baixar histórico completo'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static void _redo(BuildContext context, WidgetRef ref, Asset asset) {
    final controller = ref.read(historyBackfillProvider.notifier);
    unawaited(() async {
      final result = await controller.redo(asset.symbol.toUpperCase());
      if (context.mounted) showInfo(context, MarketLabels.result(result));
    }());
  }
}

/// Começa o histórico completo em segundo plano (depois de cadastrar um
/// ativo, por exemplo).
void startHistoryBackfill(WidgetRef ref) =>
    unawaited(ref.read(historyBackfillProvider.notifier).start());

/// Mesmo que [startHistoryBackfill], a partir de um [ProviderContainer].
void startHistoryBackfillIn(ProviderContainer container) =>
    unawaited(container.read(historyBackfillProvider.notifier).start());
