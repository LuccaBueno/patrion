import 'package:decimal/decimal.dart';

import '../../core/money/decimal_math.dart';

/// Compra ou venda pelo valor total (M-13; `FORMULAS.md` §14): quem compra
/// cripto sabe quanto pagou, não o preço unitário.
abstract final class TradeTotal {
  /// Casas de uma quantidade de cripto (satoshi).
  static const cryptoDecimals = 8;

  /// Casas do preço unitário calculado.
  static const priceScale = 12;

  static const tooLow = 'O valor total precisa ser maior que os custos.';

  static String label({bool sell = false}) =>
      sell ? 'Valor total recebido' : 'Valor total pago';

  /// Valor bruto da operação. Na compra, o total pago já inclui os custos;
  /// na venda, o total recebido já os descontou.
  static Decimal gross(Decimal total, Decimal? fees, {bool sell = false}) {
    final charges = fees ?? Decimal.zero;
    return sell ? total + charges : total - charges;
  }

  /// Preço unitário de [gross] dividido por [quantity].
  static Decimal unitPrice(Decimal gross, Decimal quantity) =>
      DecimalMath.divide(gross, quantity, scale: priceScale);
}
