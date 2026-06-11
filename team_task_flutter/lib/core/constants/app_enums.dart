enum TaskStatus {
  todo('todo', 'To Do'),
  inProgress('in_progress', 'In Progress'),
  review('review', 'Review'),
  done('done', 'Done');

  final String value;
  final String label;

  const TaskStatus(this.value, this.label);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.todo,
    );
  }
}

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  final String value;
  final String label;

  const TaskPriority(this.value, this.label);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum UserRole {
  owner('owner', 'Owner'),
  admin('admin', 'Admin'),
  member('member', 'Member'),
  viewer('viewer', 'Viewer');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.member,
    );
  }
}

enum NotificationType {
  taskAssigned('task_assigned', 'Task Assigned'),
  taskCompleted('task_completed', 'Task Completed'),
  commentAdded('comment_added', 'Comment Added'),
  memberAdded('member_added', 'Member Added'),
  groupCreated('group_created', 'Group Created');

  final String value;
  final String label;

  const NotificationType(this.value, this.label);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.taskAssigned,
    );
  }
}

abstract final class Collections {
  static const String tasks = 'tasks';
  static const String groups = 'groups';
  static const String users = 'users';
  static const String groupMembers = 'group_members';
  static const String taskComments = 'task_comments';
  static const String notifications = 'notifications';
  static const String attachments = 'attachments';
  static const String activityLogs = 'activity_logs';
}

abstract final class FirebaseFields {
  static const String id = 'id';
  static const String userId = 'userId';
  static const String groupId = 'groupId';
  static const String taskId = 'taskId';
  static const String status = 'status';
  static const String priority = 'priority';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String dueDate = 'dueDate';
  static const String startDate = 'startDate';
  static const String assignedTo = 'assignedTo';
  static const String createdBy = 'createdBy';
  static const String name = 'name';
  static const String email = 'email';
  static const String avatar = 'avatar';
}
