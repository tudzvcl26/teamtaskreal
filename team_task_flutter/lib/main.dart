import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:team_task_flutter/app.dart';
import 'package:team_task_flutter/core/localization/locale_controller.dart';
import 'package:team_task_flutter/di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocaleController.loadLocale();

  await setupServiceLocator();

  runApp(const TeamTaskApp());
}
