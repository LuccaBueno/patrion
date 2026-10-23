import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../../domain/portfolio/portfolio_valuation.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../router/app_router.dart';
import '../../widgets/common.dart';
import 'add_asset_dialog.dart';

/// Carteira real: um item por ativo, onde há mais dinheiro primeiro (M-05;
/// SPEC §16). O clique na linha abre a página do ativo em tela cheia
/// (M-07); a Carteira fica montada por baixo, com a busca e a rolagem.
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(portfolioSnapshotProvider);
    final fx = ref.watch(marketOverviewProvider).value?.fx ?? const {};
    final broker = ref.watch(brokerFilterProvider).value;
    final group = ref.watch(groupByBrokerProvider).value ?? false;
    return PageScaffold(
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
          toBrl: {
            for (final MapEntry(:key, :value) in fx.entries)
              if (value.mid != null) key: value.mid!,
          },
          broker: broker,
          group: group,
          onBroker: (id) =>
              ref.read(portfolioViewPreferencesProvider).setBroker(id),
          onGroup: (v) =>
              ref.read(portfolioViewPreferencesProvider).setGroup(v),
          onSelect: (id) => context.go(Routes.asset(id)),
        ),
      ),
    );
  }
}

/// Um grupo da lista: todas as corretoras juntas ou uma corretora.
class HoldingGroup {
  const HoldingGroup(this.holdings, {this.institution});

  final List<Holding> holdings;

  /// Nulo quando não há agrupamento.
  final Institution? institution;
}

/// Lista da Carteira, com busca, filtro e agrupamento por corretora (M-06).
/// O mesmo ticker em várias corretoras vira uma linha só (a quebra está na
/// página do ativo). Cabe em 1280 px sem rolagem lateral: as colunas
/// dividem a largura disponível.
class HoldingsList extends StatefulWidget {
  const HoldingsList({
    required this.snap,
    required this.onSelect,
    this.toBrl = const {},
    this.broker,
    this.group = false,
    this.onBroker,
    this.onGroup,
    super.key,
  });

  final PortfolioSnapshot snap;
  final Map<String, Decimal> toBrl;

  /// Instituição do filtro (nulo = todas).
  final String? broker;
  final bool group;
  final ValueChanged<String?>? onBroker;
  final ValueChanged<bool>? onGroup;
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
    Institution? institutionOf(ValuedPosition v) =>
        snap.institutionOfAccount(v.position.accountId);
    // Corretoras com posição (aberta ou encerrada), em ordem alfabética.
    final byId = <String, Institution>{};
    for (final v in snap.valued) {
      final i = institutionOf(v);
      if (i != null) byId[i.id] = i;
    }
    final brokers = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final broker = brokers.any((b) => b.id == widget.broker)
        ? widget.broker
        : null;
    final s = _search.toLowerCase();
    bool matches(Holding h) =>
        s.isEmpty ||
        (h.asset?.symbol ?? '').toLowerCase().contains(s) ||
        (h.asset?.name ?? '').toLowerCase().contains(s);
    List<Holding> build(Iterable<ValuedPosition> valued) => [
      for (final h in Holdings.build(valued, toBrl: widget.toBrl))
        if (matches(h)) h,
    ];
    final shown = [
      for (final v in snap.valued)
        if (broker == null || institutionOf(v)?.id == broker) v,
    ];
    final groups = widget.group
        ? [
            for (final b in brokers)
              if (broker == null || b.id == broker)
                HoldingGroup(
                  build(shown.where((v) => institutionOf(v)?.id == b.id)),
                  institution: b,
                ),
          ]
        : [HoldingGroup(build(shown))];
    // Grupos com mais dinheiro primeiro.
    if (widget.group) {
      groups.sort((a, b) => _total(b).compareTo(_total(a)));
    }

    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar ativo',
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
            ),
            if (brokers.length > 1) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                key: const Key('broker-all'),
                label: const Text('Todas'),
                selected: broker == null,
                onSelected: (_) => widget.onBroker?.call(null),
              ),
              for (final b in brokers)
                ChoiceChip(
                  key: Key('broker-${b.name}'),
                  label: Text(b.name),
                  selected: broker == b.id,
                  onSelected: (_) => widget.onBroker?.call(b.id),
                ),
            ],
            if (brokers.isNotEmpty) ...[
              const SizedBox(width: 8),
              FilterChip(
                key: const Key('group-by-broker'),
                label: const Text('Agrupar por corretora'),
                selected: widget.group,
                onSelected: (v) => widget.onGroup?.call(v),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        for (final (gi, g) in groups.indexed) ...[
          if (gi > 0) const SizedBox(height: 16),
          if (g.institution != null)
            _GroupHeader(
              institution: g.institution!,
              holdings: g.holdings,
              toBrl: widget.toBrl,
            ),
          Card(
            key: g.institution == null
                ? null
                : Key('group-${g.institution!.name}'),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _HeaderRow(),
                const Divider(height: 1),
                if (g.holdings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Nenhum ativo encontrado.', style: muted),
                  ),
                for (final (i, h) in g.holdings.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  _HoldingRow(
                    holding: h,
                    today: snap.asOf,
                    onTap: () => widget.onSelect(h.assetId),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Valor da posição = quantidade × cotação atual. Valorização = '
          '(cotação − preço médio) ÷ preço médio, sem proventos. Sem cotação, '
          'o ativo é ordenado pelo total aplicado. Abaixo da cotação, a fonte '
          'e a data; o tipo, a coleta e o atraso aparecem ao passar o mouse. '
          'Ativos sem cotas ficam no fim. O mesmo ativo em várias corretoras '
          'aparece numa linha só; a divisão está na página do ativo.',
          style: muted,
        ),
      ],
    );
  }

  /// Valor do grupo em reais, para ordenar.
  Decimal _total(HoldingGroup g) => g.holdings.fold(
    Decimal.zero,
    (s, h) =>
        s +
        (h.marketValue ?? h.totalCost) *
            (widget.toBrl[h.currency] ?? Decimal.one),
  );
}

/// Cabeçalho de uma corretora: nome e subtotal (M-06).
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.institution,
    required this.holdings,
    required this.toBrl,
  });

  final Institution institution;
  final List<Holding> holdings;
  final Map<String, Decimal> toBrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var total = Decimal.zero;
    var partial = false;
    for (final h in holdings) {
      if (!h.isOpen) continue;
      final v = h.marketValue;
      final rate = h.currency == 'BRL' ? Decimal.one : toBrl[h.currency];
      if (v == null || rate == null) {
        partial = true;
        continue;
      }
      total += v * rate;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              institution.name,
              key: Key('group-title-${institution.name}'),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Tooltip(
            message: partial
                ? 'Parcial: há ativos sem cotação ou sem câmbio, fora do '
                      'subtotal.'
                : 'Soma do valor das posições nesta corretora, em reais.',
            child: Text(
              '${Fmt.money(total, 'BRL')}${partial ? ' (parcial)' : ''}',
              key: Key('group-total-${institution.name}'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
    required this.onTap,
  });

  final Holding holding;
  final LocalDate today;
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
      color: Colors.transparent,
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
