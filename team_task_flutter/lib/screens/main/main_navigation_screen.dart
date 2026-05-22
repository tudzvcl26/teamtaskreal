import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/screens/groups/groups_screen.dart';
import 'package:team_task_flutter/screens/home/home_dashboard_screen.dart';
import 'package:team_task_flutter/screens/notifications/notifications_screen.dart';
import 'package:team_task_flutter/screens/profile/profile_screen.dart';
import 'package:team_task_flutter/screens/tasks/tasks_screen.dart';
import 'package:team_task_flutter/widgets/home_bottom_nav.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    _pages = [
      HomeDashboardScreen(onOpenProfileTab: () => goToTab(4)),
      GroupsScreen(onOpenProfileTab: () => goToTab(4)),
      TasksScreen(onOpenProfileTab: () => goToTab(4)),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  void goToTab(int index) {
    if (index == currentIndex) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: currentIndex,
        onTap: goToTab,
      ),
    );
  }
}
