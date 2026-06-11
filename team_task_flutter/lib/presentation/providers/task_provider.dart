import 'package:riverpod/riverpod.dart';
import 'package:team_task_flutter/di/service_locator.dart';
import 'package:team_task_flutter/domain/repositories/task_repository.dart';
import 'package:team_task_flutter/models/task_model.dart';

// Provider để lấy instance TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return getIt<TaskRepository>();
});

// Provider để lấy một task theo ID
final getTaskProvider = FutureProvider.family<TaskModel, String>((ref, taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTask(taskId);
});

// Provider để lấy danh sách tasks trong một nhóm
final getGroupTasksProvider = FutureProvider.family<List<TaskModel>, String>(
  (ref, groupId) async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasksByGroup(groupId);
  },
);

// Provider để stream tasks của một nhóm (real-time)
final streamGroupTasksProvider = StreamProvider.family<List<TaskModel>, String>(
  (ref, groupId) {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.streamGroupTasks(groupId);
  },
);

// Provider để stream một task cụ thể (real-time)
final streamTaskProvider = StreamProvider.family<TaskModel, String>(
  (ref, taskId) {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.streamTask(taskId);
  },
);

// Provider để lấy tasks được giao cho user hiện tại
final getMyTasksProvider = FutureProvider.family<List<TaskModel>, String>(
  (ref, userId) async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasksByAssignee(userId);
  },
);

// Provider để lấy tasks theo status
final getTasksByStatusProvider =
    FutureProvider.family<List<TaskModel>, ({String groupId, String status})>(
  (ref, params) async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasksByStatus(params.groupId, params.status);
  },
);

// StateNotifier để quản lý task mutations
class TaskNotifier extends StateNotifier<AsyncValue<TaskModel?>> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createTask(task);
      return task;
    });
  }

  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTask(task);
      return task;
    });
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTask(taskId);
      return null;
    });
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTaskStatus(taskId, status);
      return null;
    });
  }
}

// Provider cho TaskNotifier
final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<TaskModel?>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository);
});
