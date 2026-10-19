import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/market/market_price.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Cria ([initial] nulo) ou edita uma instituição.
Future<void> showInstitutionDialog(
  BuildContext context, {
  Institution? initial,
}) => showDialog<void>(
  context: context,
  builder: (_) => _InstitutionDialog(initial: initial),
);

class _InstitutionDialog extends ConsumerStatefulWidget {
  const _InstitutionDialog({this.initial});

  final Institution? initial;

  @override
  ConsumerState<_InstitutionDialog> createState() => _InstitutionDialogState();
}

class _InstitutionDialogState extends ConsumerState<_InstitutionDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _country = TextEditingController(
    text: widget.initial?.country ?? 'BR',
  );
  late final _notes = TextEditingController(text: widget.initial?.notes);
  late InstitutionKind? _kind = widget.initial?.kind ?? InstitutionKind.broker;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final value = Institution(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      kind: _kind!,
      country: _country.text.trim().toUpperCase(),
      notes: textOrNull(_notes),
    );
    final service = ref.read(registryServiceProvider);
    try {
      if (widget.initial == null) {
        await service.createInstitution(value);
      } else {
        await service.updateInstitution(value);
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
    return FormDialog(
      title: widget.initial == null ? 'Nova instituição' : 'Editar instituição',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      children: [
        TextFormField(
          key: const Key('institution-name'),
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome *'),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
        ),
        Choice<InstitutionKind>(
          label: 'Tipo',
          value: _kind,
          items: InstitutionKind.values,
          labelOf: (k) => k.label,
          onChanged: (v) => setState(() => _kind = v),
        ),
        TextFormField(
          controller: _country,
          decoration: const InputDecoration(
            labelText: 'País *',
            helperText: 'Código de duas letras (BR, US)',
          ),
          validator: (v) => RegExp(r'^[A-Za-z]{2}$').hasMatch(v ?? '')
              ? null
              : 'Use duas letras',
        ),
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    );
  }
}

/// Cria ou edita uma conta da instituição [institutionId].
Future<void> showAccountDialog(
  BuildContext context, {
  required String institutionId,
  Account? initial,
}) => showDialog<void>(
  context: context,
  builder: (_) =>
      _AccountDialog(institutionId: institutionId, initial: initial),
);

class _AccountDialog extends ConsumerStatefulWidget {
  const _AccountDialog({required this.institutionId, this.initial});

  final String institutionId;
  final Account? initial;

  @override
  ConsumerState<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<_AccountDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _currency = TextEditingController(
    text: widget.initial?.currency ?? 'BRL',
  );
  late AccountKind? _kind = widget.initial?.kind ?? AccountKind.brokerage;
  late bool _archived = widget.initial?.archived ?? false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final value = Account(
      id: widget.initial?.id ?? '',
      institutionId: widget.institutionId,
      name: _name.text.trim(),
      kind: _kind!,
      currency: _currency.text.trim().toUpperCase(),
      archived: _archived,
    );
    final service = ref.read(registryServiceProvider);
    try {
      if (widget.initial == null) {
        await service.createAccount(value);
      } else {
        await service.updateAccount(value);
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
    return FormDialog(
      title: widget.initial == null ? 'Nova conta' : 'Editar conta',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      children: [
        TextFormField(
          key: const Key('account-name'),
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome *'),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
        ),
        Choice<AccountKind>(
          label: 'Tipo',
          value: _kind,
          items: AccountKind.values,
          labelOf: (k) => k.label,
          onChanged: (v) => setState(() => _kind = v),
        ),
        TextFormField(
          controller: _currency,
          decoration: const InputDecoration(
            labelText: 'Moeda principal *',
            helperText: 'Código ISO (BRL, USD)',
          ),
          validator: (v) => RegExp(r'^[A-Za-z0-9]{3,10}$').hasMatch(v ?? '')
              ? null
              : 'Código inválido',
        ),
        if (widget.initial != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Arquivada'),
            subtitle: const Text(
              'Some das escolhas de novas operações; o histórico continua.',
            ),
            value: _archived,
            onChanged: (v) => setState(() => _archived = v),
          ),
      ],
    );
  }
}

/// Cria ou edita um ativo (com as características de renda fixa).
Future<void> showAssetDialog(
  BuildContext context, {
  Asset? initial,
  FixedIncomeTerms? terms,
}) => showDialog<void>(
  context: context,
  builder: (_) => _AssetDialog(initial: initial, terms: terms),
);

class _AssetDialog extends ConsumerStatefulWidget {
  const _AssetDialog({this.initial, this.terms});

  final Asset? initial;
  final FixedIncomeTerms? terms;

  @override
  ConsumerState<_AssetDialog> createState() => _AssetDialogState();
}

class _AssetDialogState extends ConsumerState<_AssetDialog> {
  final _form = GlobalKey<FormState>();
  late final Asset? _a = widget.initial;
  late final FixedIncomeTerms? _t = widget.terms;

  late final _symbol = TextEditingController(text: _a?.symbol);
  late final _name = TextEditingController(text: _a?.name);
  late final _currency = TextEditingController(text: _a?.currency ?? 'BRL');
  late final _country = TextEditingController(text: _a?.country ?? 'BR');
  late final _sector = TextEditingController(text: _a?.sector);
  late final _segment = TextEditingController(text: _a?.segment);
  late final _isin = TextEditingController(text: _a?.isin);
  late final _notes = TextEditingController(text: _a?.notes);
  late AssetClass? _class = _a?.assetClass ?? AssetClass.stockBr;
  late Market? _market = _a?.market ?? Market.b3;
  late Liquidity? _liquidity = _a?.liquidity;

  /// Escolhida pelo usuário; sem escolha, a sugerida pela classe.
  late PriceSource? _priceSource = _a?.priceSource;

  PriceSource get _effectiveSource =>
      _priceSource ?? MarketPricing.defaultSource(_class ?? AssetClass.stockBr);

  // Renda fixa.
  late FixedIncomeProduct? _product = _t?.product ?? FixedIncomeProduct.cdb;
  late Indexer? _indexer = _t?.indexer ?? Indexer.cdi;
  late DayCount? _dayCount = _t?.dayCount ?? DayCount.bus252;
  late Liquidity? _fiLiquidity = _t?.liquidity ?? Liquidity.atMaturity;
  late TaxRegime? _taxRegime = _t?.taxRegime ?? TaxRegime.regressiveIr;
  late final _issuer = TextEditingController(text: _t?.issuer);
  late final _rate = TextEditingController(
    text: _t == null ? '' : Fmt.number(_t.rate),
  );
  late final _spread = TextEditingController(
    text: _t?.spread == null ? '' : Fmt.number(_t!.spread!),
  );
  late final _issueDate = TextEditingController(
    text: _t == null ? '' : Fmt.date(_t.issueDate),
  );
  late final _maturity = TextEditingController(
    text: _t == null ? '' : Fmt.date(_t.maturityDate),
  );
  late final _grace = TextEditingController(
    text: _t?.graceUntil == null ? '' : Fmt.date(_t!.graceUntil!),
  );
  late final _costs = TextEditingController(text: _t?.costsNotes);
  bool _saving = false;

  List<TextEditingController> get _controllers => [
    _symbol,
    _name,
    _currency,
    _country,
    _sector,
    _segment,
    _isin,
    _notes,
    _issuer,
    _rate,
    _spread,
    _issueDate,
    _maturity,
    _grace,
    _costs,
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final asset = Asset(
      id: _a?.id ?? '',
      symbol: _symbol.text,
      market: _market!,
      assetClass: _class!,
      name: _name.text,
      currency: _currency.text.trim().toUpperCase(),
      country: _country.text.trim().toUpperCase(),
      isin: textOrNull(_isin),
      sector: textOrNull(_sector),
      segment: textOrNull(_segment),
      liquidity: _liquidity,
      notes: textOrNull(_notes),
      priceSource: _effectiveSource,
    );
    final terms = _class!.hasFixedIncomeTerms
        ? FixedIncomeTerms(
            assetId: asset.id,
            product: _product!,
            issuer: textOrNull(_issuer),
            indexer: _indexer!,
            rate: decimalOf(_rate)!,
            spread: decimalOf(_spread),
            dayCount: _dayCount!,
            issueDate: dateOf(_issueDate)!,
            maturityDate: dateOf(_maturity)!,
            graceUntil: dateOf(_grace),
            liquidity: _fiLiquidity!,
            taxRegime: _taxRegime!,
            costsNotes: textOrNull(_costs),
          )
        : null;
    final service = ref.read(registryServiceProvider);
    try {
      if (_a == null) {
        await service.createAsset(asset, terms: terms);
      } else {
        await service.updateAsset(asset, terms: terms);
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
    final fixedIncome = _class?.hasFixedIncomeTerms ?? false;
    String? required(String? v) =>
        (v ?? '').trim().isEmpty ? 'Obrigatório' : null;
    return FormDialog(
      title: _a == null ? 'Novo ativo' : 'Editar ativo',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 640,
      children: [
        Row(
          children: [
            Expanded(
              child: Choice<AssetClass>(
                fieldKey: const Key('asset-class'),
                label: 'Classe',
                value: _class,
                items: AssetClass.values,
                labelOf: (c) => c.label,
                onChanged: (v) => setState(() => _class = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Choice<Market>(
                label: 'Mercado',
                value: _market,
                items: Market.values,
                labelOf: (m) => m.label,
                onChanged: (v) => setState(() => _market = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('asset-symbol'),
                controller: _symbol,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Código *',
                  helperText: 'Ticker (PETR4) ou um código seu',
                ),
                validator: required,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                key: const Key('asset-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: required,
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
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{3,10}$').hasMatch(v ?? '')
                    ? null
                    : 'Código inválido',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _country,
                decoration: const InputDecoration(labelText: 'País *'),
                validator: (v) => RegExp(r'^[A-Za-z]{2}$').hasMatch(v ?? '')
                    ? null
                    : 'Use duas letras',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Choice<Liquidity>(
                label: 'Liquidez',
                required: false,
                value: _liquidity,
                items: Liquidity.values,
                labelOf: (l) => l.label,
                onChanged: (v) => setState(() => _liquidity = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sector,
                decoration: const InputDecoration(labelText: 'Setor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _segment,
                decoration: const InputDecoration(labelText: 'Segmento'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _isin,
                decoration: const InputDecoration(labelText: 'ISIN'),
              ),
            ),
          ],
        ),
        Choice<PriceSource>(
          // Recria o campo quando a sugestão muda com a classe.
          key: ValueKey(_effectiveSource),
          fieldKey: const Key('asset-price-source'),
          label: 'Preço',
          value: _effectiveSource,
          items: PriceSource.values,
          labelOf: (s) => s.label,
          onChanged: (v) => setState(() => _priceSource = v),
        ),
        if (fixedIncome) ...[
          const Divider(),
          Text(
            'Características do título',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              Expanded(
                child: Choice<FixedIncomeProduct>(
                  label: 'Produto',
                  value: _product,
                  items: FixedIncomeProduct.values,
                  labelOf: (p) => p.label,
                  onChanged: (v) => setState(() => _product = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _issuer,
                  decoration: const InputDecoration(labelText: 'Emissor'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Choice<Indexer>(
                  label: 'Indexador',
                  value: _indexer,
                  items: Indexer.values,
                  labelOf: (i) => i.label,
                  onChanged: (v) => setState(() => _indexer = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('fi-rate'),
                  controller: _rate,
                  label: 'Taxa',
                  required: true,
                  suffix: '%',
                  helper: _indexer == Indexer.pre
                      ? '% ao ano'
                      : '% do indexador (110 = 110%)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecimalField(
                  controller: _spread,
                  label: 'Taxa adicional',
                  suffix: '% a.a.',
                  helper: 'Ex.: IPCA + 6',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DateField(
                  fieldKey: const Key('fi-issue'),
                  controller: _issueDate,
                  label: 'Emissão',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateField(
                  fieldKey: const Key('fi-maturity'),
                  controller: _maturity,
                  label: 'Vencimento',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateField(
                  controller: _grace,
                  label: 'Carência até',
                  required: false,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Choice<DayCount>(
                  label: 'Base de dias',
                  value: _dayCount,
                  items: DayCount.values,
                  labelOf: (d) => d.label,
                  onChanged: (v) => setState(() => _dayCount = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Choice<Liquidity>(
                  label: 'Liquidez do título',
                  value: _fiLiquidity,
                  items: Liquidity.values,
                  labelOf: (l) => l.label,
                  onChanged: (v) => setState(() => _fiLiquidity = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Choice<TaxRegime>(
                  label: 'Tributação',
                  value: _taxRegime,
                  items: TaxRegime.values,
                  labelOf: (t) => t.label,
                  onChanged: (v) => setState(() => _taxRegime = v),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _costs,
            decoration: const InputDecoration(labelText: 'Custos do título'),
          ),
        ],
        TextFormField(
          controller: _notes,
          decoration: const InputDecoration(labelText: 'Observações'),
        ),
      ],
    );
  }
}
