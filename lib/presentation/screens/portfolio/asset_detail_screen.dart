import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/market/market_data_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/instant_format.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/market_price.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/finance/returns.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../format/sync_labels.dart';
import '../../format/performance_format.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../operations/operation_dialogs.dart';
import '../operations/operations_screen.dart';
import '../registry/registry_dialogs.dart';

/// Detalhe do ativo: características, posições, preços informados e
/// operações (SPEC §16).
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return AsyncBody(
      value: snapshot,
      builder: (snap) {
        final asset = snap.assets[assetId];
        if (asset == null) {
          return PageScaffold(
            title: 'Ativo',
            child: Align(
              alignment: Alignment.topLeft,
              child: MessageCard(
                icon: Icons.search_off,
                title: 'Ativo não encontrado',
                message: 'Ele pode ter sido excluído.',
                action: TextButton(
                  onPressed: () => context.go('/carteira'),
                  child: const Text('Voltar para a carteira'),
                ),
              ),
            ),
          );
        }
        return PageScaffold(
          title: asset.symbol,
          subtitle:
              '${asset.name} · ${asset.assetClass.label} · '
              '${asset.market.label} · ${asset.currency}',
          actions: [
            IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/carteira'),
            ),
            OutlinedButton.icon(
              onPressed: () => showAssetDialog(
                context,
                initial: asset,
                terms: snap.fixedIncome[asset.id],
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
            OutlinedButton.icon(
              key: const Key('inform-price'),
              onPressed: () => showValuationDialog(context, snap, asset),
              icon: const Icon(Icons.price_change_outlined),
              label: const Text('Informar preço'),
            ),
            FilledButton.icon(
              onPressed: snap.accounts.isEmpty
                  ? null
                  : () => showOperationEditor(context, snap, assetId: asset.id),
              icon: const Icon(Icons.add),
              label: const Text('Operação'),
            ),
          ],
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _PositionsCard(snap: snap, asset: asset),
              _PerformanceCard(snap: snap, asset: asset),
              if (asset.assetClass != AssetClass.cash)
                _MarketCard(snap: snap, asset: asset),
              if (snap.fixedIncome[asset.id] != null)
                _TermsCard(terms: snap.fixedIncome[asset.id]!),
              _ValuationsCard(snap: snap, asset: asset),
              const SizedBox(height: 8),
              Text('Operações', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 480,
                child: OperationsTable(snap: snap, assetId: asset.id),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PositionsCard extends StatelessWidget {
  const _PositionsCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final positions = snap.valued
        .where((v) => v.position.assetId == asset.id)
        .toList();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Posição por conta', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (positions.isEmpty)
              Text(
                'Sem operações neste ativo.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            for (final v in positions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Wrap(
                  spacing: 32,
                  runSpacing: 4,
                  children: [
                    _Metric('Conta', snap.accountLabel(v.position.accountId)),
                    _Metric('Quantidade', Fmt.number(v.position.quantity)),
                    _Metric(
                      'Preço médio',
                      v.position.averagePrice == null
                          ? '—'
                          : Fmt.money(v.position.averagePrice!, asset.currency),
                    ),
                    _Metric(
                      'Custo',
                      Fmt.money(v.position.totalCost, asset.currency),
                    ),
                    _Metric(
                      'Valor de mercado',
                      v.marketValue == null
                          ? null
                          : '${Fmt.money(v.marketValue!, asset.currency)} '
                                '(${Fmt.date(v.valuationDate ?? snap.asOf)})',
                    ),
                    _Metric(
                      'Lucro realizado',
                      Fmt.signedMoney(v.position.realizedPnl, asset.currency),
                    ),
                    _Metric(
                      'Proventos (líquidos)',
                      Fmt.money(v.position.incomeNet, asset.currency),
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

/// Desempenho do ativo em todas as contas: resultado em dinheiro e TIR
/// (MWR) líquida, sem proventos e bruta (SPEC §9).
class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final p = snap.assetPerformance(asset.id);
    if (p == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final c = asset.currency;
    final reason = p.gap?.label;
    String? money(Decimal? v) => v == null ? null : Fmt.signedMoney(v, c);
    return Card(
      key: const Key('asset-performance'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Desempenho', style: theme.textTheme.titleMedium),
                const SizedBox(width: 4),
                Tooltip(
                  message: ReturnMethod.mwr.description,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                    semanticLabel: 'Sobre a métrica',
                  ),
                ),
              ],
            ),
            Text(
              p.net == null
                  ? 'Todas as contas. ${reason ?? ''}'
                  : 'Todas as contas, ${p.net!.range}. TIR (MWR): '
                        'ponderada pelo dinheiro, com o valor de mercado como '
                        'fluxo final.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric('Resultado total', money(p.totalResult), reason),
                _Metric(
                  'Resultado sem proventos',
                  money(p.resultWithoutIncome),
                  reason,
                ),
                _Metric('TIR líquida, com proventos', p.net?.text, reason),
                _Metric('TIR sem proventos', p.netWithoutIncome?.text, reason),
                _Metric('TIR bruta (antes de custos)', p.gross?.text, reason),
                _Metric('Aplicado', Fmt.money(p.invested, c)),
                _Metric('Vendas e resgates', Fmt.money(p.returned, c)),
                _Metric('Custos e impostos', Fmt.money(p.costs, c)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, [this.unavailableReason]);

  final String label;

  /// Nulo mostra "indisponível".
  final String? value;

  /// Motivo mostrado no tooltip de "indisponível".
  final String? unavailableReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (value == null)
          UnavailableText(tooltip: unavailableReason)
        else
          SelectableText(value!, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard({required this.terms});

  final FixedIncomeTerms terms;

  @override
  Widget build(BuildContext context) {
    final rate = terms.indexer == Indexer.pre
        ? '${Fmt.number(terms.rate)}% a.a.'
        : '${Fmt.number(terms.rate)}% do ${terms.indexer.label}'
              '${terms.spread == null ? '' : ' + ${Fmt.number(terms.spread!)}% a.a.'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características do título',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric('Produto', terms.product.label),
                _Metric('Emissor', terms.issuer ?? '—'),
                _Metric('Taxa', rate),
                _Metric('Emissão', Fmt.date(terms.issueDate)),
                _Metric('Vencimento', Fmt.date(terms.maturityDate)),
                _Metric(
                  'Carência',
                  terms.graceUntil == null ? '—' : Fmt.date(terms.graceUntil!),
                ),
                _Metric('Liquidez', terms.liquidity.label),
                _Metric('Base', terms.dayCount.label),
                _Metric('Tributação', terms.taxRegime.label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValuationsCard extends ConsumerWidget {
  const _ValuationsCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final valuations = snap.valuations
        .where((v) => v.assetId == asset.id)
        .take(20)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preços e saldos informados',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              'Fonte: informado por você. Num ativo com preço de mercado, vale o '
              'mais recente entre o informado e a cotação (na mesma data, o '
              'informado).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (valuations.isEmpty)
              Text(
                'Nenhum valor informado: o valor de mercado fica '
                'indisponível.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            for (final v in valuations)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  v.kind == ValuationKind.balance
                      ? Icons.account_balance_wallet_outlined
                      : Icons.sell_outlined,
                  size: 20,
                ),
                title: Text(
                  '${Fmt.money(v.value, v.currency)} em ${Fmt.date(v.refDate)}',
                ),
                subtitle: Text(
                  v.kind == ValuationKind.balance
                      ? 'Saldo · ${snap.accountLabel(v.accountId!)}'
                      : 'Preço unitário',
                ),
                trailing: IconButton(
                  tooltip: 'Excluir valor',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    final ok = await confirm(
                      context,
                      title: 'Excluir este valor?',
                      message: 'O valor de mercado passa a usar o anterior.',
                    );
                    if (!ok) return;
                    try {
                      await ref.read(valuationServiceProvider).delete(v.id);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dados de mercado guardados de um ativo.
typedef _AssetMarketData = ({
  List<MarketQuote> quotes,
  (LocalDate, LocalDate, int)? range,
  int events,
});

final _assetMarketProvider =
    StreamProvider.family<_AssetMarketData, (String, String)>((ref, key) {
      final repo = ref.watch(marketRepositoryProvider);
      final (symbol, market) = key;
      Future<_AssetMarketData> load() async => (
        quotes: await repo.quotes(symbol, market),
        range: await repo.priceRange(symbol, market),
        events: (await repo.events(symbol, market)).length,
      );
      final controller = StreamController<_AssetMarketData>();
      Future<void> emit() async {
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      }

      unawaited(emit());
      final sub = repo.watchChanges().listen((_) => unawaited(emit()));
      ref.onDispose(() {
        unawaited(sub.cancel());
        unawaited(controller.close());
      });
      return controller.stream;
    });

/// Cotação usada, fonte e data, histórico guardado e atualização deste
/// ativo (SPEC §5: atualizar um ativo; regra 2).
class _MarketCard extends ConsumerWidget {
  const _MarketCard({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    String task,
    Future<RefreshResult> Function(MarketDataService s) job,
  ) async {
    final result = await ref
        .read(marketRefreshProvider.notifier)
        .run(task, job);
    if (context.mounted) showInfo(context, MarketLabels.result(result));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final busy = ref.watch(marketRefreshProvider).busy;
    final data = ref
        .watch(
          _assetMarketProvider((asset.symbol.toUpperCase(), asset.market.code)),
        )
        .value;
    final used = snap.valued
        .map((v) => v.marketPrice)
        .whereType<MarketPrice>()
        .where((p) => p.assetId == asset.id)
        .firstOrNull;
    final manual = asset.priceSource != PriceSource.market;
    final stale =
        used != null &&
        MarketPricing.isStale(used, snap.asOf, market: asset.market.code);
    final range = data?.range;
    return Card(
      key: const Key('asset-market'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dados de mercado', style: theme.textTheme.titleMedium),
            if (manual)
              Text(
                'Este ativo usa preço informado por você. Para usar cotações '
                'automáticas, escolha "preço de mercado" em Editar.',
                style: muted,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 32,
              runSpacing: 8,
              children: [
                _Metric(
                  'Preço de mercado usado',
                  used == null ? null : Fmt.money(used.price, used.currency),
                  manual
                      ? 'O ativo usa preço informado.'
                      : 'Sem cotação guardada para este ativo.',
                ),
                if (used != null) ...[
                  _Metric('Fonte', ProviderCatalog.nameOf(used.source)),
                  _Metric(
                    'Data de referência',
                    stale
                        ? '${MarketLabels.refOf(used)} (desatualizado)'
                        : MarketLabels.refOf(used),
                  ),
                  _Metric('Tipo', used.dataType.label),
                  _Metric('Coleta', SyncLabels.instant(used.collectedAt)),
                  if (used.delayNote != null) _Metric('Atraso', used.delayNote),
                ],
                _Metric(
                  'Histórico guardado',
                  range == null
                      ? 'nenhum'
                      : '${range.$3} dias, de ${Fmt.date(range.$1)} a '
                            '${Fmt.date(range.$2)}',
                ),
                if (data != null && data.events > 0)
                  _Metric('Proventos e eventos', '${data.events} guardados'),
              ],
            ),
            if (data != null && data.quotes.length > 1) ...[
              const SizedBox(height: 8),
              Text('Cotações guardadas por fonte', style: muted),
              for (final q in data.quotes)
                Text(
                  '${ProviderCatalog.nameOf(q.source)}: '
                  '${Fmt.money(q.price, q.currency)} · '
                  '${SyncLabels.instant(formatInstant(q.refAt))}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('asset-refresh'),
                  onPressed: busy
                      ? null
                      : () => _run(
                          context,
                          ref,
                          'Atualização de ${asset.symbol}',
                          (s) => s.refreshAsset(asset),
                        ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Atualizar este ativo'),
                ),
                OutlinedButton.icon(
                  key: const Key('asset-history'),
                  onPressed: busy || asset.assetClass == AssetClass.treasury
                      ? null
                      : () => _run(
                          context,
                          ref,
                          'Histórico de ${asset.symbol}',
                          (s) => s.downloadHistory(asset),
                        ),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Baixar histórico'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'O histórico é o preço publicado pela fonte, sem ajuste por '
              'proventos ou eventos. Na B3 vem do COTAHIST: só os anos que '
              'faltam, a partir do ano escolhido em Fontes de dados.',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}
