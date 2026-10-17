import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/backup/backup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/operations/operations_screen.dart';
import '../screens/portfolio/asset_detail_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';
import '../screens/registry/registry_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sync/sync_screen.dart';
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
    path: '/carteira',
    label: 'Carteira',
    icon: Icons.pie_chart_outline,
    selectedIcon: Icons.pie_chart,
  ),
  NavDestination(
    path: '/operacoes',
    label: 'Operações',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  NavDestination(
    path: '/cadastros',
    label: 'Cadastros',
    icon: Icons.account_balance_outlined,
    selectedIcon: Icons.account_balance,
  ),
  NavDestination(
    path: '/sincronizacao',
    label: 'Sincronização',
    icon: Icons.sync_alt,
    selectedIcon: Icons.sync_alt,
  ),
  NavDestination(
    path: '/backup',
    label: 'Backup',
    icon: Icons.backup_outlined,
    selectedIcon: Icons.backup,
  ),
  NavDestination(
    path: '/configuracoes',
    label: 'Configurações',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

Page<void> _page(Widget child) => NoTransitionPage(child: child);

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
            pageBuilder: (context, state) => _page(const DashboardScreen()),
          ),
          GoRoute(
            path: '/carteira',
            pageBuilder: (context, state) => _page(const PortfolioScreen()),
            routes: [
              GoRoute(
                path: 'ativo/:id',
                pageBuilder: (context, state) => _page(
                  AssetDetailScreen(assetId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/operacoes',
            pageBuilder: (context, state) => _page(const OperationsScreen()),
          ),
          GoRoute(
            path: '/cadastros',
            pageBuilder: (context, state) => _page(const RegistryScreen()),
          ),
          GoRoute(
            path: '/sincronizacao',
            pageBuilder: (context, state) => _page(const SyncScreen()),
          ),
          GoRoute(
            path: '/backup',
            pageBuilder: (context, state) => _page(const BackupScreen()),
          ),
          GoRoute(
            path: '/configuracoes',
            pageBuilder: (context, state) => _page(const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
}
