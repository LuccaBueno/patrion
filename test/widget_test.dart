import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/main.dart';

void main() {
  testWidgets('app vazio abre com o nome e o subtítulo', (tester) async {
    await tester.pumpWidget(const PatrionApp());

    expect(find.text('PATRION'), findsOneWidget);
    expect(find.text('Investimentos e Patrimônio'), findsOneWidget);
  });
}
