import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/operation_type.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'operation_dialogs.dart';

/// Operações da carteira real (SPEC §7): lista com busca, filtros e
/// ordenação; criar, editar e excluir.
class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return AsyncBody(
      value: snapshot,
      builder: (snap) => PageScaffold(
        title: 'Operações',
        subtitle: 'Toda alteração recalcula as posições a partir dela',
        actions: [
          OutlinedButton.icon(
            onPressed: snap.accounts.length < 2
                ? null
                : () => showTransferDialog(context, snap),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Transferência'),
          ),
          FilledButton.icon(
            key: const Key('new-operation'),
            onPressed: snap.accounts.isEmpty
                ? null
                : () => showOperationEditor(context, snap),
            icon: const Icon(Icons.add),
            label: const Text('Nova operação'),
          ),
        ],
        child: OperationsTable(snap: snap),
      ),
    );
  }
}

enum _SortColumn { date, type, asset, account, quantity, amount }

/// Tabela de operações. Com [assetId], mostra só as do ativo.
class OperationsTable extends ConsumerStatefulWidget {
  const OperationsTable({required this.snap, this.assetId, super.key});

  final PortfolioSnapshot snap;
  final String? assetId;

  @override
  ConsumerState<OperationsTable> createState() => _OperationsTableState();
}

class _OperationsTableState extends ConsumerState<OperationsTable> {
  String _search = '';
  String? _accountFilter;
  OperationGroup? _groupFilter;
  _SortColumn _sort = _SortColumn.date;
  bool _ascending = false;

  List<Operation> _rows() {
    final snap = widget.snap;
    final s = _search.toLowerCase();
    final rows = snap.operations.where((o) {
      if (widget.assetId != null && o.assetId != widget.assetId) return false;
      if (_accountFilter != null && o.accountId != _accountFilter) {
        return false;
      }
      if (_groupFilter != null && o.type.group != _groupFilter) return false;
      if (s.isEmpty) return true;
      final asset = snap.assets[o.assetId];
      return [
        o.type.label,
        asset?.symbol ?? '',
        asset?.name ?? '',
        snap.accountLabel(o.accountId),
        o.notes ?? '',
        o.justification ?? '',
      ].any((t) => t.toLowerCase().contains(s));
    }).toList();

    int compare(Operation a, Operation b) => switch (_sort) {
      _SortColumn.date => Operation.chronological(a, b),
      _SortColumn.type => a.type.label.compareTo(b.type.label),
      _SortColumn.asset => (snap.assets[a.assetId]?.symbol ?? '').compareTo(
        snap.assets[b.assetId]?.symbol ?? '',
      ),
      _SortColumn.account =>
        snap
            .accountLabel(a.accountId)
            .compareTo(snap.accountLabel(b.accountId)),
      _SortColumn.quantity => (a.quantity ?? Decimal.zero).compareTo(
        b.quantity ?? Decimal.zero,
      ),
      _SortColumn.amount => a.amount.compareTo(b.amount),
    };
    rows.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  DataColumn _column(
    String label,
    _SortColumn column, {
    bool numeric = false,
  }) => DataColumn(
    label: Text(label),
    numeric: numeric,
    onSort: (_, _) => setState(() {
      if (_sort == column) {
        _ascending = !_ascending;
      } else {
        _sort = column;
        _ascending = column != _SortColumn.date;
      }
    }),
  );

  Future<void> _delete(Operation op) async {
    final ok = await confirm(
      context,
      title: 'Excluir operação?',
      message: op.type.isTransfer
          ? 'As duas pontas da transferência serão excluídas.'
          : '${op.type.label} de ${Fmt.date(op.tradeDate)}. As posições '
                'serão recalculadas.',
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(operationServiceProvider).delete(op.id);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    if (snap.operations.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: MessageCard(
          icon: Icons.receipt_long_outlined,
          title: 'Nenhuma operação registrada',
          message: snap.accounts.isEmpty
              ? 'Cadastre uma instituição e uma conta em Cadastros para '
                    'começar.'
              : 'Registre compras, vendas, aportes, proventos e eventos. '
                    'As posições são calculadas a partir delas.',
        ),
      );
    }
    final rows = _rows();
    final sortIndex = _SortColumn.values.indexOf(_sort);
    final accounts = [for (final a in snap.accounts.values) a.id]
      ..sort((a, b) => snap.accountLabel(a).compareTo(snap.accountLabel(b)));

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar',
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
            ),
            if (widget.assetId == null)
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String?>(
                  initialValue: _accountFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Conta',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(child: Text('Todas')),
                    for (final id in accounts)
                      DropdownMenuItem(
                        value: id,
                        child: Text(snap.accountLabel(id)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _accountFilter = v),
                ),
              ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<OperationGroup?>(
                initialValue: _groupFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(child: Text('Todos')),
                  for (final g in OperationGroup.values)
                    DropdownMenuItem(value: g, child: Text(g.label)),
                ],
                onChanged: (v) => setState(() => _groupFilter = v),
              ),
            ),
            Text(
              '${rows.length} de ${snap.operations.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TableCard(
          child: DataTable(
            sortColumnIndex: sortIndex,
            sortAscending: _ascending,
            columns: [
              _column('Data', _SortColumn.date),
              _column('Tipo', _SortColumn.type),
              _column('Ativo', _SortColumn.asset),
              _column('Conta', _SortColumn.account),
              _column('Quantidade', _SortColumn.quantity, numeric: true),
              _column('Valor', _SortColumn.amount, numeric: true),
              const DataColumn(label: Text('Custos e impostos'), numeric: true),
              const DataColumn(label: Text('')),
            ],
            rows: [
              for (final op in rows)
                DataRow(
                  cells: [
                    DataCell(Text(Fmt.date(op.tradeDate))),
                    DataCell(
                      Tooltip(
                        message:
                            op.justification ?? op.notes ?? op.type.group.label,
                        child: Text(op.type.label),
                      ),
                    ),
                    DataCell(Text(snap.assets[op.assetId]?.symbol ?? '—')),
                    DataCell(Text(snap.accountLabel(op.accountId))),
                    DataCell(
                      Text(
                        op.type.usesRatio
                            ? '${Fmt.number(op.ratioFrom!)}:'
                                  '${Fmt.number(op.ratioTo!)}'
                            : op.quantity == null
                            ? '—'
                            : Fmt.number(op.quantity!),
                      ),
                    ),
                    DataCell(
                      Text(
                        op.type.usesRatio
                            ? '—'
                            : Fmt.money(op.amount, op.currency),
                      ),
                    ),
                    DataCell(
                      Text(
                        op.charges == Decimal.zero
                            ? '—'
                            : Fmt.money(op.charges, op.currency),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                showOperationEditor(context, snap, initial: op),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _delete(op),
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
