import 'dart:async';

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

  String _requireCurrentUserId() {
    final uid = currentUserId;

    if (uid.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    return uid;
  }

  String _memberDocId(String groupId, String userId) {
    return '${groupId}_$userId';
  }

  List<List<T>> _chunkList<T>(List<T> items, int chunkSize) {
    final chunks = <List<T>>[];

    for (int i = 0; i < items.length; i += chunkSize) {
      chunks.add(
        items.sublist(
          i,
          i + chunkSize > items.length ? items.length : i + chunkSize,
        ),
      );
    }

    return chunks;
  }

  Future<Map<String, dynamic>> _requireActiveMembership(String groupId) async {
    final uid = _requireCurrentUserId();

    if (groupId.isEmpty) {
      throw Exception('Thiếu mã nhóm');
    }

    final groupDoc = await _groups.doc(groupId).get();
    final groupData = groupDoc.data();

    if (!groupDoc.exists || groupData == null) {
      throw Exception('Không tìm thấy nhóm');
    }

    if ((groupData['isArchived'] ?? false) == true) {
      throw Exception('Nhóm này đã được lưu trữ');
    }

    final memberDoc = await _groupMembers.doc(_memberDocId(groupId, uid)).get();
    final memberData = memberDoc.data();

    if (!memberDoc.exists || memberData == null) {
      throw Exception('Bạn không thuộc nhóm này');
    }

    if ((memberData['status'] ?? '').toString() != 'active') {
      throw Exception('Bạn chưa có quyền truy cập nhóm này');
    }

    return memberData;
  }

  Future<bool> _isActiveMember({
    required String groupId,
    required String userId,
  }) async {
    if (groupId.isEmpty || userId.isEmpty) return false;

    final memberDoc =
        await _groupMembers.doc(_memberDocId(groupId, userId)).get();
    final data = memberDoc.data();

    return memberDoc.exists &&
        data != null &&
        (data['status'] ?? '').toString() == 'active';
  }

  Future<void> _requireAssignableMember({
    required String groupId,
    required String? assignedTo,
  }) async {
    if (assignedTo == null || assignedTo.isEmpty) return;

    final ok = await _isActiveMember(
      groupId: groupId,
      userId: assignedTo,
    );

    if (!ok) {
      throw Exception('Người được giao không thuộc nhóm này');
    }
  }

  Future<TaskModel> _requireTaskAccess(String taskId) async {
    if (taskId.isEmpty) {
      throw Exception('Thiếu mã công việc');
    }

    final doc = await _tasks.doc(taskId).get();
    final data = doc.data();

    if (!doc.exists || data == null) {
      throw Exception('Không tìm thấy công việc');
    }

    final task = TaskModel.fromMap(data, doc.id);
    await _requireActiveMembership(task.groupId);

    return task;
  }

  bool _canEditTask({
    required TaskModel task,
    required Map<String, dynamic> memberData,
  }) {
    final uid = _requireCurrentUserId();
    final role = (memberData['role'] ?? 'member').toString();

    return role == 'admin' ||
        role == 'leader' ||
        task.createdBy == uid ||
        task.assignedTo == uid;
  }

  bool _canDeleteTask({
    required TaskModel task,
    required Map<String, dynamic> memberData,
  }) {
    final uid = _requireCurrentUserId();
    final role = (memberData['role'] ?? 'member').toString();

    return role == 'admin' || role == 'leader' || task.createdBy == uid;
  }

  bool _canDeleteAttachment({
    required TaskModel task,
    required AttachmentModel attachment,
    required Map<String, dynamic> memberData,
  }) {
    final uid = _requireCurrentUserId();
    final role = (memberData['role'] ?? 'member').toString();

    return role == 'admin' ||
        role == 'leader' ||
        task.createdBy == uid ||
        task.assignedTo == uid ||
        attachment.uploadedBy == uid;
  }

  Stream<List<TaskModel>> streamAllTasks() {
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    final controller = StreamController<List<TaskModel>>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? memberSub;
    final taskSubs = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
    final chunkTaskMaps = <int, Map<String, TaskModel>>{};

    void emitTasks() {
      if (controller.isClosed) return;

      final merged = <String, TaskModel>{};

      for (final taskMap in chunkTaskMaps.values) {
        merged.addAll(taskMap);
      }

      final tasks = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      controller.add(tasks);
    }

    Future<void> resetTaskListeners(List<String> groupIds) async {
      for (final sub in taskSubs) {
        await sub.cancel();
      }

      taskSubs.clear();
      chunkTaskMaps.clear();

      if (groupIds.isEmpty) {
        emitTasks();
        return;
      }

      final chunks = _chunkList(groupIds, 10);

      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];

        final sub = _tasks
            .where('groupId', whereIn: chunk)
            .snapshots()
            .listen((snapshot) {
          chunkTaskMaps[i] = {
            for (final doc in snapshot.docs)
              doc.id: TaskModel.fromMap(doc.data(), doc.id),
          };

          emitTasks();
        }, onError: controller.addError);

        taskSubs.add(sub);
      }
    }

    controller.onListen = () {
      memberSub = _groupMembers
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .snapshots()
          .listen((memberSnapshot) async {
        try {
          final rawIds = memberSnapshot.docs
              .map((doc) => (doc.data()['groupId'] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList();

          final validIds = <String>[];

          for (final groupId in rawIds) {
            final groupDoc = await _groups.doc(groupId).get();
            final groupData = groupDoc.data();

            if (!groupDoc.exists || groupData == null) continue;
            if ((groupData['isArchived'] ?? false) == true) continue;

            validIds.add(groupId);
          }

          await resetTaskListeners(validIds);
        } catch (e) {
          if (!controller.isClosed) controller.addError(e);
        }
      }, onError: controller.addError);
    };

    controller.onCancel = () async {
      await memberSub?.cancel();

      for (final sub in taskSubs) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }

  Stream<TaskModel?> streamTaskById(String taskId) {
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    return _tasks.doc(taskId).snapshots().asyncMap((doc) async {
      if (!doc.exists || doc.data() == null) return null;

      final task = TaskModel.fromMap(doc.data()!, doc.id);

      try {
        await _requireActiveMembership(task.groupId);
        return task;
      } catch (_) {
        return null;
      }
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

    result.sort(
      (a, b) => a['groupName']
          .toString()
          .toLowerCase()
          .compareTo(b['groupName'].toString().toLowerCase()),
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getGroupMembersForTaskForm(
    String groupId,
  ) async {
    await _requireActiveMembership(groupId);

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

    members.sort(
      (a, b) => a['name']
          .toString()
          .toLowerCase()
          .compareTo(b['name'].toString().toLowerCase()),
    );

    return members;
  }

  Future<String> getGroupName(String groupId) async {
    try {
      await _requireActiveMembership(groupId);

      final doc = await _groups.doc(groupId).get();

      return (doc.data()?['groupName'] ?? 'Nhóm').toString();
    } catch (_) {
      return 'Nhóm';
    }
  }

  Future<String> getUserName(String userId) async {
    if (userId.isEmpty) return 'Chưa giao';

    final doc = await _users.doc(userId).get();

    return (doc.data()?['name'] ?? 'Người dùng').toString();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return await _requireTaskAccess(taskId);
    } catch (_) {
      return null;
    }
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
    final uid = _requireCurrentUserId();

    if (title.trim().isEmpty) {
      throw Exception('Tiêu đề công việc không được để trống');
    }

    if (groupId.trim().isEmpty) {
      throw Exception('Vui lòng chọn nhóm');
    }

    if (startDate != null && dueDate != null && dueDate.isBefore(startDate)) {
      throw Exception('Hạn chót không được nhỏ hơn ngày bắt đầu');
    }

    await _requireActiveMembership(groupId);
    await _requireAssignableMember(groupId: groupId, assignedTo: assignedTo);

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
    final oldTask = await _requireTaskAccess(taskId);
    final memberData = await _requireActiveMembership(oldTask.groupId);

    if (!_canEditTask(task: oldTask, memberData: memberData)) {
      throw Exception('Bạn không có quyền sửa công việc này');
    }

    if (groupId != oldTask.groupId) {
      throw Exception('Không được chuyển công việc sang nhóm khác');
    }

    if (title.trim().isEmpty) {
      throw Exception('Tiêu đề công việc không được để trống');
    }

    if (startDate != null && dueDate != null && dueDate.isBefore(startDate)) {
      throw Exception('Hạn chót không được nhỏ hơn ngày bắt đầu');
    }

    await _requireAssignableMember(
      groupId: oldTask.groupId,
      assignedTo: assignedTo,
    );

    final oldDoc = await _tasks.doc(taskId).get();
    final oldData = oldDoc.data();
    final oldAssignedTo = oldData?['assignedTo']?.toString();

    await _tasks.doc(taskId).update({
      'groupId': oldTask.groupId,
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
      groupId: oldTask.groupId,
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
        groupId: oldTask.groupId,
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
        groupId: oldTask.groupId,
        title: 'Công việc vừa được cập nhật',
        message: title.trim(),
        type: 'update',
      );
    }
  }

  Future<void> markTaskDone(TaskModel task) async {
    final freshTask = await _requireTaskAccess(task.taskId);
    final memberData = await _requireActiveMembership(freshTask.groupId);

    if (!_canEditTask(task: freshTask, memberData: memberData)) {
      throw Exception('Bạn không có quyền cập nhật công việc này');
    }

    if (freshTask.isDone) return;

    await _tasks.doc(freshTask.taskId).update({
      'status': 'done',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _addActivityLog(
      taskId: freshTask.taskId,
      groupId: freshTask.groupId,
      action: 'mark_done',
      oldValue: freshTask.status,
      newValue: 'done',
    );

    if (freshTask.createdBy.isNotEmpty &&
        freshTask.createdBy != currentUserId) {
      await _createNotification(
        userId: freshTask.createdBy,
        taskId: freshTask.taskId,
        groupId: freshTask.groupId,
        title: 'Một công việc đã hoàn thành',
        message: freshTask.title,
        type: 'status',
      );
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final freshTask = await _requireTaskAccess(task.taskId);
    final memberData = await _requireActiveMembership(freshTask.groupId);

    if (!_canDeleteTask(task: freshTask, memberData: memberData)) {
      throw Exception('Bạn không có quyền xóa công việc này');
    }

    final commentsSnapshot =
        await _comments.where('taskId', isEqualTo: freshTask.taskId).get();

    final logsSnapshot =
        await _activityLogs.where('taskId', isEqualTo: freshTask.taskId).get();

    final notificationsSnapshot =
        await _notifications.where('taskId', isEqualTo: freshTask.taskId).get();

    final attachmentsSnapshot =
        await _attachments.where('taskId', isEqualTo: freshTask.taskId).get();

    final batch = _firestore.batch();

    for (final doc in commentsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    for (final doc in logsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    for (final doc in notificationsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    for (final doc in attachmentsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_tasks.doc(freshTask.taskId));

    final logRef = _activityLogs.doc();

    batch.set(logRef, {
      'logId': logRef.id,
      'taskId': null,
      'groupId': freshTask.groupId,
      'userId': currentUserId,
      'action': 'delete_task',
      'oldValue': freshTask.title,
      'newValue': null,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  Stream<List<TaskCommentModel>> streamComments(String taskId) {
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    return _comments
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      final task = await getTaskById(taskId);

      if (task == null) {
        return <TaskCommentModel>[];
      }

      return snapshot.docs
          .map((doc) => TaskCommentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addComment({
    required String taskId,
    required String content,
    required String groupId,
  }) async {
    final uid = _requireCurrentUserId();
    final task = await _requireTaskAccess(taskId);

    if (task.groupId != groupId) {
      throw Exception('Dữ liệu nhóm của công việc không hợp lệ');
    }

    if (content.trim().isEmpty) {
      throw Exception('Nội dung bình luận không được để trống');
    }

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
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    return _activityLogs
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final task = await getTaskById(taskId);

      if (task == null) {
        return <TaskActivityLogModel>[];
      }

      return snapshot.docs
          .map((doc) => TaskActivityLogModel.fromMap(doc.data(), doc.id))
          .toList();
    });
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
    final uid = currentUserId;
    if (uid.isEmpty) return const Stream.empty();

    return _attachments
        .where('taskId', isEqualTo: taskId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final task = await getTaskById(taskId);

      if (task == null) {
        return <AttachmentModel>[];
      }

      return snapshot.docs
          .map((doc) => AttachmentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addAttachment({
    required String taskId,
    required String fileName,
    required String fileUrl,
    required String fileType,
  }) async {
    final task = await _requireTaskAccess(taskId);

    if (fileName.trim().isEmpty || fileUrl.trim().isEmpty) {
      throw Exception('Tên file và đường dẫn file không được để trống');
    }

    final docRef = _attachments.doc();

    final attachment = AttachmentModel(
      attachmentId: docRef.id,
      taskId: taskId,
      uploadedBy: currentUserId,
      fileName: fileName.trim(),
      fileUrl: fileUrl.trim(),
      fileType: fileType.trim().isEmpty ? 'file' : fileType.trim(),
      uploadedAt: DateTime.now(),
    );

    await docRef.set(attachment.toMap());

    await _addActivityLog(
      taskId: taskId,
      groupId: task.groupId,
      action: 'add_attachment',
      oldValue: null,
      newValue: fileName.trim(),
    );

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

  Future<void> deleteAttachment({
    required AttachmentModel attachment,
    String? groupId,
  }) async {
    final task = await _requireTaskAccess(attachment.taskId);
    final memberData = await _requireActiveMembership(task.groupId);

    if (groupId != null && groupId.isNotEmpty && groupId != task.groupId) {
      throw Exception('Dữ liệu nhóm của tệp không hợp lệ');
    }

    final canDelete = _canDeleteAttachment(
      task: task,
      attachment: attachment,
      memberData: memberData,
    );

    if (!canDelete) {
      throw Exception('Bạn không có quyền xóa tệp đính kèm này');
    }

    await _attachments.doc(attachment.attachmentId).delete();

    await _addActivityLog(
      taskId: attachment.taskId,
      groupId: task.groupId,
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
    final uid = _requireCurrentUserId();
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