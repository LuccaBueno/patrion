import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/domain/market/tickers.dart';
import 'package:patrion/domain/portfolio/codes.dart';
import 'package:patrion/domain/portfolio/entities.dart';
import 'package:patrion/domain/portfolio/trade_total.dart';
import 'package:patrion/presentation/format/formatters.dart';
import 'package:patrion/presentation/format/labels.dart';

Decimal d(String s) => Decimal.parse(s);

Asset asset(String symbol, Market market, AssetClass c, PriceSource s) => Asset(
  id: 'a',
  symbol: symbol,
  market: market,
  assetClass: c,
  name: symbol,
  currency: 'BRL',
  country: 'BR',
  priceSource: s,
);

/// Valor total, unidades e custódia (M-13).
void main() {
  group('valor total', () {
    test('compra: o total pago inclui os custos', () {
      expect(TradeTotal.gross(d('8500'), d('10')), d('8490'));
      expect(TradeTotal.gross(d('8500'), null), d('8500'));
    });

    test('venda: o total recebido já descontou os custos', () {
      expect(TradeTotal.gross(d('8500'), d('10'), sell: true), d('8510'));
    });

    test('preço unitário com 12 casas, sem perder o valor', () {
      final price = TradeTotal.unitPrice(d('8500'), d('0.02111111'));
      expect(price.scale, lessThanOrEqualTo(12));
      expect(price.round(scale: 2), d('402631.6'));
      expect((price * d('0.02111111')).round(scale: 2), d('8500'));
      // Muitas unidades de uma moeda barata: o erro continua abaixo de 1 centavo.
      final cheap = TradeTotal.unitPrice(d('100'), d('1000000000'));
      expect((cheap * d('1000000000')).round(scale: 2), d('100'));
    });
  });

  group('quantidade', () {
    test('8 casas sem arredondar, com vírgula ou ponto', () {
      expect(Fmt.parseDecimal('0,02111111'), d('0.02111111'));
      expect(Fmt.parseDecimal('0.02111111'), d('0.02111111'));
      expect(Fmt.number(d('0.02111111')), '0,02111111');
      expect(Fmt.number(d('0.00000001')), '0,00000001');
    });

    test('unidade: o código da cripto; cotas nos outros', () {
      final btc = asset(
        'BTC',
        Market.crypto,
        AssetClass.crypto,
        PriceSource.market,
      );
      final fii = asset(
        'HGLG11',
        Market.b3,
        AssetClass.fii,
        PriceSource.market,
      );
      expect(Units.quantity(d('0.02111111'), btc), '0,02111111 BTC');
      expect(Units.quantity(d('1'), btc), '1 BTC');
      expect(Units.quantity(d('10'), fii), '10 cotas');
      expect(Units.quantity(d('1'), fii), '1 cota');
    });

    test('preço de cripto barata não vira R\$ 0,00', () {
      expect(Fmt.unitPrice(d('0.00012345'), 'BRL'), r'R$ 0,00012345');
      expect(Fmt.unitPrice(d('402631.6'), 'BRL'), r'R$ 402.631,60');
    });
  });

  group('códigos', () {
    test('forma da B3', () {
      for (final s in ['BBAS3', 'HGLG11', 'BBAS3F', 'BOVA11', 'AAPL34']) {
        expect(Tickers.looksLikeB3(s), isTrue, reason: s);
      }
      for (final s in ['BTC', 'ETH', 'SOL', 'DOGE', 'PEPE', '1INCH']) {
        expect(Tickers.looksLikeB3(s), isFalse, reason: s);
      }
    });

    test('precisa de correção: cripto fora do mercado Cripto', () {
      const m = PriceSource.market;
      expect(
        asset('BTC', Market.b3, AssetClass.crypto, m).cryptoNeedsFix,
        isTrue,
      );
      expect(
        asset('BTC', Market.b3, AssetClass.stockBr, m).cryptoNeedsFix,
        isTrue,
      );
      expect(
        asset(
          'BTC',
          Market.crypto,
          AssetClass.crypto,
          PriceSource.manual,
        ).cryptoNeedsFix,
        isTrue,
      );
      expect(
        asset('BTC', Market.crypto, AssetClass.crypto, m).cryptoNeedsFix,
        isFalse,
      );
      expect(
        asset('PETR4', Market.b3, AssetClass.stockBr, m).cryptoNeedsFix,
        isFalse,
      );
    });
  });

  test('tipo do custodiante vem da instituição e da conta', () {
    expect(
      CustodyKind.of(InstitutionKind.other, AccountKind.cryptoWallet),
      CustodyKind.selfCustody,
    );
    expect(
      CustodyKind.of(InstitutionKind.exchange, AccountKind.brokerage),
      CustodyKind.exchange,
    );
    expect(
      CustodyKind.of(InstitutionKind.broker, AccountKind.checking),
      CustodyKind.broker,
    );
    expect(
      CustodyKind.of(InstitutionKind.bank, AccountKind.checking),
      CustodyKind.bank,
    );
    expect(
      CustodyKind.of(InstitutionKind.other, AccountKind.other),
      CustodyKind.other,
    );
    for (final k in CustodyKind.values) {
      expect(CustodyKind.of(k.institution, k.account), k);
    }
  });
}
