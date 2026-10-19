import '../../core/time/local_date.dart';
import '../finance/business_calendar.dart';

/// Horário de pregão da B3 para a atualização automática (DECISIONS D-37).
abstract final class MarketSchedule {
  /// Brasília não tem horário de verão desde 2019: UTC−3 o ano todo.
  static const brasiliaOffset = Duration(hours: -3);

  /// Janela da atualização automática em dias úteis da B3, no horário de
  /// Brasília: da abertura (10:00) até 30 minutos depois do fim do call de
  /// fechamento (18:00), para pegar a última cotação do dia, que chega com
  /// até 30 minutos de atraso.
  static const openMinute = 10 * 60;
  static const closeMinute = 18 * 60 + 30;

  /// [at] (qualquer fuso) cai na janela de pregão da B3.
  static bool inB3Session(DateTime at, {BusinessCalendar? calendar}) {
    final local = at.toUtc().add(brasiliaOffset);
    final day = LocalDate(local.year, local.month, local.day);
    if (!(calendar ?? BusinessCalendar.brazil).isBusinessDay(day)) {
      return false;
    }
    final minute = local.hour * 60 + local.minute;
    return minute >= openMinute && minute < closeMinute;
  }
}
