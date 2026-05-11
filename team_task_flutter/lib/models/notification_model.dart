import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String? taskId;
  final String? groupId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? invitationStatus;
  final String? requesterUserId;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.taskId,
    required this.groupId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.invitationStatus,
    required this.requesterUserId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return NotificationModel(
      notificationId: (map['notificationId'] ?? docId).toString(),
      userId: (map['userId'] ?? '').toString(),
      taskId: map['taskId']?.toString(),
      groupId: map['groupId']?.toString(),
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      isRead: (map['isRead'] ?? false) == true,
      invitationStatus: map['invitationStatus']?.toString(),
      requesterUserId: map['requesterUserId']?.toString(),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'taskId': taskId,
      'groupId': groupId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'invitationStatus': invitationStatus,
      'requesterUserId': requesterUserId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}