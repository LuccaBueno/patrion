import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_info.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Estrutura comum das telas: navegação lateral e área de conteúdo.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  /// A partir desta largura a navegação mostra os rótulos ao lado dos ícones.
  static const extendedRailBreakpoint = 1100.0;

  int get _selectedIndex {
    final index = navDestinations.lastIndexWhere(
      (d) => d.path == '/' ? location == '/' : location.startsWith(d.path),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final extended = MediaQuery.sizeOf(context).width >= extendedRailBreakpoint;
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
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
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
