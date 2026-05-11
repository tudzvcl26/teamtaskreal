import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_task_flutter/models/group_member_model.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/models/notification_model.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get _groupMembers =>
      _firestore.collection('group_members');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _attachments =>
      _firestore.collection('attachments');

  CollectionReference<Map<String, dynamic>> get _activityLogs =>
      _firestore.collection('activity_logs');

  User _requireCurrentUser() {
    final user = currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }
    return user;
  }

  String _memberDocId(String groupId, String userId) {
    return '${groupId}_$userId';
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String> _generateUniqueInviteCode() async {
    for (int i = 0; i < 30; i++) {
      final code = _generateInviteCode();
      final snapshot =
          await _groups.where('inviteCode', isEqualTo: code).limit(1).get();
      if (snapshot.docs.isEmpty) {
        return code;
      }
    }
    throw Exception('Không thể tạo mã mời duy nhất');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _requireGroupDoc(
    String groupId,
  ) async {
    final doc = await _groups.doc(groupId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Không tìm thấy nhóm');
    }
    return doc;
  }

  Future<Map<String, dynamic>> _requireActiveGroupData(String groupId) async {
    final doc = await _requireGroupDoc(groupId);
    final data = doc.data()!;
    if ((data['isArchived'] ?? false) == true) {
      throw Exception('Nhóm này đã được lưu trữ');
    }
    return data;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _membershipDoc({
    required String groupId,
    required String userId,
  }) async {
    return _groupMembers.doc(_memberDocId(groupId, userId)).get();
  }

  Future<String> getMyRoleInGroup(String groupId) async {
    final user = _requireCurrentUser();
    final memberDoc = await _membershipDoc(
      groupId: groupId,
      userId: user.uid,
    );

    if (!memberDoc.exists || memberDoc.data() == null) return '';

    final data = memberDoc.data()!;
    final status = (data['status'] ?? '').toString();
    if (status != 'active') return '';

    return (data['role'] ?? 'member').toString();
  }

  Future<bool> canManageGroup(String groupId) async {
    final role = await getMyRoleInGroup(groupId);
    return role == 'admin' || role == 'leader';
  }

  Future<void> _requireManagePermission(String groupId) async {
    final allowed = await canManageGroup(groupId);
    if (!allowed) {
      throw Exception('Bạn không có quyền quản lý nhóm này');
    }
  }

  Future<void> _addActivityLog({
    required String? taskId,
    required String? groupId,
    required String action,
    required String? oldValue,
    required String? newValue,
  }) async {
    final user = _requireCurrentUser();
    final logRef = _activityLogs.doc();

    await logRef.set({
      'logId': logRef.id,
      'taskId': taskId,
      'groupId': groupId,
      'userId': user.uid,
      'action': action,
      'oldValue': oldValue,
      'newValue': newValue,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
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

  Future<void> _finishRelatedJoinRequestNotifications({
    required String groupId,
    required String requesterUserId,
    required String status,
  }) async {
    final snapshot = await _notifications
        .where('groupId', isEqualTo: groupId)
        .where('requesterUserId', isEqualTo: requesterUserId)
        .where('type', isEqualTo: 'group_join_request')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'invitationStatus': status,
        'isRead': true,
      });
    }
  }

  Future<void> createGroup({
    required String groupName,
    required String description,
    required String groupColor,
    required String groupIcon,
  }) async {
    final user = _requireCurrentUser();

    final groupDoc = _groups.doc();
    final groupId = groupDoc.id;
    final inviteCode = await _generateUniqueInviteCode();

    await groupDoc.set({
      'groupId': groupId,
      'groupName': groupName.trim(),
      'description': description.trim(),
      'createdBy': user.uid,
      'inviteCode': inviteCode,
      'groupColor': groupColor,
      'groupIcon': groupIcon,
      'isArchived': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final memberRef = _groupMembers.doc(_memberDocId(groupId, user.uid));
    await memberRef.set({
      'id': memberRef.id,
      'groupId': groupId,
      'userId': user.uid,
      'role': 'admin',
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'invitedBy': user.uid,
      'invitedAt': FieldValue.serverTimestamp(),
      'respondedAt': FieldValue.serverTimestamp(),
    });

    await _addActivityLog(
      taskId: null,
      groupId: groupId,
      action: 'create_group',
      oldValue: null,
      newValue: groupName.trim(),
    );
  }

  Future<void> updateGroup({
    required String groupId,
    required String groupName,
    required String description,
    required String groupColor,
    required String groupIcon,
  }) async {
    final oldData = await _requireActiveGroupData(groupId);
    await _requireManagePermission(groupId);

    await _groups.doc(groupId).update({
      'groupName': groupName.trim(),
      'description': description.trim(),
      'groupColor': groupColor,
      'groupIcon': groupIcon,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addActivityLog(
      taskId: null,
      groupId: groupId,
      action: 'update_group',
      oldValue: oldData.toString(),
      newValue: {
        'groupName': groupName.trim(),
        'description': description.trim(),
        'groupColor': groupColor,
        'groupIcon': groupIcon,
      }.toString(),
    );
  }

  Future<void> archiveGroup(String groupId) async {
    final oldData = await _requireActiveGroupData(groupId);
    await _requireManagePermission(groupId);

    await _groups.doc(groupId).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addActivityLog(
      taskId: null,
      groupId: groupId,
      action: 'archive_group',
      oldValue: oldData.toString(),
      newValue: 'archived',
    );
  }

  Future<void> _deleteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (final doc in docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await _requireActiveGroupData(groupId);
    await _requireManagePermission(groupId);

    final taskSnapshot = await _tasks.where('groupId', isEqualTo: groupId).get();
    final memberSnapshot =
        await _groupMembers.where('groupId', isEqualTo: groupId).get();
    final groupLogSnapshot =
        await _activityLogs.where('groupId', isEqualTo: groupId).get();
    final groupNotificationSnapshot =
        await _notifications.where('groupId', isEqualTo: groupId).get();

    for (final taskDoc in taskSnapshot.docs) {
      final taskId = taskDoc.id;

      final commentsSnapshot =
          await _comments.where('taskId', isEqualTo: taskId).get();
      final taskLogsSnapshot =
          await _activityLogs.where('taskId', isEqualTo: taskId).get();
      final taskNotificationsSnapshot =
          await _notifications.where('taskId', isEqualTo: taskId).get();
      final attachmentsSnapshot =
          await _attachments.where('taskId', isEqualTo: taskId).get();

      await _deleteDocs(commentsSnapshot.docs);
      await _deleteDocs(taskLogsSnapshot.docs);
      await _deleteDocs(taskNotificationsSnapshot.docs);
      await _deleteDocs(attachmentsSnapshot.docs);
      await taskDoc.reference.delete();
    }

    await _deleteDocs(memberSnapshot.docs);
    await _deleteDocs(groupLogSnapshot.docs);
    await _deleteDocs(groupNotificationSnapshot.docs);

    await _groups.doc(groupId).delete();
  }

  Future<GroupModel> getGroupById(String groupId) async {
    final doc = await _groups.doc(groupId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Không tìm thấy nhóm');
    }

    return GroupModel.fromMap(doc.data()!);
  }

  Future<GroupModel?> findGroupByInviteCode(String inviteCode) async {
    final code = inviteCode.trim().toUpperCase();

    if (code.isEmpty) return null;

    final snapshot = await _groups
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    if ((data['isArchived'] ?? false) == true) return null;

    return GroupModel.fromMap(data);
  }

  Future<int> getMemberCount(String groupId) async {
    final snapshot = await _groupMembers
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'active')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getTaskCount(String groupId) async {
    final snapshot = await _tasks.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.length;
  }

  Future<int> getDoneTaskCount(String groupId) async {
    final snapshot = await _tasks
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'done')
        .get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> getGroupStats(String groupId) async {
    final results = await Future.wait<int>([
      getMemberCount(groupId),
      getTaskCount(groupId),
      getDoneTaskCount(groupId),
    ]);

    return {
      'memberCount': results[0],
      'taskCount': results[1],
      'doneTaskCount': results[2],
    };
  }

  List<List<T>> _chunkList<T>(List<T> items, int chunkSize) {
    final List<List<T>> chunks = [];
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

  Future<Map<String, Map<String, int>>> getStatsForGroups(
    List<String> groupIds,
  ) async {
    final uniqueIds = groupIds.toSet().toList();
    final result = <String, Map<String, int>>{};

    for (final groupId in uniqueIds) {
      result[groupId] = {
        'memberCount': 0,
        'taskCount': 0,
        'doneTaskCount': 0,
      };
    }

    if (uniqueIds.isEmpty) return result;

    final chunks = _chunkList(uniqueIds, 10);

    for (final chunk in chunks) {
      final memberSnapshot = await _groupMembers
          .where('groupId', whereIn: chunk)
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in memberSnapshot.docs) {
        final groupId = (doc.data()['groupId'] ?? '').toString();
        if (result.containsKey(groupId)) {
          result[groupId]!['memberCount'] =
              (result[groupId]!['memberCount'] ?? 0) + 1;
        }
      }

      final taskSnapshot = await _tasks.where('groupId', whereIn: chunk).get();

      for (final doc in taskSnapshot.docs) {
        final data = doc.data();
        final groupId = (data['groupId'] ?? '').toString();
        final status = (data['status'] ?? '').toString();

        if (!result.containsKey(groupId)) continue;

        result[groupId]!['taskCount'] =
            (result[groupId]!['taskCount'] ?? 0) + 1;
        if (status == 'done') {
          result[groupId]!['doneTaskCount'] =
              (result[groupId]!['doneTaskCount'] ?? 0) + 1;
        }
      }
    }

    return result;
  }

  Future<List<GroupMemberModel>> _buildMembersFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final futures = docs.map((doc) async {
      final data = doc.data();
      final userId = (data['userId'] ?? '').toString();

      String name = 'User';
      String email = '';
      String avatar = '';

      if (userId.isNotEmpty) {
        final userDoc = await _users.doc(userId).get();
        final userData = userDoc.data();

        if (userData != null) {
          name = (userData['name'] ?? 'User').toString();
          email = (userData['email'] ?? '').toString();
          avatar = (userData['avatar'] ?? '').toString();
        }
      }

      return GroupMemberModel(
        id: (data['id'] ?? '').toString(),
        groupId: (data['groupId'] ?? '').toString(),
        userId: userId,
        role: (data['role'] ?? 'member').toString(),
        status: (data['status'] ?? 'active').toString(),
        name: name,
        email: email,
        avatar: avatar,
      );
    }).toList();

    return Future.wait(futures);
  }

  Future<List<GroupMemberModel>> getGroupMembersPreview(
    String groupId, {
    int limit = 5,
  }) async {
    final memberSnapshot = await _groupMembers
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'active')
        .get();

    final docs = memberSnapshot.docs.take(limit).toList();
    return _buildMembersFromDocs(docs);
  }

  Future<List<GroupMemberModel>> getAllGroupMembers(
    String groupId, {
    bool includePending = true,
  }) async {
    final activeSnapshot = await _groupMembers
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'active')
        .get();

    final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
      ...activeSnapshot.docs,
    ];

    if (includePending) {
      final pendingSnapshot = await _groupMembers
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'pending')
          .get();
      allDocs.addAll(pendingSnapshot.docs);
    }

    final result = await _buildMembersFromDocs(allDocs);

    result.sort((a, b) {
      if (a.status == b.status) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (a.status == 'active') return -1;
      if (b.status == 'active') return 1;
      return a.status.toLowerCase().compareTo(b.status.toLowerCase());
    });

    return result;
  }

  Future<void> addMemberByEmail({
    required String groupId,
    required String email,
  }) async {
    final inviter = _requireCurrentUser();
    final groupData = await _requireActiveGroupData(groupId);
    await _requireManagePermission(groupId);

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email không được để trống');
    }

    final userSnapshot = await _users
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      throw Exception('Không tìm thấy người dùng với email này');
    }

    final userData = userSnapshot.docs.first.data();
    final userId = (userData['userId'] ?? userSnapshot.docs.first.id).toString();

    if (userId.isEmpty) {
      throw Exception('Dữ liệu người dùng không hợp lệ');
    }

    if (userId == inviter.uid) {
      throw Exception('Bạn đã ở trong nhóm này');
    }

    final memberRef = _groupMembers.doc(_memberDocId(groupId, userId));
    final memberDoc = await memberRef.get();

    if (memberDoc.exists && memberDoc.data() != null) {
      final existingData = memberDoc.data()!;
      final existingStatus = (existingData['status'] ?? '').toString();

      if (existingStatus == 'active') {
        throw Exception('Người này đã ở trong nhóm');
      }

      if (existingStatus == 'pending') {
        throw Exception('Người này đang chờ phản hồi');
      }

      await memberRef.update({
        'status': 'pending',
        'role': (existingData['role'] ?? 'member').toString(),
        'invitedBy': inviter.uid,
        'invitedAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
        'joinedAt': null,
      });
    } else {
      await memberRef.set({
        'id': memberRef.id,
        'groupId': groupId,
        'userId': userId,
        'role': 'member',
        'joinedAt': null,
        'status': 'pending',
        'invitedBy': inviter.uid,
        'invitedAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
      });
    }

    final groupName = (groupData['groupName'] ?? 'Nhóm').toString();

    await _createNotification(
      userId: userId,
      taskId: null,
      groupId: groupId,
      title: 'Lời mời tham gia nhóm',
      message: 'Bạn vừa được mời vào nhóm "$groupName".',
      type: 'group_invite',
      invitationStatus: 'pending',
    );

    await _addActivityLog(
      taskId: null,
      groupId: groupId,
      action: 'invite_member',
      oldValue: null,
      newValue: '$normalizedEmail -> pending',
    );
  }

  Future<void> requestToJoinByInviteCode(String inviteCode) async {
    final user = _requireCurrentUser();
    final group = await findGroupByInviteCode(inviteCode);

    if (group == null) {
      throw Exception('Không tìm thấy nhóm với mã này');
    }

    if (group.createdBy == user.uid) {
      throw Exception('Bạn là người tạo nhóm này rồi');
    }

    final memberRef = _groupMembers.doc(_memberDocId(group.groupId, user.uid));
    final memberDoc = await memberRef.get();

    if (memberDoc.exists && memberDoc.data() != null) {
      final status = (memberDoc.data()!['status'] ?? '').toString();

      if (status == 'active') {
        throw Exception('Bạn đã là thành viên của nhóm');
      }

      if (status == 'pending') {
        throw Exception('Yêu cầu tham gia của bạn đang chờ duyệt');
      }
    }

    await memberRef.set({
      'id': memberRef.id,
      'groupId': group.groupId,
      'userId': user.uid,
      'role': 'member',
      'joinedAt': null,
      'status': 'pending',
      'invitedBy': null,
      'invitedAt': null,
      'respondedAt': null,
      'requestBy': user.uid,
      'requestedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final adminsSnapshot = await _groupMembers
        .where('groupId', isEqualTo: group.groupId)
        .where('status', isEqualTo: 'active')
        .get();

    final requesterUserDoc = await _users.doc(user.uid).get();
    final requesterName =
        (requesterUserDoc.data()?['name'] ?? 'Một người dùng').toString();

    for (final doc in adminsSnapshot.docs) {
      final data = doc.data();
      final role = (data['role'] ?? 'member').toString();
      final adminUserId = (data['userId'] ?? '').toString();

      if (adminUserId.isEmpty) continue;
      if (role != 'admin' && role != 'leader') continue;

      await _createNotification(
        userId: adminUserId,
        taskId: null,
        groupId: group.groupId,
        title: 'Yêu cầu tham gia nhóm',
        message: '$requesterName muốn tham gia nhóm "${group.groupName}".',
        type: 'group_join_request',
        invitationStatus: 'pending',
        requesterUserId: user.uid,
      );
    }

    await _addActivityLog(
      taskId: null,
      groupId: group.groupId,
      action: 'request_join_group',
      oldValue: null,
      newValue: user.uid,
    );
  }

  Future<void> respondToGroupInvitation({
    required String notificationId,
    required bool accept,
  }) async {
    final user = _requireCurrentUser();

    final notificationDoc = await _notifications.doc(notificationId).get();
    if (!notificationDoc.exists || notificationDoc.data() == null) {
      throw Exception('Không tìm thấy thông báo');
    }

    final notificationData = notificationDoc.data()!;
    final ownerUserId = (notificationData['userId'] ?? '').toString();
    final type = (notificationData['type'] ?? '').toString();
    final currentInvitationStatus =
        (notificationData['invitationStatus'] ?? 'pending').toString();
    final groupId = (notificationData['groupId'] ?? '').toString();

    if (ownerUserId != user.uid) {
      throw Exception('Bạn không có quyền xử lý lời mời này');
    }

    if (type != 'group_invite') {
      throw Exception('Đây không phải lời mời vào nhóm');
    }

    if (currentInvitationStatus != 'pending') {
      throw Exception('Lời mời này đã được xử lý trước đó');
    }

    if (groupId.isEmpty) {
      throw Exception('Thiếu thông tin nhóm trong lời mời');
    }

    final memberRef = _groupMembers.doc(_memberDocId(groupId, user.uid));
    final memberDoc = await memberRef.get();

    if (!memberDoc.exists || memberDoc.data() == null) {
      throw Exception('Không tìm thấy lời mời tham gia nhóm');
    }

    final memberData = memberDoc.data()!;
    final memberStatus = (memberData['status'] ?? '').toString();

    if (memberStatus != 'pending') {
      await notificationDoc.reference.update({
        'invitationStatus': memberStatus == 'active' ? 'accepted' : memberStatus,
        'isRead': true,
      });
      throw Exception('Lời mời này không còn ở trạng thái chờ');
    }

    if (accept) {
      await _requireActiveGroupData(groupId);

      await memberRef.update({
        'status': 'active',
        'joinedAt': FieldValue.serverTimestamp(),
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await notificationDoc.reference.update({
        'invitationStatus': 'accepted',
        'isRead': true,
      });

      await _addActivityLog(
        taskId: null,
        groupId: groupId,
        action: 'accept_group_invite',
        oldValue: 'pending',
        newValue: 'active',
      );
    } else {
      await memberRef.update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await notificationDoc.reference.update({
        'invitationStatus': 'declined',
        'isRead': true,
      });

      await _addActivityLog(
        taskId: null,
        groupId: groupId,
        action: 'decline_group_invite',
        oldValue: 'pending',
        newValue: 'declined',
      );
    }
  }

  Future<void> respondToJoinRequest({
    required String notificationId,
    required bool accept,
  }) async {
    final user = _requireCurrentUser();

    final notificationDoc = await _notifications.doc(notificationId).get();
    if (!notificationDoc.exists || notificationDoc.data() == null) {
      throw Exception('Không tìm thấy thông báo');
    }

    final data = notificationDoc.data()!;
    final type = (data['type'] ?? '').toString();
    final groupId = (data['groupId'] ?? '').toString();
    final requesterUserId = (data['requesterUserId'] ?? '').toString();
    final currentStatus = (data['invitationStatus'] ?? 'pending').toString();
    final ownerUserId = (data['userId'] ?? '').toString();

    if (ownerUserId != user.uid) {
      throw Exception('Bạn không có quyền xử lý yêu cầu này');
    }

    if (type != 'group_join_request') {
      throw Exception('Đây không phải yêu cầu tham gia nhóm');
    }

    if (currentStatus != 'pending') {
      throw Exception('Yêu cầu này đã được xử lý rồi');
    }

    if (groupId.isEmpty || requesterUserId.isEmpty) {
      throw Exception('Thiếu dữ liệu yêu cầu tham gia');
    }

    await _requireManagePermission(groupId);
    await _requireActiveGroupData(groupId);

    final memberRef = _groupMembers.doc(_memberDocId(groupId, requesterUserId));
    final memberDoc = await memberRef.get();

    if (!memberDoc.exists || memberDoc.data() == null) {
      throw Exception('Không tìm thấy yêu cầu tham gia');
    }

    final memberData = memberDoc.data()!;
    final memberStatus = (memberData['status'] ?? '').toString();

    if (memberStatus != 'pending') {
      await _finishRelatedJoinRequestNotifications(
        groupId: groupId,
        requesterUserId: requesterUserId,
        status: memberStatus == 'active' ? 'accepted' : memberStatus,
      );
      throw Exception('Yêu cầu này không còn ở trạng thái chờ');
    }

    final group = await getGroupById(groupId);

    if (accept) {
      await memberRef.update({
        'status': 'active',
        'joinedAt': FieldValue.serverTimestamp(),
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await _finishRelatedJoinRequestNotifications(
        groupId: groupId,
        requesterUserId: requesterUserId,
        status: 'accepted',
      );

      await _createNotification(
        userId: requesterUserId,
        taskId: null,
        groupId: groupId,
        title: 'Yêu cầu tham gia đã được chấp nhận',
        message: 'Bạn đã được chấp nhận vào nhóm "${group.groupName}".',
        type: 'group_join_result',
        invitationStatus: 'accepted',
      );

      await _addActivityLog(
        taskId: null,
        groupId: groupId,
        action: 'approve_join_request',
        oldValue: 'pending',
        newValue: requesterUserId,
      );
    } else {
      await memberRef.update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await _finishRelatedJoinRequestNotifications(
        groupId: groupId,
        requesterUserId: requesterUserId,
        status: 'declined',
      );

      await _createNotification(
        userId: requesterUserId,
        taskId: null,
        groupId: groupId,
        title: 'Yêu cầu tham gia bị từ chối',
        message: 'Yêu cầu tham gia nhóm "${group.groupName}" đã bị từ chối.',
        type: 'group_join_result',
        invitationStatus: 'declined',
      );

      await _addActivityLog(
        taskId: null,
        groupId: groupId,
        action: 'reject_join_request',
        oldValue: 'pending',
        newValue: requesterUserId,
      );
    }
  }

  Stream<List<GroupModel>> getMyGroups() {
    final user = currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _groupMembers
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((memberSnapshot) async {
      final groupIds = memberSnapshot.docs
          .map((doc) => (doc.data()['groupId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (groupIds.isEmpty) return <GroupModel>[];

      final futures =
          groupIds.map((groupId) => _groups.doc(groupId).get()).toList();
      final docs = await Future.wait(futures);

      final groups = docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => GroupModel.fromMap(doc.data()!))
          .where((group) => group.isArchived != true)
          .toList();

      groups.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return groups;
    });
  }
}