import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/operation_type.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/portfolio/portfolio_summary.dart';
import 'package:patrion/domain/portfolio/portfolio_valuation.dart';

import 'portfolio_calculator_test.dart' show d, op, acc, petr, cdb;

const vale = 'ativo-vale3';
const aapl = 'ativo-aapl';

final assets = {
  petr: const Asset(
    id: petr,
    symbol: 'PETR4',
    market: Market.b3,
    assetClass: AssetClass.stockBr,
    name: 'Petrobras PN',
    currency: 'BRL',
    country: 'BR',
  ),
  vale: const Asset(
    id: vale,
    symbol: 'VALE3',
    market: Market.b3,
    assetClass: AssetClass.stockBr,
    name: 'Vale ON',
    currency: 'BRL',
    country: 'BR',
  ),
  cdb: const Asset(
    id: cdb,
    symbol: 'CDB-X-2025',
    market: Market.manual,
    assetClass: AssetClass.fixedIncome,
    name: 'CDB Banco X',
    currency: 'BRL',
    country: 'BR',
  ),
  aapl: const Asset(
    id: aapl,
    symbol: 'AAPL',
    market: Market.nasdaq,
    assetClass: AssetClass.stockIntl,
    name: 'Apple',
    currency: 'USD',
    country: 'US',
  ),
};

ManualValuation price(
  String asset,
  String date,
  String value, {
  String c = 'BRL',
}) => ManualValuation(
  id: 'p-$asset-$date',
  assetId: asset,
  refDate: LocalDate.parse(date),
  kind: ValuationKind.unitPrice,
  value: d(value),
  currency: c,
);

ManualValuation balance(String asset, String date, String value) =>
    ManualValuation(
      id: 'b-$asset-$date',
      assetId: asset,
      accountId: acc,
      refDate: LocalDate.parse(date),
      kind: ValuationKind.balance,
      value: d(value),
      currency: 'BRL',
    );

void main() {
  final asOf = LocalDate(2024, 12, 1);

  final ops = [
    op(OperationType.deposit, '2024-01-01', asset: null, gross: '10000'),
    op(OperationType.buy, '2024-01-10', qty: '100', price: '30', fees: '5'),
    op(OperationType.buy, '2024-01-10', asset: vale, qty: '10', price: '60'),
    op(OperationType.contribution, '2024-02-01', asset: cdb, gross: '2000'),
    op(OperationType.dividend, '2024-03-01', gross: '50'),
    op(
      OperationType.buy,
      '2024-04-01',
      asset: aapl,
      qty: '10',
      price: '100',
      currency: 'USD',
    ),
  ];

  PortfolioSummary summarize(List<ManualValuation> valuations) {
    final state = PortfolioCalculator.compute(
      operations: ops,
      valuations: valuations,
      assets: assets,
    );
    final valued = PortfolioValuator.value(
      state: state,
      valuations: valuations,
      assets: assets,
      asOf: asOf,
    );
    return PortfolioSummary.build(
      state: state,
      valued: valued,
      termsByAsset: {
        cdb: FixedIncomeTerms(
          assetId: cdb,
          product: FixedIncomeProduct.cdb,
          indexer: Indexer.cdi,
          rate: d('110'),
          dayCount: DayCount.bus252,
          issueDate: LocalDate(2024, 2, 1),
          maturityDate: LocalDate(2025, 1, 15),
          liquidity: Liquidity.atMaturity,
          taxRegime: TaxRegime.regressiveIr,
        ),
      },
      asOf: asOf,
    );
  }

  test('sem preço, o valor de mercado fica indisponível (nunca o custo)', () {
    final s = summarize(const []);
    final brl = s.byCurrency['BRL']!;
    expect(brl.invested, d('5605'));
    expect(brl.marketValue, Decimal.zero);
    expect(brl.unpricedCount, 3);
    expect(brl.isPartial, isTrue);
    for (final v in s.positions) {
      expect(v.marketValue, isNull);
      expect(v.unrealizedPnl, isNull);
    }
    expect(s.lastValuationDate, isNull);
  });

  test('preço manual e saldo informado viram valor de mercado', () {
    final s = summarize([
      price(petr, '2024-11-29', '35'),
      price(petr, '2024-06-01', '20'), // mais antigo: ignorado
      price(petr, '2024-12-05', '99'), // depois de asOf: ignorado
      price(vale, '2024-11-28', '55'),
      balance(cdb, '2024-11-30', '2150'),
    ]);
    final brl = s.byCurrency['BRL']!;
    // 100 × 35 + 10 × 55 + 2.150
    expect(brl.marketValue, d('6200'));
    expect(brl.invested, d('5605'));
    expect(brl.unrealizedPnl, d('595'));
    expect(brl.isPartial, isFalse);
    // Caixa: 10.000 − 3.005 − 600 − 2.000 + 50.
    expect(brl.cash, d('4445'));
    expect(brl.equity, d('10645'));
    expect(brl.incomeNet, d('50'));
    expect(s.lastValuationDate, LocalDate(2024, 11, 30));

    final petrPos = s.positions.firstWhere((v) => v.asset?.id == petr);
    expect(petrPos.unitPrice, d('35'));
    expect(petrPos.valuationDate, LocalDate(2024, 11, 29));
    expect(petrPos.simpleReturn!.round(scale: 4), d('0.1647'));
  });

  test('cada moeda tem seus totais (sem conversão até a F6)', () {
    final s = summarize([price(aapl, '2024-11-29', '110', c: 'USD')]);
    expect(s.currencies(), ['BRL', 'USD']);
    final usd = s.byCurrency['USD']!;
    expect(usd.invested, d('1000'));
    expect(usd.marketValue, d('1100'));
    expect(usd.cash, d('-1000'));
    expect(s.negativeCashAccounts, {acc});
  });

  test('preço em outra moeda não é usado', () {
    final s = summarize([price(aapl, '2024-11-29', '600', c: 'BRL')]);
    final apple = s.positions.firstWhere((v) => v.asset?.id == aapl);
    expect(apple.marketValue, isNull);
  });

  test('saldo anterior à última operação é marcado como desatualizado', () {
    final s = summarize([balance(cdb, '2024-01-15', '1990')]);
    final cdbPos = s.positions.firstWhere((v) => v.asset?.id == cdb);
    expect(cdbPos.valuationStale, isTrue);
  });

  test('alocação por classe inclui o caixa e soma 100%', () {
    final s = summarize([
      price(petr, '2024-11-29', '35'),
      price(vale, '2024-11-28', '55'),
      balance(cdb, '2024-11-30', '2150'),
    ]);
    final slices = s.allocation('BRL', (v) => v.asset!.assetClass);
    expect(slices.map((x) => x.key), [
      null, // caixa 4.445
      AssetClass.stockBr, // 4.050
      AssetClass.fixedIncome, // 2.150
    ]);
    final total = slices.fold(Decimal.zero, (a, x) => a + x.fraction);
    expect(total.round(scale: 10), Decimal.one);
  });

  test('maiores posições e vencimentos próximos', () {
    final s = summarize([
      price(petr, '2024-11-29', '35'),
      price(vale, '2024-11-28', '55'),
    ]);
    expect(s.topPositions('BRL').map((v) => v.asset!.symbol), [
      'PETR4',
      'VALE3',
    ]);
    expect(s.upcomingMaturities.single.asset.id, cdb);
    expect(s.upcomingMaturities.single.daysLeft, 45);
  });
}
