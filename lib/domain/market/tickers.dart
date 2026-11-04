import '../portfolio/codes.dart';

/// Códigos de negociação (tickers).
abstract final class Tickers {
  static final _b3Fractional = RegExp(r'^([A-Z0-9]{4}\d{1,2})F$');
  static final _spaces = RegExp(r'\s+');
  static final _b3Shape = RegExp(r'^[A-Z0-9]{4}\d{1,2}F?$');

  /// Criptomoedas comuns, com o identificador da CoinGecko.
  static const cryptoIds = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'USDT': 'tether',
    'USDC': 'usd-coin',
    'BNB': 'binancecoin',
    'SOL': 'solana',
    'XRP': 'ripple',
    'ADA': 'cardano',
    'DOGE': 'dogecoin',
    'TRX': 'tron',
  };

  /// Tem a forma de um código da B3 (quatro caracteres e o número do papel:
  /// BBAS3, HGLG11, BBAS3F). Códigos de cripto não têm (BTC, ETH, SOL).
  static bool looksLikeB3(String symbol) => _b3Shape.hasMatch(symbol);

  /// Mercados em que o código é um ticker (maiúsculo, sem espaços). Nos
  /// outros (Tesouro, manual), o código é do usuário e fica como digitado.
  static bool isTickerMarket(Market market) => switch (market) {
    Market.b3 ||
    Market.nyse ||
    Market.nasdaq ||
    Market.crypto ||
    Market.otc => true,
    Market.tesouro || Market.manual => false,
  };

  /// "bbas3 " vira "BBAS3". Na B3, o código do fracionário ("BBAS3F") vira
  /// o do lote padrão ("BBAS3"): é o mesmo papel.
  static String normalize(String text, {Market market = Market.b3}) {
    if (!isTickerMarket(market)) return text.trim();
    final t = text.trim().toUpperCase().replaceAll(_spaces, '');
    if (market != Market.b3) return t;
    final m = _b3Fractional.firstMatch(t);
    return m == null ? t : m.group(1)!;
  }

  /// Classes que o cadastro rápido atende (M-01 e M-13).
  static const quickClasses = [
    AssetClass.stockBr,
    AssetClass.fii,
    AssetClass.etfBr,
    AssetClass.bdr,
    AssetClass.crypto,
  ];
}
