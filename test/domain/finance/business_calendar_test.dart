import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/business_calendar.dart';

void main() {
  final cal = BusinessCalendar.brazil;

  test('Páscoa em anos conhecidos', () {
    expect(BusinessCalendar.easterSunday(2024), LocalDate(2024, 3, 31));
    expect(BusinessCalendar.easterSunday(2025), LocalDate(2025, 4, 20));
    expect(BusinessCalendar.easterSunday(2026), LocalDate(2026, 4, 5));
    expect(BusinessCalendar.easterSunday(2000), LocalDate(2000, 4, 23));
  });

  test('feriados nacionais de 2025 (calendário ANBIMA)', () {
    final expected = {
      LocalDate(2025, 1, 1),
      LocalDate(2025, 3, 3), // Carnaval
      LocalDate(2025, 3, 4), // Carnaval
      LocalDate(2025, 4, 18), // Sexta-feira Santa
      LocalDate(2025, 4, 21),
      LocalDate(2025, 5, 1),
      LocalDate(2025, 6, 19), // Corpus Christi
      LocalDate(2025, 9, 7),
      LocalDate(2025, 10, 12),
      LocalDate(2025, 11, 2),
      LocalDate(2025, 11, 15),
      LocalDate(2025, 11, 20),
      LocalDate(2025, 12, 25),
    };
    expect(cal.holidays(2025), expected);
  });

  test('20 de novembro é feriado nacional só a partir de 2024', () {
    expect(cal.isHoliday(LocalDate(2023, 11, 20)), isFalse);
    expect(cal.isHoliday(LocalDate(2024, 11, 20)), isTrue);
  });

  test('fim de semana e feriado não são dias úteis', () {
    expect(cal.isBusinessDay(LocalDate(2025, 1, 4)), isFalse); // sábado
    expect(cal.isBusinessDay(LocalDate(2025, 1, 5)), isFalse); // domingo
    expect(cal.isBusinessDay(LocalDate(2025, 1, 1)), isFalse);
    expect(cal.isBusinessDay(LocalDate(2025, 1, 2)), isTrue);
  });

  test('dias úteis: início incluído, fim excluído', () {
    final mon = LocalDate(2025, 1, 6);
    expect(cal.businessDaysBetween(mon, mon), 0);
    expect(cal.businessDaysBetween(mon, mon.addDays(1)), 1);
    expect(cal.businessDaysBetween(mon, mon.addDays(7)), 5);
    expect(cal.businessDaysBetween(mon.addDays(7), mon), -5);
  });

  test('2025 tem 252 dias úteis', () {
    // 261 dias de segunda a sexta menos 9 feriados em dias de semana
    // (7/9, 12/10 e 2/11 caíram no domingo; 15/11, no sábado).
    expect(
      cal.businessDaysBetween(LocalDate(2025, 1, 1), LocalDate(2026, 1, 1)),
      252,
    );
  });

  test('próximo dia útil e soma de dias úteis', () {
    // Sexta-feira Santa de 2025 (18/04) e Tiradentes na segunda (21/04).
    expect(cal.nextBusinessDay(LocalDate(2025, 4, 18)), LocalDate(2025, 4, 22));
    expect(
      cal.addBusinessDays(LocalDate(2025, 4, 17), 1),
      LocalDate(2025, 4, 22),
    );
    expect(
      cal.addBusinessDays(LocalDate(2025, 4, 22), -1),
      LocalDate(2025, 4, 17),
    );
  });

  test('feriado extraordinário', () {
    final custom = BusinessCalendar(extra: {LocalDate(2025, 1, 2)});
    expect(custom.isBusinessDay(LocalDate(2025, 1, 2)), isFalse);
    expect(cal.isBusinessDay(LocalDate(2025, 1, 2)), isTrue);
  });
}
