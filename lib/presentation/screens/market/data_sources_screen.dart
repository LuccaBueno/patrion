import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/market/market_data_service.dart';

import '../../../application/market/market_overview.dart';
import '../../../application/settings/market_preferences.dart';
import '../../../data/repositories/provider_state_repository.dart';
import '../../../domain/market/market_price.dart';
import '../../../domain/market/provider_catalog.dart';
import '../../../domain/portfolio/codes.dart';
import '../../../domain/portfolio/entities.dart';
import '../../format/formatters.dart';
import '../../format/market_labels.dart';
import '../../format/sync_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Fontes de dados (SPEC §3 e §16): o que cada provedor fornece, o que é
/// enviado a ele, licença e limites, chave de API, estado e atualização.
class DataSourcesScreen extends ConsumerWidget {
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(providerStatesProvider);
    return PageScaffold(
      title: 'Fontes de dados',
      subtitle:
          'Cotações, câmbio e indicadores. As requisições levam só códigos '
          'de ativos e de séries: nunca quantidades, valores ou contas.',
      actions: const [RefreshButton()],
      child: AsyncBody(
        value: states,
        builder: (list) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const RefreshStatusBanner(),
            const _ManualAssetsCard(),
            const _UpdateSettingsCard(),
            const MarketOverviewCard(),
            const SizedBox(height: 8),
            Text('Provedores', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final s in list) _ProviderCard(state: s),
          ],
        ),
      ),
    );
  }
}

/// Botão "Atualizar agora" (carteira inteira, câmbio e indicadores).
class RefreshButton extends ConsumerWidget {
  const RefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketRefreshProvider);
    return FilledButton.icon(
      key: const Key('market-refresh'),
      onPressed: state.busy
          ? null
          : () => ref.read(marketRefreshProvider.notifier).refreshPortfolio(),
      icon: state.busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(state.busy ? 'Atualizando…' : 'Atualizar agora'),
    );
  }
}

/// Resultado da última atualização: sem conexão, falhas ou resumo.
class RefreshStatusBanner extends ConsumerWidget {
  const RefreshStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketRefreshProvider);
    final result = state.lastResult;
    final theme = Theme.of(context);
    if (state.busy) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: ListTile(
            leading: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('${state.running}…'),
          ),
        ),
      );
    }
    if (result == null) return const SizedBox.shrink();
    final problem =
        result.offline ||
        result.failures.isNotEmpty ||
        result.notices.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('market-status'),
        child: ListTile(
          leading: Icon(
            result.offline
                ? Icons.cloud_off_outlined
                : problem
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            color: problem ? theme.colorScheme.error : null,
            semanticLabel: result.offline
                ? 'Sem conexão'
                : problem
                ? 'Aviso'
                : 'Concluído',
          ),
          title: Text(MarketLabels.result(result)),
          subtitle: Text(
            [
              if (state.lastRunAt != null)
                '${state.lastTask} · '
                    '${state.lastRunAt!.hour.toString().padLeft(2, '0')}:'
                    '${state.lastRunAt!.minute.toString().padLeft(2, '0')}',
              // Uma linha por provedor e mensagem (o SGS falha uma vez por
              // série, com a mesma mensagem).
              if (!result.offline) ...{
                for (final f in result.failures)
                  '${ProviderCatalog.nameOf(f.provider)}: ${f.message}',
              },
              ...result.notices,
            ].join('\n'),
          ),
        ),
      ),
    );
  }
}

class _UpdateSettingsCard extends ConsumerWidget {
  const _UpdateSettingsCard();

  static String _label(int minutes) => switch (minutes) {
    0 => 'Desligada',
    60 => 'A cada hora',
    240 => 'A cada 4 horas',
    _ => 'A cada $minutes minutos',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(marketPreferencesProvider);
    final minutes =
        ref.watch(marketRefreshMinutesProvider).value ??
        MarketPreferences.defaultRefreshMinutes;
    final year = DateTime.now().year;
    final startYear =
        ref.watch(_startYearProvider).value ??
        MarketPreferences.defaultStartYear(year);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atualização', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<int>(
                    key: const Key('refresh-interval'),
                    isExpanded: true,
                    initialValue: minutes,
                    decoration: const InputDecoration(
                      labelText: 'Atualização automática (app aberto)',
                    ),
                    items: [
                      for (final m in MarketPreferences.refreshOptions)
                        DropdownMenuItem(value: m, child: Text(_label(m))),
                    ],
                    onChanged: (v) {
                      if (v != null) prefs.setRefreshMinutes(v);
                    },
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: DropdownButtonFormField<int>(
                    key: const Key('history-start'),
                    isExpanded: true,
                    initialValue: startYear,
                    decoration: const InputDecoration(
                      labelText: 'Histórico a partir de',
                    ),
                    items: [
                      for (var y = year; y >= 1994; y--)
                        DropdownMenuItem(value: y, child: Text('$y')),
                    ],
                    onChanged: (v) {
                      if (v != null) prefs.setHistoryStartYear(v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Vale só para este computador. A atualização automática busca '
              'as cotações dos ativos da carteira com preço de mercado, o '
              'câmbio e os indicadores. O histórico da B3 (COTAHIST) é '
              'baixado só para os anos necessários, e o arquivo é apagado '
              'depois de extraído.',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

final _startYearProvider = StreamProvider<int?>(
  (ref) => ref.watch(marketPreferencesProvider).watchHistoryStartYear(),
);

/// Câmbio e indicadores guardados, com fonte e data.
class MarketOverviewCard extends ConsumerWidget {
  const MarketOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(marketOverviewProvider).value;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      key: const Key('market-overview'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câmbio e indicadores', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (overview == null || overview.isEmpty)
              const UnavailableText(
                tooltip:
                    'Ainda não há câmbio nem indicadores guardados. Use '
                    '"Atualizar agora" com internet.',
              )
            else
              Wrap(
                spacing: 32,
                runSpacing: 12,
                children: _items(overview, muted),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _items(MarketOverview o, TextStyle? muted) {
    Widget item(String label, String value, String detail) => SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          Text(value),
          Text(detail, style: muted),
        ],
      ),
    );
    return [
      for (final MapEntry(key: c, value: r) in o.fx.entries)
        if (r.mid != null)
          item(
            c,
            MarketLabels.fx(r.mid!),
            '${MarketLabels.fxKind(r.kind)} de ${Fmt.date(r.refDate)} · '
            '${ProviderCatalog.nameOf(r.source)}',
          ),
      for (final MapEntry(key: s, value: p) in o.indicators.entries)
        item(
          s.label,
          MarketLabels.indicator(p),
          '${s.isMonthly ? 'mês de ${p.refDate.month.toString().padLeft(2, '0')}/${p.refDate.year}' : Fmt.date(p.refDate)} · '
          '${ProviderCatalog.nameOf(p.source)}',
        ),
      if (o.cdiAnnual != null)
        item(
          'CDI anualizado',
          '${Fmt.percent(o.cdiAnnual!, signed: false)} ao ano',
          'Calculado do último CDI diário (base 252)',
        ),
      if (o.ipca12m case final ipca?)
        item(
          'IPCA em 12 meses',
          Fmt.percent(ipca.value),
          'Calculado de ${ipca.from.month.toString().padLeft(2, '0')}/'
              '${ipca.from.year} a ${ipca.to.month.toString().padLeft(2, '0')}/'
              '${ipca.to.year}',
        ),
    ];
  }
}

class _ProviderCard extends ConsumerStatefulWidget {
  const _ProviderCard({required this.state});

  final ProviderState state;

  @override
  ConsumerState<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<_ProviderCard> {
  final _keyField = TextEditingController();
  bool _editingKey = false;
  bool _testing = false;

  @override
  void dispose() {
    _keyField.dispose();
    super.dispose();
  }

  ProviderInfo get _info => widget.state.info;

  bool get _hasKey =>
      ref.read(apiKeyStoreProvider).providersWithKey().contains(_info.code);

  void _saveKey() {
    try {
      ref.read(apiKeyStoreProvider).write(_info.code, _keyField.text);
      _keyField.clear();
      setState(() => _editingKey = false);
      showInfo(context, 'Chave de ${_info.name} guardada neste computador.');
    } on Object catch (error) {
      showError(context, error);
    }
  }

  Future<void> _deleteKey() async {
    final ok = await confirm(
      context,
      title: 'Apagar a chave?',
      message:
          'A chave de ${_info.name} deixa de ser usada neste computador. '
          'Os dados já baixados continuam guardados.',
      confirmLabel: 'Apagar',
    );
    if (!ok || !mounted) return;
    try {
      ref.read(apiKeyStoreProvider).delete(_info.code);
      setState(() {});
    } on Object catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    final result = await ref
        .read(marketRefreshProvider.notifier)
        .run('Teste de ${_info.name}', (s) => s.testProvider(_info.code));
    if (!mounted) return;
    setState(() => _testing = false);
    if (result.failures.isEmpty) {
      showInfo(context, '${_info.name} respondeu corretamente.');
    } else {
      showInfo(context, '${_info.name}: ${result.failures.first.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final info = _info;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final hasKey = _hasKey;
    final status = !s.enabled
        ? 'Desligado'
        : s.failing
        ? 'Falhou em ${SyncLabels.instant(s.lastErrorAt!)}: ${s.lastError}'
        : s.lastSuccessAt != null
        ? 'Funcionando · último acesso em ${SyncLabels.instant(s.lastSuccessAt!)}'
        : 'Ainda não usado';
    return Card(
      key: Key('provider-${info.code}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.name, style: theme.textTheme.titleSmall),
                      Text(info.role),
                    ],
                  ),
                ),
                Switch(
                  key: Key('provider-switch-${info.code}'),
                  value: s.enabled,
                  onChanged: (v) => ref
                      .read(providerStateRepositoryProvider)
                      .setEnabled(info.code, v),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  !s.enabled
                      ? Icons.pause_circle_outline
                      : s.failing
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  size: 16,
                  color: s.enabled && s.failing
                      ? theme.colorScheme.error
                      : null,
                  semanticLabel: 'Estado',
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(status, style: theme.textTheme.bodySmall)),
              ],
            ),
            if (info.warning != null) ...[
              const SizedBox(height: 6),
              Text(
                info.warning!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text('Envia: ${info.sends}', style: muted),
            Text('Licença: ${info.license}', style: muted),
            Text('Limites: ${info.limits}', style: muted),
            if (info.monthlyQuota != null) QuotaMeter(state: s),
            if (info.autoOnlyInSession)
              Text(
                'Na atualização automática, só em horário de pregão da B3 '
                '(dias úteis, 10:00 às 18:30 de Brasília) e no máximo a cada '
                '${info.minAutoInterval?.inMinutes ?? 30} minutos por ativo. '
                '"Atualizar agora" consulta a qualquer hora.',
                style: muted,
              ),
            if (info.attribution != null) Text(info.attribution!, style: muted),
            Text(info.site, style: muted),
            if (info.key != KeyRequirement.none) ...[
              const SizedBox(height: 8),
              _keyRow(hasKey),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: Key('provider-test-${info.code}'),
                onPressed: !s.enabled || _testing ? null : _test,
                icon: const Icon(Icons.network_check, size: 18),
                label: Text(_testing ? 'Testando…' : 'Testar conexão'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyRow(bool hasKey) {
    final info = _info;
    final required = info.key == KeyRequirement.required;
    if (hasKey && !_editingKey) {
      return Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.key, size: 18, semanticLabel: 'Chave'),
          const Text('Chave cadastrada neste computador'),
          TextButton(
            onPressed: () => setState(() => _editingKey = true),
            child: const Text('Trocar'),
          ),
          TextButton(
            key: Key('key-delete-${info.code}'),
            onPressed: _deleteKey,
            child: const Text('Apagar'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required
              ? 'Precisa de chave. ${info.keyHelp ?? ''}'
              : 'Chave opcional (amplia o acesso). ${info.keyHelp ?? ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 360,
              child: TextField(
                key: Key('key-field-${info.code}'),
                controller: _keyField,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Chave de API',
                  isDense: true,
                  helperText:
                      'Fica só neste computador, protegida pelo Windows. Não '
                      'vai no save, nos backups nem no log.',
                ),
                onSubmitted: (_) => _saveKey(),
              ),
            ),
            FilledButton(
              key: Key('key-save-${info.code}'),
              onPressed: _saveKey,
              child: const Text('Guardar chave'),
            ),
            if (_editingKey)
              TextButton(
                onPressed: () => setState(() {
                  _editingKey = false;
                  _keyField.clear();
                }),
                child: const Text('Cancelar'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Ativos com preço informado que o app sabe cotar: oferece trocar para a
/// cotação automática (os ativos criados antes da F6 ficaram com preço
/// informado).
class _ManualAssetsCard extends ConsumerWidget {
  const _ManualAssetsCard();

  static Asset _withMarket(Asset a) => Asset(
    id: a.id,
    symbol: a.symbol,
    market: a.market,
    assetClass: a.assetClass,
    name: a.name,
    currency: a.currency,
    country: a.country,
    priceSource: PriceSource.market,
    isin: a.isin,
    sector: a.sector,
    segment: a.segment,
    liquidity: a.liquidity,
    notes: a.notes,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(portfolioSnapshotProvider).value;
    if (snap == null) return const SizedBox.shrink();
    final candidates = [
      for (final a in snap.assets.values)
        if (a.priceSource == PriceSource.manual &&
            MarketPricing.hasAutomaticSource(a.assetClass))
          a,
    ]..sort((a, b) => a.symbol.compareTo(b.symbol));
    if (candidates.isEmpty) return const SizedBox.shrink();
    Future<void> apply() async {
      final ok = await confirm(
        context,
        title: 'Usar cotações automáticas?',
        message:
            '${candidates.map((a) => a.symbol).join(', ')} passam a usar a '
            'cotação das fontes de dados. Os preços e saldos que você '
            'informou continuam guardados e valem quando forem mais '
            'recentes que a cotação. Dá para voltar em Editar, no detalhe '
            'de cada ativo.',
        confirmLabel: 'Usar cotações',
      );
      if (!ok) return;
      try {
        final registry = ref.read(registryServiceProvider);
        for (final a in candidates) {
          await registry.updateAsset(
            _withMarket(a),
            terms: snap.fixedIncome[a.id],
          );
        }
        if (context.mounted) {
          showInfo(context, 'Pronto. Use "Atualizar agora" para buscar.');
        }
      } on Object catch (error) {
        if (context.mounted) showError(context, error);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('manual-assets'),
        child: ListTile(
          leading: const Icon(Icons.price_change_outlined),
          title: Text(
            '${candidates.length} '
            '${candidates.length == 1 ? 'ativo usa' : 'ativos usam'} preço '
            'informado, mas ${candidates.length == 1 ? 'tem' : 'têm'} '
            'cotação automática disponível',
          ),
          subtitle: Text(candidates.map((a) => a.symbol).join(', ')),
          trailing: FilledButton.tonal(
            key: const Key('manual-assets-apply'),
            onPressed: apply,
            child: const Text('Usar cotações'),
          ),
        ),
      ),
    );
  }
}

/// Uso da cota mensal de um provedor neste computador (SPEC §5: respeito aos
/// limites), com aviso a partir de 80% e ao esgotar.
class QuotaMeter extends StatelessWidget {
  const QuotaMeter({required this.state, super.key});

  final ProviderState state;

  /// Requisições do mês atual (a contagem de um mês anterior não vale).
  static int usedNow(ProviderState s, DateTime now) =>
      s.quotaPeriod == ProviderStateRepository.periodOf(now) ? s.quotaUsed : 0;

  @override
  Widget build(BuildContext context) {
    final quota = state.info.monthlyQuota!;
    final now = DateTime.now();
    final used = usedNow(state, now);
    final theme = Theme.of(context);
    final warn = used >= quota * ProviderInfo.quotaWarningFraction;
    final exhausted = used >= quota;
    final color = warn ? theme.colorScheme.error : null;
    final pct = (used * 100) ~/ quota;
    return Padding(
      key: Key('quota-${state.info.code}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cota do mês (${ProviderStateRepository.periodOf(now)}): '
            '${Fmt.number(Decimal.fromInt(used))} de '
            '${Fmt.number(Decimal.fromInt(quota))} requisições ($pct%)',
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 360,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                // Conversão para desenho apenas (regra 6, exceção).
                value: (used / quota).clamp(0, 1).toDouble(),
                minHeight: 6,
                color: color,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          if (warn)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                exhausted
                    ? 'Cota esgotada: até o mês que vem, os ativos da B3 usam o '
                          'fechamento oficial do COTAHIST.'
                    : 'Mais de 80% da cota usada. Ao acabar, os ativos da B3 '
                          'passam a usar o fechamento oficial do COTAHIST.',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          Text(
            'Contadas neste computador; a brapi conta todas as requisições '
            'da sua chave, inclusive de outros PCs.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso no Início quando a cota de algum provedor passou de 80%.
class QuotaWarningBanner extends ConsumerWidget {
  const QuotaWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final states = ref.watch(providerStatesProvider).value ?? const [];
    final now = DateTime.now();
    final over = [
      for (final s in states)
        if (s.info.monthlyQuota case final q?)
          if (s.enabled &&
              QuotaMeter.usedNow(s, now) >=
                  q * ProviderInfo.quotaWarningFraction)
            s,
    ];
    if (over.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('quota-warning'),
        child: ListTile(
          leading: Icon(
            Icons.data_usage,
            color: theme.colorScheme.error,
            semanticLabel: 'Aviso de cota',
          ),
          title: Text(
            [
              for (final s in over)
                QuotaMeter.usedNow(s, now) >= s.info.monthlyQuota!
                    ? 'A cota mensal de ${s.info.name} acabou: até o mês que '
                          'vem, os ativos da B3 usam o fechamento oficial do '
                          'COTAHIST.'
                    : MarketDataService.quotaNotice(
                        s.info.code,
                        QuotaMeter.usedNow(s, now),
                        s.info.monthlyQuota!,
                      ),
            ].join('\n'),
          ),
          trailing: TextButton(
            onPressed: () => GoRouter.of(context).go('/fontes'),
            child: const Text('Fontes de dados'),
          ),
        ),
      ),
    );
  }
}
