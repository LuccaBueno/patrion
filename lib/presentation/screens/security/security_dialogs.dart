import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/security/recovery_key.dart';

/// Campo de senha com o botão de mostrar/ocultar.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    this.fieldKey,
    this.validator,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final Key? fieldKey;
  final String? Function(String?)? validator;
  final bool autofocus;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      obscureText: _obscure,
      autofocus: widget.autofocus,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        errorMaxLines: 3,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Mostrar' : 'Ocultar',
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// Senha nova e a confirmação, com as regras de [PasswordPolicy].
class _NewPasswordFields extends StatelessWidget {
  const _NewPasswordFields({
    required this.password,
    required this.confirm,
    this.label = 'Nova senha',
    this.autofocus = false,
  });

  final TextEditingController password;
  final TextEditingController confirm;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PasswordField(
          fieldKey: const Key('new-password'),
          controller: password,
          label: label,
          autofocus: autofocus,
          validator: (v) => PasswordPolicy.check(v ?? ''),
        ),
        const SizedBox(height: 8),
        PasswordField(
          fieldKey: const Key('new-password-confirm'),
          controller: confirm,
          label: 'Repita a senha',
          validator: (v) =>
              v == password.text ? null : 'As senhas não são iguais.',
        ),
      ],
    );
  }
}

/// Esqueci a senha: chave de recuperação e nova senha. Devolve
/// `(chave, nova senha)`.
class RecoveryDialog extends StatefulWidget {
  const RecoveryDialog({super.key});

  @override
  State<RecoveryDialog> createState() => _RecoveryDialogState();
}

class _RecoveryDialogState extends State<RecoveryDialog> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar o acesso'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digite a chave de recuperação que o Patrion mostrou quando o '
                'bloqueio foi ativado e defina uma nova senha. Sem a senha e '
                'sem a chave de recuperação, os dados não podem ser abertos.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('recovery-key'),
                controller: _code,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Chave de recuperação',
                  hintText: 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX',
                ),
                validator: (v) => RecoveryKey.normalize(v ?? '') == null
                    ? 'A chave tem 32 letras e números (os hífens são '
                          'opcionais).'
                    : null,
              ),
              const SizedBox(height: 8),
              _NewPasswordFields(password: _password, confirm: _confirm),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop((_code.text, _password.text));
          },
          child: const Text('Recuperar'),
        ),
      ],
    );
  }
}

/// Ativar o bloqueio. Devolve `(senha, criptografar backups antigos)`.
class EnableLockDialog extends StatefulWidget {
  const EnableLockDialog({super.key});

  @override
  State<EnableLockDialog> createState() => _EnableLockDialogState();
}

class _EnableLockDialogState extends State<EnableLockDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _encryptBackups = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Ativar o bloqueio'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O banco de dados deste computador será criptografado e só '
                  'abrirá com a senha. Antes, o app faz um backup. A senha vale '
                  'só para este PC.',
                ),
                const SizedBox(height: 8),
                Text(
                  'Depois de ativar, o app mostra uma chave de recuperação, uma '
                  'única vez. Guarde-a fora deste computador: sem a senha e sem '
                  'a chave de recuperação, os dados não podem ser recuperados.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                const SizedBox(height: 16),
                _NewPasswordFields(
                  password: _password,
                  confirm: _confirm,
                  label: 'Senha',
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _encryptBackups,
                  onChanged: (v) => setState(() => _encryptBackups = v!),
                  title: const Text(
                    'Criptografar também os backups já existentes na pasta de '
                    'backups (recomendado)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop((_password.text, _encryptBackups));
          },
          child: const Text('Ativar'),
        ),
      ],
    );
  }
}

/// Pede uma senha (para confirmar uma ação ou abrir um arquivo).
class PasswordPromptDialog extends StatefulWidget {
  const PasswordPromptDialog({
    required this.title,
    required this.message,
    this.action = 'Confirmar',
    this.label = 'Senha',
    super.key,
  });

  final String title;
  final String message;
  final String action;
  final String label;

  @override
  State<PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<PasswordPromptDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text.isEmpty) return;
    Navigator.of(context).pop(_password.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextField(
              key: const Key('prompt-password'),
              controller: _password,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: widget.label),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}

/// Trocar a senha. Devolve `(atual, nova)`.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trocar a senha'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PasswordField(
                fieldKey: const Key('current-password'),
                controller: _current,
                label: 'Senha atual',
                autofocus: true,
                validator: (v) =>
                    (v ?? '').isEmpty ? 'Digite a senha atual.' : null,
              ),
              const SizedBox(height: 8),
              _NewPasswordFields(password: _password, confirm: _confirm),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop((_current.text, _password.text));
          },
          child: const Text('Trocar'),
        ),
      ],
    );
  }
}

/// Mostra a chave de recuperação uma única vez. Só fecha depois de o
/// usuário confirmar que a guardou.
class RecoveryKeyDialog extends StatefulWidget {
  const RecoveryKeyDialog({required this.code, super.key});

  final String code;

  @override
  State<RecoveryKeyDialog> createState() => _RecoveryKeyDialogState();
}

class _RecoveryKeyDialogState extends State<RecoveryKeyDialog> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Chave de recuperação'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anote ou imprima esta chave e guarde-a fora deste computador. '
              'Ela libera os dados se você esquecer a senha. Ela não será '
              'mostrada de novo.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    widget.code,
                    key: const Key('recovery-key-text'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Consolas',
                      letterSpacing: 1,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar',
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: widget.code)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sem a senha e sem esta chave, os dados não podem ser '
              'recuperados por ninguém.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _saved,
              onChanged: (v) => setState(() => _saved = v!),
              title: const Text('Guardei a chave de recuperação'),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _saved ? () => Navigator.of(context).pop() : null,
          child: const Text('Concluir'),
        ),
      ],
    );
  }
}
