/// Formatos de data e hora gravados no banco e no save (DECISIONS D-10).
///
/// - Instantes: ISO-8601 em UTC com milissegundos (`2026-10-17T17:30:00.000Z`).
/// - Datas de calendário: `AAAA-MM-DD`, sem fuso.
library;

/// Converte um instante para o texto gravado no banco.
///
/// Os microssegundos são descartados (truncados), para que todos os instantes
/// tenham o mesmo tamanho e ordenem corretamente como texto.
String formatInstant(DateTime instant) {
  final utc = instant.toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  final year = utc.year.toString().padLeft(4, '0');
  final ms = utc.millisecond.toString().padLeft(3, '0');
  return '$year-${two(utc.month)}-${two(utc.day)}'
      'T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}.${ms}Z';
}

final _instantPattern = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$',
);

/// Interpreta um instante gravado por [formatInstant].
///
/// Lança [FormatException] se o texto não estiver no formato do app.
DateTime parseInstant(String text) {
  if (!_instantPattern.hasMatch(text)) {
    throw FormatException('Instante fora do formato do app', text);
  }
  return DateTime.parse(text);
}

/// Converte uma data de calendário para `AAAA-MM-DD`, ignorando a hora.
String formatCalendarDate(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-'
      '${two(date.month)}-${two(date.day)}';
}

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// Interpreta `AAAA-MM-DD` como uma data de calendário (meia-noite UTC).
///
/// Lança [FormatException] para datas inexistentes, como 2026-02-30.
DateTime parseCalendarDate(String text) {
  final match = _datePattern.firstMatch(text);
  if (match == null) {
    throw FormatException('Data fora do formato AAAA-MM-DD', text);
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw FormatException('Data inexistente', text);
  }
  return date;
}
