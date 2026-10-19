import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_price.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/portfolio_valuation.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Carteira real: posições por conta e ativo (SPEC §16).
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    return PageScaffold(
      title: 'Carteira',
      subtitle: 'Posições calculadas a partir das operações',
      child: AsyncBody(
        value: snapshot,
        builder: (snap) => PositionsTable(snap: snap),
      ),
    );
  }
}

/// Colunas da tabela. A classe fica embaixo do ativo, o preço médio embaixo
/// da quantidade e o percentual embaixo do resultado, para a tabela inteira
/// caber numa janela de 1280 px sem rolar para o lado.
enum _Col { asset, account, quantity, cost, value, pnl }

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
      _Col.cost => a.position.totalCost.compareTo(b.position.totalCost),
      _Col.value => _cmp(a.marketValue, b.marketValue),
      _Col.pnl => _cmp(a.unrealizedPnl, b.unrealizedPnl),
    };
    rows.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  DataColumn _column(String label, _Col column, {bool numeric = false}) =>
      DataColumn(
        label: Text(label),
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
              'As posições aparecem aqui depois que você registrar compras, '
              'aportes ou outras operações em Operações.',
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
            columnSpacing: 20,
            horizontalMargin: 16,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 60,
            sortColumnIndex: _Col.values.indexOf(_sort),
            sortAscending: _ascending,
            columns: [
              _column('Ativo', _Col.asset),
              _column('Conta', _Col.account),
              _column('Quantidade', _Col.quantity, numeric: true),
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
                    DataCell(Text(snap.accountLabel(v.position.accountId))),
                    DataCell(
                      _TwoLines(
                        top: Text(
                          v.position.quantity == Decimal.zero
                              ? '—'
                              : Fmt.number(v.position.quantity),
                        ),
                        bottom: v.position.averagePrice == null
                            ? null
                            : 'PM ${Fmt.money(v.position.averagePrice!, v.position.currency)}',
                      ),
                    ),
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
          'sobre o custo, sem proventos. PM = preço médio. Abaixo do valor, a '
          'fonte e a data do preço; o tipo, a coleta e o atraso aparecem ao '
          'passar o mouse.',
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
    final market = v.marketPrice;
    final String message;
    final bool stale;
    if (market != null) {
      stale = MarketPricing.isStale(
        market,
        today,
        market: v.asset?.market.code,
      );
      message =
          '${MarketLabels.price(market)}\n'
          '${MarketLabels.collected(market.collectedAt)}'
          '${stale ? '\nDesatualizado: a data é anterior ao último pregão.' : ''}';
    } else {
      stale = v.valuationStale;
      final source = v.valuationKind == ValuationKind.balance
          ? 'Saldo informado'
          : 'Preço informado';
      message =
          '$source em ${Fmt.date(v.valuationDate!)}'
          '${stale ? '\nHá operações depois desta data: o valor pode estar desatualizado.' : ''}';
    }
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stale)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.history,
                size: 16,
                color: muted,
                semanticLabel: 'Valor desatualizado',
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.money(v.marketValue!, v.position.currency)),
              Text(
                market != null
                    ? '${ProviderCatalog.shortNameOf(market.source)} · '
                          '${MarketLabels.refOf(market)}'
                    : 'informado · ${Fmt.date(v.valuationDate!)}',
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
