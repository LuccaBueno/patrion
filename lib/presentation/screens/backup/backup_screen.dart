import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/backup/backup_service.dart';
import '../../../core/errors/app_error.dart';
import '../../../domain/backup/backup_metadata.dart';
import '../../format/sync_labels.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../security/security_dialogs.dart';

/// Backups do banco deste computador e restauração (SPEC §11).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  bool _noticeDismissed = false;

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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup({required bool chooseFolder}) async {
    String? folder;
    if (chooseFolder) {
      folder = await ref
          .read(fileDialogsProvider)
          .pickDirectory(dialogTitle: 'Pasta do backup');
      if (folder == null) return;
    }
    final row = await ref
        .read(backupServiceProvider)
        .createManual(directory: folder);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        content: Text('Backup criado e verificado: ${row.path}'),
      ),
    );
  }

  Future<void> _restoreFromFile() async {
    final path = await ref
        .read(fileDialogsProvider)
        .pickFile(dialogTitle: 'Escolha o backup', extensions: const ['db']);
    if (path != null) await _restore(path);
  }

  Future<void> _restore(String path) async {
    final controller = ref.read(sessionControllerProvider);
    if (controller == null) {
      throw const InternalError('Restauração indisponível nesta execução.');
    }
    // Confere antes de pedir a confirmação: um arquivo recusado nem chega a
    // ser oferecido.
    final backups = ref.read(backupServiceProvider);
    String? secret;
    RestoreCandidate candidate;
    try {
      candidate = backups.checkRestore(path);
    } on BackupLockedError {
      // Criptografado com a chave de antes de o bloqueio ser desativado e
      // ativado de novo: pede a senha daquela época.
      if (!mounted) return;
      secret = await showDialog<String>(
        context: context,
        builder: (context) => const PasswordPromptDialog(
          title: 'Backup protegido por outra senha',
          message:
              'Este backup foi criptografado com uma chave anterior do '
              'bloqueio. Digite a senha (ou a chave de recuperação) que '
              'valia quando ele foi feito.',
          label: 'Senha ou chave de recuperação',
          action: 'Abrir',
        ),
      );
      if (secret == null) return;
      final key = await backups.unlockBackup(path, secret);
      try {
        candidate = backups.checkRestore(path, backupKey: key);
      } finally {
        key.destroy();
      }
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmRestoreDialog(candidate: candidate),
    );
    if (confirmed != true) return;
    await controller.restore(path, backupSecret: secret);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final env = ref.watch(appEnvironmentProvider);
    final notice = ref.watch(sessionNoticeProvider);
    final backups = ref.watch(backupsProvider);

    return PageScaffold(
      title: 'Backup',
      subtitle:
          'Cópias integrais do banco deste computador, para recuperação. '
          'Restaurar substitui todos os dados',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => _backup(chooseFolder: false)),
                icon: const Icon(Icons.backup_outlined),
                label: const Text('Fazer backup agora'),
              ),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => _backup(chooseFolder: true)),
                icon: const Icon(Icons.drive_folder_upload_outlined),
                label: const Text('Backup em outra pasta…'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _run(_restoreFromFile),
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar de um arquivo…'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_busy) const LinearProgressIndicator(),
          if (notice != null && !_noticeDismissed)
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(notice),
                trailing: IconButton(
                  tooltip: 'Fechar aviso',
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _noticeDismissed = true),
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Como funciona', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'O backup é uma cópia consistente do banco, conferida '
                    '(integridade e versão) assim que é criada. O app também '
                    'faz backups automáticos antes de atualizar o banco, de '
                    'importar um save e de restaurar um backup, e guarda os '
                    '10 mais recentes de cada tipo; os manuais nunca são '
                    'apagados pelo app. Com o bloqueio ativo '
                    '(Configurações), os backups saem criptografados com a '
                    'chave do banco e levam ao lado um arquivo .keys.json, '
                    'que permite abri-los com a senha.\n\n'
                    'Para levar dados a outro computador, use a '
                    'Sincronização (save): o backup substitui tudo, o save '
                    'mescla.\n\nPasta dos backups: ${env.paths.backupsDir}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AsyncBody(
            value: backups,
            builder: (list) => list.isEmpty
                ? const Text('Nenhum backup registrado ainda.')
                : Card(
                    child: Column(
                      children: [
                        for (final entry in list)
                          _BackupTile(
                            entry: entry,
                            onRestore: _busy
                                ? null
                                : () => _run(() => _restore(entry.row.path)),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({required this.entry, required this.onRestore});

  final BackupEntry entry;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = entry.row;
    final reason = entry.reason?.label ?? row.reason;
    return ListTile(
      leading: Icon(
        entry.fileExists ? Icons.inventory_2_outlined : Icons.error_outline,
        color: entry.fileExists ? null : theme.colorScheme.error,
        semanticLabel: entry.fileExists ? null : 'Arquivo não encontrado',
      ),
      title: Text('${SyncLabels.instant(row.at)} · $reason'),
      subtitle: Text(
        '${entry.fileExists ? '' : 'Arquivo não encontrado · '}'
        '${entry.encrypted ? 'criptografado · ' : ''}'
        'schema ${row.schemaVersion} · app ${row.appVersion} · '
        '${SyncLabels.bytes(row.size)}\n${row.path}',
      ),
      isThreeLine: true,
      trailing: entry.fileExists
          ? TextButton(onPressed: onRestore, child: const Text('Restaurar'))
          : null,
    );
  }
}

class _ConfirmRestoreDialog extends StatefulWidget {
  const _ConfirmRestoreDialog({required this.candidate});

  final RestoreCandidate candidate;

  @override
  State<_ConfirmRestoreDialog> createState() => _ConfirmRestoreDialogState();
}

class _ConfirmRestoreDialogState extends State<_ConfirmRestoreDialog> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
    final m = c.metadata;
    return AlertDialog(
      title: const Text('Restaurar este backup?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(c.path),
            const SizedBox(height: 8),
            if (m != null)
              Text(
                'Criado em ${SyncLabels.instant(m.createdAt)} '
                '(${m.reason.label.toLowerCase()}), no computador '
                '${m.deviceName ?? c.info.deviceName ?? '?'}, Patrion '
                '${m.appVersion}.',
              )
            else
              Text(
                'Backup sem metadados, do computador '
                '${c.info.deviceName ?? '?'}.',
              ),
            Text(
              'Schema ${c.info.schemaVersion}; integridade conferida'
              '${m == null ? '' : ' e SHA-256 igual ao do momento do backup'}.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Todos os dados atuais deste computador serão substituídos pelo '
              'conteúdo do backup. Antes, o app faz um backup automático do '
              'estado atual, para você poder voltar.',
            ),
            if (m != null && m.reason == BackupReason.preMigration)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Este backup é de uma versão anterior do banco: ele será '
                  'atualizado ao abrir.',
                ),
              ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _understood,
              onChanged: (v) => setState(() => _understood = v ?? false),
              title: const Text(
                'Entendo que os dados atuais serão substituídos',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _understood ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Restaurar'),
        ),
      ],
    );
  }
}
