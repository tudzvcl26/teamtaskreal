import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupName;
  final String description;
  final String createdBy;
  final String inviteCode;
  final String groupColor;
  final String groupIcon;
  final bool isArchived;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.createdBy,
    required this.inviteCode,
    required this.groupColor,
    required this.groupIcon,
    required this.isArchived,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      groupColor: map['groupColor'] ?? 'indigo',
      groupIcon: map['groupIcon'] ?? 'group_work',
      isArchived: map['isArchived'] ?? false,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'description': description,
      'createdBy': createdBy,
      'inviteCode': inviteCode,
      'groupColor': groupColor,
      'groupIcon': groupIcon,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}