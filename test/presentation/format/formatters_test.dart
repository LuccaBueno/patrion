import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/presentation/format/formatters.dart';

Decimal d(String s) => Decimal.parse(s);

void main() {
  group('money', () {
    test('pt-BR com 2 casas e milhar', () {
      expect(Fmt.money(d('2885.4'), 'BRL'), r'R$ 2.885,40');
      expect(Fmt.money(d('1234567.891'), 'BRL'), r'R$ 1.234.567,89');
      expect(Fmt.money(d('0'), 'BRL'), r'R$ 0,00');
      expect(Fmt.money(d('-10'), 'BRL'), r'-R$ 10,00');
      expect(Fmt.money(d('5'), 'USD'), r'US$ 5,00');
      expect(Fmt.money(d('3'), 'GBP'), 'GBP 3,00');
    });

    test('arredonda meio para cima na exibição', () {
      expect(Fmt.money(d('0.125'), 'BRL'), r'R$ 0,13');
      expect(Fmt.money(d('-0.125'), 'BRL'), r'-R$ 0,13');
    });

    test('signedMoney põe + nos ganhos', () {
      expect(Fmt.signedMoney(d('470.4'), 'BRL'), r'+R$ 470,40');
      expect(Fmt.signedMoney(d('-1'), 'BRL'), r'-R$ 1,00');
      expect(Fmt.signedMoney(d('0.001'), 'BRL'), r'R$ 0,00');
    });
  });

  test('number sem zeros à direita', () {
    expect(Fmt.number(d('1234.5')), '1.234,5');
    expect(Fmt.number(d('180')), '180');
    expect(Fmt.number(d('0.00012345')), '0,00012345');
    expect(Fmt.number(d('32.06000000000000000000')), '32,06');
  });

  test('percent', () {
    expect(Fmt.percent(d('0.16472545757071547421')), '+16,47%');
    expect(Fmt.percent(d('-0.01')), '-1,00%');
    expect(Fmt.percent(d('0.25'), signed: false), '25,00%');
  });

  test('date', () {
    expect(Fmt.date(LocalDate(2026, 10, 7)), '07/10/2026');
  });

  group('parseDecimal', () {
    test('aceita pt-BR e ponto decimal', () {
      expect(Fmt.parseDecimal('1.234,56'), d('1234.56'));
      expect(Fmt.parseDecimal('1234,56'), d('1234.56'));
      expect(Fmt.parseDecimal('0.5'), d('0.5'));
      expect(Fmt.parseDecimal('1.234.567'), d('1234567'));
      expect(Fmt.parseDecimal(r'R$ 30,05'), d('30.05'));
      expect(Fmt.parseDecimal('-1,5'), d('-1.5'));
      expect(Fmt.parseDecimal('  '), isNull);
    });

    test('recusa texto inválido', () {
      expect(() => Fmt.parseDecimal('abc'), throwsFormatException);
      expect(() => Fmt.parseDecimal('1,2,3'), throwsFormatException);
    });
  });

  test('parseDate aceita dd/mm/aaaa e ISO', () {
    expect(Fmt.parseDate('7/1/2024'), LocalDate(2024, 1, 7));
    expect(Fmt.parseDate('2024-01-07'), LocalDate(2024, 1, 7));
    expect(() => Fmt.parseDate('31/02/2024'), throwsFormatException);
  });
}
