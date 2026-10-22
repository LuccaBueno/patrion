import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/portfolio_valuation.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'add_asset_dialog.dart';

/// Carteira real: posições por conta e ativo (SPEC §16).
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return PageScaffold(
      title: 'Carteira',
      subtitle: 'Posições calculadas a partir das operações',
      actions: [
        FilledButton.icon(
          key: const Key('portfolio-add-asset'),
          onPressed: () => showAddAssetDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar ativo'),
        ),
      ],
      child: AsyncBody(
        value: snapshot,
        builder: (snap) => PositionsTable(snap: snap),
      ),
    );
  }
}

/// Colunas da tabela. A classe fica embaixo do ativo, o preço atual embaixo
/// do preço médio e o percentual embaixo do resultado, para a tabela inteira
/// caber numa janela de 1280 px sem rolar para o lado.
enum _Col { asset, account, quantity, price, cost, value, pnl }

/// Tabela de posições, ordenável, com busca e opção de mostrar encerradas.
class PositionsTable extends StatefulWidget {
  const PositionsTable({required this.snap, super.key});

  final PortfolioSnapshot snap;

  @override
  State<PositionsTable> createState() => _PositionsTableState();
}

class _PositionsTableState extends State<PositionsTable> {
  String _search = '';
  bool _showClosed = false;
  _Col _sort = _Col.value;
  bool _ascending = false;

  List<ValuedPosition> _rows() {
    final snap = widget.snap;
    final s = _search.toLowerCase();
    final rows = snap.valued.where((v) {
      if (!_showClosed && !v.position.isOpen) return false;
      if (s.isEmpty) return true;
      return [
        v.asset?.symbol ?? '',
        v.asset?.name ?? '',
        snap.accountLabel(v.position.accountId),
      ].any((t) => t.toLowerCase().contains(s));
    }).toList();

    int compare(ValuedPosition a, ValuedPosition b) => switch (_sort) {
      _Col.asset => (a.asset?.symbol ?? '').compareTo(b.asset?.symbol ?? ''),
      _Col.account =>
        snap
            .accountLabel(a.position.accountId)
            .compareTo(snap.accountLabel(b.position.accountId)),
      _Col.quantity => a.position.quantity.compareTo(b.position.quantity),
      _Col.price => _cmp(a.unitPrice, b.unitPrice),
      _Col.cost => a.position.totalCost.compareTo(b.position.totalCost),
      _Col.value => _cmp(a.marketValue, b.marketValue),
      _Col.pnl => _cmp(a.unrealizedPnl, b.unrealizedPnl),
    };
    rows.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  DataColumn _column(
    String label,
    _Col column, {
    bool numeric = false,
    String? tooltip,
  }) => DataColumn(
    label: Text(label, textAlign: numeric ? TextAlign.end : null),
    tooltip: tooltip,
    numeric: numeric,
    onSort: (_, _) => setState(() {
      if (_sort == column) {
        _ascending = !_ascending;
      } else {
        _sort = column;
        _ascending = !numeric;
      }
    }),
  );

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    if (snap.state.positions.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: MessageCard(
          icon: Icons.pie_chart_outline,
          title: 'Nenhuma posição',
          message:
              'Use "Adicionar ativo" para incluir as ações, FIIs, ETFs e '
              'BDRs que você tem, ou registre operações em Operações.',
        ),
      );
    }
    final rows = _rows();
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar ativo ou conta',
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
            ),
            FilterChip(
              label: const Text('Mostrar encerradas'),
              selected: _showClosed,
              onSelected: (v) => setState(() => _showClosed = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TableCard(
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 16,
            horizontalMargin: 12,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            sortColumnIndex: _Col.values.indexOf(_sort),
            sortAscending: _ascending,
            columns: [
              _column('Ativo', _Col.asset),
              _column('Conta', _Col.account),
              _column(
                'Qtd.',
                _Col.quantity,
                numeric: true,
                tooltip: 'Quantidade',
              ),
              // Duas linhas, como as células: preço médio em cima, atual
              // embaixo.
              _column(
                'Preço médio /\nAtual',
                _Col.price,
                numeric: true,
                tooltip:
                    'Preço médio de compra e, embaixo, o preço unitário '
                    'atual. Ordena pelo atual.',
              ),
              _column('Custo', _Col.cost, numeric: true),
              _column('Valor de mercado', _Col.value, numeric: true),
              _column('Resultado', _Col.pnl, numeric: true),
            ],
            rows: [
              for (final v in rows)
                DataRow(
                  onSelectChanged: (_) =>
                      context.go('/carteira/ativo/${v.position.assetId}'),
                  cells: [
                    DataCell(
                      _TwoLines(
                        alignEnd: false,
                        top: Text(
                          v.asset?.symbol ?? '?',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        bottom: v.asset?.assetClass.label,
                      ),
                    ),
                    DataCell(_AccountCell(snap: snap, v: v)),
                    DataCell(
                      Text(
                        v.position.quantity == Decimal.zero
                            ? '—'
                            : Fmt.number(v.position.quantity),
                      ),
                    ),
                    DataCell(_PriceCell(v: v, today: snap.asOf)),
                    DataCell(
                      Text(
                        Fmt.money(v.position.totalCost, v.position.currency),
                      ),
                    ),
                    DataCell(_MarketValueCell(v: v, today: snap.asOf)),
                    DataCell(
                      v.unrealizedPnl == null
                          ? const Text('—')
                          : _TwoLines(
                              top: PnlText(
                                value: v.unrealizedPnl!,
                                singleLine: true,
                                text: Fmt.signedMoney(
                                  v.unrealizedPnl!,
                                  v.position.currency,
                                ),
                              ),
                              bottom: v.simpleReturn == null
                                  ? null
                                  : Fmt.percent(v.simpleReturn!),
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Resultado = valor de mercado − custo; embaixo, o retorno simples '
          'sobre o custo, sem proventos. Abaixo do preço médio, o preço '
          'unitário atual; abaixo do valor, a fonte e a data do preço. O '
          'tipo, a coleta e o atraso aparecem ao passar o mouse.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MarketValueCell extends StatelessWidget {
  const _MarketValueCell({required this.v, required this.today});

  final ValuedPosition v;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    if (!v.position.isOpen) return const Text('—');
    if (v.marketValue == null) {
      return UnavailableText(
        tooltip: v.asset?.priceSource == PriceSource.market
            ? 'Sem cotação guardada. Use "Atualizar agora" em Fontes de '
                  'dados ou informe o preço no detalhe do ativo.'
            : 'Sem preço ou saldo informado. Informe no detalhe do ativo.',
      );
    }
    final note = MarketLabels.valuation(v, today)!;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: note.message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.stale) _StaleIcon(color: muted),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.money(v.marketValue!, v.position.currency)),
              Text(
                note.short,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Instituição em cima e conta embaixo (em uma linha, o nome completo
/// alargava a tabela além de 1280 px); nomes longos são cortados, com o
/// nome inteiro no tooltip.
class _AccountCell extends StatelessWidget {
  const _AccountCell({required this.snap, required this.v});

  final PortfolioSnapshot snap;
  final ValuedPosition v;

  @override
  Widget build(BuildContext context) {
    final account = snap.accounts[v.position.accountId];
    final institution = account == null
        ? null
        : snap.institutions[account.institutionId];
    final theme = Theme.of(context);
    return Tooltip(
      message: snap.accountLabel(v.position.accountId),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              institution?.name ?? account?.name ?? '—',
              overflow: TextOverflow.ellipsis,
            ),
            if (institution != null)
              Text(
                account!.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Preço médio em cima e preço unitário atual embaixo, alinhados para
/// comparar. A fonte e a data do preço atual ficam no tooltip; sem preço,
/// "indisponível".
class _PriceCell extends StatelessWidget {
  const _PriceCell({required this.v, required this.today});

  final ValuedPosition v;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    if (!v.position.isOpen) return const Text('—');
    final currency = v.position.currency;
    final average = v.position.averagePrice;
    final price = v.unitPrice;
    final note = MarketLabels.valuation(v, today);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final Widget current;
    if (price == null || note == null) {
      current = UnavailableText(
        tooltip: v.valuationKind == ValuationKind.balance
            ? 'Avaliado por saldo informado: não há preço unitário.'
            : v.asset?.priceSource == PriceSource.market
            ? 'Sem cotação guardada. Use "Atualizar agora" em Fontes de '
                  'dados ou informe o preço no detalhe do ativo.'
            : 'Sem preço informado. Informe no detalhe do ativo.',
      );
    } else {
      current = Tooltip(
        message: note.message,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.stale) _StaleIcon(color: muted),
            Text(
              Fmt.money(price, currency),
              key: const Key('current-price'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(average == null ? '—' : Fmt.money(average, currency)),
        current,
      ],
    );
  }
}

class _StaleIcon extends StatelessWidget {
  const _StaleIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Icon(
      Icons.history,
      size: 16,
      color: color,
      semanticLabel: 'Valor desatualizado',
    ),
  );
}

/// Célula com o valor e uma nota menor embaixo.
class _TwoLines extends StatelessWidget {
  const _TwoLines({required this.top, this.bottom, this.alignEnd = true});

  final Widget top;
  final String? bottom;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final note = bottom;
    if (note == null) return top;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        top,
        Text(
          note,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Compara valores opcionais; ausentes ficam antes de todos.
int _cmp(Decimal? a, Decimal? b) {
  if (a == null) return b == null ? 0 : -1;
  if (b == null) return 1;
  return a.compareTo(b);
}
