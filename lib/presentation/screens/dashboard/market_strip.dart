import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/market/market_overview.dart';
import '../../../core/money/decimal_math.dart';
import '../../../domain/market/market_data.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../format/formatters.dart';
import '../../format/market_labels.dart';
import '../../providers.dart';
import '../../router/app_router.dart';

/// Faixa compacta de câmbio e indicadores no rodapé do Painel (item 8 do
/// M-04; F8). Cada item mostra a data e a fonte no tooltip; o clique leva
/// a Fontes de dados, onde está o cartão completo.
class MarketStrip extends ConsumerWidget {
  const MarketStrip({super.key});

  /// Indicadores da faixa, nesta ordem.
  static const series = [
    IndicatorSeries.selicTarget,
    IndicatorSeries.ibovespa,
    IndicatorSeries.ifix,
    IndicatorSeries.btcUsd,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = ref.watch(marketOverviewProvider).value;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final small = theme.textTheme.bodySmall;
    final items = o == null ? const <_Item>[] : _items(o);
    return Card(
      key: const Key('market-strip'),
      child: InkWell(
        onTap: () => context.go(Routes.dataSources),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Wrap(
            spacing: 20,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Câmbio e indicadores',
                style: small?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (items.isEmpty)
                Text(
                  'indisponível — use "Atualizar agora" com internet',
                  style: small?.copyWith(
                    color: muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              for (final i in items)
                Tooltip(
                  message: i.detail,
                  child: Text.rich(
                    key: Key('strip-${i.label}'),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${i.label} ',
                          style: small?.copyWith(color: muted),
                        ),
                        TextSpan(text: i.value, style: small),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_Item> _items(MarketOverview o) {
    return [
      for (final MapEntry(key: c, value: r) in o.fx.entries)
        if (r.mid != null)
          _Item(
            c,
            MarketLabels.fx(r.mid!),
            '${MarketLabels.fxKind(r.kind)} de ${Fmt.date(r.refDate)} · '
            '${ProviderCatalog.nameOf(r.source)}',
          ),
      if ((o.cdiAnnual, o.indicators[IndicatorSeries.cdi]) case (
        final annual?,
        final cdi?,
      ))
        _Item(
          'CDI',
          '${Fmt.percent(annual, signed: false)} a.a.',
          'Anualizado do último CDI diário (base 252), de '
              '${Fmt.date(cdi.refDate)} · ${ProviderCatalog.nameOf(cdi.source)}',
        ),
      if (o.ipca12m case final ipca?)
        _Item(
          'IPCA 12m',
          Fmt.percent(ipca.value),
          'De ${Fmt.monthYear(ipca.from)} a ${Fmt.monthYear(ipca.to)}',
        ),
      for (final s in series)
        if (o.indicators[s] case final p?)
          _Item(
            s == IndicatorSeries.selicTarget ? 'Selic' : s.label,
            s == IndicatorSeries.selicTarget
                ? '${Fmt.number(DecimalMath.roundHalfUp(p.value))}% a.a.'
                : MarketLabels.indicator(p),
            '${s.label}: ${Fmt.date(p.refDate)} · '
            '${ProviderCatalog.nameOf(p.source)}',
          ),
    ];
  }
}

class _Item {
  const _Item(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;
}
