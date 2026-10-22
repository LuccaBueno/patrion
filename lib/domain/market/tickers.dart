import '../portfolio/codes.dart';

/// Códigos de negociação (tickers).
abstract final class Tickers {
  static final _b3Fractional = RegExp(r'^([A-Z0-9]{4}\d{1,2})F$');
  static final _spaces = RegExp(r'\s+');

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

  /// Classes que o cadastro rápido da B3 atende (M-01).
  static const b3QuickClasses = [
    AssetClass.stockBr,
    AssetClass.fii,
    AssetClass.etfBr,
    AssetClass.bdr,
  ];
}
