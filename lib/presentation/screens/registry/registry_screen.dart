import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../portfolio/add_asset_dialog.dart';
import 'registry_dialogs.dart';

/// Cadastros: instituições, contas e ativos (SPEC §6).
class RegistryScreen extends ConsumerWidget {
  const RegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return DefaultTabController(
      length: 2,
      child: PageScaffold(
        title: 'Cadastros',
        subtitle: 'Instituições, contas e ativos da carteira real',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Instituições e contas'),
                Tab(text: 'Ativos'),
              ],
            ),
            Expanded(
              child: AsyncBody(
                value: snapshot,
                builder: (snap) => TabBarView(
                  children: [
                    _InstitutionsTab(snap: snap),
                    _AssetsTab(snap: snap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _guard(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _InstitutionsTab extends ConsumerWidget {
  const _InstitutionsTab({required this.snap});

  final PortfolioSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final institutions = snap.institutions.values.toList()
      ..sort((a, b) => a.nameKey.compareTo(b.nameKey));
    final service = ref.read(registryServiceProvider);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => showInstitutionDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nova instituição'),
          ),
        ),
        const SizedBox(height: 16),
        if (institutions.isEmpty)
          const MessageCard(
            icon: Icons.account_balance_outlined,
            title: 'Nenhuma instituição cadastrada',
            message:
                'Comece pela corretora, banco ou exchange onde ficam seus '
                'investimentos. Depois crie as contas dentro dela.',
          ),
        for (final inst in institutions)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_balance_outlined),
                    title: Text(inst.name),
                    subtitle: Text('${inst.kind.label} · ${inst.country}'),
                    trailing: Wrap(
                      children: [
                        TextButton.icon(
                          onPressed: () => showAccountDialog(
                            context,
                            institutionId: inst.id,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Conta'),
                        ),
                        IconButton(
                          tooltip: 'Editar instituição',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              showInstitutionDialog(context, initial: inst),
                        ),
                        IconButton(
                          tooltip: 'Excluir instituição',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await confirm(
                              context,
                              title: 'Excluir ${inst.name}?',
                              message:
                                  'A instituição some das listas. Só é '
                                  'possível excluir instituições sem contas.',
                            );
                            if (ok && context.mounted) {
                              await _guard(
                                context,
                                () => service.deleteInstitution(inst.id),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  for (final acc in snap.accounts.values.where(
                    (a) => a.institutionId == inst.id,
                  ))
                    _AccountTile(account: acc),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(registryServiceProvider);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40),
      dense: true,
      leading: Icon(
        account.archived ? Icons.inventory_2_outlined : Icons.wallet_outlined,
        size: 20,
      ),
      title: Text(
        account.archived ? '${account.name} (arquivada)' : account.name,
      ),
      subtitle: Text('${account.kind.label} · ${account.currency}'),
      trailing: Wrap(
        children: [
          IconButton(
            tooltip: 'Editar conta',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showAccountDialog(
              context,
              institutionId: account.institutionId,
              initial: account,
            ),
          ),
          IconButton(
            tooltip: 'Excluir conta',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final ok = await confirm(
                context,
                title: 'Excluir a conta ${account.name}?',
                message:
                    'Só é possível excluir contas sem operações. Para '
                    'esconder uma conta com histórico, arquive-a.',
              );
              if (ok && context.mounted) {
                await _guard(context, () => service.deleteAccount(account.id));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AssetsTab extends ConsumerStatefulWidget {
  const _AssetsTab({required this.snap});

  final PortfolioSnapshot snap;

  @override
  ConsumerState<_AssetsTab> createState() => _AssetsTabState();
}

class _AssetsTabState extends ConsumerState<_AssetsTab> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    final f = _filter.toLowerCase();
    final assets =
        snap.assets.values
            .where(
              (a) =>
                  f.isEmpty ||
                  a.symbol.toLowerCase().contains(f) ||
                  a.name.toLowerCase().contains(f),
            )
            .toList()
          ..sort((a, b) => a.symbol.compareTo(b.symbol));
    final service = ref.read(registryServiceProvider);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Row(
          children: [
            FilledButton.icon(
              key: const Key('registry-add-asset'),
              onPressed: () => showAddAssetDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar ativo'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => showAssetDialog(context),
              icon: const Icon(Icons.tune),
              label: const Text('Cadastro completo'),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar por código ou nome',
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _filter = v.trim()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (snap.assets.isEmpty)
          const MessageCard(
            icon: Icons.category_outlined,
            title: 'Nenhum ativo cadastrado',
            message:
                'Cadastre ações, FIIs, títulos de renda fixa, cripto e o que '
                'mais você tiver. O preço pode ser informado manualmente.',
          )
        else
          TableCard(
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('Código')),
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Classe')),
                DataColumn(label: Text('Mercado')),
                DataColumn(label: Text('Moeda')),
                DataColumn(label: Text('Vencimento')),
                DataColumn(label: Text('')),
              ],
              rows: [
                for (final a in assets)
                  DataRow(
                    onSelectChanged: (_) =>
                        context.go('/carteira/ativo/${a.id}'),
                    cells: [
                      DataCell(Text(a.symbol)),
                      DataCell(Text(a.name)),
                      DataCell(Text(a.assetClass.label)),
                      DataCell(Text(a.market.label)),
                      DataCell(Text(a.currency)),
                      DataCell(
                        Text(
                          snap.fixedIncome[a.id] == null
                              ? '—'
                              : Fmt.date(snap.fixedIncome[a.id]!.maturityDate),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar ativo',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => showAssetDialog(
                                context,
                                initial: a,
                                terms: snap.fixedIncome[a.id],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Excluir ativo',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                final ok = await confirm(
                                  context,
                                  title: 'Excluir ${a.symbol}?',
                                  message:
                                      'Só é possível excluir ativos sem '
                                      'operações. Os preços informados '
                                      'também são excluídos.',
                                );
                                if (ok && context.mounted) {
                                  await _guard(
                                    context,
                                    () => service.deleteAsset(a.id),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
