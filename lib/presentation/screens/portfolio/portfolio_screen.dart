import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'add_asset_dialog.dart';
import 'asset_panel.dart';

/// Carteira real: um item por ativo, onde há mais dinheiro primeiro, com o
/// painel de detalhes por cima da lista (M-05; SPEC §16).
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
    final snap = snapshot.value;
    final holdings = snap == null ? const <Holding>[] : _holdings(snap, fx);
    final page = PageScaffold(
      title: 'Carteira',
      subtitle: 'Onde está o seu dinheiro, do maior valor para o menor',
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
        builder: (snap) => HoldingsList(
          snap: snap,
          holdings: holdings,
          selected: _selected,
          onSelect: (id) => setState(() => _selected = id),
        ),
      ),
    );
    final selected = holdings.where((h) => h.assetId == _selected).firstOrNull;
    if (snap == null || selected == null) return page;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 640 ? constraints.maxWidth : 560.0;
        return Stack(
          children: [
            page,
            Positioned.fill(
              child: GestureDetector(
                key: const Key('asset-panel-scrim'),
                onTap: () => setState(() => _selected = null),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: width,
              child: AssetPanel(
                snap: snap,
                holding: selected,
                all: holdings,
                onClose: () => setState(() => _selected = null),
              ),
            ),
          ],
        );
      },
    );
  }

  static List<Holding> _holdings(
    PortfolioSnapshot snap,
    Map<String, FxRate> fx,
  ) => Holdings.build(
    snap.valued,
    toBrl: {
      for (final MapEntry(:key, :value) in fx.entries)
        if (value.mid != null) key: value.mid!,
    },
  );
}

/// Lista da Carteira, com busca. Cabe em 1280 px sem rolagem lateral: as
/// colunas dividem a largura disponível.
class HoldingsList extends StatefulWidget {
  const HoldingsList({
    required this.snap,
    required this.holdings,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final PortfolioSnapshot snap;
  final List<Holding> holdings;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  State<HoldingsList> createState() => _HoldingsListState();
}

class _HoldingsListState extends State<HoldingsList> {
  String _search = '';

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
    final s = _search.toLowerCase();
    final rows = [
      for (final h in widget.holdings)
        if (s.isEmpty ||
            (h.asset?.symbol ?? '').toLowerCase().contains(s) ||
            (h.asset?.name ?? '').toLowerCase().contains(s))
          h,
    ];
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 320,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar ativo',
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _HeaderRow(),
              const Divider(height: 1),
              for (final (i, h) in rows.indexed) ...[
                if (i > 0) const Divider(height: 1),
                _HoldingRow(
                  holding: h,
                  today: snap.asOf,
                  selected: h.assetId == widget.selected,
                  onTap: () => widget.onSelect(h.assetId),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Valor da posição = quantidade × cotação atual. Valorização = '
          '(cotação − preço médio) ÷ preço médio, sem proventos. Sem cotação, '
          'o ativo é ordenado pelo total aplicado. Abaixo da cotação, a fonte '
          'e a data; o tipo, a coleta e o atraso aparecem ao passar o mouse. '
          'Ativos sem cotas ficam no fim.',
          style: muted,
        ),
      ],
    );
  }
}

/// Larguras relativas das colunas.
const _flex = [5, 3, 3, 3, 3];
const _buttonWidth = 104.0;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    Widget cell(int i, String text, {bool end = true}) => Expanded(
      flex: _flex[i],
      child: Text(text, style: style, textAlign: end ? TextAlign.end : null),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          cell(0, 'Ativo', end: false),
          cell(1, 'Valor da posição'),
          cell(2, 'Preço médio'),
          cell(3, 'Cotação atual'),
          cell(4, 'Valorização'),
          const SizedBox(width: _buttonWidth),
        ],
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({
    required this.holding,
    required this.today,
    required this.selected,
    required this.onTap,
  });

  final Holding holding;
  final LocalDate today;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = holding;
    final c = h.currency;
    final muted = theme.colorScheme.onSurfaceVariant;
    final closed = !h.isOpen;
    final asset = h.asset;
    final priced = h.priced;
    final note = priced == null ? null : MarketLabels.valuation(priced, today);
    final unavailable = asset?.priceSource == PriceSource.market
        ? 'Sem cotação guardada. Use "Atualizar agora" ou informe o preço na '
              'página do ativo.'
        : 'Sem preço ou saldo informado. Informe na página do ativo.';

    // Em janelas estreitas, o número encolhe em vez de cortar.
    Widget end(Widget child) => Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: child,
      ),
    );

    final value = h.marketValue;
    final appreciation = h.appreciation;
    final row = Row(
      children: [
        Expanded(
          flex: _flex[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: asset?.symbol ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (asset != null)
                      TextSpan(
                        text: '  ${asset.name}',
                        style: TextStyle(color: muted),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                closed
                    ? 'sem cotas'
                    : h.quantity > Decimal.zero
                    ? '${Fmt.number(h.quantity)} '
                          '${h.quantity == Decimal.one ? 'cota' : 'cotas'}'
                    : asset?.assetClass.singular ?? '',
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        Expanded(
          flex: _flex[1],
          child: end(
            closed
                ? const Text('—')
                : value == null
                ? UnavailableText(tooltip: unavailable)
                : Text(
                    Fmt.money(value, c),
                    key: const Key('holding-value'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        Expanded(
          flex: _flex[2],
          child: end(
            Text(h.averagePrice == null ? '—' : Fmt.money(h.averagePrice!, c)),
          ),
        ),
        Expanded(
          flex: _flex[3],
          child: end(
            closed
                ? const Text('—')
                : h.unitPrice == null || note == null
                ? UnavailableText(
                    tooltip: priced == null && value != null
                        ? 'Avaliado por saldo informado: não há preço unitário.'
                        : unavailable,
                  )
                : Tooltip(
                    message: note.message,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (note.stale)
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Fmt.money(h.unitPrice!, c),
                              key: const Key('current-price'),
                            ),
                            Text(
                              note.short,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Expanded(
          flex: _flex[4],
          child: end(
            closed
                ? const Text('—')
                : appreciation == null
                ? UnavailableText(tooltip: unavailable)
                : PnlText(
                    key: const Key('holding-appreciation'),
                    value: appreciation,
                    text: Fmt.percent(appreciation),
                    singleLine: true,
                  ),
          ),
        ),
        SizedBox(
          width: _buttonWidth,
          child: end(
            TextButton(
              key: Key('details-${asset?.symbol ?? h.assetId}'),
              onPressed: onTap,
              child: const Text('Detalhes'),
            ),
          ),
        ),
      ],
    );
    return Material(
      color: selected
          ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        key: Key('holding-${asset?.symbol ?? h.assetId}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Opacity(opacity: closed ? 0.5 : 1, child: row),
        ),
      ),
    );
  }
}
