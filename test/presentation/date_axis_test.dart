import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/presentation/widgets/date_axis.dart';

void main() {
  test('vários anos: rótulos no 1º de janeiro de cada ano', () {
    final axis = DateAxis(LocalDate(2016, 10, 24), LocalDate(2026, 10, 22));
    expect(axis.anchor, LocalDate(2016, 1, 1));
    expect(axis.interval, 365.25);
    expect(axis.x(LocalDate(2016, 10, 24)), 297);
    // Os múltiplos do intervalo caem na virada de cada ano (± 1 dia).
    for (var k = 1; k <= 10; k++) {
      final d = axis.dateAt(k * axis.interval);
      final jan1 = LocalDate(2016 + k, 1, 1);
      expect(d.daysSince(jan1).abs(), lessThanOrEqualTo(1), reason: '$d');
      expect(axis.label(k * axis.interval), '${2016 + k}');
    }
  });

  test('um ano: meses alternados; um mês: dias', () {
    final year = DateAxis(LocalDate(2025, 10, 22), LocalDate(2026, 10, 22));
    expect(year.anchor, LocalDate(2025, 10, 1));
    expect(year.label(year.interval), 'dez/25');
    expect(year.label(2 * year.interval), 'fev/26');
    final month = DateAxis(LocalDate(2026, 9, 22), LocalDate(2026, 10, 22));
    expect(month.interval, 7);
    expect(month.label(7), '29/09');
  });
}
