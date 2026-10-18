import 'package:flutter/material.dart';

import '../../../core/config/app_info.dart';
import '../../../core/errors/app_error.dart';
import '../../session/app_session.dart';
import '../../theme/app_theme.dart';
import 'security_dialogs.dart';

/// App bloqueado (SPEC §3): só a tela de desbloqueio existe; o banco está
/// fechado.
class UnlockApp extends StatelessWidget {
  const UnlockApp({required this.manager, super.key});

  final SessionManager manager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: UnlockScreen(manager: manager),
    );
  }
}

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({required this.manager, super.key});

  final SessionManager manager;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is AppError ? e.message : 'Erro: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unlock() => _run(() async {
    final text = _password.text;
    _password.clear();
    await widget.manager.unlockWithPassword(text);
  });

  Future<void> _recover() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const RecoveryDialog(),
    );
    if (result == null) return;
    await _run(
      () => widget.manager.unlockWithRecoveryKey(result.$1, result.$2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hello = widget.manager.helloEnabled;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/branding/patrion-simbolo-256.png',
                  height: 72,
                  semanticLabel: AppInfo.name,
                ),
                const SizedBox(height: 16),
                Text(
                  '${AppInfo.name} bloqueado',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite a senha deste computador para abrir os dados.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('unlock-password'),
                  controller: _password,
                  obscureText: _obscure,
                  autofocus: true,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    errorText: _error,
                    errorMaxLines: 3,
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Mostrar a senha' : 'Ocultar a senha',
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _unlock,
                  child: const Text('Desbloquear'),
                ),
                if (hello) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _run(widget.manager.unlockWithHello),
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Usar o Windows Hello'),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : _recover,
                  child: const Text('Esqueci a senha'),
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
