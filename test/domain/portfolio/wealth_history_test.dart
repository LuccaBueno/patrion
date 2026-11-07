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

  group('TWR com compra a preço diferente do valor do dia', () {
    const btc = Asset(
      id: 'btc',
      symbol: 'BTC',
      market: Market.crypto,
      assetClass: AssetClass.crypto,
      name: 'Bitcoin',
      currency: 'BRL',
      country: 'BR',
      priceSource: PriceSource.market,
    );
    final prices = {
      'petr': closes({
        '2026-01-05': '10',
        '2026-01-06': '11',
        '2026-01-07': '12',
        '2026-01-08': '12',
        '2026-01-09': '12',
      }),
      'btc': closes({
        '2026-01-05': '400000',
        '2026-01-06': '410000',
        '2026-01-07': '430000',
        '2026-01-08': '430000',
        '2026-01-09': '473000',
      }),
    };
    WealthSeries twoAssets(
      List<Operation> ops, {
      Map<String, Decimal>? finalValues,
      String today = '2026-01-09',
    }) => build(
      ops,
      prices: prices,
      assets: {'petr': _asset, 'btc': btc},
      finalValues: finalValues,
      today: today,
    );
    Decimal? twr(WealthSeries s) =>
        s.twrBetween(day('2026-01-05'), day('2026-01-09'));

    test('compra grande abaixo do mercado numa carteira pequena: a diferença '
        'rende sobre o capital que entrou, não sobre o da véspera', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(
          OperationType.buy,
          '2026-01-07',
          asset: 'btc',
          qty: '1',
          price: '350000',
        ),
      ]);
      final day7 = s.points[2];
      expect(day7.value, d('431200'));
      expect(day7.flow, d('350000'));
      expect(day7.entryGain, d('80000'));
      // Antes: (431.200 − 350.000) ÷ 1.100 = 73,8× só nesse dia. Agora: a
      // carteira da véspera rende 1.200 ÷ 1.100, e os 80.000 rendem sobre
      // os 351.200 aplicados: 431.200 ÷ 351.200.
      final factor = s.twrIndex()[2].$2;
      expect(factor.toDouble(), closeTo(1.2 * 431200 / 351200, 1e-12));
      // O dia 9: 1.200 + 473.000 sobre 431.200.
      expect(
        twr(s)!.toDouble(),
        closeTo(1.2 * 431200 / 351200 * 474200 / 431200 - 1, 1e-12),
      );
    });

    test('compra acima do mercado é perda sobre o capital que entrou', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(
          OperationType.buy,
          '2026-01-07',
          asset: 'btc',
          qty: '1',
          price: '500000',
        ),
      ], today: '2026-01-07');
      expect(s.points.last.entryGain, d('-70000'));
      expect(
        s.twrIndex().last.$2.toDouble(),
        closeTo(1.2 * 431200 / 501200, 1e-12),
      );
    });

    test('compra pelo fechamento continua sem diferença', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(
          OperationType.buy,
          '2026-01-07',
          asset: 'btc',
          qty: '1',
          price: '430000',
        ),
      ], today: '2026-01-07');
      expect(s.points.last.entryGain, isNull);
      expect(s.twrIndex().last.$2, d('1.2'));
    });

    test('compra no último dia usa o valor da Carteira', () {
      final s = twoAssets(
        [
          op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
          op(
            OperationType.buy,
            '2026-01-07',
            asset: 'btc',
            qty: '1',
            price: '350000',
          ),
        ],
        finalValues: {'petr': d('1200'), 'btc': d('440000')},
        today: '2026-01-07',
      );
      expect(s.points.last.entryGain, d('90000'));
      expect(
        s.twrIndex().last.$2.toDouble(),
        closeTo(1.2 * 441200 / 351200, 1e-12),
      );
    });

    test('custos da compra pesam sobre o capital que entrou', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(
          OperationType.buy,
          '2026-01-07',
          asset: 'btc',
          qty: '1',
          price: '430000',
          fees: '1000',
        ),
      ], today: '2026-01-07');
      expect(s.points.last.entryGain, d('-1000'));
      expect(
        s.twrIndex().last.$2.toDouble(),
        closeTo(1.2 * 431200 / 432200, 1e-12),
      );
    });

    test('só a quantidade líquida comprada no dia conta', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        // Compra 100 a 8 e vende 50 a 12, com o fechamento a 12.
        op(OperationType.buy, '2026-01-07', qty: '100', price: '8'),
        op(OperationType.sell, '2026-01-07', qty: '50', price: '12'),
      ], today: '2026-01-07');
      // Sobram 50 das compradas, com custo 400 e valor 600.
      expect(s.points.last.entryGain, d('200'));
    });

    test('venda a preço diferente do fechamento não muda: o capital da '
        'véspera já inclui o ativo vendido', () {
      final s = twoAssets([
        op(OperationType.buy, '2026-01-05', qty: '100', price: '10'),
        op(OperationType.sell, '2026-01-07', qty: '100', price: '15'),
      ], today: '2026-01-07');
      expect(s.points.last.entryGain, isNull);
      expect(s.twrIndex().last.$2.toDouble(), closeTo(1.5, 1e-12));
    });

    test('saldo informado não tem preço unitário: fica como estava', () {
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
          op(
            OperationType.buy,
            '2026-01-07',
            asset: 'cdb',
            qty: '1',
            price: '1000',
          ),
        ],
        assets: {'petr': _asset, 'cdb': cdb},
        valuations: [
          ManualValuation(
            id: 'v',
            accountId: 'conta',
            assetId: 'cdb',
            kind: ValuationKind.balance,
            refDate: day('2026-01-07'),
            value: d('1100'),
            currency: 'BRL',
          ),
        ],
        today: '2026-01-07',
      );
      expect(s.points.last.entryGain, isNull);
    });
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
