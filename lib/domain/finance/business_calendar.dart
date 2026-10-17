import '../../core/time/local_date.dart';

/// Calendário de dias úteis do mercado financeiro brasileiro: segunda a
/// sexta, menos os feriados nacionais (`docs/FORMULAS.md` §5).
///
/// Feriados considerados (os do calendário da ANBIMA, usado para CDI, Selic
/// e títulos na base 252):
///
/// - fixos: 1/1, 21/4 (Tiradentes), 1/5, 7/9, 12/10, 2/11, 15/11, 20/11
///   (Consciência Negra, nacional a partir de 2024, Lei 14.759/2023) e 25/12;
/// - móveis, a partir da Páscoa: segunda e terça de Carnaval (−48 e −47
///   dias), Sexta-feira Santa (−2) e Corpus Christi (+60).
///
/// Feriados estaduais e municipais não entram. Datas extraordinárias (um
/// feriado decretado num ano específico) podem ser passadas em [extra].
class BusinessCalendar {
  BusinessCalendar({this.extra = const {}});

  /// Calendário nacional sem datas extraordinárias.
  static final brazil = BusinessCalendar();

  /// Feriados extraordinários, além dos nacionais.
  final Set<LocalDate> extra;
  final _byYear = <int, Set<LocalDate>>{};

  /// Feriados nacionais de [year] que caem em qualquer dia da semana.
  Set<LocalDate> holidays(int year) =>
      _byYear.putIfAbsent(year, () => _nationalHolidays(year));

  bool isHoliday(LocalDate date) =>
      holidays(date.year).contains(date) || extra.contains(date);

  bool isBusinessDay(LocalDate date) => !date.isWeekend && !isHoliday(date);

  /// Dias úteis de [start] (inclusive) até [end] (exclusive), a convenção
  /// usada no mercado brasileiro para contar "du". Negativo se [end] for
  /// anterior a [start].
  int businessDaysBetween(LocalDate start, LocalDate end) {
    if (end.isBefore(start)) return -businessDaysBetween(end, start);
    var count = 0;
    for (var d = start; d.isBefore(end); d = d.addDays(1)) {
      if (isBusinessDay(d)) count++;
    }
    return count;
  }

  /// [date] se for dia útil; senão, o próximo dia útil.
  LocalDate nextBusinessDay(LocalDate date) {
    var d = date;
    while (!isBusinessDay(d)) {
      d = d.addDays(1);
    }
    return d;
  }

  /// Soma [days] dias úteis a [date] (que não precisa ser dia útil).
  LocalDate addBusinessDays(LocalDate date, int days) {
    var d = date;
    var left = days.abs();
    final step = days >= 0 ? 1 : -1;
    while (left > 0) {
      d = d.addDays(step);
      if (isBusinessDay(d)) left--;
    }
    return d;
  }

  static Set<LocalDate> _nationalHolidays(int year) {
    final easter = easterSunday(year);
    return {
      LocalDate(year, 1, 1),
      LocalDate(year, 4, 21),
      LocalDate(year, 5, 1),
      LocalDate(year, 9, 7),
      LocalDate(year, 10, 12),
      LocalDate(year, 11, 2),
      LocalDate(year, 11, 15),
      if (year >= 2024) LocalDate(year, 11, 20),
      LocalDate(year, 12, 25),
      easter.addDays(-48),
      easter.addDays(-47),
      easter.addDays(-2),
      easter.addDays(60),
    };
  }

  /// Domingo de Páscoa no calendário gregoriano (algoritmo de Meeus,
  /// Jones e Butcher).
  static LocalDate easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = (h + l - 7 * m + 114) % 31 + 1;
    return LocalDate(year, month, day);
  }
}
