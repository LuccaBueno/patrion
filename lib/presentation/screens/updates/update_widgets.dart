import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../../application/updates/update_checker.dart';
import '../../../application/updates/update_installer.dart';
import '../../../core/config/app_info.dart';
import '../../../core/time/instant_format.dart';
import '../../format/sync_labels.dart';
import '../../providers.dart';
import '../../router/app_router.dart';
import '../../services/update_task.dart';

final _log = Logger('updates');

/// Consulta automática de atualizações, um pouco depois de abrir (SPEC §19).
/// Sem internet, falha em silêncio; nunca atrapalha o uso.
class UpdateAutoCheck extends ConsumerStatefulWidget {
  const UpdateAutoCheck({
    required this.child,
    this.delay = const Duration(seconds: 10),
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  ConsumerState<UpdateAutoCheck> createState() => _UpdateAutoCheckState();
}

class _UpdateAutoCheckState extends ConsumerState<UpdateAutoCheck> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () => unawaited(_check()));
  }

  Future<void> _check() async {
    if (!mounted) return;
    try {
      final state = await ref.read(updateCheckerProvider).checkIfDue();
      final release = state.available;
      if (mounted &&
          state.installOnClose &&
          release != null &&
          ref.read(selfUpdateAvailableProvider)) {
        await ref
            .read(updateTaskProvider.notifier)
            .prepareInBackground(release);
      }
    } on Object catch (error) {
      _log.fine('Verificação automática falhou', error);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Aviso no Início: o resultado da última atualização e a versão nova não
/// ignorada, com "Atualizar agora".
class UpdateReminder extends ConsumerWidget {
  const UpdateReminder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcome = ref.watch(updateOutcomeProvider).value;
    final release = ref.watch(updateSnapshotProvider).value?.available;
    final task = ref.watch(updateTaskProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (outcome != null) _OutcomeCard(outcome),
        if (release != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              key: const Key('update-reminder'),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.system_update_alt,
                      color: theme.colorScheme.primary,
                      semanticLabel: 'Atualização disponível',
                    ),
                    title: Text(
                      'Nova versão disponível: ${release.version}'
                      '${release.prerelease ? ' (versão de teste)' : ''}.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (ref.watch(selfUpdateAvailableProvider))
                          _UpdateNowButton(release),
                        TextButton(
                          onPressed: () =>
                              GoRouter.of(context).go(Routes.about),
                          child: const Text('Ver detalhes'),
                        ),
                      ],
                    ),
                  ),
                  if (task.busy || task.phase == UpdatePhase.failed)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _UpdateProgress(),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Resultado da atualização: versão nova com as notas, ou o que fazer.
class _OutcomeCard extends ConsumerWidget {
  const _OutcomeCard(this.outcome);

  final UpdateOutcome outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notes = outcome.notes.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('update-outcome'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    outcome.updated ? Icons.check_circle : Icons.error_outline,
                    color: outcome.updated
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    semanticLabel: outcome.updated
                        ? 'Atualizado'
                        : 'Atualização não concluída',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      outcome.updated
                          ? 'Atualizado para a versão ${outcome.to}.'
                          : 'A atualização para a versão ${outcome.to} não '
                                'foi concluída.',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(updateOutcomeProvider.notifier).dismiss(),
                  ),
                ],
              ),
              if (!outcome.updated)
                SelectableText(
                  'Sua versão continua funcionando, com os dados como '
                  'estavam. O backup feito antes de atualizar está em Backup. '
                  'Detalhes: ${outcome.log ?? 'sem log'}.',
                  style: theme.textTheme.bodySmall,
                )
              else if (notes.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      notes,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Atualizar agora": desabilitado enquanto outra atualização anda.
class _UpdateNowButton extends ConsumerWidget {
  const _UpdateNowButton(this.release);

  final ReleaseInfo release;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(updateTaskProvider).busy;
    return FilledButton.icon(
      key: const Key('update-now'),
      onPressed: busy
          ? null
          : () => ref.read(updateTaskProvider.notifier).updateNow(release),
      icon: const Icon(Icons.system_update_alt),
      label: const Text('Atualizar agora'),
    );
  }
}

/// Barra de progresso do download, com cancelar, e a mensagem de falha.
class _UpdateProgress extends ConsumerWidget {
  const _UpdateProgress();

  static String _megabytes(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(updateTaskProvider);
    final theme = Theme.of(context);
    switch (task.phase) {
      case UpdatePhase.idle:
        return const SizedBox.shrink();
      case UpdatePhase.failed:
        return Text(
          task.message ?? 'Não foi possível atualizar.',
          key: const Key('update-error'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
      case UpdatePhase.installing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(
              'Fazendo o backup e abrindo o instalador. O app fecha e reabre '
              'sozinho.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      case UpdatePhase.downloading:
        final total = task.total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              key: const Key('update-progress'),
              value: task.fraction,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    total == null
                        ? 'Baixando: ${_megabytes(task.received)} MB'
                        : 'Baixando: ${_megabytes(task.received)} de '
                              '${_megabytes(total)} MB',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  key: const Key('update-cancel'),
                  onPressed: () =>
                      ref.read(updateTaskProvider.notifier).cancel(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        );
    }
  }
}

/// Seção "Atualizações" das Configurações.
class UpdateSettingsSection extends ConsumerStatefulWidget {
  const UpdateSettingsSection({super.key});

  @override
  ConsumerState<UpdateSettingsSection> createState() =>
      _UpdateSettingsSectionState();
}

class _UpdateSettingsSectionState extends ConsumerState<UpdateSettingsSection> {
  bool _checking = false;
  String? _error;

  Future<void> _checkNow() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      await ref.read(updateCheckerProvider).checkNow();
    } on UpdateCheckFailure catch (e) {
      _error = e.message;
    } on Object catch (e) {
      _log.warning('Falha ao verificar atualizações', e);
      _error = 'Não foi possível verificar agora. Detalhes no log.';
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _open(Uri uri) async {
    final ok = await ref.read(linkOpenerProvider)(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o navegador: $uri')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final snapshot = ref.watch(updateSnapshotProvider).value;
    final checker = ref.read(updateCheckerProvider);
    final newer = snapshot?.newer;
    final skipped = newer != null && snapshot?.skipped == newer.version;

    final String status;
    if (snapshot?.checkedAt == null) {
      status = 'Ainda não verificado neste computador.';
    } else {
      final when = SyncLabels.instant(formatInstant(snapshot!.checkedAt!));
      status = newer == null
          ? 'Você está na versão mais recente (verificado em $when).'
          : 'Verificado em $when.';
    }

    final selfUpdate = ref.watch(selfUpdateAvailableProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Versão instalada: ${AppInfo.version}'
          '${snapshot?.latest == null ? '' : ' · Mais recente: ${snapshot!.latest!.version}'}',
          key: const Key('updates-versions'),
          style: theme.textTheme.bodyMedium,
        ),
        if (!selfUpdate)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Esta cópia não veio do instalador (versão portátil), então '
              'não se atualiza sozinha: baixe o ZIP novo na página da versão.',
              key: const Key('updates-portable'),
              style: muted,
            ),
          ),
        SwitchListTile(
          key: const Key('updates-automatic'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Verificar ao abrir o app'),
          subtitle: const Text(
            'No máximo uma vez por dia, nas Releases do GitHub. A consulta '
            'leva só o nome e a versão do app; sem internet, nada acontece.',
          ),
          value: snapshot?.automatic ?? true,
          onChanged: (v) => checker.setAutomatic(v),
        ),
        SwitchListTile(
          key: const Key('updates-prerelease'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Incluir versões de teste (beta e rc)'),
          value: snapshot?.includePrerelease ?? false,
          onChanged: (v) => checker.setIncludePrerelease(v),
        ),
        if (selfUpdate)
          SwitchListTile(
            key: const Key('updates-install-on-close'),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Baixar em segundo plano e instalar ao fechar o app',
            ),
            subtitle: const Text(
              'A versão nova é conferida como no "Atualizar agora" e entra '
              'na próxima vez que você abrir o app.',
            ),
            value: snapshot?.installOnClose ?? false,
            onChanged: (v) => checker.setInstallOnClose(v),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              key: const Key('updates-check-now'),
              onPressed: _checking ? null : _checkNow,
              icon: _checking
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Verificar agora'),
            ),
            Text(status, style: muted),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (newer != null) ...[
          const SizedBox(height: 16),
          _ReleaseCard(
            release: newer,
            skipped: skipped,
            onOpen: () => _open(newer.page),
            onSkip: () => checker.skip(skipped ? null : newer.version),
          ),
        ],
      ],
    );
  }
}

class _ReleaseCard extends ConsumerWidget {
  const _ReleaseCard({
    required this.release,
    required this.skipped,
    required this.onOpen,
    required this.onSkip,
  });

  final ReleaseInfo release;
  final bool skipped;
  final VoidCallback onOpen;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selfUpdate = ref.watch(selfUpdateAvailableProvider);
    final published = release.publishedAt == null
        ? ''
        : ', publicada em '
              '${SyncLabels.instant(formatInstant(release.publishedAt!))}';
    return Container(
      key: const Key('update-release'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Versão ${release.version} disponível$published'
            '${release.prerelease ? ' (versão de teste)' : ''}',
            style: theme.textTheme.titleSmall,
          ),
          if (skipped)
            Text(
              'Você pediu para ignorar esta versão: o Início não avisa.',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: SelectableText(
                release.notes.trim().isEmpty
                    ? 'Sem notas publicadas.'
                    : release.notes.trim(),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            selfUpdate
                ? 'O app baixa a versão, confere a assinatura, faz um backup, '
                      'fecha e reabre atualizado. Os dados ficam onde estão. '
                      'Se a versão nova não abrir, reinstale a anterior pela '
                      'página de Releases; o backup fica em Backup.'
                : 'Para atualizar, baixe o ZIP na página da versão. Os dados '
                      'ficam onde estão.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          const _UpdateProgress(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (selfUpdate) _UpdateNowButton(release),
              (selfUpdate ? OutlinedButton.icon : FilledButton.icon)(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir página de download'),
              ),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  skipped ? 'Voltar a avisar' : 'Ignorar esta versão',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
