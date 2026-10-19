import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/domain/market/market_schedule.dart';

/// Janela de pregão da B3 para a atualização automática (DECISIONS D-37).
void main() {
  // Horário de Brasília = UTC−3.
  DateTime brt(int y, int m, int d, int h, int min) =>
      DateTime.utc(y, m, d, h + 3, min);

  test('dia útil: das 10:00 às 18:29 de Brasília', () {
    expect(MarketSchedule.inB3Session(brt(2026, 10, 16, 9, 59)), isFalse);
    expect(MarketSchedule.inB3Session(brt(2026, 10, 16, 10, 0)), isTrue);
    expect(MarketSchedule.inB3Session(brt(2026, 10, 16, 13, 30)), isTrue);
    expect(MarketSchedule.inB3Session(brt(2026, 10, 16, 18, 29)), isTrue);
    expect(MarketSchedule.inB3Session(brt(2026, 10, 16, 18, 30)), isFalse);
  });

  test('fim de semana e feriado ficam fora', () {
    expect(MarketSchedule.inB3Session(brt(2026, 10, 17, 13, 0)), isFalse);
    expect(MarketSchedule.inB3Session(brt(2026, 12, 25, 13, 0)), isFalse);
  });

  test('o instante local do PC não importa: vale o horário de Brasília', () {
    // 22:00 UTC de sexta = 19:00 em Brasília: fora.
    expect(MarketSchedule.inB3Session(DateTime.utc(2026, 10, 16, 22)), isFalse);
  });
}
