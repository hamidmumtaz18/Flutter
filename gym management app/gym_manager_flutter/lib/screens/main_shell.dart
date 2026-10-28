// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'members/members_screen.dart';
import 'fees/fees_screen.dart';
import 'plans/plans_screen.dart';
import 'calculator/calculator_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    MembersScreen(),
    FeesScreen(),
    PlansScreen(),
    CalculatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: AppTheme.primary),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 12),
              Text('Loading Gym Manager...', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: state.expiringSoon > 0,
                label: Text('${state.expiringSoon}'),
                child: const Icon(Icons.people_outline),
              ),
              activeIcon: const Icon(Icons.people),
              label: 'Members',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Fees',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.card_membership_outlined),
              activeIcon: Icon(Icons.card_membership),
              label: 'Plans',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Calculator',
            ),
          ],
        ),
      ),
    );
  }
}
