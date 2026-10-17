import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/instant_format.dart';

void main() {
  group('instantes', () {
    test('UTC com milissegundos e Z', () {
      final t = DateTime.utc(2026, 10, 17, 17, 30);
      expect(formatInstant(t), '2026-10-17T17:30:00.000Z');
    });

    test('converte hora local para UTC', () {
      final local = DateTime(2026, 1, 2, 3, 4, 5, 6);
      expect(parseInstant(formatInstant(local)), local.toUtc());
    });

    test('trunca microssegundos', () {
      final t = DateTime.utc(2026, 10, 17, 1, 2, 3, 456, 789);
      expect(formatInstant(t), '2026-10-17T01:02:03.456Z');
    });

    test('texto ordena como o tempo', () {
      final a = formatInstant(DateTime.utc(2026, 9, 30, 23, 59, 59, 999));
      final b = formatInstant(DateTime.utc(2026, 10, 1));
      expect(a.compareTo(b), lessThan(0));
    });

    test('parse recusa outros formatos', () {
      expect(() => parseInstant('2026-10-17T17:30:00Z'), throwsFormatException);
      expect(
        () => parseInstant('2026-10-17T17:30:00.000-03:00'),
        throwsFormatException,
      );
    });
  });

  group('datas de calendário', () {
    test('AAAA-MM-DD sem hora', () {
      expect(formatCalendarDate(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
      expect(parseCalendarDate('2026-03-05'), DateTime.utc(2026, 3, 5));
    });

    test('recusa data inexistente', () {
      expect(() => parseCalendarDate('2026-02-30'), throwsFormatException);
      expect(() => parseCalendarDate('2026-2-3'), throwsFormatException);
    });
  });
}
