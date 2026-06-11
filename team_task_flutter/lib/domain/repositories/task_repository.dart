import 'package:team_task_flutter/models/task_model.dart';

abstract class TaskRepository {
  Future<TaskModel> getTask(String taskId);

  Future<List<TaskModel>> getTasksByGroup(String groupId);

  Future<List<TaskModel>> getTasksByAssignee(String userId);

  Future<List<TaskModel>> getTasksByStatus(String groupId, String status);

  Future<void> createTask(TaskModel task);

  Future<void> updateTask(TaskModel task);

  Future<void> deleteTask(String taskId);

  Future<void> updateTaskStatus(String taskId, String status);

  Stream<List<TaskModel>> streamGroupTasks(String groupId);

  Stream<TaskModel> streamTask(String taskId);
}
