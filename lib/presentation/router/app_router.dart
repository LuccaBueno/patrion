import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../shell/app_shell.dart';

/// Item da navegação lateral.
class NavDestination {
  const NavDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Telas disponíveis. Novas telas entram aqui conforme as fases (SPEC §16).
const navDestinations = [
  NavDestination(
    path: '/',
    label: 'Início',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
  ),
  NavDestination(
    path: '/configuracoes',
    label: 'Configurações',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/configuracoes',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
}
