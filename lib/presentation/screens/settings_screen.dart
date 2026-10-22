import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/settings/appearance_service.dart';
import '../../core/config/app_info.dart';
import '../providers.dart';
import '../router/app_router.dart';
import '../services/native_licenses.dart';
import '../widgets/common.dart';
import 'backup/backup_screen.dart';
import 'market/data_sources_screen.dart';
import 'security/lock_settings_section.dart';
import 'sync/sync_screen.dart';
import 'updates/update_widgets.dart';

/// Seções das Configurações (M-02), cada uma com o próprio endereço.
enum SettingsSection {
  general('geral', 'Geral', Icons.tune),
  security('seguranca', 'Segurança', Icons.lock_outline),
  dataSources('fontes', 'Fontes de dados', Icons.cloud_download_outlined),
  backup('backup', 'Backup', Icons.backup_outlined),
  sync('sincronizacao', 'Sincronização', Icons.sync_alt),
  about('sobre', 'Sobre', Icons.info_outline);

  const SettingsSection(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  String get route =>
      this == general ? Routes.settings : '${Routes.settings}/$path';

  /// Seção do endereço; desconhecida vira a Geral.
  static SettingsSection ofPath(String path) => values.firstWhere(
    (s) => s.path == path,
    orElse: () => SettingsSection.general,
  );
}

/// Configurações: seções à esquerda e o conteúdo da seção escolhida.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.section, super.key});

  final SettingsSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 224,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text('Configurações', style: theme.textTheme.titleLarge),
              ),
              for (final s in SettingsSection.values)
                _SectionItem(
                  key: Key('settings-${s.path}'),
                  section: s,
                  selected: s == section,
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: switch (section) {
            SettingsSection.general => const _GeneralSection(),
            SettingsSection.security => const _SecuritySection(),
            SettingsSection.dataSources => const DataSourcesScreen(),
            SettingsSection.backup => const BackupScreen(),
            SettingsSection.sync => const SyncScreen(),
            SettingsSection.about => const _AboutSection(),
          },
        ),
      ],
    );
  }
}

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference =
        ref.watch(themePreferenceProvider).value ?? ThemePreference.system;
    final trackCash = ref.watch(trackCashProvider).value ?? false;
    return PageScaffold(
      title: 'Geral',
      subtitle: 'Aparência e preferências',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SettingsCard(
            title: 'Carteira',
            children: [
              SwitchListTile(
                key: const Key('track-cash'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Controlar saldo em caixa'),
                subtitle: Text(
                  trackCash
                      ? 'Ligado: depósitos, retiradas, compras e vendas '
                            'movimentam o caixa de cada conta, que entra no '
                            'patrimônio. Registre os depósitos para o caixa '
                            'não ficar negativo.'
                      : 'Desligado: compras e vendas não movimentam caixa e '
                            'o patrimônio é o valor de mercado das posições. '
                            'Para incluir dinheiro parado, cadastre um ativo '
                            'da classe Caixa e informe o saldo. Vale nos '
                            'computadores sincronizados.',
                ),
                value: trackCash,
                onChanged: (v) =>
                    ref.read(portfolioPreferencesProvider).setTrackCash(v),
              ),
            ],
          ),
          SettingsCard(
            title: 'Aparência',
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tema'),
                subtitle: Text('Vale só para este computador.'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<ThemePreference>(
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
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Segurança',
      subtitle:
          'Senha, Windows Hello, bloqueio por inatividade e chave de '
          'recuperação',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: const [
          SettingsCard(
            title: 'Bloqueio do app',
            children: [LockSettingsSection()],
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvironmentProvider);
    return PageScaffold(
      title: 'Sobre',
      subtitle: 'Versão, atualizações, licenças e pastas deste computador',
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SettingsCard(
            title: AppInfo.name,
            children: [
              _InfoRow(label: 'Versão', value: env.appVersion),
              const _InfoRow(label: 'Aplicativo', value: AppInfo.subtitle),
              const _InfoRow(
                label: 'Dados de mercado',
                value:
                    'Fonte, licença e atribuição de cada provedor em Fontes '
                    'de dados.',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('third-party-licenses'),
                    onPressed: () {
                      NativeLicenses.ensureRegistered();
                      showLicensePage(
                        context: context,
                        applicationName: AppInfo.name,
                        applicationVersion: env.appVersion,
                        applicationLegalese:
                            'Copyright (C) 2026 Lucca Bueno. Usa o SQLCipher '
                            '(Zetetic LLC) e o OpenSSL, além das bibliotecas '
                            'listadas abaixo.',
                      );
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Licenças de terceiros'),
                  ),
                  TextButton(
                    onPressed: () => context.go(Routes.dataSources),
                    child: const Text('Fontes de dados'),
                  ),
                ],
              ),
            ],
          ),
          const SettingsCard(
            title: 'Atualizações',
            children: [UpdateSettingsSection()],
          ),
          SettingsCard(
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
        ],
      ),
    );
  }
}

/// Cartão de uma seção das Configurações.
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.title, required this.children, super.key});

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

/// Item da lista de seções; só o selecionado tem fundo.
class _SectionItem extends StatelessWidget {
  const _SectionItem({
    required this.section,
    required this.selected,
    super.key,
  });

  final SettingsSection section;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go(section.route),
          child: Semantics(
            selected: selected,
            button: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(section.icon, size: 20, color: color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      section.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
