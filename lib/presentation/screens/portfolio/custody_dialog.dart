import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/operation_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'broker_field.dart';

/// Transferência de custódia (M-06): leva cotas de uma corretora para
/// outra, mantendo o custo e o preço médio (`FORMULAS.md` §1.3).
Future<void> showCustodyDialog(
  BuildContext context,
  PortfolioSnapshot snap,
  Asset asset,
) => showDialog<void>(
  context: context,
  builder: (_) => _CustodyDialog(snap: snap, asset: asset),
);

class _CustodyDialog extends ConsumerStatefulWidget {
  const _CustodyDialog({required this.snap, required this.asset});

  final PortfolioSnapshot snap;
  final Asset asset;

  @override
  ConsumerState<_CustodyDialog> createState() => _CustodyDialogState();
}

class _CustodyDialogState extends ConsumerState<_CustodyDialog> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _date = TextEditingController(
    text: Fmt.date(LocalDate.fromDateTime(DateTime.now())),
  );
  final _to = TextEditingController();
  bool _saving = false;

  Map<String, Decimal> get _held => {
    for (final p in widget.snap.state.positions)
      if (p.assetId == widget.asset.id && p.quantity > Decimal.zero)
        p.accountId: p.quantity,
  };

  late final _fromOptions = Brokers.options(
    widget.snap,
    only: _held.keys.toSet(),
  );
  late final _from = TextEditingController(
    text: Brokers.labelOf(_fromOptions, _largest()) ?? '',
  );
  late final _toOptions = Brokers.options(widget.snap);

  String? _largest() {
    final held = _held.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return held.isEmpty ? null : held.first.key;
  }

  @override
  void initState() {
    super.initState();
    final from = Brokers.match(_fromOptions, _from.text);
    if (from != null) _quantity.text = Fmt.number(_held[from]!);
  }

  @override
  void dispose() {
    for (final c in [_quantity, _date, _to, _from]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final from = Brokers.match(_fromOptions, _from.text)!;
    setState(() => _saving = true);
    try {
      final to = await Brokers.resolve(
        ref.read(registryServiceProvider),
        _toOptions,
        _to.text,
      );
      if (to == from) {
        throw const FormatException('Escolha outra corretora de destino.');
      }
      await ref
          .read(operationServiceProvider)
          .saveTransfer(
            TransferInput(
              fromAccountId: from,
              toAccountId: to,
              date: dateOf(_date)!,
              currency: widget.asset.currency,
              assetId: widget.asset.id,
              quantity: decimalOf(_quantity),
              notes: 'Transferência de custódia',
            ),
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Transferência de ${_quantity.text} ${widget.asset.symbol} '
            'registrada. O preço médio foi mantido.',
          ),
        ),
      );
    } on FormatException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showError(context, e.message);
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
    final from = Brokers.match(_fromOptions, _from.text);
    final available = from == null ? null : _held[from];
    return FormDialog(
      title: 'Transferir ${widget.asset.symbol} de corretora',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 520,
      children: [
        BrokerField(
          fieldKey: const Key('custody-from'),
          label: 'De (corretora de origem)',
          controller: _from,
          options: _fromOptions,
          allowNew: false,
          onChanged: (_) => setState(() {}),
        ),
        BrokerField(
          fieldKey: const Key('custody-to'),
          label: 'Para (corretora de destino)',
          controller: _to,
          options: _toOptions,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecimalField(
                fieldKey: const Key('custody-quantity'),
                controller: _quantity,
                label: 'Quantidade',
                required: true,
                helper: available == null
                    ? null
                    : 'Na origem: ${Fmt.number(available)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateField(
                fieldKey: const Key('custody-date'),
                controller: _date,
                label: 'Data',
              ),
            ),
          ],
        ),
        Text(
          'A posição muda de corretora com o mesmo custo e o mesmo preço '
          'médio: não é venda nem compra, e não gera lucro.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
