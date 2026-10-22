import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/presentation/screens/dashboard/dashboard_charts.dart';

void main() {
  test('rótulos curtos do eixo dos gráficos de barras', () {
    expect(compact(0), '0');
    expect(compact(950), '950');
    expect(compact(5000), '5 mil');
    expect(compact(12500), '12,5 mil');
    expect(compact(1500000), '1,5 mi');
  });
}
