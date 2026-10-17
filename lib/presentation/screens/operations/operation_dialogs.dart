import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/portfolio/operation_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../../domain/portfolio/operation_type.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Abre o diálogo certo para criar ou editar [initial]: transferências têm
/// o próprio formulário.
Future<void> showOperationEditor(
  BuildContext context,
  PortfolioSnapshot snap, {
  Operation? initial,
  String? assetId,
}) {
  if (initial != null && initial.type.isTransfer) {
    return showTransferDialog(context, snap, leg: initial);
  }
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _OperationDialog(snap: snap, initial: initial, assetId: assetId),
  );
}

String _text(Decimal? v) => v == null ? '' : Fmt.number(v, maxDecimals: 20);

class _OperationDialog extends ConsumerStatefulWidget {
  const _OperationDialog({required this.snap, this.initial, this.assetId});

  final PortfolioSnapshot snap;
  final Operation? initial;
  final String? assetId;

  @override
  ConsumerState<_OperationDialog> createState() => _OperationDialogState();
}

class _OperationDialogState extends ConsumerState<_OperationDialog> {
  final _form = GlobalKey<FormState>();
  late final Operation? _op = widget.initial;

  late OperationType _type = _op?.type ?? OperationType.buy;
  late String? _accountId = _op?.accountId ?? _defaultAccount();
  late String? _assetId = _op?.assetId ?? widget.assetId;

  late final _date = TextEditingController(
    text: Fmt.date(_op?.tradeDate ?? LocalDate.fromDateTime(DateTime.now())),
  );
  late final _settlement = TextEditingController(
    text: _op?.settlementDate == null ? '' : Fmt.date(_op!.settlementDate!),
  );
  late final _quantity = TextEditingController(text: _text(_op?.quantity));
  late final _price = TextEditingController(text: _text(_op?.unitPrice));
  late final _gross = TextEditingController(text: _text(_op?.grossAmount));
  late final _fees = TextEditingController(
    text: _op == null || _op.fees == Decimal.zero ? '' : _text(_op.fees),
  );
  late final _taxes = TextEditingController(
    text: _op == null || _op.taxes == Decimal.zero ? '' : _text(_op.taxes),
  );
  late final _currency = TextEditingController(
    text: _op?.currency ?? _currencyFor(_assetId, _accountId),
  );
  late final _fx = TextEditingController(text: _text(_op?.fxRate));
  late final _ratioFrom = TextEditingController(text: _text(_op?.ratioFrom));
  late final _ratioTo = TextEditingController(text: _text(_op?.ratioTo));
  late final _justification = TextEditingController(text: _op?.justification);
  late final _notes = TextEditingController(text: _op?.notes);
  bool _saving = false;

  String? _defaultAccount() {
    final active = widget.snap.accounts.values.where((a) => !a.archived);
    return active.length == 1 ? active.first.id : null;
  }

  String _currencyFor(String? assetId, String? accountId) =>
      widget.snap.assets[assetId]?.currency ??
      widget.snap.accounts[accountId]?.currency ??
      'BRL';

  List<TextEditingController> get _controllers => [
    _date,
    _settlement,
    _quantity,
    _price,
    _gross,
    _fees,
    _taxes,
    _currency,
    _fx,
    _ratioFrom,
    _ratioTo,
    _justification,
    _notes,
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Campos que cada tipo usa.
  bool get _usesQuantity =>
      !_type.usesRatio &&
      _type != OperationType.deposit &&
      _type != OperationType.withdrawal &&
      _type != OperationType.amortization &&
      _type != OperationType.maturity &&
      !(_type.group == OperationGroup.cost);

  bool get _usesUnitPrice =>
      _type == OperationType.buy ||
      _type == OperationType.sell ||
      _type == OperationType.reinvestment ||
      _type.isIncome && _type != OperationType.interest;

  bool get _usesGross => !_type.usesRatio;

  bool get _usesCharges =>
      !_type.usesRatio && _type != OperationType.manualAdjustment;

  bool get _adjustment => _type == OperationType.manualAdjustment;

  String get _quantityLabel => switch (_type) {
    OperationType.manualAdjustment => 'Variação de quantidade',
    OperationType.bonusShares => 'Ações recebidas',
    OperationType.dividend ||
    OperationType.jcp ||
    OperationType.fiiIncome ||
    OperationType.interest => 'Quantidade com direito',
    _ => 'Quantidade',
  };

  String get _priceLabel =>
      _type.isIncome ? 'Valor por ação/cota' : 'Preço unitário';

  String get _grossLabel => switch (_type) {
    OperationType.manualAdjustment => 'Variação de custo ou caixa',
    OperationType.bonusShares => 'Custo atribuído',
    OperationType.maturity => 'Valor recebido no vencimento',
    OperationType.buy ||
    OperationType.sell ||
    OperationType.reinvestment => 'Valor total (se diferente de qtd × preço)',
    _ when _type.isIncome => 'Valor bruto total',
    _ => 'Valor',
  };

  Future<void> _save({bool allowDuplicate = false}) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final draft = OperationDraft(
      accountId: _accountId ?? '',
      assetId: _type.assetUse == AssetUse.none ? null : _assetId,
      type: _type,
      tradeDate: dateOf(_date)!,
      settlementDate: dateOf(_settlement),
      quantity: _usesQuantity ? decimalOf(_quantity) : null,
      unitPrice: _usesUnitPrice ? decimalOf(_price) : null,
      grossAmount: _usesGross ? decimalOf(_gross) : null,
      fees: _usesCharges ? decimalOf(_fees) : null,
      taxes: _usesCharges ? decimalOf(_taxes) : null,
      currency: _currency.text.trim().toUpperCase(),
      fxRate: decimalOf(_fx),
      ratioFrom: _type.usesRatio ? decimalOf(_ratioFrom) : null,
      ratioTo: _type.usesRatio ? decimalOf(_ratioTo) : null,
      justification: _adjustment ? textOrNull(_justification) : null,
      notes: textOrNull(_notes),
      relatedOperationId: _op?.relatedOperationId,
      origin: _op?.origin ?? OperationOrigin.manual,
    );
    final service = ref.read(operationServiceProvider);
    try {
      final outcome = await service.save(
        draft,
        id: _op?.id,
        allowDuplicate: allowDuplicate,
      );
      if (!mounted) return;
      switch (outcome) {
        case Saved():
          Navigator.pop(context);
        case PossibleDuplicate(:final matches):
          setState(() => _saving = false);
          final again = await confirm(
            context,
            title: 'Possível duplicata',
            message:
                'Já existe ${matches.length == 1 ? 'uma operação igual' : '${matches.length} operações iguais'} '
                '(${_type.label} em ${Fmt.date(draft.tradeDate)}, mesma '
                'conta, ativo, quantidade e valor). Gravar mesmo assim?',
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
    final accounts =
        snap.accounts.values
            .where((a) => !a.archived || a.id == _accountId)
            .toList()
          ..sort(
            (a, b) =>
                snap.accountLabel(a.id).compareTo(snap.accountLabel(b.id)),
          );
    final assets = snap.assets.values.toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));
    final types = [
      for (final t in OperationType.values)
        if (!t.isTransfer) t,
    ];
    final needsFx = _currency.text.trim().toUpperCase() != 'BRL';

    return FormDialog(
      title: _op == null ? 'Nova operação' : 'Editar operação',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 640,
      children: [
        Row(
          children: [
            Expanded(
              child: Choice<OperationType>(
                fieldKey: const Key('op-type'),
                label: 'Tipo',
                value: _type,
                items: types,
                labelOf: (t) => '${t.label}  ·  ${t.group.label}',
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateField(
                fieldKey: const Key('op-date'),
                controller: _date,
                label: 'Data',
              ),
            ),
          ],
        ),
        Choice<String>(
          fieldKey: const Key('op-account'),
          label: 'Conta',
          value: _accountId,
          items: [for (final a in accounts) a.id],
          labelOf: snap.accountLabel,
          onChanged: (v) => setState(() {
            _accountId = v;
            if (_assetId == null) _currency.text = _currencyFor(null, v);
          }),
        ),
        if (_type.assetUse != AssetUse.none)
          Choice<String>(
            fieldKey: const Key('op-asset'),
            label: _type.assetUse == AssetUse.optional
                ? 'Ativo (opcional)'
                : 'Ativo',
            required: _type.assetUse == AssetUse.required,
            value: _assetId,
            items: [for (final a in assets) a.id],
            labelOf: (id) =>
                '${snap.assets[id]!.symbol} — ${snap.assets[id]!.name}',
            onChanged: (v) => setState(() {
              _assetId = v;
              _currency.text = _currencyFor(v, _accountId);
            }),
          ),
        if (_type.usesRatio)
          Row(
            children: [
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('op-ratio-from'),
                  controller: _ratioFrom,
                  label: 'De',
                  required: true,
                  helper: _type == OperationType.split
                      ? '1 em "1 para 2"'
                      : '10 em "10 para 1"',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('op-ratio-to'),
                  controller: _ratioTo,
                  label: 'Para',
                  required: true,
                  helper: _type == OperationType.split
                      ? '2 em "1 para 2"'
                      : '1 em "10 para 1"',
                ),
              ),
            ],
          ),
        if (_usesQuantity || _usesUnitPrice)
          Row(
            children: [
              if (_usesQuantity)
                Expanded(
                  child: DecimalField(
                    fieldKey: const Key('op-quantity'),
                    controller: _quantity,
                    label: _quantityLabel,
                    required: _type.requiresQuantity,
                    allowNegative: _adjustment,
                  ),
                ),
              if (_usesQuantity && _usesUnitPrice) const SizedBox(width: 12),
              if (_usesUnitPrice)
                Expanded(
                  child: DecimalField(
                    fieldKey: const Key('op-price'),
                    controller: _price,
                    label: _priceLabel,
                  ),
                ),
            ],
          ),
        if (_usesGross)
          DecimalField(
            fieldKey: const Key('op-gross'),
            controller: _gross,
            label: _grossLabel,
            allowNegative: _adjustment,
            helper: _adjustment
                ? 'Com ativo: muda o custo. Sem ativo: muda o caixa da conta.'
                : null,
          ),
        if (_usesCharges)
          Row(
            children: [
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('op-fees'),
                  controller: _fees,
                  label: 'Custos (corretagem, emolumentos)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('op-taxes'),
                  controller: _taxes,
                  label: 'Impostos e retenções',
                ),
              ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _currency,
                decoration: const InputDecoration(labelText: 'Moeda *'),
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{3,10}$').hasMatch(v ?? '')
                    ? null
                    : 'Código inválido',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: needsFx
                  ? DecimalField(
                      controller: _fx,
                      label: 'Câmbio para BRL',
                      helper: 'Opcional',
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateField(
                controller: _settlement,
                label: 'Liquidação',
                required: false,
              ),
            ),
          ],
        ),
        if (_adjustment)
          TextFormField(
            key: const Key('op-justification'),
            controller: _justification,
            decoration: const InputDecoration(labelText: 'Justificativa *'),
            validator: (v) => (v ?? '').trim().isEmpty
                ? 'O ajuste manual precisa de justificativa'
                : null,
          ),
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    );
  }
}

/// Cria uma transferência ou edita a transferência de [leg].
Future<void> showTransferDialog(
  BuildContext context,
  PortfolioSnapshot snap, {
  Operation? leg,
}) => showDialog<void>(
  context: context,
  builder: (_) => _TransferDialog(snap: snap, leg: leg),
);

class _TransferDialog extends ConsumerStatefulWidget {
  const _TransferDialog({required this.snap, this.leg});

  final PortfolioSnapshot snap;
  final Operation? leg;

  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  final _form = GlobalKey<FormState>();
  late final Operation? _out = _legOf(OperationType.transferOut);
  late final Operation? _in = _legOf(OperationType.transferIn);

  late String? _from = _out?.accountId;
  late String? _to = _in?.accountId;
  late bool _ofAsset = widget.leg?.assetId != null;
  late String? _assetId = widget.leg?.assetId;
  late final _date = TextEditingController(
    text: Fmt.date(
      widget.leg?.tradeDate ?? LocalDate.fromDateTime(DateTime.now()),
    ),
  );
  late final _quantity = TextEditingController(text: _text(_out?.quantity));
  late final _amount = TextEditingController(text: _text(_out?.grossAmount));
  late final _fees = TextEditingController(
    text: _out == null || _out.fees == Decimal.zero ? '' : _text(_out.fees),
  );
  late final _currency = TextEditingController(
    text: widget.leg?.currency ?? 'BRL',
  );
  late final _notes = TextEditingController(text: widget.leg?.notes);
  bool _saving = false;

  Operation? _legOf(OperationType type) {
    final leg = widget.leg;
    if (leg == null) return null;
    if (leg.type == type) return leg;
    for (final o in widget.snap.operations) {
      if (o.transferGroupId == leg.transferGroupId && o.type == type) return o;
    }
    return null;
  }

  @override
  void dispose() {
    for (final c in [_date, _quantity, _amount, _fees, _currency, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final input = TransferInput(
      fromAccountId: _from!,
      toAccountId: _to!,
      date: dateOf(_date)!,
      currency: _currency.text.trim().toUpperCase(),
      assetId: _ofAsset ? _assetId : null,
      quantity: _ofAsset ? decimalOf(_quantity) : null,
      amount: _ofAsset ? null : decimalOf(_amount),
      fees: decimalOf(_fees),
      notes: textOrNull(_notes),
    );
    try {
      await ref
          .read(operationServiceProvider)
          .saveTransfer(input, groupId: widget.leg?.transferGroupId);
      if (mounted) Navigator.pop(context);
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
    final accounts = [
      for (final a in snap.accounts.values)
        if (!a.archived || a.id == _from || a.id == _to) a.id,
    ]..sort((a, b) => snap.accountLabel(a).compareTo(snap.accountLabel(b)));
    final assets = snap.assets.values.toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));
    return FormDialog(
      title: widget.leg == null ? 'Nova transferência' : 'Editar transferência',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Dinheiro')),
            ButtonSegment(value: true, label: Text('Ativo (custódia)')),
          ],
          selected: {_ofAsset},
          onSelectionChanged: (s) => setState(() => _ofAsset = s.single),
        ),
        Choice<String>(
          fieldKey: const Key('tr-from'),
          label: 'Conta de origem',
          value: _from,
          items: accounts,
          labelOf: snap.accountLabel,
          onChanged: (v) => setState(() => _from = v),
        ),
        Choice<String>(
          fieldKey: const Key('tr-to'),
          label: 'Conta de destino',
          value: _to,
          items: accounts,
          labelOf: snap.accountLabel,
          onChanged: (v) => setState(() => _to = v),
        ),
        if (_ofAsset)
          Choice<String>(
            label: 'Ativo',
            value: _assetId,
            items: [for (final a in assets) a.id],
            labelOf: (id) => snap.assets[id]!.symbol,
            onChanged: (v) => setState(() {
              _assetId = v;
              _currency.text = snap.assets[v]?.currency ?? _currency.text;
            }),
          ),
        Row(
          children: [
            Expanded(
              child: DateField(controller: _date, label: 'Data'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ofAsset
                  ? DecimalField(
                      controller: _quantity,
                      label: 'Quantidade',
                      required: true,
                    )
                  : DecimalField(
                      fieldKey: const Key('tr-amount'),
                      controller: _amount,
                      label: 'Valor',
                      required: true,
                    ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DecimalField(
                controller: _fees,
                label: 'Custos (na origem)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _currency,
                decoration: const InputDecoration(labelText: 'Moeda *'),
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{3,10}$').hasMatch(v ?? '')
                    ? null
                    : 'Código inválido',
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    );
  }
}

/// Informa o preço unitário ou o saldo de [asset].
Future<void> showValuationDialog(
  BuildContext context,
  PortfolioSnapshot snap,
  Asset asset, {
  ValuationKind? kind,
}) => showDialog<void>(
  context: context,
  builder: (_) => _ValuationDialog(snap: snap, asset: asset, kind: kind),
);

class _ValuationDialog extends ConsumerStatefulWidget {
  const _ValuationDialog({required this.snap, required this.asset, this.kind});

  final PortfolioSnapshot snap;
  final Asset asset;
  final ValuationKind? kind;

  @override
  ConsumerState<_ValuationDialog> createState() => _ValuationDialogState();
}

class _ValuationDialogState extends ConsumerState<_ValuationDialog> {
  final _form = GlobalKey<FormState>();
  late ValuationKind _kind =
      widget.kind ??
      (widget.asset.assetClass.valuedByBalance
          ? ValuationKind.balance
          : ValuationKind.unitPrice);
  String? _accountId;
  final _date = TextEditingController(
    text: Fmt.date(LocalDate.fromDateTime(DateTime.now())),
  );
  final _value = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Contas onde o ativo tem posição aberta vêm primeiro.
    final holding = widget.snap.state.positions.where(
      (p) => p.assetId == widget.asset.id && p.isOpen,
    );
    if (holding.length == 1) _accountId = holding.first.accountId;
  }

  @override
  void dispose() {
    _date.dispose();
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final service = ref.read(valuationServiceProvider);
    try {
      if (_kind == ValuationKind.unitPrice) {
        await service.setUnitPrice(
          assetId: widget.asset.id,
          refDate: dateOf(_date)!,
          price: decimalOf(_value)!,
          notes: textOrNull(_notes),
        );
      } else {
        await service.setBalance(
          assetId: widget.asset.id,
          accountId: _accountId!,
          refDate: dateOf(_date)!,
          balance: decimalOf(_value)!,
          notes: textOrNull(_notes),
        );
      }
      if (mounted) Navigator.pop(context);
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
    final accounts = [for (final a in snap.accounts.values) a.id]
      ..sort((a, b) => snap.accountLabel(a).compareTo(snap.accountLabel(b)));
    return FormDialog(
      title: 'Informar valor de ${widget.asset.symbol}',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 480,
      children: [
        SegmentedButton<ValuationKind>(
          segments: const [
            ButtonSegment(
              value: ValuationKind.unitPrice,
              label: Text('Preço unitário'),
            ),
            ButtonSegment(
              value: ValuationKind.balance,
              label: Text('Saldo na conta'),
            ),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => setState(() => _kind = s.single),
        ),
        if (_kind == ValuationKind.balance)
          Choice<String>(
            label: 'Conta',
            value: _accountId,
            items: accounts,
            labelOf: snap.accountLabel,
            onChanged: (v) => setState(() => _accountId = v),
          ),
        DateField(
          fieldKey: const Key('val-date'),
          controller: _date,
          label: 'Data de referência',
        ),
        DecimalField(
          fieldKey: const Key('val-value'),
          controller: _value,
          label: _kind == ValuationKind.unitPrice
              ? 'Preço (${widget.asset.currency})'
              : 'Saldo (${widget.asset.currency})',
          required: true,
          helper: _kind == ValuationKind.unitPrice
              ? 'Vale para todas as contas. Fonte: informado por você.'
              : 'Valor total do ativo nesta conta, como a instituição informa.',
        ),
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    );
  }
}
