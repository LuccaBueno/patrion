import 'package:flutter/material.dart';

import '../security/security_dialogs.dart';

/// Escolha da proteção do arquivo de save antes de salvar (SPEC §10.6).
/// Devolve `(senha ou null)` dentro de um registro, ou `null` se cancelar.
class SavePasswordDialog extends StatefulWidget {
  const SavePasswordDialog({
    required this.protectByDefault,
    this.importedPassword,
    super.key,
  });

  /// Marcado por padrão quando o bloqueio do app está ativo.
  final bool protectByDefault;

  /// Senha do arquivo que acabou de ser importado ("Importar e gerar novo
  /// save"), para oferecer a mesma.
  final String? importedPassword;

  @override
  State<SavePasswordDialog> createState() => _SavePasswordDialogState();
}

class _SavePasswordDialogState extends State<SavePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late bool _protect =
      widget.protectByDefault || widget.importedPassword != null;
  late bool _reuse = widget.importedPassword != null;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_protect) {
      Navigator.of(context).pop((password: null));
      return;
    }
    if (_reuse && widget.importedPassword != null) {
      Navigator.of(context).pop((password: widget.importedPassword));
      return;
    }
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop((password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final askPassword =
        _protect && !(_reuse && widget.importedPassword != null);
    return AlertDialog(
      title: const Text('Salvar arquivo de save'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O arquivo leva todos os dados da carteira. Com senha, ele é '
                'criptografado (AES-256) e só abre no outro computador com a '
                'mesma senha.',
              ),
              CheckboxListTile(
                key: const Key('save-protect'),
                contentPadding: EdgeInsets.zero,
                value: _protect,
                onChanged: (v) => setState(() => _protect = v!),
                title: const Text('Proteger o arquivo com senha'),
              ),
              if (_protect && widget.importedPassword != null)
                CheckboxListTile(
                  key: const Key('save-reuse-password'),
                  contentPadding: EdgeInsets.zero,
                  value: _reuse,
                  onChanged: (v) => setState(() => _reuse = v!),
                  title: const Text('Usar a mesma senha do arquivo importado'),
                ),
              if (askPassword) ...[
                PasswordField(
                  fieldKey: const Key('save-password'),
                  controller: _password,
                  label: 'Senha do arquivo',
                  autofocus: true,
                  validator: (v) => (v ?? '').length < 8
                      ? 'Use pelo menos 8 caracteres.'
                      : null,
                ),
                const SizedBox(height: 8),
                PasswordField(
                  fieldKey: const Key('save-password-confirm'),
                  controller: _confirm,
                  label: 'Repita a senha',
                  validator: (v) =>
                      v == _password.text ? null : 'As senhas não são iguais.',
                ),
                const SizedBox(height: 8),
                Text(
                  'Sem a senha, o arquivo não pode ser aberto. Ela não fica '
                  'guardada em lugar nenhum.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (!_protect)
                Text(
                  'Sem senha, qualquer pessoa com o arquivo pode ler os dados. '
                  'Guarde-o em local seguro.',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continuar')),
      ],
    );
  }
}
