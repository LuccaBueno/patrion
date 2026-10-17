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
}
