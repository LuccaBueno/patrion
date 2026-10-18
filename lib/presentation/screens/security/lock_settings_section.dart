import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/lock_preferences.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import 'security_dialogs.dart';

/// Configurações do bloqueio do app (SPEC §3): ativar, senha, chave de
/// recuperação, Windows Hello, tempo de inatividade e desativar.
class LockSettingsSection extends ConsumerStatefulWidget {
  const LockSettingsSection({super.key});

  @override
  ConsumerState<LockSettingsSection> createState() =>
      _LockSettingsSectionState();
}

class _LockSettingsSectionState extends ConsumerState<LockSettingsSection> {
  bool _busy = false;
  bool _noticeDismissed = false;
  bool? _helloAvailable;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(sessionControllerProvider);
    controller?.helloAvailable().then((v) {
      if (mounted) setState(() => _helloAvailable = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final code = controller?.takePendingRecoveryKey();
      if (code != null && mounted) _showRecoveryKey(code);
    });
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showRecoveryKey(String code) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RecoveryKeyDialog(code: code),
  );

  Future<String?> _askPassword(String title, String message) =>
      showDialog<String>(
        context: context,
        builder: (context) =>
            PasswordPromptDialog(title: title, message: message),
      );

  Future<void> _enable(SessionController controller) async {
    final input = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => const EnableLockDialog(),
    );
    if (input == null) return;
    // A sessão é trocada e esta tela é remontada: a tela nova mostra a
    // chave de recuperação (`takePendingRecoveryKey`).
    await _run(() => controller.enableLock(input.$1, encryptBackups: input.$2));
  }

  Future<void> _disable(SessionController controller) async {
    final password = await _askPassword(
      'Desativar o bloqueio',
      'O banco de dados volta a ficar sem criptografia, e o app passa a abrir '
          'sem senha. Antes, o app faz um backup (criptografado). Os backups '
          'criptografados continuam pedindo a senha atual para serem '
          'restaurados.',
    );
    if (password == null) return;
    await _run(() => controller.disableLock(password));
  }

  Future<void> _changePassword(SessionController controller) async {
    final input = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
    if (input == null) return;
    var changed = false;
    await _run(() async {
      await controller.changePassword(input.$1, input.$2);
      changed = true;
    });
    if (!changed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        showCloseIcon: true,
        content: Text(
          'Senha trocada. Os backups feitos antes continuam abrindo com a '
          'chave do banco, que não mudou.',
        ),
      ),
    );
  }

  Future<void> _newRecoveryKey(SessionController controller) async {
    final password = await _askPassword(
      'Gerar nova chave de recuperação',
      'A chave de recuperação atual deixa de valer para este banco. Digite '
          'a senha para continuar.',
    );
    if (password == null) return;
    String? code;
    await _run(() async => code = await controller.newRecoveryKey(password));
    if (code != null && mounted) await _showRecoveryKey(code!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(sessionControllerProvider);
    if (controller == null) return const SizedBox.shrink();
    final notice = ref.watch(lockNoticeProvider);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final muted = theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
        final enabled = controller.lockEnabled;
        final children = <Widget>[
          if (notice != null && !_noticeDismissed)
            Card(
              color: theme.colorScheme.secondaryContainer,
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
          if (_busy) const LinearProgressIndicator(),
        ];
        if (!enabled) {
          children.addAll([
            Text(
              'Desativado. Com o bloqueio, o banco de dados deste computador '
              'é criptografado (SQLCipher) e só abre com a senha; o app se '
              'bloqueia sozinho depois de um tempo sem uso, e os backups '
              'também ficam criptografados.',
              style: muted,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _enable(controller),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Ativar o bloqueio…'),
              ),
            ),
          ]);
        } else {
          final idle =
              ref.watch(idleMinutesProvider).value ??
              LockPreferences.defaultIdleMinutes;
          children.addAll([
            Text(
              'Ativado. O banco de dados deste computador é criptografado e '
              'só abre com a senha, a chave de recuperação ou o Windows Hello.',
              style: muted,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : () => _run(controller.lockNow),
                  icon: const Icon(Icons.lock),
                  label: const Text('Bloquear agora'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : () => _changePassword(controller),
                  child: const Text('Trocar a senha…'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : () => _newRecoveryKey(controller),
                  child: const Text('Gerar nova chave de recuperação…'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bloquear depois de'),
              subtitle: const Text('Tempo sem usar o mouse ou o teclado.'),
              trailing: DropdownButton<int>(
                key: const Key('idle-minutes'),
                value: LockPreferences.idleOptions.contains(idle) ? idle : null,
                items: [
                  for (final m in LockPreferences.idleOptions)
                    DropdownMenuItem(
                      value: m,
                      child: Text(
                        m == 0
                            ? 'Nunca'
                            : m == 1
                            ? '1 minuto'
                            : '$m minutos',
                      ),
                    ),
                ],
                onChanged: _busy
                    ? null
                    : (v) =>
                          ref.read(lockPreferencesProvider).setIdleMinutes(v!),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.helloEnabled,
              onChanged: _busy || _helloAvailable != true
                  ? null
                  : (v) => _run(() => controller.setHello(v)),
              title: const Text('Desbloquear com o Windows Hello'),
              subtitle: Text(
                _helloAvailable == false
                    ? 'O Windows Hello (rosto, digital ou PIN) não está '
                          'configurado neste computador.'
                    : 'Rosto, digital ou PIN do Windows; a senha continua '
                          'valendo. A chave fica protegida pela sua conta do '
                          'Windows: protege contra quem copia a pasta de '
                          'dados, mas não contra quem já está logado na sua '
                          'conta.',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : () => _disable(controller),
                icon: const Icon(Icons.lock_open),
                label: const Text('Desativar o bloqueio…'),
              ),
            ),
          ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}
