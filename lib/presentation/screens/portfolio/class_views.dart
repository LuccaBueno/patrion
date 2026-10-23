import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/class_views_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/money/decimal_math.dart';
import '../../../domain/portfolio/class_views.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/holdings.dart';
import '../../../domain/portfolio/passive_income.dart';
import '../../format/formatters.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../dashboard/dashboard_charts.dart';
import '../income/income_screen.dart';
import '../performance/returns_tab.dart';

/// Visões por classe da Carteira (F8, parte 5; SPEC §12.1 a §12.4): FIIs,
/// renda fixa, cripto e internacional, cada uma só quando há a classe.
class ClassViewBody extends ConsumerWidget {
  const ClassViewBody({
    required this.view,
    required this.snap,
    required this.toBrl,
    required this.onSelect,
    super.key,
  });

  final ClassView view;
  final PortfolioSnapshot snap;
  final Map<String, Decimal> toBrl;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(classViewsProvider);
    final holdings = [
      for (final h in Holdings.build(snap.valued, toBrl: toBrl))
        if (h.isOpen && h.asset != null && view.includes(h.asset!)) h,
    ];
    return AsyncBody(
      value: data,
      builder: (d) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: switch (view) {
          ClassView.fii => _fii(context, ref, holdings, d),
          ClassView.fixedIncome => _fixed(context, holdings, d),
          ClassView.crypto ||
          ClassView.international => _foreign(context, holdings, d),
          ClassView.all => const [],
        },
      ),
    );
  }

  // -- FIIs ------------------------------------------------------------------

  List<Widget> _fii(
    BuildContext context,
    WidgetRef ref,
    List<Holding> holdings,
    ClassViewsData d,
  ) {
    final income = ref.watch(passiveIncomeProvider).value;
    final received = income?.totals.byAsset12m ?? const {};
    final announced = <String, Decimal>{};
    for (final a in income?.match.announced ?? const <AnnouncedIncome>[]) {
      announced[a.assetId] = (announced[a.assetId] ?? Decimal.zero) + a.gross;
    }
    String pvp(FiiMetrics? m) => m?.pvp == null ? '—' : Fmt.fixed2(m!.pvp!);
    return [
      DashCard(
        key: const Key('fii-table'),
        title: 'FIIs',
        subtitle:
            'P/VP pelo valor patrimonial por cota do último informe mensal da '
            'CVM; DY pelos rendimentos com data-com nos últimos 12 meses (B3) '
            '÷ cotação; liquidez pelo volume financeiro médio dos últimos 30 '
            'pregões (COTAHIST).',
        child: _table(
          context,
          [
            'Ativo',
            'Cotação',
            'VP/cota',
            'P/VP',
            'DY 12 meses',
            'Liquidez diária',
            'Segmento',
          ],
          [for (final h in holdings) _row(h, d.fii[h.assetId], pvp)],
          rightFrom: 1,
          keyPrefix: 'fii',
        ),
      ),
      const SizedBox(height: 16),
      DashCard(
        key: const Key('fii-income'),
        title: 'Rendimentos: recebido, anunciado e estimado',
        subtitle:
            'Recebido: proventos registrados nos últimos 12 meses. Anunciado: '
            'publicados pela B3 a pagar. Estimado: o último rendimento por '
            'cota × a quantidade de hoje, hipotético (não é previsão).',
        child: _table(
          context,
          [
            'Ativo',
            'Último por cota',
            'Data-com',
            'Recebido (12 meses)',
            'Anunciado',
            'Estimado por mês',
          ],
          [
            for (final h in holdings)
              [
                h.asset!.symbol,
                ...switch (d.fii[h.assetId]?.lastIncome) {
                  final e? => [perShare(e.amount!), Fmt.date(e.comDate!)],
                  null => ['—', '—'],
                },
                Fmt.money(received[h.assetId] ?? Decimal.zero, 'BRL'),
                Fmt.money(announced[h.assetId] ?? Decimal.zero, 'BRL'),
                switch (d.fii[h.assetId]?.lastIncome?.amount) {
                  final v? => Fmt.money(
                    DecimalMath.roundHalfUp(v * h.quantity),
                    'BRL',
                  ),
                  null => '—',
                },
              ],
          ],
          rightFrom: 1,
          keyPrefix: 'fii-income',
        ),
      ),
      const SizedBox(height: 16),
      DashCard(
        key: const Key('fii-monthly'),
        title: 'Rendimento por cota, mês a mês',
        subtitle:
            'Pela data-com, nos últimos 12 meses (B3); vazio = sem '
            'rendimento publicado no mês',
        child: _monthly(context, holdings, d),
      ),
      const SizedBox(height: 12),
      ...notesOf(context, [
        for (final h in holdings)
          if (d.fii[h.assetId]?.amortizations case final a? when a.isNotEmpty)
            '${h.asset!.symbol}: ${a.length} '
                '${a.length == 1 ? 'amortização' : 'amortizações'} nos últimos '
                '12 meses (${a.map((e) => '${Fmt.date(e.exDate)}: ${e.amount == null ? 'valor não informado' : perShare(e.amount!)}').join('; ')}).',
        'Vacância e emissões: indisponíveis. A CVM só publica esses dados no '
            'informe trimestral, sem um formato estruturado por imóvel (decisão '
            'aprovada em 23/10/2026).',
        'P/VP indisponível quando o FII não tem informe mensal guardado (a '
            'atualização baixa o da CVM uma vez por mês) ou sem ISIN.',
      ]),
    ];
  }

  static List<String> _row(
    Holding h,
    FiiMetrics? m,
    String Function(FiiMetrics?) pvp,
  ) => [
    h.asset!.symbol,
    h.unitPrice == null ? '—' : Fmt.money(h.unitPrice!, 'BRL'),
    m?.nav == null
        ? '—'
        : '${Fmt.money(m!.nav!, 'BRL')} (${Fmt.monthYear(m.navMonth!)})',
    pvp(m),
    m?.dy12m == null ? '—' : Fmt.percent(m!.dy12m!, signed: false),
    m?.avgVolume == null
        ? '—'
        : Fmt.money(DecimalMath.roundHalfUp(m!.avgVolume!, scale: 0), 'BRL'),
    h.asset!.segment ?? h.asset!.sector ?? '—',
  ];

  Widget _monthly(
    BuildContext context,
    List<Holding> holdings,
    ClassViewsData d,
  ) {
    final first = d.fii.values.firstOrNull?.monthly ?? const [];
    if (first.isEmpty) {
      return const UnavailableText(tooltip: 'Sem rendimentos da B3 guardados.');
    }
    return _table(
      context,
      ['Ativo', for (final (m, _) in first) Fmt.monthShort(m)],
      [
        for (final h in holdings)
          [
            h.asset!.symbol,
            for (final (_, v) in d.fii[h.assetId]?.monthly ?? first)
              v == null
                  ? ''
                  : v.scale <= 2
                  ? Fmt.fixed2(v)
                  : Fmt.number(v, maxDecimals: 4),
          ],
      ],
      rightFrom: 1,
    );
  }

  // -- Renda fixa --------------------------------------------------------------

  List<Widget> _fixed(
    BuildContext context,
    List<Holding> holdings,
    ClassViewsData d,
  ) {
    final groups = <String, List<Holding>>{};
    for (final h in holdings) {
      final g = FixedIncomeView.group(snap.fixedIncome[h.assetId]);
      (groups[g] ??= []).add(h);
    }
    final order = [
      'Prefixados',
      'Pós-fixados',
      'Inflação (IPCA+)',
      'Sem condições cadastradas',
    ];
    return [
      for (final g in order)
        if (groups[g] case final list?) ...[
          DashCard(
            key: Key('fixed-$g'),
            title: g,
            subtitle:
                'Saldo informado pela instituição, projeção bruta calculada '
                'pelo indexador (antes do IR) e valor de mercado (Tesouro), '
                'lado a lado. Rentabilidade: TIR desde a aplicação, pelo valor '
                'da Carteira (ou pela projeção, sem ele).',
            child: _table(
              context,
              [
                'Título',
                'Condições',
                'Vencimento',
                'Aplicado',
                'Saldo informado',
                'Projeção',
                'Mercado',
                'Rent. a.a.',
                '% do CDI',
              ],
              [for (final h in list) _fixedRow(h, d.fixedIncome[h.assetId])],
              rightFrom: 3,
              keyPrefix: 'fixed',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ...notesOf(context, [
        'A projeção usa o CDI, a Selic, o IPCA e o IGP-M publicados (até a data '
            'mostrada); sem o índice ou sem as condições do título, fica '
            'indisponível. Não desconta IR, IOF nem custos: o saldo da '
            'instituição continua sendo a referência.',
        '% do CDI = TIR do título ÷ TIR dos mesmos aportes e resgates no CDI '
            '(comparação hipotética).',
      ]),
    ];
  }

  List<String> _fixedRow(Holding h, FixedIncomeView? v) {
    final t = snap.fixedIncome[h.assetId];
    final balance = [
      for (final m in snap.valuations)
        if (m.assetId == h.assetId && m.kind == ValuationKind.balance) m,
    ]..sort((a, b) => b.refDate.compareTo(a.refDate));
    final market = h.marketPrice != null ? h.marketValue : null;
    return [
      h.asset!.symbol,
      t == null ? '—' : _conditions(t),
      t == null ? '—' : Fmt.date(t.maturityDate),
      Fmt.money(h.totalCost, h.currency),
      balance.isEmpty
          ? '—'
          : '${Fmt.money(balance.first.value, h.currency)} '
                '(${Fmt.date(balance.first.refDate)})',
      v?.projected == null
          ? 'indisponível${v?.missing == null ? '' : ' (sem ${v!.missing})'}'
          : '${Fmt.money(v!.projected!, h.currency)}'
                '${v.projectedUntil == null ? '' : ' (até ${Fmt.date(v.projectedUntil!)})'}',
      market == null ? '—' : Fmt.money(market, h.currency),
      v?.annualReturn == null ? '—' : Fmt.percent(v!.annualReturn!),
      v?.ofCdi == null ? '—' : percentOfCdi(v!.ofCdi!),
    ];
  }

  static String _conditions(FixedIncomeTerms t) => switch (t.indexer) {
    Indexer.pre => '${Fmt.number(t.rate)}% a.a.',
    Indexer.cdi || Indexer.selic =>
      '${Fmt.number(t.rate)}% do ${t.indexer == Indexer.cdi ? 'CDI' : 'Selic'}'
          '${t.spread == null ? '' : ' + ${Fmt.number(t.spread!)}%'}',
    Indexer.ipca || Indexer.igpm =>
      '${t.indexer == Indexer.ipca ? 'IPCA' : 'IGP-M'}'
          '${t.spread == null ? '' : ' + ${Fmt.number(t.spread!)}% a.a.'}',
  };

  // -- Cripto e internacional -----------------------------------------------

  List<Widget> _foreign(
    BuildContext context,
    List<Holding> holdings,
    ClassViewsData d,
  ) {
    final crypto = view == ClassView.crypto;
    return [
      DashCard(
        key: Key(crypto ? 'crypto-table' : 'intl-table'),
        title: crypto ? 'Cripto' : 'Internacional',
        subtitle: crypto
            ? 'Custo, preço médio, cotação e retorno em reais; cotação em '
                  'dólar convertida pela PTAX do último dia guardado.'
            : 'Retorno na moeda original e em reais, com o efeito do câmbio '
                  'separado: (1 + em R\$) = (1 + na moeda) × (1 + câmbio). O '
                  'câmbio de custo é a média das compras (o da operação ou a '
                  'PTAX do dia).',
        child: _table(
          context,
          [
            'Ativo',
            'Quantidade',
            'Custo',
            'Preço médio',
            'Cotação',
            'Valor em R\$',
            if (!crypto) 'Na moeda',
            if (!crypto) 'Câmbio',
            'Em R\$',
          ],
          [
            for (final h in holdings)
              _foreignRow(h, d.foreign[h.assetId], d, withSplit: !crypto),
          ],
          rightFrom: 1,
          keyPrefix: crypto ? 'crypto' : 'intl',
        ),
      ),
    ];
  }

  List<String> _foreignRow(
    Holding h,
    ForeignReturn? f,
    ClassViewsData d, {
    required bool withSplit,
  }) {
    final brl = h.currency == 'BRL';
    final value = h.marketValue;
    final fx = d.fxNow[h.currency];
    final valueBrl = value == null
        ? null
        : brl
        ? value
        : fx == null
        ? null
        : DecimalMath.roundHalfUp(value * fx);
    final inBrl = brl
        ? (value == null || h.totalCost <= Decimal.zero
              ? null
              : DecimalMath.divide(value, h.totalCost) - Decimal.one)
        : f?.split.totalReturn;
    return [
      h.asset!.symbol,
      Fmt.number(h.quantity),
      Fmt.money(h.totalCost, h.currency),
      h.averagePrice == null ? '—' : Fmt.money(h.averagePrice!, h.currency),
      h.unitPrice == null ? '—' : Fmt.money(h.unitPrice!, h.currency),
      valueBrl == null ? 'indisponível' : Fmt.money(valueBrl, 'BRL'),
      if (withSplit) f == null ? '—' : Fmt.percent(f.split.assetReturn),
      if (withSplit) f == null ? '—' : Fmt.percent(f.split.fxReturn),
      inBrl == null ? '—' : Fmt.percent(inBrl),
    ];
  }

  // -- Tabela ------------------------------------------------------------------

  /// Tabela de texto; valores com sinal ganham a cor de ganho ou perda (o
  /// sinal continua no texto). Com [keyPrefix], cada célula tem a chave
  /// `prefixo-código-coluna`.
  static Widget _table(
    BuildContext context,
    List<String> head,
    List<List<String>> rows, {
    required int rightFrom,
    String? keyPrefix,
  }) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final muted = theme.colorScheme.onSurfaceVariant;
    final colors = SemanticColors.of(context);
    TextStyle? styleOf(String t) => t.startsWith('+') && t.endsWith('%')
        ? small?.copyWith(color: colors.gain)
        : t.startsWith('-') && t.endsWith('%')
        ? small?.copyWith(color: colors.loss)
        : small;
    Widget cell(String t, int i, {TextStyle? style, Key? key}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        t,
        key: key,
        style: style ?? styleOf(t),
        textAlign: i >= rightFrom ? TextAlign.right : null,
      ),
    );
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.1)},
      border: TableBorder(
        horizontalInside: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      children: [
        TableRow(
          children: [
            for (final (i, h) in head.indexed)
              cell(
                h,
                i,
                style: small?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        for (final r in rows)
          TableRow(
            children: [
              for (final (i, c) in r.indexed)
                cell(
                  c,
                  i,
                  key: keyPrefix == null ? null : Key('$keyPrefix-${r[0]}-$i'),
                ),
            ],
          ),
      ],
    );
  }
}

/// Seletor das visões (só aparece quando a carteira tem alguma classe com
/// visão própria).
class ClassViewBar extends StatelessWidget {
  const ClassViewBar({
    required this.views,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<ClassView> views;
  final ClassView selected;
  final ValueChanged<ClassView> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<ClassView>(
    key: const Key('class-views'),
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: [
      for (final v in views)
        ButtonSegment(
          value: v,
          label: Text(v.label, key: Key('view-${v.name}')),
        ),
    ],
    selected: {selected},
    onSelectionChanged: (s) => onChanged(s.single),
  );
}

/// Visões disponíveis para o retrato.
List<ClassView> classViewsOf(PortfolioSnapshot snap) =>
    ClassViewsService.available(snap);
