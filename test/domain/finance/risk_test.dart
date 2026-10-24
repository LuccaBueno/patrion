import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/benchmark.dart';
import 'package:patrion/domain/finance/risk.dart';
import 'package:patrion/domain/market/market_data.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);
Decimal r4(Decimal v) => DecimalMath.roundHalfUp(v, scale: 4);

/// Níveis diários a partir de 100, com os retornos dados, um por dia
/// corrido desde 01/01/2024.
List<(LocalDate, Decimal)> levels(List<Decimal> returns) {
  var v = Decimal.fromInt(100);
  var date = day('2024-01-01');
  final result = <(LocalDate, Decimal)>[(date, v)];
  for (final r in returns) {
    date = date.addDays(1);
    v = DecimalMath.rescale(v * (Decimal.one + r));
    result.add((date, v));
  }
  return result;
}

List<Decimal> alternating(int n, {String base = '0'}) => [
  for (var i = 0; i < n; i++) d(base) + (i.isEven ? d('0.01') : d('-0.01')),
];

void main() {
  test('volatilidade: ±1% em dias corridos, anualizada por 365,25', () {
    final r = Risk.returns(levels(alternating(20)));
    expect(r.map((e) => r4(e.$2)).toSet(), {d('0.01'), d('-0.01')});
    // Desvio √(20 × 0,0001 ÷ 19) = 0,0102598 × √365,25.
    expect(r4(Risk.volatility(r)!), d('0.1961'));
    expect(Risk.volatility(r.sublist(1)), isNull, reason: 'menos de 20');
  });

  test('drawdown: pico, fundo e recuperação', () {
    final dd = Risk.maxDrawdown([
      (day('2024-01-01'), d('100')),
      (day('2024-01-02'), d('120')),
      (day('2024-01-03'), d('90')),
      (day('2024-01-04'), d('100')),
      (day('2024-01-05'), d('125')),
    ])!;
    expect(dd.depth, d('-0.25'));
    expect(dd.peak, day('2024-01-02'));
    expect(dd.trough, day('2024-01-03'));
    expect(dd.recovery, day('2024-01-05'));
    final open = Risk.maxDrawdown([
      (day('2024-01-01'), d('100')),
      (day('2024-01-02'), d('80')),
    ])!;
    expect(open.recovery, isNull);
    expect(
      Risk.maxDrawdown([
        (day('2024-01-01'), d('100')),
        (day('2024-01-02'), d('110')),
      ])!.depth,
      Decimal.zero,
    );
  });

  test('correlação: 1 com o dobro dos retornos, −1 com o oposto', () {
    final base = [
      for (var i = 0; i < 70; i++) d('0.001') * Decimal.fromInt(i % 7 - 3),
    ];
    final a = levels(base);
    expect(
      r4(Risk.correlation(a, levels([for (final x in base) x * d('2')]))!),
      d('1'),
    );
    expect(
      r4(Risk.correlation(a, levels([for (final x in base) -x]))!),
      d('-1'),
    );
    expect(
      Risk.correlation(a.sublist(0, 50), a.sublist(0, 50)),
      isNull,
      reason: 'menos de 60 retornos em comum',
    );
  });

  test('beta 1,5 contra o mercado; nulo com menos de 12 meses', () {
    final m = [
      for (var i = 0; i < 400; i++) d('0.002') * Decimal.fromInt(i % 5 - 2),
    ];
    final market = levels(m);
    final portfolio = levels([for (final x in m) x * d('1.5')]);
    expect(r4(Risk.beta(portfolio, market)!), d('1.5'));
    expect(Risk.beta(portfolio.sublist(0, 300), market), isNull);
  });

  test('Sharpe: excesso médio de 0,1% ao dia com desvio de ~1%', () {
    // CDI de 0,04% ao dia corrido; a carteira rende o CDI + 0,1% ± 1%.
    final cdi = IndexLevels(IndicatorSeries.cdi, [
      for (var i = 0; i <= 400; i++)
        (
          day('2024-01-01').addDays(i),
          DecimalMath.pow(d('1.0004'), Decimal.fromInt(i)),
        ),
    ]);
    final p = levels(alternating(400, base: '0.0014'));
    // 0,001 ÷ √(400 × 0,0001 ÷ 399) × √365,25 = 1,9088.
    expect(r4(Risk.sharpe(p, cdi)!), d('1.9088'));
    expect(Risk.sharpe(p.sublist(0, 100), cdi), isNull);
    // "1 ano" num sábado vai de sexta a sexta: 364 dias entre os pregões
    // ainda são 12 meses; 359 dias, não.
    expect(Risk.sharpe(p.sublist(0, 365), cdi), isNotNull);
    expect(Risk.sharpe(p.sublist(0, 360), cdi), isNull);
  });

  test('concentração: maior, cinco maiores, HHI e número efetivo', () {
    final c = Concentration.of({'A': d('50'), 'B': d('30'), 'C': d('20')})!;
    expect(c.largest, 'A');
    expect(c.largestWeight, d('0.5'));
    expect(c.top5, d('1'));
    expect(c.hhi, d('0.38'));
    expect(r4(c.effective), d('2.6316'));
    expect(Concentration.of({'A': Decimal.zero}), isNull);
  });

  test('janela: o último nível até o início e os seguintes até o fim', () {
    final w = Risk.window(
      [
        (day('2024-01-01'), d('1')),
        (day('2024-01-03'), d('2')),
        (day('2024-01-05'), d('3')),
        (day('2024-01-07'), d('4')),
      ],
      day('2024-01-04'),
      day('2024-01-05'),
    );
    expect(w, [(day('2024-01-03'), d('2')), (day('2024-01-05'), d('3'))]);
  });
}
