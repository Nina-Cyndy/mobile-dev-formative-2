import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'startup_dashboard_screen.dart';
import 'startup_profile_screen.dart';
import '../user/profile_screen.dart';

class StartupShell extends StatefulWidget {
  const StartupShell({super.key});

  @override
  State<StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<StartupShell> {
  int _index = 0;

  final _screens = const [
    StartupDashboardScreen(),
    StartupProfileScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.aluBlue.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: AppColors.aluBlue), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), selectedIcon: Icon(Icons.rocket_launch, color: AppColors.aluBlue), label: 'Startup'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.aluBlue), label: 'Profile'),
        ],
      ),
    );
  }
}
