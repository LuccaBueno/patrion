import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'common.dart';

/// Cartão de um número com rótulo, nota e, opcionalmente, ganho ou perda e a
/// metodologia num ícone (Painel e Desempenho).
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.note,
    this.big = false,
    this.pnl,
    this.info,
    this.unavailableReason,
    this.footer,
    super.key,
  });

  final String label;

  /// Linha extra embaixo da nota (a variação do dia, no patrimônio).
  final Widget? footer;

  /// Nulo mostra "indisponível" com [unavailableReason].
  final String? value;
  final String note;

  /// Quando informado, o valor é mostrado como ganho ou perda.
  final Decimal? pnl;

  /// Explicação da metodologia, num ícone com tooltip ao lado do rótulo.
  final String? info;
  final String? unavailableReason;

  /// Destaque do topo (M-04): maior e mais largo.
  final bool big;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = big
        ? theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.titleLarge;
    final muted = theme.colorScheme.onSurfaceVariant;
    final Widget valueWidget;
    if (value == null) {
      valueWidget = UnavailableText(tooltip: unavailableReason);
    } else {
      // O valor nunca quebra linha: se não couber, a fonte diminui.
      valueWidget = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: pnl == null
            ? Text(value!, maxLines: 1, softWrap: false, style: style)
            : PnlText(
                value: pnl!,
                text: value!,
                style: style,
                singleLine: true,
              ),
      );
    }
    return SizedBox(
      width: big ? null : 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(color: muted),
                    ),
                  ),
                  if (info != null) ...[
                    const SizedBox(width: 4),
                    Tooltip(
                      message: info,
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: muted,
                        semanticLabel: 'Sobre a métrica',
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: valueWidget,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              if (footer != null) ...[const SizedBox(height: 6), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
