import 'instant_format.dart';

/// Data de calendário, sem hora nem fuso (`AAAA-MM-DD`, DECISIONS D-10).
///
/// Usada para datas de operação, pregão, vencimento e referência de preços.
final class LocalDate implements Comparable<LocalDate> {
  LocalDate(int year, int month, int day)
    : this._(DateTime.utc(year, month, day));

  LocalDate._(DateTime utc) : year = utc.year, month = utc.month, day = utc.day;

  /// Data de calendário de [instant] no fuso local (o dia que o usuário vê).
  factory LocalDate.fromDateTime(DateTime instant) =>
      LocalDate(instant.year, instant.month, instant.day);

  /// Interpreta `AAAA-MM-DD`. Lança [FormatException] se for inválida.
  factory LocalDate.parse(String text) => LocalDate._(parseCalendarDate(text));

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  LocalDate addDays(int days) => LocalDate._(_utc.add(Duration(days: days)));

  /// Dias corridos de [other] até esta data.
  int daysSince(LocalDate other) => _utc.difference(other._utc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `AAAA-MM-DD`, o formato gravado no banco.
  @override
  String toString() => formatCalendarDate(_utc);
}
