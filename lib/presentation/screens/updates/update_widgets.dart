import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../../application/updates/update_checker.dart';
import '../../../core/time/instant_format.dart';
import '../../format/sync_labels.dart';
import '../../providers.dart';
import '../../router/app_router.dart';

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
      await ref.read(updateCheckerProvider).checkIfDue();
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

/// Aviso no Início quando há uma versão nova não ignorada.
class UpdateReminder extends ConsumerWidget {
  const UpdateReminder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(updateSnapshotProvider).value?.available;
    if (release == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('update-reminder'),
        child: ListTile(
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
          trailing: TextButton(
            onPressed: () => GoRouter.of(context).go(Routes.about),
            child: const Text('Ver detalhes'),
          ),
        ),
      ),
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

class _ReleaseCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            'Para atualizar, baixe o instalador na página da versão e '
            'execute-o com o Patrion fechado. Os dados ficam onde estão.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
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
