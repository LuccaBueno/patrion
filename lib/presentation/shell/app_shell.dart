import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_info.dart';
import '../providers.dart';
import '../router/app_router.dart';
import '../screens/sync/sync_screen.dart';
import '../theme/app_theme.dart';

/// Estrutura comum das telas: navegação lateral e área de conteúdo.
///
/// Em cima, as telas de uso diário; no rodapé, depois de um divisor,
/// Sincronizar e Configurações (M-02).
class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  /// A partir desta largura a navegação mostra os rótulos ao lado dos ícones.
  static const extendedRailBreakpoint = 1100.0;

  /// Item de cima selecionado; nulo quando a tela é do rodapé.
  int? get _selectedIndex {
    if (location.startsWith(Routes.settings)) return null;
    final index = navDestinations.lastIndexWhere(
      (d) => d.path == '/' ? location == '/' : location.startsWith(d.path),
    );
    return index < 0 ? 0 : index;
  }

  /// Item do rodapé selecionado: Sincronizar na seção de sincronização,
  /// Configurações nas outras seções.
  String? get _selectedFooter {
    if (location.startsWith(Routes.sync)) return Routes.sync;
    if (location.startsWith(Routes.settings)) return Routes.settings;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extended = MediaQuery.sizeOf(context).width >= extendedRailBreakpoint;
    final peers = ref.watch(syncPeersProvider).value ?? const [];
    final syncStale = peers.any(
      (p) => (daysSince(p.lastSyncAt) ?? 0) >= staleSyncDays,
    );
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 220,
            selectedIndex: _selectedIndex,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: _Brand(extended: extended),
            destinations: [
              for (final d in navDestinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
            onDestinationSelected: (i) => context.go(navDestinations[i].path),
            trailingAtBottom: true,
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: extended ? 196 : 56,
                    child: const Divider(height: 24),
                  ),
                  for (final d in footerDestinations)
                    _FooterItem(
                      key: Key('nav-${d.label}'),
                      destination: d,
                      extended: extended,
                      selected: _selectedFooter == d.path,
                      badge: d.path == Routes.sync && syncStale,
                      tooltip: d.path == Routes.sync
                          ? syncStale
                                ? 'A última sincronização foi há '
                                      '$staleSyncDays dias ou mais. Exporte '
                                      'ou importe o arquivo de save.'
                                : 'Exportar e importar o arquivo de save'
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Item do rodapé com a mesma aparência dos destinos da navegação.
class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.destination,
    required this.extended,
    required this.selected,
    required this.badge,
    this.tooltip,
    super.key,
  });

  final NavDestination destination;
  final bool extended;
  final bool selected;

  /// Marca de atenção no ícone (sincronização antiga).
  final bool badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rail = NavigationRailTheme.of(context);
    final scheme = theme.colorScheme;
    final iconColor = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final icon = Badge(
      isLabelVisible: badge,
      smallSize: 8,
      child: Icon(
        selected ? destination.selectedIcon : destination.icon,
        color: iconColor,
        semanticLabel: badge ? 'Sincronização antiga' : null,
      ),
    );
    final pill = Container(
      width: 56,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? rail.indicatorColor ?? scheme.secondaryContainer
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: icon,
    );
    final labelStyle =
        (selected
            ? rail.selectedLabelTextStyle
            : rail.unselectedLabelTextStyle) ??
        theme.textTheme.labelMedium?.copyWith(
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
        );
    final label = Text(
      destination.label,
      style: labelStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final content = extended
        ? SizedBox(
            width: 196,
            height: 44,
            child: Row(
              children: [
                pill,
                const SizedBox(width: 12),
                Flexible(child: label),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [pill, const SizedBox(height: 4), label],
            ),
          );
    final item = Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(destination.path),
        child: content,
      ),
    );
    return tooltip == null ? item : Tooltip(message: tooltip, child: item);
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final symbol = Image.asset(
      'assets/branding/patrion-simbolo-256.png',
      width: 40,
      height: 40,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Símbolo do ${AppInfo.name}',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: extended
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                symbol,
                const SizedBox(width: 12),
                Text(
                  AppInfo.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SemanticColors.of(context).brandAccent,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : symbol,
    );
  }
}
