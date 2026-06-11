import 'package:team_task_flutter/core/utils/logger.dart';
import 'package:team_task_flutter/data/datasources/task_datasource.dart';
import 'package:team_task_flutter/domain/repositories/task_repository.dart';
import 'package:team_task_flutter/models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<TaskModel> getTask(String taskId) async {
    try {
      return await _dataSource.getTask(taskId);
    } catch (e) {
      AppLogger.error('Repository error in getTask', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByGroup(String groupId) async {
    try {
      return await _dataSource.getTasksByGroup(groupId);
    } catch (e) {
      AppLogger.error('Repository error in getTasksByGroup', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByAssignee(String userId) async {
    try {
      return await _dataSource.getTasksByAssignee(userId);
    } catch (e) {
      AppLogger.error('Repository error in getTasksByAssignee', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String groupId, String status) async {
    try {
      return await _dataSource.getTasksByStatus(groupId, status);
    } catch (e) {
      AppLogger.error('Repository error in getTasksByStatus', e);
      rethrow;
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _dataSource.createTask(task);
      AppLogger.info('Task created via repository: ${task.taskId}');
    } catch (e) {
      AppLogger.error('Repository error in createTask', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _dataSource.updateTask(task);
      AppLogger.info('Task updated via repository: ${task.taskId}');
    } catch (e) {
      AppLogger.error('Repository error in updateTask', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
      AppLogger.info('Task deleted via repository: $taskId');
    } catch (e) {
      AppLogger.error('Repository error in deleteTask', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _dataSource.updateTaskStatus(taskId, status);
      AppLogger.info('Task status updated via repository: $taskId -> $status');
    } catch (e) {
      AppLogger.error('Repository error in updateTaskStatus', e);
      rethrow;
    }
  }

  @override
  Stream<List<TaskModel>> streamGroupTasks(String groupId) {
    return _dataSource.streamGroupTasks(groupId);
  }

  @override
  Stream<TaskModel> streamTask(String taskId) {
    return _dataSource.streamTask(taskId);
  }
}
