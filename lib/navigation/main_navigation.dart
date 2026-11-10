import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/analytics/analytics_page.dart';
import '../features/devices/devices_page.dart';
import '../features/settings/settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    DashboardPage(),
    AnalyticsPage(),
    DevicesPage(),
    SettingsPage(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart_rounded),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(Icons.sensors_outlined),
      selectedIcon: Icon(Icons.sensors_rounded),
      label: 'Devices',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useRail = screenWidth >= 600;

    if (useRail) {
      return _buildRailLayout();
    }
    return _buildBottomNavLayout();
  }

  Widget _buildBottomNavLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.forestGreen.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) =>
              setState(() => _selectedIndex = i),
          destinations: _destinations,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildRailLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) =>
                setState(() => _selectedIndex = i),
            destinations: _destinations
                .map((d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ))
                .toList(),
            backgroundColor: AppColors.pureWhite,
            selectedIconTheme:
                const IconThemeData(color: AppColors.forestGreen),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.forestGreen,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.mutedText,
              fontFamily: 'Inter',
            ),
            indicatorColor: AppColors.freshLime,
            useIndicator: true,
            labelType: NavigationRailLabelType.all,
            minWidth: 72,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
