import 'package:flutter/material.dart';
import 'package:team_task_flutter/screens/home/home_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenProfileTab;

  const HomeScreen({
    super.key,
    this.onOpenProfileTab,
  });

  @override
  Widget build(BuildContext context) {
    return HomeDashboardScreen(
      onOpenProfileTab: onOpenProfileTab ?? () {},
    );
  }
}