import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/operation_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/operation_type.dart';
import '../../format/formatters.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Compra ou venda rápida de um ativo já cadastrado (painel da Carteira,
/// M-05): pede só conta, quantidade, preço, data e custos opcionais.
Future<void> showTradeDialog(
  BuildContext context,
  PortfolioSnapshot snap,
  Asset asset, {
  required bool sell,
}) => showDialog<void>(
  context: context,
  builder: (_) => _TradeDialog(snap: snap, asset: asset, sell: sell),
);

class _TradeDialog extends ConsumerStatefulWidget {
  const _TradeDialog({
    required this.snap,
    required this.asset,
    required this.sell,
  });

  final PortfolioSnapshot snap;
  final Asset asset;
  final bool sell;

  @override
  ConsumerState<_TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends ConsumerState<_TradeDialog> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _fees = TextEditingController();
  final _date = TextEditingController(
    text: Fmt.date(LocalDate.fromDateTime(DateTime.now())),
  );
  late String? _accountId = _defaultAccount();
  bool _saving = false;

  /// Quantidade do ativo em cada conta.
  Map<String, Decimal> get _held => {
    for (final p in widget.snap.state.positions)
      if (p.assetId == widget.asset.id && p.quantity > Decimal.zero)
        p.accountId: p.quantity,
  };

  /// Venda: a conta com mais cotas. Compra: a conta onde o ativo está; senão
  /// a da operação mais recente; senão a única.
  String? _defaultAccount() {
    final held = _held;
    if (held.isNotEmpty) {
      return (held.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;
    }
    if (widget.sell) return null;
    for (final op in widget.snap.operations) {
      final account = widget.snap.accounts[op.accountId];
      if (account != null && !account.archived) return account.id;
    }
    final active = widget.snap.accounts.values.where((a) => !a.archived);
    return active.length == 1 ? active.single.id : null;
  }

  @override
  void dispose() {
    for (final c in [_quantity, _price, _fees, _date]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save({bool allowDuplicate = false}) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final draft = OperationDraft(
      accountId: _accountId!,
      assetId: widget.asset.id,
      type: widget.sell ? OperationType.sell : OperationType.buy,
      tradeDate: dateOf(_date)!,
      currency: widget.asset.currency,
      quantity: decimalOf(_quantity),
      unitPrice: decimalOf(_price),
      fees: decimalOf(_fees),
    );
    try {
      final outcome = await ref
          .read(operationServiceProvider)
          .save(draft, allowDuplicate: allowDuplicate);
      if (!mounted) return;
      switch (outcome) {
        case Saved():
          final messenger = ScaffoldMessenger.of(context);
          Navigator.pop(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '${widget.sell ? 'Venda' : 'Compra'} de '
                '${Fmt.number(draft.quantity!)} ${widget.asset.symbol} '
                'registrada.',
              ),
            ),
          );
        case PossibleDuplicate():
          setState(() => _saving = false);
          final again = await confirm(
            context,
            title: 'Possível duplicata',
            message:
                'Já existe uma operação igual nesta data e conta. Gravar '
                'mesmo assim?',
            confirmLabel: 'Gravar mesmo assim',
          );
          if (again) await _save(allowDuplicate: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snap = widget.snap;
    final held = _held;
    final accounts = [
      for (final a in snap.accounts.values)
        if (widget.sell ? held.containsKey(a.id) : !a.archived) a.id,
    ]..sort((a, b) => snap.accountLabel(a).compareTo(snap.accountLabel(b)));
    final available = _accountId == null ? null : held[_accountId];
    final currency = widget.asset.currency;
    return FormDialog(
      title: '${widget.sell ? 'Vender' : 'Comprar'} ${widget.asset.symbol}',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 520,
      children: [
        Choice<String>(
          fieldKey: const Key('trade-account'),
          label: 'Conta',
          value: _accountId,
          items: accounts,
          labelOf: snap.accountLabel,
          onChanged: (v) => setState(() => _accountId = v),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecimalField(
                fieldKey: const Key('trade-quantity'),
                controller: _quantity,
                label: 'Quantidade',
                required: true,
                helper: widget.sell && available != null
                    ? 'Disponível: ${Fmt.number(available)}'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecimalField(
                fieldKey: const Key('trade-price'),
                controller: _price,
                label: 'Preço unitário',
                required: true,
                suffix: currency,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DateField(
                fieldKey: const Key('trade-date'),
                controller: _date,
                label: 'Data',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecimalField(
                fieldKey: const Key('trade-fees'),
                controller: _fees,
                label: 'Custos (opcional)',
                suffix: currency,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
