import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:team_task_flutter/data/datasources/task_datasource_impl.dart';
import 'package:team_task_flutter/data/repositories/task_repository_impl.dart';
import 'package:team_task_flutter/domain/repositories/task_repository.dart';
import 'package:team_task_flutter/services/auth_service.dart';
import 'package:team_task_flutter/services/dashboard_service.dart';
import 'package:team_task_flutter/services/firestore_service.dart';
import 'package:team_task_flutter/services/group_service.dart';
import 'package:team_task_flutter/services/profile_service.dart';
import 'package:team_task_flutter/services/task_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Firebase instances (Singletons)
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Core services
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<AuthService>(AuthService());

  // Data Sources
  getIt.registerSingleton<TaskDataSourceImpl>(
    TaskDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  // Repositories
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(getIt<TaskDataSourceImpl>()),
  );

  // Feature services
  getIt.registerSingleton<TaskService>(TaskService());
  getIt.registerSingleton<GroupService>(GroupService());
  getIt.registerSingleton<ProfileService>(ProfileService());
  getIt.registerSingleton<DashboardService>(DashboardService());
}
