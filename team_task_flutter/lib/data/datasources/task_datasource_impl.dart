import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_task_flutter/core/constants/app_enums.dart';
import 'package:team_task_flutter/core/exceptions/app_exception.dart';
import 'package:team_task_flutter/core/utils/logger.dart';
import 'package:team_task_flutter/data/datasources/task_datasource.dart';
import 'package:team_task_flutter/models/task_model.dart';

class TaskDataSourceImpl implements TaskDataSource {
  final FirebaseFirestore _firestore;

  TaskDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _firestore.collection(Collections.tasks);

  @override
  Future<TaskModel> getTask(String taskId) async {
    try {
      final doc = await _tasksRef.doc(taskId).get();
      if (!doc.exists || doc.data() == null) {
        throw NotFoundException('Task not found');
      }
      return TaskModel.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      AppLogger.error('Error fetching task: $taskId', e);
      throw NetworkException('Failed to fetch task: ${e.message}');
    } catch (e) {
      AppLogger.error('Error fetching task: $taskId', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByGroup(String groupId) async {
    try {
      final snapshot = await _tasksRef
          .where(FirebaseFields.groupId, isEqualTo: groupId)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error fetching tasks for group: $groupId', e);
      throw NetworkException('Failed to fetch tasks: ${e.message}');
    } catch (e) {
      AppLogger.error('Error fetching tasks for group: $groupId', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByAssignee(String userId) async {
    try {
      final snapshot = await _tasksRef
          .where(FirebaseFields.assignedTo, isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Error fetching tasks for user: $userId', e);
      throw NetworkException('Failed to fetch tasks: ${e.message}');
    } catch (e) {
      AppLogger.error('Error fetching tasks for user: $userId', e);
      rethrow;
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String groupId, String status) async {
    try {
      final snapshot = await _tasksRef
          .where(FirebaseFields.groupId, isEqualTo: groupId)
          .where(FirebaseFields.status, isEqualTo: status)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      AppLogger.error(
        'Error fetching tasks for group: $groupId with status: $status',
        e,
      );
      throw NetworkException('Failed to fetch tasks: ${e.message}');
    } catch (e) {
      AppLogger.error(
        'Error fetching tasks for group: $groupId with status: $status',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _tasksRef.doc(task.taskId).set(task.toMap());
      AppLogger.info('Task created: ${task.taskId}');
    } on FirebaseException catch (e) {
      AppLogger.error('Error creating task', e);
      throw NetworkException('Failed to create task: ${e.message}');
    } catch (e) {
      AppLogger.error('Error creating task', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksRef.doc(task.taskId).update(task.toMap());
      AppLogger.info('Task updated: ${task.taskId}');
    } on FirebaseException catch (e) {
      AppLogger.error('Error updating task: ${task.taskId}', e);
      throw NetworkException('Failed to update task: ${e.message}');
    } catch (e) {
      AppLogger.error('Error updating task: ${task.taskId}', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRef.doc(taskId).delete();
      AppLogger.info('Task deleted: $taskId');
    } on FirebaseException catch (e) {
      AppLogger.error('Error deleting task: $taskId', e);
      throw NetworkException('Failed to delete task: ${e.message}');
    } catch (e) {
      AppLogger.error('Error deleting task: $taskId', e);
      rethrow;
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _tasksRef.doc(taskId).update({
        FirebaseFields.status: status,
        FirebaseFields.updatedAt: FieldValue.serverTimestamp(),
      });
      AppLogger.info('Task status updated: $taskId -> $status');
    } on FirebaseException catch (e) {
      AppLogger.error('Error updating task status: $taskId', e);
      throw NetworkException('Failed to update task: ${e.message}');
    } catch (e) {
      AppLogger.error('Error updating task status: $taskId', e);
      rethrow;
    }
  }

  @override
  Stream<List<TaskModel>> streamGroupTasks(String groupId) {
    try {
      return _tasksRef
          .where(FirebaseFields.groupId, isEqualTo: groupId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      AppLogger.error('Error streaming tasks for group: $groupId', e);
      return Stream.error(NetworkException('Failed to stream tasks'));
    }
  }

  @override
  Stream<TaskModel> streamTask(String taskId) {
    try {
      return _tasksRef.doc(taskId).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          throw NotFoundException('Task not found');
        }
        return TaskModel.fromMap(snapshot.data()!, snapshot.id);
      });
    } catch (e) {
      AppLogger.error('Error streaming task: $taskId', e);
      return Stream.error(NetworkException('Failed to stream task'));
    }
  }
}
