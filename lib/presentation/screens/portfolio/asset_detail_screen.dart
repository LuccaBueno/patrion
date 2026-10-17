import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
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

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;

  /// Nulo mostra "indisponível".
  final String? value;

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
          const UnavailableText()
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
              'Fonte: informado por você. Cotações automáticas chegam numa '
              'próxima etapa.',
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
