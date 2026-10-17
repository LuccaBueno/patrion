import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/time/local_date.dart';
import '../../domain/portfolio/operation_validator.dart';
import '../format/formatters.dart';
import '../theme/app_theme.dart';

/// Estrutura de uma tela: título, ações à direita e conteúdo.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.title,
    required this.child,
    this.actions = const [],
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        if (subtitle != null)
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (actions.isEmpty) return heading;
              // Em janelas estreitas, as ações vão para baixo do título.
              if (constraints.maxWidth < 900) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: heading),
                  for (final a in actions)
                    Padding(padding: const EdgeInsets.only(left: 8), child: a),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Mostra carregando, erro ou o conteúdo de um [AsyncValue].
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({required this.value, required this.builder, super.key});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => Center(
        child: MessageCard(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar os dados',
          message: errorMessage(error),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Cartão de mensagem (estado vazio, aviso ou erro).
class MessageCard extends StatelessWidget {
  const MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 16),
                      action!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Texto "indisponível" para dados ausentes (regra 1).
class UnavailableText extends StatelessWidget {
  const UnavailableText({this.tooltip, super.key});

  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      'indisponível',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
    return tooltip == null ? text : Tooltip(message: tooltip, child: text);
  }
}

/// Ganho ou perda: cor, sinal e ícone (a cor nunca é o único indicador).
class PnlText extends StatelessWidget {
  const PnlText({
    required this.value,
    required this.text,
    this.style,
    super.key,
  });

  final Decimal value;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium;
    final (color, icon, label) = value > Decimal.zero
        ? (colors.gain, Icons.arrow_upward, 'Ganho')
        : value < Decimal.zero
        ? (colors.loss, Icons.arrow_downward, 'Perda')
        : (theme.colorScheme.onSurfaceVariant, Icons.remove, 'Sem variação');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (base?.fontSize ?? 14) + 2,
          color: color,
          semanticLabel: label,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(text, style: base?.copyWith(color: color)),
        ),
      ],
    );
  }
}

/// Tabela larga dentro de um cartão, com rolagem horizontal quando a janela
/// for estreita.
class TableCard extends StatelessWidget {
  const TableCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Mensagem amigável de um erro.
String errorMessage(Object error) => switch (error) {
  ValidationFailure(:final message) => message,
  AppError(:final message) => message,
  _ => 'Erro inesperado. Detalhes no log.',
};

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage(error)), showCloseIcon: true),
  );
}

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Pergunta antes de uma ação; devolve `true` se o usuário confirmar.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Campo numérico em pt-BR (`1.234,56`), lido sem ponto flutuante.
class DecimalField extends StatelessWidget {
  const DecimalField({
    required this.controller,
    required this.label,
    this.required = false,
    this.allowNegative = false,
    this.helper,
    this.suffix,
    this.fieldKey,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final bool allowNegative;
  final String? helper;
  final String? suffix;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helper,
        suffixText: suffix,
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(allowNegative ? r'[-0-9.,]' : r'[0-9.,]'),
        ),
      ],
      validator: (text) {
        try {
          final value = Fmt.parseDecimal(text ?? '');
          if (value == null) return required ? 'Obrigatório' : null;
          if (!allowNegative && value < Decimal.zero) return 'Não negativo';
          return null;
        } on FormatException {
          return 'Número inválido';
        }
      },
    );
  }
}

/// Lê um [DecimalField] já validado.
Decimal? decimalOf(TextEditingController c) => Fmt.parseDecimal(c.text);

/// Campo de data (`dd/mm/aaaa`) com botão de calendário.
class DateField extends StatelessWidget {
  const DateField({
    required this.controller,
    required this.label,
    this.required = true,
    this.fieldKey,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: 'dd/mm/aaaa',
        suffixIcon: IconButton(
          tooltip: 'Escolher no calendário',
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: () async {
            LocalDate? current;
            try {
              current = Fmt.parseDate(controller.text);
            } on FormatException {
              current = null;
            }
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: current == null
                  ? now
                  : DateTime(current.year, current.month, current.day),
              firstDate: DateTime(1970),
              lastDate: DateTime(now.year + 50),
            );
            if (picked != null) {
              controller.text = Fmt.date(LocalDate.fromDateTime(picked));
            }
          },
        ),
      ),
      validator: (text) {
        if ((text ?? '').trim().isEmpty) return required ? 'Obrigatório' : null;
        try {
          Fmt.parseDate(text!);
          return null;
        } on FormatException {
          return 'Data inválida';
        }
      },
    );
  }
}

/// Lê um [DateField] já validado (nulo se vazio).
LocalDate? dateOf(TextEditingController c) =>
    c.text.trim().isEmpty ? null : Fmt.parseDate(c.text);

/// Texto opcional: vazio vira `null`.
String? textOrNull(TextEditingController c) {
  final t = c.text.trim();
  return t.isEmpty ? null : t;
}

/// Caixa de diálogo de formulário com Cancelar/Salvar.
class FormDialog extends StatelessWidget {
  const FormDialog({
    required this.title,
    required this.formKey,
    required this.onSave,
    required this.children,
    this.width = 560,
    this.saving = false,
    super.key,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final List<Widget> children;
  final double width;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: width,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in children)
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving ? null : onSave,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Lista suspensa de um formulário.
class Choice<T> extends StatelessWidget {
  const Choice({
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.required = true,
    this.fieldKey,
    super.key,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool required;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: required ? '$label *' : label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(labelOf(item))),
      ],
      onChanged: onChanged,
      validator: (v) => required && v == null ? 'Obrigatório' : null,
    );
  }
}
