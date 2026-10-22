import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/core/money/decimal_math.dart';
import 'package:patrion/core/time/local_date.dart';
import 'package:patrion/domain/market/market_data.dart';
import 'package:patrion/domain/market/market_price.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/holdings.dart';
import 'package:patrion/domain/portfolio/portfolio_calculator.dart';
import 'package:patrion/domain/portfolio/portfolio_valuation.dart';

Decimal d(String v) => Decimal.parse(v);

Asset _asset(String symbol, {String currency = 'BRL'}) => Asset(
  id: symbol,
  symbol: symbol,
  market: Market.b3,
  assetClass: AssetClass.stockBr,
  name: symbol,
  currency: currency,
  country: 'BR',
  priceSource: PriceSource.market,
);

/// Posição com custo [cost] e, com [price], avaliada a esse preço.
ValuedPosition _pos(
  String symbol,
  String qty,
  String cost, {
  String? price,
  String account = 'conta',
  String realized = '0',
  String income = '0',
  String currency = 'BRL',
  MarketPrice? market,
}) {
  final p = Position(
    accountId: account,
    assetId: symbol,
    currency: currency,
    quantity: d(qty),
    totalCost: d(cost),
    realizedPnl: d(realized),
    incomeGross: d(income),
    incomeNet: d(income),
    lastOperationDate: LocalDate(2026, 1, 2),
  );
  final unit = price == null ? null : d(price);
  return ValuedPosition(
    position: p,
    asset: _asset(symbol, currency: currency),
    unitPrice: unit,
    marketValue: !p.isOpen
        ? Decimal.zero
        : unit == null
        ? null
        : p.quantity * unit,
    valuationDate: unit == null ? null : LocalDate(2026, 10, 22),
    marketPrice: market,
  );
}

PriceBar _close(String date, String close) => PriceBar(
  symbol: 'BBAS3',
  market: 'B3',
  refDate: LocalDate.parse(date),
  close: d(close),
  currency: 'BRL',
  source: 'b3_cotahist',
  dataType: MarketDataType.close,
  collectedAt: '2026-10-22T12:00:00.000Z',
);

void main() {
  test('ordem: valor da posição decrescente; sem cotação, pelo total '
      'aplicado; zero cotas no fim', () {
    final list = Holdings.build([
      _pos('AAAA3', '10', '100', price: '12'), // 120
      _pos('BBBB3', '100', '2500', price: '23.92'), // 2392
      _pos('CCCC3', '5', '500'), // sem cotação: 500 aplicado
      _pos('DDDD3', '0', '0', realized: '30'), // vendida
      _pos('EEEE3', '50', '900', price: '20'), // 1000
    ]);
    expect(
      [for (final h in list) h.asset!.symbol],
      ['BBBB3', 'EEEE3', 'CCCC3', 'AAAA3', 'DDDD3'],
    );
    expect(list.last.isOpen, isFalse);
    expect(list[2].marketValue, isNull);
  });

  test('valorização = (cotação − PM) ÷ PM; lucro = não realizado + '
      'realizado; % da carteira', () {
    final list = Holdings.build([
      _pos('BBAS3', '100', '2500', price: '23.92', realized: '40'),
      _pos('PETR4', '10', '300', price: '40', income: '12.5'),
    ]);
    final bbas = list.firstWhere((h) => h.assetId == 'BBAS3');
    expect(bbas.averagePrice, d('25'));
    expect(bbas.appreciation, d('-0.0432'));
    expect(bbas.unrealizedPnl, d('-108'));
    expect(bbas.profit, d('-68'));
    expect(
      Holdings.shareOf(bbas, list),
      DecimalMath.divide(d('2392'), d('2792')),
    );
    final petr = list.firstWhere((h) => h.assetId == 'PETR4');
    expect(petr.incomeNet, d('12.5'));
  });

  test('soma as contas; uma conta sem preço deixa o valor indisponível', () {
    final list = Holdings.build([
      _pos('BBAS3', '100', '2500', price: '24', account: 'a'),
      _pos('BBAS3', '50', '1300', price: '24', account: 'b'),
    ]);
    final h = list.single;
    expect(h.quantity, d('150'));
    expect(h.totalCost, d('3800'));
    expect(h.marketValue, d('3600'));
    final partial = Holdings.build([
      _pos('BBAS3', '100', '2500', price: '24', account: 'a'),
      _pos('BBAS3', '50', '1300', account: 'b'),
    ]).single;
    expect(partial.marketValue, isNull);
  });

  test('outras moedas ordenam pelo valor em reais quando há câmbio', () {
    final list = Holdings.build(
      [
        _pos('AAPL', '10', '1000', price: '100', currency: 'USD'), // 1000 USD
        _pos('BBAS3', '100', '2500', price: '30'), // 3000 BRL
      ],
      toBrl: {'USD': d('5')},
    );
    expect(list.first.assetId, 'AAPL');
  });

  test('variação do dia e do mês pelos fechamentos guardados; sem '
      'fechamento anterior, indisponível', () {
    final quote = MarketPrice(
      assetId: 'BBAS3',
      price: d('23.92'),
      currency: 'BRL',
      refDate: LocalDate(2026, 10, 22),
      source: 'brapi',
      dataType: MarketDataType.intraday,
      collectedAt: '2026-10-22T20:45:00.000Z',
    );
    final priced = MarketPricing.withReferences(quote, [
      _close('2026-09-29', '22.00'),
      _close('2026-09-30', '22.50'),
      _close('2026-10-20', '23.80'),
      _close('2026-10-21', '24.10'),
      _close('2026-10-22', '23.92'),
    ]);
    expect(priced.previousClose!.refDate, LocalDate(2026, 10, 21));
    expect(priced.dayChange!.perUnit, d('-0.18'));
    expect(
      priced.dayChange!.fraction,
      DecimalMath.divide(d('-0.18'), d('24.10')),
    );
    expect(priced.previousMonthClose!.refDate, LocalDate(2026, 9, 30));
    expect(priced.monthChange!.perUnit, d('1.42'));

    final h = Holdings.build([
      _pos('BBAS3', '100', '2500', price: '23.92', market: priced),
    ]).single;
    expect(h.dayChangeAmount, d('-18'));

    final alone = MarketPricing.withReferences(quote, const []);
    expect(alone.dayChange, isNull);
    expect(
      Holdings.build([
        _pos('BBAS3', '100', '2500', price: '23.92', market: alone),
      ]).single.dayChangeAmount,
      isNull,
    );
  });
}
