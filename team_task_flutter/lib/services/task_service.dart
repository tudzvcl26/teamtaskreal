import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attachment_model.dart';
import '../models/notification_model.dart';
import '../models/task_activity_log_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');

  CollectionReference<Map<String, dynamic>> get _activityLogs =>
      _firestore.collection('activity_logs');

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get _groupMembers =>
      _firestore.collection('group_members');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _attachments =>
      _firestore.collection('attachments');

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Stream<List<TaskModel>> streamAllTasks() {
    return _tasks.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snapshot) async {
        final myGroupIds = (await getMyGroupIds()).toSet();

        return snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .where((task) => myGroupIds.contains(task.groupId))
            .toList();
      },
    );
  }

  Stream<TaskModel?> streamTaskById(String taskId) {
    return _tasks.doc(taskId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return TaskModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<List<String>> getMyGroupIds() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    final snapshot = await _groupMembers
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    final rawIds = snapshot.docs
        .map((doc) => (doc.data()['groupId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (rawIds.isEmpty) return [];

    final validIds = <String>[];

    for (final groupId in rawIds) {
      final groupDoc = await _groups.doc(groupId).get();
      final groupData = groupDoc.data();
      if (!groupDoc.exists || groupData == null) continue;
      if ((groupData['isArchived'] ?? false) == true) continue;
      validIds.add(groupId);
    }

    return validIds;
  }

  Future<List<Map<String, dynamic>>> getMyGroupsForTaskForm() async {
    final ids = await getMyGroupIds();
    if (ids.isEmpty) return [];

    final result = <Map<String, dynamic>>[];

    for (final groupId in ids) {
      final doc = await _groups.doc(groupId).get();
      final data = doc.data();
      if (!doc.exists || data == null) continue;
      if ((data['isArchived'] ?? false) == true) continue;

      result.add({
        'groupId': doc.id,
        'groupName': (data['groupName'] ?? 'Nhóm').toString(),
      });
    }

    result.sort((a, b) => a['groupName']
        .toString()
        .toLowerCase()
        .compareTo(b['groupName'].toString().toLowerCase()));

    return result;
  }

  Future<List<Map<String, dynamic>>> getGroupMembersForTaskForm(
    String groupId,
  ) async {
    final memberSnapshot = await _groupMembers
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'active')
        .get();

    final List<Map<String, dynamic>> members = [];

    for (final memberDoc in memberSnapshot.docs) {
      final data = memberDoc.data();
      final userId = (data['userId'] ?? '').toString();
      if (userId.isEmpty) continue;

      final userDoc = await _users.doc(userId).get();
      final userData = userDoc.data();

      members.add({
        'userId': userId,
        'name': (userData?['name'] ?? 'Người dùng').toString(),
        'email': (userData?['email'] ?? '').toString(),
      });
    }

    members.sort((a, b) => a['name']
        .toString()
        .toLowerCase()
        .compareTo(b['name'].toString().toLowerCase()));

    return members;
  }

  Future<String> getGroupName(String groupId) async {
    final doc = await _groups.doc(groupId).get();
    return (doc.data()?['groupName'] ?? 'Nhóm').toString();
  }

  Future<String> getUserName(String userId) async {
    if (userId.isEmpty) return 'Chưa giao';
    final doc = await _users.doc(userId).get();
    return (doc.data()?['name'] ?? 'Người dùng').toString();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _tasks.doc(taskId).get();
    if (!doc.exists || doc.data() == null) return null;
    return TaskModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> createTask({
    required String groupId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required String? assignedTo,
    required DateTime? startDate,
    required DateTime? dueDate,
  }) async {
    final uid = currentUserId;
    final docRef = _tasks.doc();

    final task = TaskModel(
      taskId: docRef.id,
      groupId: groupId,
      title: title.trim(),
      description: description.trim(),
      assignedTo: assignedTo,
      status: status,
      priority: priority,
      startDate: startDate,
      dueDate: dueDate,
      createdBy: uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(task.toMap());

    await _addActivityLog(
      taskId: docRef.id,
      groupId: groupId,
      action: 'create_task',
      oldValue: null,
      newValue: 'Tạo công việc: ${title.trim()}',
    );

    if (assignedTo != null && assignedTo.isNotEmpty && assignedTo != uid) {
      await _createNotification(
        userId: assignedTo,
        taskId: docRef.id,
        groupId: groupId,
        title: 'Bạn được giao công việc mới',
        message: title.trim(),
        type: 'assign',
      );
    }
  }

  Future<void> updateTask({
    required String taskId,
    required String groupId,
    required String title,
    required String description,
    required String status,
    required String priority,
    required String? assignedTo,
    required DateTime? startDate,
    required DateTime? dueDate,
  }) async {
    final oldDoc = await _tasks.doc(taskId).get();
    final oldData = oldDoc.data();
    final oldAssignedTo = oldData?['assignedTo']?.toString();

    await _tasks.doc(taskId).update({
      'groupId': groupId,
      'title': title.trim(),
      'description': description.trim(),
      'assignedTo': assignedTo,
      'status': status,
      'priority': priority,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _addActivityLog(
      taskId: taskId,
      groupId: groupId,
      action: 'update_task',
      oldValue: oldData == null ? null : oldData.toString(),
      newValue: 'Cập nhật công việc: ${title.trim()}',
    );

    if (assignedTo != null &&
        assignedTo.isNotEmpty &&
        assignedTo != currentUserId &&
        assignedTo != oldAssignedTo) {
      await _createNotification(
        userId: assignedTo,
        taskId: taskId,
        groupId: groupId,
        title: 'Bạn được giao công việc',
        message: title.trim(),
        type: 'assign',
      );
    }

    final createdBy = oldData?['createdBy']?.toString() ?? '';
    if (createdBy.isNotEmpty && createdBy != currentUserId) {
      await _createNotification(
        userId: createdBy,
        taskId: taskId,
        groupId: groupId,
        title: 'Công việc vừa được cập nhật',
        message: title.trim(),
        type: 'update',
      );
    }
  }

  Future<void> markTaskDone(TaskModel task) async {
    await _tasks.doc(task.taskId).update({
      'status': 'done',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _addActivityLog(
      taskId: task.taskId,
      groupId: task.groupId,
      action: 'mark_done',
      oldValue: task.status,
      newValue: 'done',
    );

    if (task.createdBy.isNotEmpty && task.createdBy != currentUserId) {
      await _createNotification(
        userId: task.createdBy,
        taskId: task.taskId,
        groupId: task.groupId,
        title: 'Một công việc đã hoàn thành',
        message: task.title,
        type: 'status',
      );
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final commentsSnapshot =
        await _comments.where('taskId', isEqualTo: task.taskId).get();
    final logsSnapshot =
        await _activityLogs.where('taskId', isEqualTo: task.taskId).get();
    final notificationsSnapshot =
        await _notifications.where('taskId', isEqualTo: task.taskId).get();
    final attachmentsSnapshot =
        await _attachments.where('taskId', isEqualTo: task.taskId).get();

    for (final doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }
    for (final doc in logsSnapshot.docs) {
      await doc.reference.delete();
    }
    for (final doc in notificationsSnapshot.docs) {
      await doc.reference.delete();
    }
    for (final doc in attachmentsSnapshot.docs) {
      await doc.reference.delete();
    }

    final oldTitle = task.title;
    await _tasks.doc(task.taskId).delete();

    final logRef = _activityLogs.doc();
    await logRef.set({
      'logId': logRef.id,
      'taskId': null,
      'groupId': task.groupId,
      'userId': currentUserId,
      'action': 'delete_task',
      'oldValue': oldTitle,
      'newValue': null,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<TaskCommentModel>> streamComments(String taskId) {
    return _comments
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskCommentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addComment({
    required String taskId,
    required String content,
    required String groupId,
  }) async {
    final uid = currentUserId;
    final docRef = _comments.doc();

    final comment = TaskCommentModel(
      commentId: docRef.id,
      taskId: taskId,
      userId: uid,
      content: content.trim(),
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    await docRef.set(comment.toMap());

    await _addActivityLog(
      taskId: taskId,
      groupId: groupId,
      action: 'comment',
      oldValue: null,
      newValue: content.trim(),
    );

    final task = await getTaskById(taskId);
    if (task == null) return;

    final receivers = <String>{};
    if (task.createdBy.isNotEmpty && task.createdBy != uid) {
      receivers.add(task.createdBy);
    }
    if (task.assignedTo != null &&
        task.assignedTo!.isNotEmpty &&
        task.assignedTo != uid) {
      receivers.add(task.assignedTo!);
    }

    for (final userId in receivers) {
      await _createNotification(
        userId: userId,
        taskId: taskId,
        groupId: groupId,
        title: 'Có bình luận mới',
        message: task.title,
        type: 'comment',
      );
    }
  }

  Stream<List<TaskActivityLogModel>> streamActivityLogs(String taskId) {
    return _activityLogs
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskActivityLogModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<NotificationModel>> streamMyNotifications() {
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    return _notifications
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final uid = currentUserId;
    if (uid.isEmpty) return;

    final doc = await _notifications.doc(notificationId).get();
    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;
    if ((data['userId'] ?? '').toString() != uid) return;
    if ((data['isRead'] ?? false) == true) return;

    await _notifications.doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead() async {
    final uid = currentUserId;
    if (uid.isEmpty) return;

    final snapshot = await _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final type = (data['type'] ?? '').toString();
      final invitationStatus = (data['invitationStatus'] ?? '').toString();

      if ((type == 'group_invite' || type == 'group_join_request') &&
          invitationStatus == 'pending') {
        continue;
      }

      await doc.reference.update({'isRead': true});
    }
  }

  Stream<List<AttachmentModel>> streamAttachments(String taskId) {
    return _attachments
        .where('taskId', isEqualTo: taskId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttachmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addAttachment({
    required String taskId,
    required String fileName,
    required String fileUrl,
    required String fileType,
  }) async {
    final docRef = _attachments.doc();

    final attachment = AttachmentModel(
      attachmentId: docRef.id,
      taskId: taskId,
      uploadedBy: currentUserId,
      fileName: fileName.trim(),
      fileUrl: fileUrl.trim(),
      fileType: fileType.trim(),
      uploadedAt: DateTime.now(),
    );

    await docRef.set(attachment.toMap());

    final task = await getTaskById(taskId);

    await _addActivityLog(
      taskId: taskId,
      groupId: task?.groupId,
      action: 'add_attachment',
      oldValue: null,
      newValue: fileName.trim(),
    );

    if (task != null) {
      final receivers = <String>{};
      if (task.createdBy.isNotEmpty && task.createdBy != currentUserId) {
        receivers.add(task.createdBy);
      }
      if (task.assignedTo != null &&
          task.assignedTo!.isNotEmpty &&
          task.assignedTo != currentUserId) {
        receivers.add(task.assignedTo!);
      }

      for (final userId in receivers) {
        await _createNotification(
          userId: userId,
          taskId: taskId,
          groupId: task.groupId,
          title: 'Có tệp đính kèm mới',
          message: task.title,
          type: 'update',
        );
      }
    }
  }

  Future<void> deleteAttachment({
    required AttachmentModel attachment,
    String? groupId,
  }) async {
    await _attachments.doc(attachment.attachmentId).delete();

    await _addActivityLog(
      taskId: attachment.taskId,
      groupId: groupId,
      action: 'delete_attachment',
      oldValue: attachment.fileName,
      newValue: null,
    );
  }

  Future<void> _addActivityLog({
    required String? taskId,
    required String? groupId,
    required String action,
    required String? oldValue,
    required String? newValue,
  }) async {
    final uid = currentUserId;
    final docRef = _activityLogs.doc();

    final log = TaskActivityLogModel(
      logId: docRef.id,
      taskId: taskId,
      groupId: groupId,
      userId: uid,
      action: action,
      oldValue: oldValue,
      newValue: newValue,
      createdAt: DateTime.now(),
    );

    await docRef.set(log.toMap());
  }

  Future<void> _createNotification({
    required String userId,
    required String? taskId,
    required String? groupId,
    required String title,
    required String message,
    required String type,
    String? invitationStatus,
    String? requesterUserId,
  }) async {
    final docRef = _notifications.doc();

    final notification = NotificationModel(
      notificationId: docRef.id,
      userId: userId,
      taskId: taskId,
      groupId: groupId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      invitationStatus: invitationStatus,
      requesterUserId: requesterUserId,
      createdAt: DateTime.now(),
    );

    await docRef.set(notification.toMap());
  }
}