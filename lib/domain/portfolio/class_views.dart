import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../finance/benchmark.dart';
import '../finance/business_calendar.dart';
import '../finance/cash_flow.dart';
import '../finance/index_accrual.dart';
import '../finance/interest.dart';
import '../finance/returns.dart';
import '../market/market_data.dart';
import 'codes.dart';
import 'entities.dart';
import 'operation_type.dart';

/// Números de um FII (`docs/FORMULAS.md` §13.1; SPEC §12.1).
class FiiMetrics {
  const FiiMetrics({
    required this.assetId,
    this.price,
    this.nav,
    this.navMonth,
    this.income12m,
    this.lastIncome,
    this.monthly = const [],
    this.avgVolume,
    this.volumeDays = 0,
    this.amortizations = const [],
  });

  final String assetId;

  /// Cotação usada (a da Carteira).
  final Decimal? price;

  /// Valor patrimonial por cota do último informe mensal da CVM e o mês.
  final Decimal? nav;
  final LocalDate? navMonth;

  /// Rendimentos por cota com data-com nos últimos 12 meses (B3).
  final Decimal? income12m;

  /// Último rendimento por cota pago ou anunciado.
  final CorporateEvent? lastIncome;

  /// Rendimento por cota de cada um dos últimos 12 meses (pela data-com),
  /// do mais antigo para o mais recente; nulo no mês sem rendimento.
  final List<(LocalDate, Decimal?)> monthly;

  /// Volume financeiro médio por pregão nos últimos 30 pregões guardados.
  final Decimal? avgVolume;
  final int volumeDays;

  /// Amortizações dos últimos 12 meses.
  final List<CorporateEvent> amortizations;

  /// P/VP: cotação ÷ valor patrimonial por cota.
  Decimal? get pvp => price == null || nav == null || nav! <= Decimal.zero
      ? null
      : DecimalMath.divide(price!, nav!);

  /// DY de 12 meses: rendimentos por cota ÷ cotação.
  Decimal? get dy12m =>
      price == null || income12m == null || price! <= Decimal.zero
      ? null
      : DecimalMath.divide(income12m!, price!);

  static FiiMetrics compute({
    required String assetId,
    required LocalDate today,
    Decimal? price,
    FundReport? report,
    List<CorporateEvent> events = const [],
    List<PriceBar> bars = const [],
  }) {
    final since = LocalDate(today.year, today.month, 1).addMonths(-11);
    final incomes = [
      for (final e in events)
        if (e.kind == CorporateEventKind.fiiIncome &&
            e.amount != null &&
            e.comDate != null &&
            e.status != CorporateEventStatus.suspect)
          e,
    ]..sort((a, b) => a.comDate!.compareTo(b.comDate!));
    final inWindow = [
      for (final e in incomes)
        if (!e.comDate!.isBefore(since) && !e.comDate!.isAfter(today)) e,
    ];
    final monthly = <(LocalDate, Decimal?)>[
      for (var i = 0; i < 12; i++) (since.addMonths(i), null),
    ];
    for (final e in inWindow) {
      final i =
          (e.comDate!.year - since.year) * 12 + e.comDate!.month - since.month;
      if (i < 0 || i >= 12) continue;
      monthly[i] = (monthly[i].$1, (monthly[i].$2 ?? Decimal.zero) + e.amount!);
    }
    // Volume financeiro: o COTAHIST traz o volume do dia em reais.
    final withVolume = [
      for (final b in bars)
        if (b.volume != null && b.volume! > Decimal.zero) b,
    ]..sort((a, b) => a.refDate.compareTo(b.refDate));
    final recent = withVolume.length > 30
        ? withVolume.sublist(withVolume.length - 30)
        : withVolume;
    return FiiMetrics(
      assetId: assetId,
      price: price,
      nav: report?.quota,
      navMonth: report?.refDate,
      income12m: incomes.isEmpty
          ? null
          : inWindow.fold(Decimal.zero, (a, e) => a! + e.amount!),
      lastIncome: incomes.isEmpty ? null : incomes.last,
      monthly: monthly,
      avgVolume: recent.isEmpty
          ? null
          : DecimalMath.divide(
              recent.fold(Decimal.zero, (a, b) => a + b.volume!),
              Decimal.fromInt(recent.length),
            ),
      volumeDays: recent.length,
      amortizations: [
        for (final e in events)
          if (e.kind == CorporateEventKind.amortization &&
              !e.exDate.isBefore(since))
            e,
      ],
    );
  }
}

/// Renda fixa: projeção bruta pelo indexador e rentabilidade desde a
/// aplicação (`docs/FORMULAS.md` §13.2).
class FixedIncomeView {
  const FixedIncomeView({
    required this.assetId,
    required this.terms,
    this.projected,
    this.projectedUntil,
    this.missing,
    this.annualReturn,
    this.cdiAnnual,
  });

  final String assetId;
  final FixedIncomeTerms? terms;

  /// Saldo bruto projetado (antes do IR), com os indexadores publicados até
  /// [projectedUntil]; nulo sem condições ou sem índice ([missing] diz o
  /// quê).
  final Decimal? projected;
  final LocalDate? projectedUntil;
  final String? missing;

  /// TIR desde a aplicação, com o valor de referência de hoje (informado,
  /// de mercado ou projetado, nessa ordem).
  final Decimal? annualReturn;

  /// TIR dos mesmos aportes e resgates no CDI, para o "% do CDI".
  final Decimal? cdiAnnual;

  Decimal? get ofCdi =>
      annualReturn == null || cdiAnnual == null || cdiAnnual! <= Decimal.zero
      ? null
      : DecimalMath.divide(annualReturn!, cdiAnnual!);

  /// Grupo da comparação: prefixado, pós-fixado ou inflação.
  static String group(FixedIncomeTerms? t) => switch (t?.indexer) {
    Indexer.pre => 'Prefixados',
    Indexer.cdi || Indexer.selic => 'Pós-fixados',
    Indexer.ipca || Indexer.igpm => 'Inflação (IPCA+)',
    null => 'Sem condições cadastradas',
  };

  /// Fluxos do ativo do ponto de vista do título: aportes positivos,
  /// resgates, amortizações e vencimentos negativos.
  static List<(LocalDate, Decimal)> flows(
    Iterable<Operation> operations,
    String assetId,
  ) => [
    for (final o in operations)
      if (o.assetId == assetId)
        if (switch (o.type) {
              OperationType.buy ||
              OperationType.contribution ||
              OperationType.reinvestment => o.amount + o.charges,
              OperationType.sell ||
              OperationType.redemption ||
              OperationType.amortization ||
              OperationType.maturity => -(o.amount - o.charges),
              _ => null,
            }
            case final v?)
          (o.tradeDate, v),
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  static FixedIncomeView compute({
    required String assetId,
    required FixedIncomeTerms? terms,
    required List<(LocalDate, Decimal)> flows,
    required LocalDate today,
    required Map<IndicatorSeries, List<IndicatorPoint>> daily,
    required Map<IndicatorSeries, IndexLevels> monthly,
    IndexLevels? cdiLevels,
    Decimal? reference,
    BusinessCalendar? calendar,
  }) {
    final cal = calendar ?? BusinessCalendar.brazil;
    Decimal? projected;
    LocalDate? until;
    String? missing;
    if (terms != null && flows.isNotEmpty) {
      final end = terms.maturityDate.isBefore(today)
          ? terms.maturityDate
          : today;
      final rate = DecimalMath.divide(terms.rate, Decimal.fromInt(100));
      final spread = terms.spread == null
          ? null
          : DecimalMath.divide(terms.spread!, Decimal.fromInt(100));
      Decimal? factor(LocalDate from) {
        switch (terms.indexer) {
          case Indexer.pre:
            until = end;
            return Interest.annualRateFactor(rate, terms.dayCount, from, end);
          case Indexer.cdi || Indexer.selic:
            final series = terms.indexer == Indexer.cdi
                ? IndicatorSeries.cdi
                : IndicatorSeries.selic;
            final points = daily[series] ?? const [];
            if (points.isEmpty) {
              missing = series.label;
              return null;
            }
            var f = Decimal.one;
            LocalDate? last;
            for (final p in points) {
              if (p.refDate.isBefore(from) || !p.refDate.isBefore(end)) {
                continue;
              }
              f = DecimalMath.rescale(
                f *
                    (Decimal.one +
                        DecimalMath.rescale(
                          rate *
                              DecimalMath.divide(p.value, Decimal.fromInt(100)),
                        )),
              );
              last = p.refDate;
            }
            final stop = last == null
                ? from
                : cal.nextBusinessDay(last.addDays(1));
            until = until == null || stop.isBefore(until!) ? stop : until;
            if (spread != null) {
              f = DecimalMath.rescale(
                f *
                    IndexAccrual.spreadFactor(
                      spread,
                      cal.businessDaysBetween(from, stop),
                    ),
              );
            }
            return f;
          case Indexer.ipca || Indexer.igpm:
            final series = terms.indexer == Indexer.ipca
                ? IndicatorSeries.ipca
                : IndicatorSeries.igpm;
            final levels = monthly[series];
            if (levels == null || levels.isEmpty) {
              missing = series.label;
              return null;
            }
            final last = levels.last!;
            final stop = last.isBefore(end) ? last : end;
            // `rate` é o percentual do índice (100 = 100% do IPCA).
            final g = DecimalMath.rescale(
              (levels.growth(from, stop) ?? Decimal.zero) * rate,
            );
            until = until == null || stop.isBefore(until!) ? stop : until;
            // A taxa do título (IPCA + taxa) vai até o fim; o índice, até o
            // último mês publicado.
            final real = spread == null
                ? Decimal.one
                : Interest.annualRateFactor(
                    spread,
                    DayCount.bus252,
                    from,
                    end,
                    calendar: cal,
                  );
            return DecimalMath.rescale((Decimal.one + g) * real);
        }
      }

      var total = Decimal.zero;
      for (final (d, v) in flows) {
        if (d.isAfter(end)) continue;
        final f = factor(d);
        if (f == null) {
          total = Decimal.zero;
          projected = null;
          break;
        }
        total += v * f;
        projected = total;
      }
      if (projected case final p?) projected = DecimalMath.roundHalfUp(p);
    } else if (terms == null) {
      missing = 'condições do título';
    }

    final ref = reference ?? projected;
    return FixedIncomeView(
      assetId: assetId,
      terms: terms,
      projected: projected,
      projectedUntil: until,
      missing: projected == null ? missing : null,
      annualReturn: ref == null ? null : _xirr(flows, ref, today),
      cdiAnnual: cdiLevels == null ? null : _cdiXirr(flows, cdiLevels, today),
    );
  }

  static Decimal? _xirr(
    List<(LocalDate, Decimal)> flows,
    Decimal value,
    LocalDate today,
  ) {
    if (flows.isEmpty || !today.isAfter(flows.first.$1)) return null;
    return Xirr.compute([
      for (final (d, v) in flows) CashFlow(d, -v),
      CashFlow(today, value),
    ])?.rate;
  }

  /// Os mesmos fluxos no CDI (hipotético, só para comparar).
  static Decimal? _cdiXirr(
    List<(LocalDate, Decimal)> flows,
    IndexLevels cdi,
    LocalDate today,
  ) {
    if (flows.isEmpty) return null;
    final end = cdi.last;
    if (end == null) return null;
    var value = Decimal.zero;
    for (final (d, v) in flows) {
      final g = cdi.growth(d, end);
      if (g == null) return null;
      value += v * (Decimal.one + g);
    }
    return _xirr(flows, value, end);
  }
}

/// Ativo em outra moeda: retorno na moeda original e em reais, com o efeito
/// cambial separado (`docs/FORMULAS.md` §9 e §13.3).
class ForeignReturn {
  const ForeignReturn({
    required this.costOriginal,
    required this.valueOriginal,
    required this.costFx,
    required this.fxNow,
    required this.split,
  });

  final Decimal costOriginal;
  final Decimal valueOriginal;

  /// Câmbio médio das compras (reais por unidade), ponderado pelo valor.
  final Decimal costFx;
  final Decimal fxNow;
  final FxDecomposition split;

  Decimal get costBrl => DecimalMath.roundHalfUp(costOriginal * costFx);
  Decimal get valueBrl => DecimalMath.roundHalfUp(valueOriginal * fxNow);

  /// [buys]: valor em moeda original e câmbio de cada compra (o da
  /// operação ou a PTAX do dia). Nulo sem câmbio ou sem custo.
  static ForeignReturn? compute({
    required Decimal costOriginal,
    required Decimal valueOriginal,
    required List<(Decimal amount, Decimal fx)> buys,
    required Decimal? fxNow,
  }) {
    if (fxNow == null || buys.isEmpty || costOriginal <= Decimal.zero) {
      return null;
    }
    var amount = Decimal.zero;
    var brl = Decimal.zero;
    for (final (a, fx) in buys) {
      amount += a;
      brl += a * fx;
    }
    if (amount <= Decimal.zero) return null;
    final costFx = DecimalMath.divide(brl, amount);
    final split = FxDecomposition.fromValues(
      startValue: costOriginal,
      endValue: valueOriginal,
      startFx: costFx,
      endFx: fxNow,
    );
    if (split == null) return null;
    return ForeignReturn(
      costOriginal: costOriginal,
      valueOriginal: valueOriginal,
      costFx: costFx,
      fxNow: fxNow,
      split: split,
    );
  }
}

/// Classes de cada visão da Carteira (F8).
enum ClassView {
  all('Todos'),
  fii('FIIs'),
  fixedIncome('Renda fixa'),
  crypto('Cripto'),
  international('Internacional');

  const ClassView(this.label);

  final String label;

  bool includes(Asset a) => switch (this) {
    all => true,
    fii => a.assetClass == AssetClass.fii,
    fixedIncome =>
      a.assetClass == AssetClass.fixedIncome ||
          a.assetClass == AssetClass.treasury ||
          a.assetClass == AssetClass.bankProduct,
    crypto => a.assetClass == AssetClass.crypto,
    international =>
      a.assetClass == AssetClass.stockIntl ||
          a.assetClass == AssetClass.etfIntl ||
          a.assetClass == AssetClass.reit,
  };
}
