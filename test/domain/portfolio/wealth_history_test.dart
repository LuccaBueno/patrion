import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/finance/benchmark.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/market/price_series.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/wealth_history.dart';

Decimal d(String v) => Decimal.parse(v);
LocalDate day(String v) => LocalDate.parse(v);

const _asset = Asset(
  id: 'petr',
  symbol: 'PETR4',
  market: Market.b3,
  assetClass: AssetClass.stockBr,
  name: 'Petrobras',
  currency: 'BRL',
  country: 'BR',
  priceSource: PriceSource.market,
);

var _seq = 0;

Operation op(
  OperationType type,
  String date, {
  String asset = 'petr',
  String? qty,
  String? price,
  String? gross,
  String fees = '0',
  String currency = 'BRL',
  String account = 'conta',
}) => Operation(
  id: 'op${_seq++}',
  accountId: account,
  assetId: asset,
  type: type,
  tradeDate: day(date),
  currency: currency,
  quantity: qty == null ? null : d(qty),
  unitPrice: price == null ? null : d(price),
  grossAmount: gross == null ? null : d(gross),
  fees: d(fees),
);

List<PricePoint> closes(Map<String, String> m) => [
  for (final e in m.entries) PricePoint(day(e.key), d(e.value)),
];

WealthSeries build(
  List<Operation> ops, {
  Map<String, List<PricePoint>>? prices,
  Map<String, Asset>? assets,
  List<ManualValuation> valuations = const [],
  Map<String, List<(LocalDate, Decimal)>> fx = const {},
  String today = '2026-01-09',
  Map<String, Decimal>? finalValues,
}) => WealthHistory.build(
  operations: ops,
  valuations: valuations,
  assets: assets ?? {'petr': _asset},
  closes:
      prices ??
      {
        'petr': closes({
          '2026-01-05': '10',
          '2026-01-06': '11',
          '2026-01-07': '12',
          '2026-01-08': '12',
          '2026-01-09': '12',
        }),
      },
  fxToBrl: fx,
  today: day(today),
  finalValues: finalValues,
);

void main() {
  test('patrimônio = quantidade × fechamento do dia; aplicado acumulado; '
      'TWR por subperíodos', () {
    final s = build([
      op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
      // Segunda compra no dia 7, a 12: o aporte não é retorno.
      op(OperationType.buy, '2026-01-07', qty: '100', price: '12'),
      // Venda total no dia 8, a 12.
      op(OperationType.sell, '2026-01-08', qty: '200', price: '12'),
    ]);
    expect(s.points.map((p) => p.date), [
      day('2026-01-05'),
      day('2026-01-06'),
      day('2026-01-07'),
      day('2026-01-08'),
      day('2026-01-09'),
    ]);
    expect(s.points.map((p) => p.value), [
      d('1000'),
      d('1100'),
      d('2400'),
      d('0'),
      d('0'),
    ]);
    expect(s.points.map((p) => p.invested), [
      d('1000'),
      d('1000'),
      d('2200'),
      d('-200'),
      d('-200'),
    ]);
    // Ganho final = vendeu 2.400 tendo posto 2.200.
    expect(s.points.last.gain, d('200'));
    expect(s.points[2].buys, d('1200'));
    expect(s.points[3].sells, d('2400'));
    // 1100/1000 × 1200/1100 × 2400/2400 − 1 = 20%.
    expect(s.twrBetween(day('2026-01-05'), day('2026-01-09')), d('0.2'));
    expect(s.twrBetween(day('2026-01-06'), day('2026-01-07')), isNotNull);
  });

  test('proventos saem como retirada: entram no TWR, não no patrimônio', () {
    final s = build([
      op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
      op(OperationType.dividend, '2026-01-06', gross: '50'),
    ]);
    expect(s.points[1].value, d('1100'));
    expect(s.points[1].income, d('50'));
    expect(s.points[1].invested, d('1000'));
    // (1100 + 50) ÷ 1000 − 1.
    expect(s.twrBetween(day('2026-01-05'), day('2026-01-06')), d('0.15'));
  });

  test('custos entram no aplicado (compra) e saem do resgate (venda)', () {
    final s = build([
      op(OperationType.buy, '2026-01-05', qty: '100', price: '10', fees: '5'),
      op(OperationType.sell, '2026-01-07', qty: '50', price: '12', fees: '5'),
    ]);
    expect(s.points.first.invested, d('1005'));
    // 1005 − (600 − 5).
    expect(s.points[2].invested, d('410'));
    expect(s.points[2].value, d('600'));
  });

  test('ativo comprado antes do histórico entra no primeiro preço, com o '
      'aplicado acumulado até ali', () {
    final s = build([
      op(OperationType.buy, '2026-01-02', qty: '100', price: '9'),
    ], today: '2026-01-07');
    // 02/01 sem fechamento: fora do valor e do aplicado.
    expect(s.points.first.date, day('2026-01-02'));
    expect(s.points.first.missing, {'petr'});
    expect(s.points.first.value, Decimal.zero);
    expect(s.points.first.invested, Decimal.zero);
    final entry = s.points.firstWhere((p) => p.date == day('2026-01-05'));
    expect(entry.value, d('1000'));
    expect(entry.invested, d('900'));
    // Entra como aporte do próprio valor: sem retorno inventado no dia.
    expect(entry.flow, d('1000'));
    expect(s.entries, {'petr': day('2026-01-05')});
    expect(s.twrBetween(day('2026-01-05'), day('2026-01-07')), d('0.2'));
  });

  test('ativo sem nenhum preço fica fora; o último dia usa os valores da '
      'Carteira', () {
    const cdb = Asset(
      id: 'cdb',
      symbol: 'CDB',
      market: Market.manual,
      assetClass: AssetClass.fixedIncome,
      name: 'CDB',
      currency: 'BRL',
      country: 'BR',
    );
    final s = build(
      [
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(OperationType.buy, '2026-01-05', asset: 'cdb', gross: '5000'),
      ],
      assets: {'petr': _asset, 'cdb': cdb},
      finalValues: {'petr': d('1234.56')},
    );
    expect(s.excluded, {'cdb'});
    expect(s.points.first.invested, d('1000'));
    expect(s.points.last.value, d('1234.56'));
  });

  test('ativo em dólar convertido pelo câmbio do dia', () {
    const aapl = Asset(
      id: 'aapl',
      symbol: 'AAPL',
      market: Market.nasdaq,
      assetClass: AssetClass.stockIntl,
      name: 'Apple',
      currency: 'USD',
      country: 'US',
      priceSource: PriceSource.market,
    );
    final s = build(
      [
        op(
          OperationType.buy,
          '2026-01-05',
          asset: 'aapl',
          qty: '10',
          price: '200',
          currency: 'USD',
        ),
      ],
      assets: {'aapl': aapl},
      prices: {
        'aapl': closes({'2026-01-05': '200', '2026-01-06': '210'}),
      },
      fx: {
        'USD': [(day('2026-01-02'), d('5.00')), (day('2026-01-06'), d('5.50'))],
      },
      today: '2026-01-06',
    );
    expect(s.points.first.value, d('10000'));
    expect(s.points.first.invested, d('10000'));
    expect(s.points.last.value, d('11550'));
  });

  group('índices', () {
    IndicatorPoint ip(IndicatorSeries s, String date, String v) =>
        IndicatorPoint(
          series: s,
          refDate: day(date),
          value: d(v),
          source: 'teste',
          collectedAt: '',
        );

    test('CDI: mesmos aportes, nas mesmas datas, rendendo o índice', () {
      final s = build([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(OperationType.buy, '2026-01-07', qty: '100', price: '12'),
      ]);
      final cdi = IndexLevels.cdi([
        for (final x in [
          '2026-01-02',
          '2026-01-05',
          '2026-01-06',
          '2026-01-07',
          '2026-01-08',
        ])
          ip(IndicatorSeries.cdi, x, '1'), // 1% ao dia, para conferir
      ]);
      final sim = Benchmark.simulate(s.points, cdi)!;
      // 1000; 1010; 1020,10 + 1200; 2242,30...; o dia 9 sem CDI fica parado.
      expect(sim.map((p) => p.value), [
        d('1000'),
        d('1010'),
        d('2220.1'),
        d('2242.301'),
        d('2242.301'),
      ]);
      expect(sim[2].cumulative, d('0.0201'));
      // Índice que começa depois da carteira: sem comparação.
      final late = IndexLevels.cdi([
        ip(IndicatorSeries.cdi, '2026-01-07', '1'),
      ]);
      expect(Benchmark.simulate(s.points, late), isNull);
    });

    test('IPCA: o mês rende a variação publicada, dividida pelos dias', () {
      final ipca = IndexLevels.ipca([
        ip(IndicatorSeries.ipca, '2026-01-01', '1'),
        ip(IndicatorSeries.ipca, '2026-02-01', '0.5'),
      ]);
      final jan31 = ipca.levels.firstWhere((e) => e.$1 == day('2026-01-31'));
      expect(jan31.$2, d('1.01'));
      final feb28 = ipca.levels.last;
      expect(feb28.$1, day('2026-02-28'));
      expect(feb28.$2, d('1.01505'));
      final jan16 = ipca.levels.firstWhere((e) => e.$1 == day('2026-01-16'));
      expect(jan16.$2 > Decimal.one && jan16.$2 < d('1.01'), isTrue);
    });

    test('Ibovespa: os pontos são o nível', () {
      final ibov = IndexLevels.points(IndicatorSeries.ibovespa, [
        ip(IndicatorSeries.ibovespa, '2026-01-05', '160000'),
        ip(IndicatorSeries.ibovespa, '2026-01-06', '176000'),
      ]);
      final s = build([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
      ], today: '2026-01-06');
      final sim = Benchmark.simulate(s.points, ibov)!;
      expect(sim.last.value, d('1100'));
      expect(sim.last.cumulative, d('0.1'));
    });
  });
}
