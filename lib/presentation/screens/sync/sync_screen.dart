import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../application/sync/save_service.dart';
import '../../../core/time/instant_format.dart';
import '../../../data/db/app_database.dart';
import '../../../domain/sync/invsave_codec.dart';
import '../../../domain/sync/merge_planner.dart';
import '../../format/sync_labels.dart';
import '../../providers.dart';
import '../../services/open_requests.dart';
import '../../widgets/common.dart';
import '../security/security_dialogs.dart';
import 'import_preview_dialog.dart';
import 'save_password_dialog.dart';
import '../../router/app_router.dart';

/// Dias sem sincronizar a partir dos quais o app avisa (sem bloquear,
/// SPEC §10.5).
const staleSyncDays = 7;

/// Sincronização entre computadores pelo arquivo de save (SPEC §10).
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _busy = false;
  OpenRequests? _requests;

  @override
  void initState() {
    super.initState();
    // Arquivo aberto pelo Explorador: começa a importação com a prévia, que
    // pede a confirmação antes de aplicar (D-39).
    _requests = ref.read(openRequestsProvider)?..addListener(_openPending);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPending());
  }

  @override
  void dispose() {
    _requests?.removeListener(_openPending);
    super.dispose();
  }

  void _openPending() {
    if (!mounted || _busy) return;
    final path = _requests?.take();
    if (path == null) return;
    unawaited(_run(() => _import(thenExport: false, path: path)));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Não foi possível concluir'),
            content: Text(errorMessage(e)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        // Um arquivo pode ter chegado durante a ação.
        scheduleMicrotask(_openPending);
      }
    }
  }

  Future<void> _export({String? importedPassword}) async {
    final choice = await showDialog<({String? password, bool market})>(
      context: context,
      builder: (context) => SavePasswordDialog(
        protectByDefault:
            ref.read(sessionControllerProvider)?.lockEnabled ?? false,
        importedPassword: importedPassword,
      ),
    );
    if (choice == null) return;
    final service = ref.read(saveServiceProvider);
    final export = await service.buildExport(
      password: choice.password,
      includeMarket: choice.market,
    );
    final path = await ref
        .read(fileDialogsProvider)
        .saveBytes(
          dialogTitle: 'Salvar arquivo de save',
          suggestedName: export.suggestedFileName,
          extension: InvsaveCodec.extension,
          bytes: export.bytes,
        );
    if (path == null) return;
    await service.recordExport(export, p.basename(path));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _ExportSummary(export: export, path: path),
    );
  }

  /// Sem [path], pede o arquivo ao usuário.
  Future<void> _import({required bool thenExport, String? path}) async {
    final chosen =
        path ??
        await ref
            .read(fileDialogsProvider)
            .pickFile(
              dialogTitle: 'Escolha o arquivo de save',
              extensions: const [InvsaveCodec.extension],
            );
    if (chosen == null) return;
    final service = ref.read(saveServiceProvider);
    final bytes = await File(chosen).readAsBytes();
    String? password;
    if (InvsaveCodec.isProtected(bytes)) {
      if (!mounted) return;
      password = await showDialog<String>(
        context: context,
        builder: (context) => PasswordPromptDialog(
          title: 'Arquivo protegido por senha',
          message:
              'O save ${p.basename(chosen)} foi protegido com uma senha no '
              'outro computador. Digite a senha do arquivo.',
          label: 'Senha do arquivo',
          action: 'Abrir',
        ),
      );
      if (password == null) return;
    }
    final preview = await service.preview(
      bytes,
      fileName: p.basename(chosen),
      password: password,
    );
    if (!mounted) return;
    final choices = await showDialog<Map<RowRef, MergeSide>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImportPreviewDialog(
        preview: preview,
        thenExport: thenExport,
        recheck: (choices) =>
            service.consistency(preview, resolutions: choices),
      ),
    );
    if (choices == null) return;
    final result = await service.apply(preview, resolutions: choices);
    if (!mounted) return;
    final plan = result.plan;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text(
          plan.visibleChanges == 0
              ? 'Importação concluída: nenhuma alteração visível.'
              : 'Importação concluída: ${plan.visibleChanges} '
                    '${plan.visibleChanges == 1 ? 'alteração' : 'alterações'}.',
        ),
      ),
    );
    if (thenExport) await _export(importedPassword: password);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Sincronização',
      subtitle:
          'Leve os dados de um computador para outro com o arquivo de save '
          '(.invsave), sem internet',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _run(_export),
                icon: const Icon(Icons.save_alt),
                label: const Text('Salvar arquivo de save'),
              ),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => _import(thenExport: false)),
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Importar save…'),
              ),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => _import(thenExport: true)),
                icon: const Icon(Icons.sync),
                label: const Text('Importar e gerar novo save…'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_busy) const LinearProgressIndicator(),
          const _HowTo(),
          const _PeersCard(),
          const _HistoryCard(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _HowTo extends StatelessWidget {
  const _HowTo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      title: 'Como sincronizar',
      child: Text(
        'Quando houver alterações nos dois computadores:\n'
        '1. No PC A, "Salvar arquivo de save".\n'
        '2. Leve o arquivo ao PC B (pendrive, rede, e-mail ou nuvem) e use '
        '"Importar e gerar novo save": ele mescla e já gera o save de volta.\n'
        '3. No PC A, importe o save gerado no PC B.\n\n'
        'O save leva todos os registros (inclusive exclusões) e é mesclado '
        'registro a registro: nada é apagado sem aparecer na prévia, e '
        'importar o mesmo arquivo de novo não muda nada. Configurações deste '
        'computador, logs e chaves de API não vão no arquivo. Ao salvar, você '
        'pode proteger o arquivo com senha (criptografado; já vem marcado com '
        'o bloqueio do app ativo).',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _PeersCard extends ConsumerWidget {
  const _PeersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peers = ref.watch(syncPeersProvider).value ?? const [];
    return _Section(
      title: 'Computadores sincronizados',
      child: peers.isEmpty
          ? const Text('Nenhuma importação de outro computador ainda.')
          : Column(children: [for (final peer in peers) _PeerTile(peer: peer)]),
    );
  }
}

class _PeerTile extends StatelessWidget {
  const _PeerTile({required this.peer});

  final DevSyncPeerRow peer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = daysSince(peer.lastSyncAt);
    final stale = days != null && days >= staleSyncDays;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        stale ? Icons.warning_amber_outlined : Icons.computer,
        color: stale ? theme.colorScheme.error : null,
        semanticLabel: stale ? 'Sincronização antiga' : null,
      ),
      title: Text(peer.peerName),
      subtitle: Text(
        'Última importação: ${SyncLabels.instant(peer.lastSyncAt)}'
        '${days == null ? '' : ' (há $days ${days == 1 ? 'dia' : 'dias'})'}',
      ),
    );
  }
}

/// Dias inteiros desde o instante gravado [at].
int? daysSince(String at) {
  try {
    return clock.now().toUtc().difference(parseInstant(at)).inDays;
  } on FormatException {
    return null;
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(syncHistoryProvider).value ?? const [];
    return _Section(
      title: 'Histórico',
      child: history.isEmpty
          ? const Text('Nenhum save exportado ou importado ainda.')
          : Column(
              children: [
                for (final h in history)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      h.result != 'ok'
                          ? Icons.error_outline
                          : h.direction == 'export'
                          ? Icons.upload_file
                          : Icons.download,
                      semanticLabel: h.result != 'ok' ? 'Falhou' : null,
                    ),
                    title: Text(
                      '${SyncLabels.instant(h.at)} · '
                      '${h.direction == 'export' ? 'Exportado' : 'Importado'}'
                      '${h.peerName != null && h.direction == 'import' ? ' de ${h.peerName}' : ''}'
                      ' · ${h.fileName}',
                    ),
                    subtitle: Text(_historyDetail(h)),
                  ),
              ],
            ),
    );
  }

  static String _historyDetail(DevSyncHistoryRow h) {
    if (h.result != 'ok') {
      return 'Falhou: ${h.message ?? ''} Nada foi alterado.';
    }
    final counts = jsonDecode(h.countsJson) as Map<String, Object?>;
    if (h.direction == 'export') {
      final total = counts.values.whereType<int>().fold(0, (a, b) => a + b);
      return '$total registros';
    }
    var changes = 0;
    for (final v in counts.values) {
      if (v is Map<String, Object?>) {
        changes += v.values.whereType<int>().fold(0, (a, b) => a + b);
      }
    }
    final conflicts = counts['conflicts'] ?? 0;
    final unified = counts['unifications'] ?? 0;
    return '$changes alterações, $conflicts conflitos, $unified unificações';
  }
}

class _ExportSummary extends StatelessWidget {
  const _ExportSummary({required this.export, required this.path});

  final SaveExport export;
  final String path;

  @override
  Widget build(BuildContext context) {
    final counts = export.manifest.counts.entries.where((e) => e.value > 0);
    return AlertDialog(
      title: const Text('Arquivo de save salvo'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(path),
            const SizedBox(height: 8),
            Text(
              '${export.totalRecords} registros '
              '(${SyncLabels.bytes(export.bytes.length)})'
              '${export.protected ? ', protegido por senha' : ', sem senha'}.',
            ),
            const SizedBox(height: 8),
            for (final e in counts)
              Text('${SyncLabels.table(e.key)}: ${e.value}'),
            Text(
              export.marketRecords == 0
                  ? 'Dados de mercado: não incluídos'
                  : 'Dados de mercado: ${export.marketRecords} registros',
            ),
            const SizedBox(height: 12),
            const Text(
              'Leve este arquivo ao outro computador e use "Importar save" '
              'lá.',
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Aviso, sem bloquear, de que a última sincronização com algum computador
/// é antiga (SPEC §10.5). Some quando não há o que avisar.
class SyncReminder extends ConsumerWidget {
  const SyncReminder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peers = ref.watch(syncPeersProvider).value ?? const [];
    final stale = [
      for (final p in peers)
        if ((daysSince(p.lastSyncAt) ?? 0) >= staleSyncDays) p,
    ];
    if (stale.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final names = stale.map((p) => p.peerName).join(', ');
    final days = daysSince(stale.first.lastSyncAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.sync_problem_outlined,
            color: theme.colorScheme.error,
            semanticLabel: 'Sincronização antiga',
          ),
          title: Text(
            'A última sincronização com $names foi há $days dias. Gere um '
            'save para manter os computadores iguais.',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: TextButton(
            onPressed: () => GoRouter.of(context).go(Routes.sync),
            child: const Text('Sincronizar'),
          ),
        ),
      ),
    );
  }
}
