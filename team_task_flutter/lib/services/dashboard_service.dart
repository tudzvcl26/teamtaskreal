import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_task_flutter/models/dashboard_data.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DashboardData> getDashboardData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final uid = user.uid;

    // 1. Lấy thông tin user
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userName = userDoc.data()?['name'] ?? 'User';

    // 2. Lấy danh sách group mà user tham gia
    final groupMemberSnapshot = await _firestore
        .collection('group_members')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    final groupIds = groupMemberSnapshot.docs
        .map((doc) => doc['groupId'] as String)
        .toList();

    int totalGroups = groupIds.length;

    List<Map<String, dynamic>> recentGroups = [];

    if (groupIds.isNotEmpty) {
      final groupFutures = groupIds.map(
        (groupId) => _firestore.collection('groups').doc(groupId).get(),
      );

      final groupDocs = await Future.wait(groupFutures);

      recentGroups = groupDocs
          .where((doc) => doc.exists)
          .map((doc) {
            final data = doc.data()!;
            return {
              'groupId': data['groupId'] ?? '',
              'groupName': data['groupName'] ?? '',
              'inviteCode': data['inviteCode'] ?? '',
              'createdAt': data['createdAt'],
            };
          })
          .toList();

      recentGroups.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];

        if (aTime == null || bTime == null) return 0;
        return (bTime as Timestamp).compareTo(aTime as Timestamp);
      });

      if (recentGroups.length > 5) {
        recentGroups = recentGroups.take(5).toList();
      }
    }

    // 3. Lấy task thuộc các group của user
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allTaskDocs = [];

    for (final groupId in groupIds) {
      final taskSnapshot = await _firestore
          .collection('tasks')
          .where('groupId', isEqualTo: groupId)
          .get();

      allTaskDocs.addAll(taskSnapshot.docs);
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    int totalTasks = allTaskDocs.length;
    int completedTasks = 0;
    int overdueTasks = 0;

    List<Map<String, dynamic>> todayTasks = [];

    for (final doc in allTaskDocs) {
      final data = doc.data();

      final status = (data['status'] ?? '').toString().toLowerCase();
      final dueDateRaw = data['dueDate'];
      DateTime? dueDate;

      if (dueDateRaw is Timestamp) {
        dueDate = dueDateRaw.toDate();
      } else if (dueDateRaw is String && dueDateRaw.isNotEmpty) {
        dueDate = DateTime.tryParse(dueDateRaw);
      }

      if (status == 'done') {
        completedTasks++;
      }

      if (dueDate != null && dueDate.isBefore(now) && status != 'done') {
        overdueTasks++;
      }

      if (dueDate != null &&
          dueDate.isAfter(todayStart) &&
          dueDate.isBefore(todayEnd)) {
        todayTasks.add({
          'taskId': data['taskId'] ?? '',
          'title': data['title'] ?? '',
          'status': data['status'] ?? '',
          'priority': data['priority'] ?? '',
          'groupId': data['groupId'] ?? '',
          'dueDate': dueDate,
        });
      }
    }

    todayTasks.sort((a, b) {
      final aDate = a['dueDate'] as DateTime?;
      final bDate = b['dueDate'] as DateTime?;
      if (aDate == null || bDate == null) return 0;
      return aDate.compareTo(bDate);
    });

    return DashboardData(
      userName: userName,
      totalGroups: totalGroups,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      recentGroups: recentGroups,
      todayTasks: todayTasks,
    );
  }
}