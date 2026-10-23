import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/operations/operations_screen.dart';
import '../screens/performance/performance_screen.dart';
import '../screens/portfolio/asset_detail_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';
import '../screens/settings_screen.dart';
import '../shell/app_shell.dart';

/// Endereços das telas.
abstract final class Routes {
  static const dashboard = '/';
  static const portfolio = '/carteira';
  static const performance = '/desempenho';
  static const operations = '/operacoes';
  static const registry = '/configuracoes/corretoras';
  static const settings = '/configuracoes';
  static const security = '/configuracoes/seguranca';
  static const dataSources = '/configuracoes/fontes';
  static const backup = '/configuracoes/backup';
  static const sync = '/configuracoes/sincronizacao';
  static const about = '/configuracoes/sobre';

  static String asset(String id) => '/carteira/ativo/$id';
}

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

/// Telas de uso diário, na parte de cima do menu (M-02). As das próximas
/// fases (hipotéticas, simuladores) entram aqui, antes de Operações.
const navDestinations = [
  NavDestination(
    path: Routes.dashboard,
    label: 'Painel',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
  ),
  NavDestination(
    path: Routes.portfolio,
    label: 'Carteira',
    icon: Icons.pie_chart_outline,
    selectedIcon: Icons.pie_chart,
  ),
  NavDestination(
    path: Routes.performance,
    label: 'Desempenho',
    icon: Icons.query_stats_outlined,
    selectedIcon: Icons.query_stats,
  ),
  NavDestination(
    path: Routes.operations,
    label: 'Operações',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
];

/// Rodapé do menu, depois de um divisor: Sincronizar e, sempre por último,
/// Configurações.
const footerDestinations = [
  NavDestination(
    path: Routes.sync,
    label: 'Sincronizar',
    icon: Icons.sync_alt,
    selectedIcon: Icons.sync_alt,
  ),
  NavDestination(
    path: Routes.settings,
    label: 'Configurações',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

Page<void> _page(Widget child) => NoTransitionPage(child: child);

GoRouter createRouter({String initialLocation = Routes.dashboard}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Endereços da 1.0.0, mantidos para avisos e atalhos antigos.
      GoRoute(path: '/fontes', redirect: (_, _) => Routes.dataSources),
      GoRoute(path: '/backup', redirect: (_, _) => Routes.backup),
      GoRoute(path: '/sincronizacao', redirect: (_, _) => Routes.sync),
      // Cadastros saiu do menu (M-06): agora em Configurações.
      GoRoute(path: '/cadastros', redirect: (_, _) => Routes.registry),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (context, state) => _page(const DashboardScreen()),
          ),
          GoRoute(
            path: Routes.portfolio,
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
            path: Routes.performance,
            pageBuilder: (context, state) => _page(const PerformanceScreen()),
          ),
          GoRoute(
            path: Routes.operations,
            pageBuilder: (context, state) => _page(const OperationsScreen()),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) =>
                _page(const SettingsScreen(section: SettingsSection.general)),
            routes: [
              GoRoute(
                path: ':section',
                pageBuilder: (context, state) => _page(
                  SettingsScreen(
                    section: SettingsSection.ofPath(
                      state.pathParameters['section']!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
