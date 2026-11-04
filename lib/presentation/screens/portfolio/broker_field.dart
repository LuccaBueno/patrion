import 'package:flutter/material.dart';

import '../../../application/portfolio/portfolio_query.dart';
import '../../../application/portfolio/registry_service.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/labels.dart';
import '../../widgets/common.dart';

/// Uma conta oferecida no campo "Corretora / custodiante".
class BrokerOption {
  const BrokerOption(this.accountId, this.label, this.kind);

  final String accountId;

  /// O nome da corretora; com mais de uma conta ativa nela, "XP · Conta".
  final String label;
  final CustodyKind kind;
}

/// Corretoras e contas (M-06; DECISIONS D-52).
abstract final class Brokers {
  /// Contas ativas como opções, em ordem alfabética. [only] restringe às
  /// contas informadas (a venda só oferece onde há o ativo). Com [crypto],
  /// exchanges e autocustódia vêm primeiro (M-13).
  static List<BrokerOption> options(
    PortfolioSnapshot snap, {
    Set<String>? only,
    bool crypto = false,
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
          snap.custodyOf(a.id),
        ),
    ]..sort((a, b) {
      if (crypto && a.kind.forCrypto != b.kind.forCrypto) {
        return a.kind.forCrypto ? -1 : 1;
      }
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
  }

  /// A conta da operação mais recente; senão, a única ativa. Com [crypto],
  /// só exchanges e autocustódia: a cripto não vai para a corretora de ações
  /// sem o usuário escolher (M-13).
  static String? lastUsed(
    PortfolioSnapshot snap, {
    Set<String>? only,
    bool crypto = false,
  }) {
    bool fits(Account a) =>
        !a.archived &&
        (only == null || only.contains(a.id)) &&
        (!crypto || snap.custodyOf(a.id).forCrypto);
    for (final op in snap.operations) {
      final account = snap.accounts[op.accountId];
      if (account != null && fits(account)) return account.id;
    }
    final active = snap.accounts.values.where(fits).toList();
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
  /// (criada do tipo [kind], se for nova).
  static Future<String> resolve(
    RegistryService registry,
    List<BrokerOption> options,
    String text, {
    CustodyKind kind = CustodyKind.broker,
  }) async =>
      match(options, text) ?? await registry.accountForBroker(text, kind: kind);
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
    this.kind = CustodyKind.broker,
    this.onKindChanged,
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

  /// Tipo do custodiante novo, escolhido ao digitar um nome novo (M-13).
  final CustodyKind kind;
  final ValueChanged<CustodyKind>? onKindChanged;

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
    final onKindChanged = widget.onKindChanged;
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
              final field = TextFormField(
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
              // Sempre a mesma coluna: se o campo mudasse de lugar na árvore,
              // perderia o foco ao aparecer o tipo, na primeira letra digitada.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field,
                  if (isNew && allowNew && onKindChanged != null) ...[
                    const SizedBox(height: 12),
                    Choice<CustodyKind>(
                      // Recria o campo quando o tipo sugerido muda.
                      key: ValueKey(widget.kind),
                      fieldKey: const Key('custody-kind'),
                      label: 'Tipo do custodiante',
                      value: widget.kind,
                      items: CustodyKind.values,
                      labelOf: (k) => k.label,
                      onChanged: (k) {
                        if (k != null) onKindChanged(k);
                      },
                    ),
                  ],
                ],
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
                    subtitle: Text(o.kind.label),
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
