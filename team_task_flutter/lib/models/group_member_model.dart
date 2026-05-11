class GroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final String status;
  final String name;
  final String email;
  final String avatar;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    required this.name,
    required this.email,
    required this.avatar,
  });
}