import 'package:cloud_firestore/cloud_firestore.dart';

class TaskActivityLogModel {
  final String logId;
  final String? taskId;
  final String? groupId;
  final String userId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  const TaskActivityLogModel({
    required this.logId,
    required this.taskId,
    required this.groupId,
    required this.userId,
    required this.action,
    required this.oldValue,
    required this.newValue,
    required this.createdAt,
  });

  factory TaskActivityLogModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return TaskActivityLogModel(
      logId: (map['logId'] ?? docId).toString(),
      taskId: map['taskId']?.toString(),
      groupId: map['groupId']?.toString(),
      userId: (map['userId'] ?? '').toString(),
      action: (map['action'] ?? '').toString(),
      oldValue: map['oldValue']?.toString(),
      newValue: map['newValue']?.toString(),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'taskId': taskId,
      'groupId': groupId,
      'userId': userId,
      'action': action,
      'oldValue': oldValue,
      'newValue': newValue,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}