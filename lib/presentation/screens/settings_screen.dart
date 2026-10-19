import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/appearance_service.dart';
import '../../core/config/app_info.dart';
import '../providers.dart';
import 'security/lock_settings_section.dart';
import 'updates/update_widgets.dart';

/// Configurações deste PC: aparência, bloqueio, pastas e versão.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final env = ref.watch(appEnvironmentProvider);
    final themePreference =
        ref.watch(themePreferenceProvider).value ?? ThemePreference.system;

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Configurações', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        _Section(
          title: 'Aparência',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tema'),
              subtitle: const Text('Vale só para este computador.'),
              trailing: SegmentedButton<ThemePreference>(
                segments: [
                  for (final p in ThemePreference.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {themePreference},
                onSelectionChanged: (selection) => ref
                    .read(appearanceServiceProvider)
                    .setTheme(selection.single),
              ),
            ),
          ],
        ),
        const _Section(
          title: 'Bloqueio do app',
          children: [LockSettingsSection()],
        ),
        _Section(
          title: 'Dados deste computador',
          children: [
            _InfoRow(label: 'Nome do computador', value: env.deviceName),
            _InfoRow(
              label: 'Identificador do dispositivo',
              value: env.deviceId,
            ),
            _InfoRow(label: 'Pasta de dados', value: env.paths.dataDir),
            _InfoRow(label: 'Banco de dados', value: env.paths.databaseFile),
            _InfoRow(label: 'Logs', value: env.paths.logsDir),
            _InfoRow(label: 'Cache', value: env.paths.cacheDir),
          ],
        ),
        const _Section(
          title: 'Atualizações',
          children: [UpdateSettingsSection()],
        ),
        _Section(
          title: 'Sobre',
          children: [
            _InfoRow(label: 'Versão', value: env.appVersion),
            const _InfoRow(label: 'Aplicativo', value: AppInfo.subtitle),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
