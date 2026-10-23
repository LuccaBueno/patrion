import 'package:flutter/material.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../application/portfolio/registry_service.dart';
import '../../../domain/portfolio/entities.dart';

/// Uma conta oferecida no campo "Corretora / custodiante".
class BrokerOption {
  const BrokerOption(this.accountId, this.label);

  final String accountId;

  /// O nome da corretora; com mais de uma conta ativa nela, "XP · Conta".
  final String label;
}

/// Corretoras e contas (M-06; DECISIONS D-52).
abstract final class Brokers {
  /// Contas ativas como opções, em ordem alfabética. [only] restringe às
  /// contas informadas (a venda só oferece onde há o ativo).
  static List<BrokerOption> options(
    PortfolioSnapshot snap, {
    Set<String>? only,
  }) {
    final active = [
      for (final a in snap.accounts.values)
        if (!a.archived && (only == null || only.contains(a.id))) a,
    ];
    final perInstitution = <String, int>{};
    for (final a in snap.accounts.values) {
      if (a.archived) continue;
      perInstitution[a.institutionId] =
          (perInstitution[a.institutionId] ?? 0) + 1;
    }
    return [
      for (final a in active)
        BrokerOption(
          a.id,
          (perInstitution[a.institutionId] ?? 0) > 1
              ? snap.accountLabel(a.id)
              : snap.institutions[a.institutionId]?.name ??
                    snap.accountLabel(a.id),
        ),
    ]..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }

  /// A conta da operação mais recente; senão, a única ativa.
  static String? lastUsed(PortfolioSnapshot snap, {Set<String>? only}) {
    for (final op in snap.operations) {
      final account = snap.accounts[op.accountId];
      if (account == null || account.archived) continue;
      if (only != null && !only.contains(account.id)) continue;
      return account.id;
    }
    final active = [
      for (final a in snap.accounts.values)
        if (!a.archived && (only == null || only.contains(a.id))) a,
    ];
    return active.length == 1 ? active.single.id : null;
  }

  static String? labelOf(List<BrokerOption> options, String? accountId) {
    for (final o in options) {
      if (o.accountId == accountId) return o.label;
    }
    return null;
  }

  /// A conta escolhida pelo texto digitado; nulo se for uma corretora nova
  /// (ou digitada de outro jeito: o serviço acha pelo nome ao salvar).
  static String? match(List<BrokerOption> options, String text) {
    final key = normalizeNameKey(text);
    for (final o in options) {
      if (normalizeNameKey(o.label) == key) return o.accountId;
    }
    return null;
  }

  /// A conta do texto: a escolhida na lista ou a da corretora com esse nome
  /// (criada se for nova).
  static Future<String> resolve(
    RegistryService registry,
    List<BrokerOption> options,
    String text,
  ) async => match(options, text) ?? await registry.accountForBroker(text);
}

/// Campo "Corretora / custodiante": escolhe uma das corretoras usadas ou
/// aceita um nome novo, criado ao salvar ("XP · Principal").
class BrokerField extends StatefulWidget {
  const BrokerField({
    required this.controller,
    required this.options,
    this.fieldKey,
    this.allowNew = true,
    this.onChanged,
    this.label = 'Corretora / custodiante',
    super.key,
  });

  final TextEditingController controller;
  final List<BrokerOption> options;
  final Key? fieldKey;

  /// A venda não aceita corretora nova (só onde o ativo está).
  final bool allowNew;
  final ValueChanged<String>? onChanged;

  /// Rótulo do campo (sem o asterisco de obrigatório).
  final String label;

  @override
  State<BrokerField> createState() => _BrokerFieldState();
}

class _BrokerFieldState extends State<BrokerField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final allowNew = widget.allowNew;
    final onChanged = widget.onChanged;
    return RawAutocomplete<BrokerOption>(
      textEditingController: widget.controller,
      focusNode: _focus,
      displayStringForOption: (o) => o.label,
      optionsBuilder: (value) {
        final text = value.text.trim().toLowerCase();
        // Com uma corretora já escolhida, mostra todas ao abrir.
        if (text.isEmpty || Brokers.match(options, value.text) != null) {
          return options;
        }
        return options.where((o) => o.label.toLowerCase().contains(text));
      },
      onSelected: (o) => onChanged?.call(o.label),
      fieldViewBuilder: (context, textController, focusNode, onSubmit) =>
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, _) {
              final text = value.text.trim();
              final isNew =
                  text.isNotEmpty && Brokers.match(options, text) == null;
              return TextFormField(
                key: widget.fieldKey,
                controller: textController,
                focusNode: focusNode,
                onChanged: onChanged,
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: '${widget.label} *',
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  helperText: isNew && allowNew
                      ? 'Nova: cria "$text · ${RegistryService.defaultAccountName}" '
                            'ao salvar.'
                      : options.isEmpty
                      ? 'Digite o nome (ex.: Nubank, XP).'
                      : null,
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Obrigatório';
                  if (!allowNew && Brokers.match(options, t) == null) {
                    return 'Escolha uma corretora onde o ativo está.';
                  }
                  return null;
                },
              );
            },
          ),
      optionsViewBuilder: (context, onSelected, list) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final o in list)
                  ListTile(
                    key: Key('broker-option-${o.label}'),
                    dense: true,
                    title: Text(o.label),
                    onTap: () => onSelected(o),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
