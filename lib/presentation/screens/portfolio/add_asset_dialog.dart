import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/market/market_data_service.dart';
import '../../../application/portfolio/operation_service.dart';
import '../../../application/portfolio/portfolio_query.dart';
import '../../../application/portfolio/quick_add_service.dart';
import '../../../core/time/local_date.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/market/tickers.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../registry/registry_dialogs.dart';

/// Adição rápida de ações, FIIs, ETFs e BDRs da B3 pelo ticker (M-01).
///
/// Devolve o id do ativo quando grava.
Future<String?> showAddAssetDialog(BuildContext context) => showDialog<String>(
  context: context,
  builder: (_) => const AddAssetDialog(),
);

/// Compra ou posição que o usuário já tem (saldo inicial).
enum AddMode { buy, initialBalance }

enum _Lookup { idle, loading, found, notFound, offline, failed }

class AddAssetDialog extends ConsumerStatefulWidget {
  const AddAssetDialog({super.key});

  @override
  ConsumerState<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends ConsumerState<AddAssetDialog> {
  final _form = GlobalKey<FormState>();
  final _tickerFocus = FocusNode();
  final _ticker = TextEditingController();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _fees = TextEditingController();
  final _institution = TextEditingController();
  final _date = TextEditingController(
    text: Fmt.date(LocalDate.fromDateTime(DateTime.now())),
  );
  final _sector = TextEditingController();
  final _segment = TextEditingController();
  final _isin = TextEditingController();
  final _notes = TextEditingController();

  AddMode? _mode;
  String? _accountId;
  bool _accountChosen = false;
  AssetClass? _class;
  Liquidity? _liquidity = Liquidity.daily;
  PriceSource _priceSource = PriceSource.market;

  _Lookup _lookup = _Lookup.idle;
  String? _lookedUp;
  String? _sourceNote;
  Future<void>? _pending;
  bool _saving = false;
  bool _offsetCash = true;

  @override
  void initState() {
    super.initState();
    _tickerFocus.addListener(() {
      if (!_tickerFocus.hasFocus) unawaited(_runLookup());
    });
  }

  @override
  void dispose() {
    for (final c in [
      _ticker,
      _name,
      _quantity,
      _price,
      _fees,
      _institution,
      _date,
      _sector,
      _segment,
      _isin,
      _notes,
    ]) {
      c.dispose();
    }
    _tickerFocus.dispose();
    super.dispose();
  }

  String get _symbol => Tickers.normalize(_ticker.text);

  /// Ativo da B3 já cadastrado com o ticker digitado.
  Asset? _existing(PortfolioSnapshot snap) {
    final symbol = _symbol;
    if (symbol.isEmpty) return null;
    for (final a in snap.assets.values) {
      if (a.market == Market.b3 && a.symbol.toUpperCase() == symbol) return a;
    }
    return null;
  }

  /// A conta da operação mais recente; senão, a única ativa.
  String? _defaultAccount(PortfolioSnapshot snap) {
    for (final op in snap.operations) {
      final account = snap.accounts[op.accountId];
      if (account != null && !account.archived) return account.id;
    }
    final active = snap.accounts.values.where((a) => !a.archived).toList();
    return active.length == 1 ? active.single.id : null;
  }

  Future<void> _runLookup() {
    final symbol = _symbol;
    if (symbol.isEmpty || symbol == _lookedUp) {
      return _pending ?? Future.value();
    }
    if (_ticker.text != symbol) {
      _ticker.value = TextEditingValue(
        text: symbol,
        selection: TextSelection.collapsed(offset: symbol.length),
      );
    }
    final snap = ref.read(portfolioSnapshotProvider).value;
    if (snap != null && _existing(snap) != null) {
      setState(() {
        _lookedUp = symbol;
        _lookup = _Lookup.idle;
      });
      return Future.value();
    }
    setState(() {
      _lookedUp = symbol;
      _lookup = _Lookup.loading;
    });
    final future = _doLookup(symbol);
    _pending = future;
    return future;
  }

  Future<void> _doLookup(String symbol) async {
    TickerLookup? result;
    try {
      result = await ref.read(marketDataServiceProvider).lookupTicker(symbol);
    } on Object {
      result = null;
    }
    if (!mounted || _lookedUp != symbol) return;
    final info = result?.info;
    setState(() {
      if (info == null) {
        _lookup = result == null
            ? _Lookup.failed
            : result.offline
            ? _Lookup.offline
            : _Lookup.notFound;
        _sourceNote = null;
        // Sem fonte, o ticker provavelmente não é cotado: preço informado.
        _priceSource = _lookup == _Lookup.notFound
            ? PriceSource.manual
            : PriceSource.market;
        return;
      }
      _lookup = _Lookup.found;
      _priceSource = PriceSource.market;
      _name.text = info.name ?? _name.text;
      final cls = info.assetClass;
      if (cls != null) _class = byCode(AssetClass.values, cls);
      _isin.text = info.isin ?? '';
      _sector.text = info.sector ?? '';
      _segment.text = info.segment ?? '';
      _sourceNote = [
        for (final code in info.source.split('+'))
          code == ProviderCatalog.b3Cotahist.code
              ? 'B3 (COTAHIST)'
              : ProviderCatalog.byCode(code)?.short ?? code,
      ].join(' e ');
    });
  }

  Future<void> _save({bool allowDuplicate = false}) async {
    await _runLookup();
    if (!mounted || !_form.currentState!.validate()) return;
    final snap = ref.read(portfolioSnapshotProvider).value;
    if (snap == null) return;
    final mode = _mode ?? _defaultMode(snap);
    final existing = _existing(snap);
    final symbol = _symbol;
    final accountId = _accountChosen ? _accountId : _defaultAccount(snap);
    if (existing == null && (_class == null || _name.text.trim().isEmpty)) {
      // Os campos de nome e classe aparecem depois da consulta: valida de
      // novo quando estiverem na tela.
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _form.currentState?.validate(),
      );
      return;
    }
    setState(() => _saving = true);
    final input = QuickAddInput(
      assetId: existing?.id,
      newAsset: existing != null
          ? null
          : Asset(
              id: '',
              symbol: symbol,
              market: Market.b3,
              assetClass: _class!,
              name: _name.text.trim(),
              currency: 'BRL',
              country: 'BR',
              priceSource: _priceSource,
              isin: textOrNull(_isin),
              sector: textOrNull(_sector),
              segment: textOrNull(_segment),
              liquidity: _liquidity,
              notes: textOrNull(_notes),
            ),
      accountId: snap.accounts.isEmpty ? null : accountId,
      newInstitutionName: snap.accounts.isEmpty ? _institution.text : null,
      quantity: decimalOf(_quantity)!,
      price: decimalOf(_price)!,
      date: dateOf(_date)!,
      fees: mode == AddMode.buy ? decimalOf(_fees) : null,
      initialBalance: mode == AddMode.initialBalance,
      offsetCash:
          mode == AddMode.initialBalance && snap.trackCash && _offsetCash,
    );
    try {
      final result = await ref
          .read(quickAddServiceProvider)
          .add(input, allowDuplicate: allowDuplicate);
      if (!mounted) return;
      switch (result.outcome) {
        case Saved():
          final messenger = ScaffoldMessenger.of(context);
          Navigator.pop(context, result.assetId);
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '$symbol: ${mode == AddMode.initialBalance ? 'saldo inicial' : 'compra'} '
                'de ${Fmt.number(input.quantity)} registrado.',
              ),
            ),
          );
          if (_priceSource == PriceSource.market && existing == null) {
            _fetchPrice(result.assetId);
          }
        case PossibleDuplicate():
          setState(() => _saving = false);
          final again = await confirm(
            context,
            title: 'Possível duplicata',
            message:
                'Já existe uma compra igual de $symbol nesta data e conta. '
                'Gravar mesmo assim?',
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

  /// Busca a cotação do ativo novo em segundo plano (a consulta do ticker
  /// já guarda a da brapi, com chave; esta traz o fechamento da B3).
  void _fetchPrice(String assetId) {
    final controller = ref.read(marketRefreshProvider.notifier);
    final backfill = ref.read(historyBackfillProvider.notifier);
    final repos = ref.read(portfolioRepositoriesProvider);
    unawaited(() async {
      final asset = await repos.assets.byId(assetId);
      if (asset == null) return;
      await controller.run(
        'Cotação de ${asset.symbol}',
        (s) => s.refreshAsset(asset),
      );
      // E o histórico de dez anos, em segundo plano (M-08).
      await backfill.start();
    }());
  }

  AddMode _defaultMode(PortfolioSnapshot snap) =>
      snap.operations.isEmpty ? AddMode.initialBalance : AddMode.buy;

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(portfolioSnapshotProvider).value;
    if (snap == null) {
      return const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final mode = _mode ?? _defaultMode(snap);
    final existing = _existing(snap);
    final accountId = _accountChosen ? _accountId : _defaultAccount(snap);
    final accounts = snap.accounts.values.where((a) => !a.archived).toList()
      ..sort(
        (a, b) => snap.accountLabel(a.id).compareTo(snap.accountLabel(b.id)),
      );
    final initial = mode == AddMode.initialBalance;
    final newAsset =
        existing == null &&
        _lookup != _Lookup.idle &&
        _lookup != _Lookup.loading;

    return FormDialog(
      title: 'Adicionar ativo',
      formKey: _form,
      saving: _saving,
      onSave: _save,
      width: 620,
      children: [
        SegmentedButton<AddMode>(
          key: const Key('add-mode'),
          segments: const [
            ButtonSegment(
              value: AddMode.initialBalance,
              label: Text('Posição que já tenho (saldo inicial)'),
            ),
            ButtonSegment(value: AddMode.buy, label: Text('Nova compra')),
          ],
          selected: {mode},
          onSelectionChanged: (s) => setState(() => _mode = s.single),
        ),
        TextFormField(
          key: const Key('add-ticker'),
          controller: _ticker,
          focusNode: _tickerFocus,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [_UpperCase()],
          decoration: InputDecoration(
            labelText: 'Ticker *',
            helperText:
                'Ações, FIIs, ETFs e BDRs da B3 (ex.: BBAS3, HGLG11). '
                'Ao sair do campo, o app busca nome e classe.',
            helperMaxLines: 2,
            suffixIcon: _lookup == _Lookup.loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Buscar',
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _lookedUp = null;
                      unawaited(_runLookup());
                    },
                  ),
          ),
          onFieldSubmitted: (_) => unawaited(_runLookup()),
          validator: (v) =>
              Tickers.normalize(v ?? '').isEmpty ? 'Obrigatório' : null,
        ),
        if (existing != null)
          _Note(
            key: const Key('add-existing'),
            icon: Icons.check_circle_outline,
            text:
                'Já cadastrado: ${existing.symbol} — ${existing.name} '
                '(${existing.assetClass.singular}). Só a '
                '${initial ? 'posição' : 'compra'} será registrada.',
          )
        else if (_lookup == _Lookup.found)
          _Note(
            key: const Key('add-found'),
            icon: Icons.verified_outlined,
            text:
                'Encontrado em $_sourceNote. Confira o nome e a classe antes '
                'de salvar.',
          )
        else if (_lookup == _Lookup.notFound ||
            _lookup == _Lookup.offline ||
            _lookup == _Lookup.failed)
          _Note(
            key: const Key('add-not-found'),
            icon: Icons.warning_amber_outlined,
            warning: true,
            text: switch (_lookup) {
              _Lookup.offline =>
                'Sem conexão, e o ticker não está nos dados já baixados. '
                    'Preencha nome e classe para cadastrar manualmente.',
              _Lookup.failed =>
                'Não foi possível consultar as fontes agora. Preencha nome e '
                    'classe para cadastrar manualmente.',
              _ =>
                'Ticker não encontrado na B3 nem na brapi. Confira o código '
                    'ou preencha nome e classe para cadastrar manualmente.',
            },
          ),
        if (newAsset)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  key: const Key('add-name'),
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Choice<AssetClass>(
                  // Recria o campo quando a consulta preenche a classe.
                  key: ValueKey(_class),
                  fieldKey: const Key('add-class'),
                  label: 'Classe',
                  value: _class,
                  items: Tickers.b3QuickClasses,
                  labelOf: (c) => c.singular,
                  onChanged: (v) => setState(() => _class = v),
                ),
              ),
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecimalField(
                fieldKey: const Key('add-quantity'),
                controller: _quantity,
                label: 'Quantidade',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecimalField(
                fieldKey: const Key('add-price'),
                controller: _price,
                label: initial ? 'Preço médio' : 'Preço unitário',
                required: true,
                suffix: 'R\$',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateField(
                fieldKey: const Key('add-date'),
                controller: _date,
                label: initial ? 'Data aproximada' : 'Data',
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: accounts.isEmpty
                  ? TextFormField(
                      key: const Key('add-institution'),
                      controller: _institution,
                      decoration: const InputDecoration(
                        labelText: 'Corretora ou banco *',
                        helperText:
                            'Cria a instituição com uma "Conta principal".',
                      ),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
                    )
                  : Choice<String>(
                      key: ValueKey(accountId),
                      fieldKey: const Key('add-account'),
                      label: 'Conta',
                      value: accountId,
                      items: [for (final a in accounts) a.id],
                      labelOf: snap.accountLabel,
                      onChanged: (v) => setState(() {
                        _accountId = v;
                        _accountChosen = true;
                      }),
                    ),
            ),
            if (!initial) ...[
              const SizedBox(width: 12),
              Expanded(
                child: DecimalField(
                  fieldKey: const Key('add-fees'),
                  controller: _fees,
                  label: 'Custos (opcional)',
                  suffix: 'R\$',
                ),
              ),
            ],
          ],
        ),
        if (initial && snap.trackCash)
          CheckboxListTile(
            key: const Key('add-offset-cash'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _offsetCash,
            onChanged: (v) => setState(() => _offsetCash = v ?? true),
            title: const Text('Não mexer no caixa'),
            subtitle: const Text(
              'Com o controle de caixa ligado, registra também um depósito '
              'do mesmo valor, para o saldo inicial não deixar o caixa '
              'negativo.',
            ),
          ),
        if (initial)
          Text(
            'Copie a quantidade e o preço médio da corretora. A TIR fica '
            'aproximada; para rentabilidade exata, registre as compras '
            'individuais.',
            key: const Key('add-initial-note'),
            style: muted,
          ),
        if (newAsset)
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const Key('add-more'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text('Mais detalhes'),
              subtitle: Text(
                'Setor, segmento, ISIN, liquidez, preço e observações',
                style: muted,
              ),
              children: [
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
                        decoration: const InputDecoration(
                          labelText: 'Segmento',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _isin,
                        decoration: const InputDecoration(labelText: 'ISIN'),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Choice<PriceSource>(
                        key: ValueKey(_priceSource),
                        fieldKey: const Key('add-price-source'),
                        label: 'Preço',
                        value: _priceSource,
                        items: PriceSource.values,
                        labelOf: (s) => s.label,
                        onChanged: (v) =>
                            setState(() => _priceSource = v ?? _priceSource),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('add-full-form'),
            onPressed: _saving
                ? null
                : () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    unawaited(showAssetDialog(navigator.context));
                  },
            icon: const Icon(Icons.tune, size: 18),
            label: const Text(
              'Renda fixa, cripto ou internacional: cadastro completo',
            ),
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    this.warning = false,
    super.key,
  });

  final IconData icon;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = warning
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// Ticker em maiúsculas enquanto digita.
class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
