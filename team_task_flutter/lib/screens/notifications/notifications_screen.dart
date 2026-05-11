import 'package:flutter/material.dart';
import 'package:team_task_flutter/models/notification_model.dart';
import 'package:team_task_flutter/screens/tasks/task_detail_screen.dart';
import 'package:team_task_flutter/services/group_service.dart';
import 'package:team_task_flutter/services/task_service.dart';
import 'package:team_task_flutter/widgets/empty_task_state.dart';
import 'package:team_task_flutter/widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskService _taskService = TaskService();
  final GroupService _groupService = GroupService();
  List<NotificationModel> _lastNotifications = [];

  Future<void> _handleGroupInvite(NotificationModel item) async {
    final status = (item.invitationStatus ?? 'pending').toLowerCase();

    if (status == 'accepted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã chấp nhận lời mời này rồi')),
      );
      return;
    }

    if (status == 'declined') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã từ chối lời mời này rồi')),
      );
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lời mời tham gia nhóm'),
        content: Text(item.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'decline'),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'accept'),
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );

    if (action == null) return;

    try {
      await _groupService.respondToGroupInvitation(
        notificationId: item.notificationId,
        accept: action == 'accept',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'accept'
                ? 'Bạn đã tham gia nhóm thành công'
                : 'Bạn đã từ chối lời mời tham gia nhóm',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _handleJoinRequest(NotificationModel item) async {
    final status = (item.invitationStatus ?? 'pending').toLowerCase();

    if (status == 'accepted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu này đã được chấp nhận rồi')),
      );
      return;
    }

    if (status == 'declined') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu này đã bị từ chối rồi')),
      );
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Yêu cầu tham gia nhóm'),
        content: Text(item.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'decline'),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'accept'),
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );

    if (action == null) return;

    try {
      await _groupService.respondToJoinRequest(
        notificationId: item.notificationId,
        accept: action == 'accept',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'accept'
                ? 'Đã chấp nhận người dùng vào nhóm'
                : 'Đã từ chối yêu cầu tham gia nhóm',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _openNotification(NotificationModel item) async {
    if (item.type == 'group_invite') {
      await _handleGroupInvite(item);
      return;
    }

    if (item.type == 'group_join_request') {
      await _handleJoinRequest(item);
      return;
    }

    try {
      await _taskService.markNotificationAsRead(item.notificationId);
    } catch (_) {}

    if (!mounted) return;

    if (item.taskId != null && item.taskId!.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: item.taskId!),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(item.message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: _taskService.streamMyNotifications(),
      builder: (context, snapshot) {
        final hasFreshData = snapshot.hasData;
        final notifications = hasFreshData ? snapshot.data! : _lastNotifications;

        if (hasFreshData) {
          _lastNotifications = snapshot.data!;
        }

        final unreadCount = notifications.where((e) => !e.isRead).length;
        final isLoadingFirstTime =
            snapshot.connectionState == ConnectionState.waiting &&
                _lastNotifications.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Thông báo',
              style: TextStyle(
                fontFamily: _headlineFont,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await _taskService.markAllNotificationsAsRead();
                  },
                  child: const Text(
                    'Đọc hết',
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.notifications_active_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng quan thông báo',
                            style: TextStyle(
                              fontFamily: _headlineFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unreadCount thông báo chưa đọc',
                            style: const TextStyle(
                              fontFamily: _bodyFont,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isLoadingFirstTime)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notifications.isEmpty)
                const EmptyTaskState(message: 'Chưa có thông báo nào')
              else
                ...notifications.map(
                  (item) => NotificationCard(
                    notification: item,
                    onTap: () => _openNotification(item),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}