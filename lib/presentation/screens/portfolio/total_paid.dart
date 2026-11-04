import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../domain/portfolio/trade_total.dart';
import '../../format/formatters.dart';

/// Liga "Informar valor total pago" no lugar do preço unitário (M-13).
class UseTotalSwitch extends StatelessWidget {
  const UseTotalSwitch({
    required this.value,
    required this.onChanged,
    this.sell = false,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool sell;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('Informar ${TradeTotal.label(sell: sell).toLowerCase()}'),
    subtitle: const Text('O app calcula o preço unitário.'),
    value: value,
    onChanged: onChanged,
  );
}

/// Preço unitário calculado, visível antes de salvar.
class TotalPreview extends StatelessWidget {
  const TotalPreview({
    required this.quantity,
    required this.total,
    required this.currency,
    this.fees,
    this.sell = false,
    super.key,
  });

  final TextEditingController quantity;
  final TextEditingController total;
  final TextEditingController? fees;
  final String currency;
  final bool sell;

  Decimal? _parse(TextEditingController? c) {
    try {
      return c == null ? null : Fmt.parseDecimal(c.text);
    } on FormatException {
      return null;
    }
  }

  String _text() {
    final q = _parse(quantity);
    final t = _parse(total);
    if (q == null || t == null || q <= Decimal.zero) {
      return 'Preço unitário: informe a quantidade e o valor total.';
    }
    final gross = TradeTotal.gross(t, _parse(fees), sell: sell);
    if (gross <= Decimal.zero) return TradeTotal.tooLow;
    final price = Fmt.unitPrice(TradeTotal.unitPrice(gross, q), currency);
    return 'Preço unitário calculado: $price';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([quantity, total, ?fees]),
      builder: (context, _) => Text(
        _text(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
