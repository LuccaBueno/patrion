import '../../core/time/local_date.dart';
import '../format/formatters.dart';

/// Eixo de datas dos gráficos de linha: `x` em dias desde uma âncora (1º de
/// janeiro ou dia 1 do mês), para os rótulos caírem no início de cada ano
/// ou mês. O fl_chart põe os rótulos nos múltiplos de [interval] a partir
/// do zero do eixo.
class DateAxis {
  factory DateAxis(LocalDate first, LocalDate last) {
    final days = last.daysSince(first);
    if (days > 900) {
      final years = days / 365.25;
      final step = years <= 11 ? 1 : (years / 10).ceil();
      return DateAxis._(LocalDate(first.year, 1, 1), 365.25 * step, _Unit.year);
    }
    if (days > 62) {
      final step = days > 200 ? 2 : 1;
      return DateAxis._(
        LocalDate(first.year, first.month, 1),
        30.4375 * step,
        _Unit.month,
      );
    }
    return DateAxis._(first, days > 14 ? 7 : 2, _Unit.day);
  }

  DateAxis._(this.anchor, this.interval, this._unit);

  final LocalDate anchor;
  final double interval;
  final _Unit _unit;

  /// Posição da data no eixo (conversão só para desenho, regra 6).
  double x(LocalDate d) => d.daysSince(anchor).toDouble();

  LocalDate dateAt(double x) => anchor.addDays(x.round());

  /// "2019", "out/25" ou "17/10".
  String label(double v) {
    switch (_unit) {
      case _Unit.year:
        return '${anchor.year + (v / 365.25).round()}';
      case _Unit.month:
        final total = anchor.month - 1 + (v / 30.4375).round();
        return Fmt.monthShort(
          LocalDate(anchor.year + total ~/ 12, total % 12 + 1, 1),
        );
      case _Unit.day:
        final d = dateAt(v);
        return '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}';
    }
  }
}

enum _Unit { year, month, day }
