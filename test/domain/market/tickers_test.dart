import 'package:flutter_test/flutter_test.dart';
import 'package:patrion/domain/market/tickers.dart';
import 'package:patrion/domain/portfolio/codes.dart';

void main() {
  test('ticker em maiúsculas, sem espaços; fracionário vira o lote padrão', () {
    expect(Tickers.normalize(' bbas3 '), 'BBAS3');
    expect(Tickers.normalize('bbas3f'), 'BBAS3');
    expect(Tickers.normalize('TAEE11F'), 'TAEE11');
    expect(Tickers.normalize('hglg11'), 'HGLG11');
    // "F" que não é do fracionário fica.
    expect(Tickers.normalize('ABCF'), 'ABCF');
    expect(Tickers.normalize('aapl', market: Market.nasdaq), 'AAPL');
    expect(
      Tickers.normalize('btc', market: Market.crypto),
      'BTC',
      reason: 'fracionário só na B3',
    );
  });

  test('códigos próprios (Tesouro, manual) ficam como digitados', () {
    expect(
      Tickers.normalize(' CDB Inter 2027 ', market: Market.manual),
      'CDB Inter 2027',
    );
    expect(
      Tickers.normalize('Tesouro IPCA+ 2035', market: Market.tesouro),
      'Tesouro IPCA+ 2035',
    );
  });
}
