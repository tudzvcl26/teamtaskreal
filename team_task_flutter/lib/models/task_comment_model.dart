import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCommentModel {
  final String commentId;
  final String taskId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskCommentModel({
    required this.commentId,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskCommentModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return TaskCommentModel(
      commentId: (map['commentId'] ?? docId).toString(),
      taskId: (map['taskId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'taskId': taskId,
      'userId': userId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}