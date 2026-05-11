import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String groupId;
  final String title;
  final String description;
  final String? assignedTo;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.taskId,
    required this.groupId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return TaskModel(
      taskId: (map['taskId'] ?? docId).toString(),
      groupId: (map['groupId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      assignedTo: map['assignedTo']?.toString(),
      status: (map['status'] ?? 'todo').toString(),
      priority: (map['priority'] ?? 'medium').toString(),
      startDate: parseDate(map['startDate']),
      dueDate: parseDate(map['dueDate']),
      createdBy: (map['createdBy'] ?? '').toString(),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'groupId': groupId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'status': status,
      'priority': priority,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? groupId,
    String? title,
    String? description,
    String? assignedTo,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? dueDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearAssignedTo = false,
    bool clearStartDate = false,
    bool clearDueDate = false,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDone => status == 'done';

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day + 1));
  }
}