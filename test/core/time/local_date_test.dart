import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';

void main() {
  test('ida e volta pelo texto AAAA-MM-DD', () {
    final date = LocalDate.parse('2024-02-29');
    expect(date.year, 2024);
    expect(date.month, 2);
    expect(date.day, 29);
    expect(date.toString(), '2024-02-29');
  });

  test('datas inexistentes são recusadas', () {
    expect(() => LocalDate.parse('2023-02-29'), throwsFormatException);
    expect(() => LocalDate.parse('17/10/2026'), throwsFormatException);
  });

  test('comparação, igualdade e diferença em dias', () {
    final a = LocalDate(2024, 1, 1);
    final b = LocalDate(2025, 1, 1);
    expect(a.isBefore(b), isTrue);
    expect(b.isAfter(a), isTrue);
    expect(b.daysSince(a), 366);
    expect(a.addDays(31), LocalDate(2024, 2, 1));
    expect(LocalDate(2024, 1, 1), a);
    expect({a, LocalDate(2024, 1, 1)}, hasLength(1));
  });

  test('soma de meses limita ao último dia do mês', () {
    expect(LocalDate(2024, 1, 31).addMonths(1), LocalDate(2024, 2, 29));
    expect(LocalDate(2023, 1, 31).addMonths(1), LocalDate(2023, 2, 28));
    expect(LocalDate(2024, 11, 15).addMonths(3), LocalDate(2025, 2, 15));
    expect(LocalDate(2024, 3, 31).addMonths(-1), LocalDate(2024, 2, 29));
    expect(LocalDate(2024, 1, 10).addMonths(-13), LocalDate(2022, 12, 10));
  });

  test('dia da semana e fim de semana', () {
    expect(LocalDate(2026, 10, 17).weekday, DateTime.saturday);
    expect(LocalDate(2026, 10, 17).isWeekend, isTrue);
    expect(LocalDate(2026, 10, 19).isWeekend, isFalse);
  });
}
