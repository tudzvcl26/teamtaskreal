import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/theme/app_theme.dart';
import 'package:team_task_flutter/core/theme/theme_controller.dart';
import 'package:team_task_flutter/screens/splash/splash_screen.dart';

class TeamTaskApp extends StatelessWidget {
  const TeamTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Team Task',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}