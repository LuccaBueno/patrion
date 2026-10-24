import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';
import '../../core/time/local_date.dart';
import '../finance/benchmark.dart';
import '../finance/cash_flow.dart';
import '../finance/returns.dart';
import 'wealth_history.dart';

/// Períodos da tela Desempenho (SPEC §8; F8).
enum PerformancePeriod {
  m1('1M', 'em 1 mês'),
  m3('3M', 'em 3 meses'),
  m6('6M', 'em 6 meses'),
  ytd('YTD', 'no ano'),
  y1('1A', 'em 1 ano'),
  y3('3A', 'em 3 anos'),
  y5('5A', 'em 5 anos'),
  y10('10A', 'em 10 anos'),
  all('Tudo', 'desde o início'),
  custom('Personalizado', 'no período');

  const PerformancePeriod(this.label, this.phrase);

  final String label;
  final String phrase;

  /// Fim do dia-base do período terminado em [today] (o retorno conta a
  /// partir do fim desse dia). Nulo em [all] e [custom].
  LocalDate? baseDate(LocalDate today) => switch (this) {
    m1 => today.addMonths(-1),
    m3 => today.addMonths(-3),
    m6 => today.addMonths(-6),
    ytd => LocalDate(today.year - 1, 12, 31),
    y1 => today.addMonths(-12),
    y3 => today.addMonths(-36),
    y5 => today.addMonths(-60),
    y10 => today.addMonths(-120),
    all || custom => null,
  };

  /// Os dados sustentam o período: a carteira já existia no dia-base (SPEC
  /// §8, "aparecem só os períodos que os dados sustentam").
  static List<PerformancePeriod> available(
    WealthSeries series,
    LocalDate today,
  ) {
    if (series.points.length < 2) return const [];
    final first = series.points.first.date;
    return [
      for (final p in values)
        if (p == all || p == custom)
          p
        else if (!first.isAfter(p.baseDate(today)!))
          p,
    ];
  }
}

/// Um ano da tabela de rentabilidade (`docs/FORMULAS.md` §3.4).
class ReturnTableRow {
  const ReturnTableRow({
    required this.year,
    required this.months,
    required this.total,
    required this.accumulated,
    required this.cdi,
    required this.partial,
  });

  final int year;

  /// TWR de cada mês (índice 0 = janeiro); nulo sem carteira no mês.
  final List<Decimal?> months;

  /// TWR do ano (parcial no primeiro e no ano corrente).
  final Decimal total;

  /// TWR desde o início até o fim do ano.
  final Decimal accumulated;

  /// CDI no mesmo intervalo do [total]; nulo sem dados.
  final Decimal? cdi;

  /// O ano não está completo (a carteira começou depois de 1/1 ou o ano
  /// ainda não acabou).
  final bool partial;

  /// Rentabilidade em % do CDI (fração: 1,1 = 110% do CDI). Nula sem CDI
  /// positivo.
  Decimal? get ofCdi => cdi == null || cdi! <= Decimal.zero
      ? null
      : DecimalMath.divide(total, cdi!);
}

/// Tabela mês × ano a partir do índice do TWR da carteira.
abstract final class ReturnTable {
  static List<ReturnTableRow> build(WealthSeries series, {IndexLevels? cdi}) {
    final index = series.twrIndex();
    if (index.length < 2) return const [];
    final months = PeriodReturns.compute(index, ReturnPeriodUnit.month);
    final years = PeriodReturns.compute(index, ReturnPeriodUnit.year);
    final first = index.first;
    final rows = <ReturnTableRow>[];
    for (final y in years) {
      final cells = List<Decimal?>.filled(12, null);
      for (final m in months) {
        if (m.start.year == y.start.year) cells[m.start.month - 1] = m.value;
      }
      // Base do ano: o último ponto do ano anterior (ou o primeiro ponto).
      final base = _lastOnOrBefore(index, LocalDate(y.start.year - 1, 12, 31));
      final baseDate = base?.$1 ?? first.$1;
      final endLevel = _lastOnOrBefore(index, y.end)!.$2;
      rows.add(
        ReturnTableRow(
          year: y.start.year,
          months: cells,
          total: y.value,
          accumulated: DecimalMath.divide(endLevel, first.$2) - Decimal.one,
          cdi: cdi?.growth(baseDate, y.end),
          // Parcial: o primeiro ano (sem base no ano anterior) e o último,
          // se ainda não acabou (o último pregão do ano pode ser 29 ou 30/12).
          partial:
              base == null ||
              (identical(y, years.last) &&
                  y.end.isBefore(LocalDate(y.start.year, 12, 31))),
        ),
      );
    }
    return rows;
  }

  static (LocalDate, Decimal)? _lastOnOrBefore(
    List<(LocalDate, Decimal)> index,
    LocalDate d,
  ) {
    (LocalDate, Decimal)? found;
    for (final e in index) {
      if (e.$1.isAfter(d)) break;
      found = e;
    }
    return found;
  }
}

/// Rentabilidade da carteira num período (`docs/FORMULAS.md` §3.4).
class PeriodPerformance {
  const PeriodPerformance({
    required this.from,
    required this.to,
    required this.twr,
    this.cdi,
    this.cdiUntil,
    this.ipca,
    this.ipcaUntil,
    this.mwr,
  });

  /// Prazo mínimo da TIR do período: em poucos dias, a taxa que equilibra os
  /// fluxos não tem significado (M-12).
  static const minMwrDays = 30;

  /// Dia-base (o retorno conta a partir do fim dele) e último dia.
  final LocalDate from;
  final LocalDate to;

  /// TWR do período (fração).
  final Decimal twr;

  /// CDI e IPCA do mesmo intervalo, até o último dia publicado; nulos sem
  /// dados ou sem nenhum dia publicado depois do dia-base (o índice do
  /// período ainda não existe; não é 0%).
  final Decimal? cdi;
  final Decimal? ipca;

  /// Último dia coberto pelo CDI publicado (antes de [to] quando os últimos
  /// dias ainda não saíram).
  final LocalDate? cdiUntil;

  /// Último dia coberto pelo IPCA publicado (antes de [to] quando o mês
  /// ainda não saiu).
  final LocalDate? ipcaUntil;

  /// TIR (MWR) do período, ao ano; nula em menos de [minMwrDays] dias.
  final XirrResult? mwr;

  int get days => to.daysSince(from);

  /// Retorno real: descontado o IPCA do período.
  Decimal? get real => ipca == null ? null : Returns.real(twr, ipca!);

  /// Taxa anual equivalente (CAGR do TWR), só em períodos de mais de um
  /// ano.
  Decimal? get cagr => days > 366 ? Returns.annualize(twr, days) : null;

  /// TWR em % do CDI (fração). Nulo sem CDI positivo.
  Decimal? get ofCdi => cdi == null || cdi! <= Decimal.zero
      ? null
      : DecimalMath.divide(twr, cdi!);

  /// Calcula o período de [from] (fim do dia; antes do primeiro ponto =
  /// desde o início) até [to]. Nulo sem dois pontos no intervalo.
  static PeriodPerformance? compute(
    WealthSeries series, {
    required LocalDate from,
    required LocalDate to,
    IndexLevels? cdi,
    IndexLevels? ipca,
  }) {
    final points = series.points;
    if (points.length < 2) return null;
    final start = points.first.date.isAfter(from) ? points.first.date : from;
    final twr = series.twrBetween(start, to);
    if (twr == null) return null;
    // Datas efetivas: o último ponto até o início e até o fim.
    var base = points.first;
    var end = points.first;
    for (final p in points) {
      if (p.date.isAfter(to)) break;
      if (!p.date.isAfter(start)) base = p;
      end = p;
    }
    LocalDate? until(IndexLevels? levels) {
      final last = levels?.last;
      if (last == null || !last.isAfter(base.date)) return null;
      return last.isBefore(end.date) ? last : end.date;
    }

    final cdiEnd = until(cdi);
    final ipcaEnd = until(ipca);
    return PeriodPerformance(
      from: base.date,
      to: end.date,
      twr: twr,
      cdi: cdiEnd == null ? null : cdi!.growth(base.date, cdiEnd),
      cdiUntil: cdiEnd,
      ipca: ipcaEnd == null ? null : ipca!.growth(base.date, ipcaEnd),
      ipcaUntil: ipcaEnd,
      mwr: end.date.daysSince(base.date) < minMwrDays
          ? null
          : _mwr(points, base, end),
    );
  }

  /// TIR: o patrimônio do dia-base como aporte inicial, os aportes e
  /// resgates de cada dia e os proventos como fluxos, e o patrimônio final
  /// como resgate.
  static XirrResult? _mwr(
    List<WealthPoint> points,
    WealthPoint base,
    WealthPoint end,
  ) {
    final flows = <CashFlow>[];
    for (final p in points) {
      if (p.date.isBefore(base.date)) continue;
      if (p.date.isAfter(end.date)) break;
      if (identical(p, base)) {
        // O patrimônio no fim do dia-base (no primeiro dia, o aporte dele).
        if (p.value != Decimal.zero) flows.add(CashFlow(p.date, -p.value));
        continue;
      }
      final amount = p.income - p.flow;
      if (amount != Decimal.zero) flows.add(CashFlow(p.date, amount));
    }
    flows.add(CashFlow(end.date, end.value));
    return Xirr.compute(flows);
  }
}
