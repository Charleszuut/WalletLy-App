import 'package:flutter/material.dart';

import '../categories/categories_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../reports/reports_screen.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/widgets/transaction_editor_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static final _destinations = [
    _Destination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      builder: () => const DashboardScreen(),
    ),
    _Destination(
      label: 'Transactions',
      icon: Icons.swap_vert_circle_outlined,
      activeIcon: Icons.swap_vert_circle,
      builder: () => const TransactionsScreen(),
    ),
    _Destination(
      label: 'Categories',
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      builder: () => const CategoriesScreen(),
    ),
    _Destination(
      label: 'Reports',
      icon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      builder: () => const ReportsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_index];
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: destination.builder(),
      ),
      floatingActionButton: _shouldShowFab()
          ? FloatingActionButton.extended(
              onPressed: () => TransactionEditorSheet.show(context),
              icon: const Icon(Icons.add),
              label: const Text('Quick Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        height: 80,
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }

  bool _shouldShowFab() => _index == 0 || _index == 1;
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget Function() builder;
}
