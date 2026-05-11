import 'package:flutter/material.dart';

import '../models/task_activity_log_model.dart';

class TaskActivitySection extends StatelessWidget {
  final List<TaskActivityLogModel> logs;
  final Future<String> Function(String userId) getUserName;

  const TaskActivitySection({
    super.key,
    required this.logs,
    required this.getUserName,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'create_task':
        return 'Đã tạo công việc';
      case 'update_task':
        return 'Đã cập nhật công việc';
      case 'mark_done':
        return 'Đã đổi trạng thái sang hoàn thành';
      case 'comment':
        return 'Đã thêm bình luận';
      case 'delete_task':
        return 'Đã xóa công việc';
      default:
        return action;
    }
  }

  Widget _activityItem(TaskActivityLogModel log) {
    return FutureBuilder<String>(
      future: getUserName(log.userId),
      builder: (context, snapshot) {
        final actor = snapshot.data ?? 'Người dùng';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B1B63),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 44,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _actionLabel(log.action),
                      style: const TextStyle(
                        fontFamily: _headlineFont,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'bởi $actor • ${_formatTimeAgo(log.createdAt)}',
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoạt động',
            style: TextStyle(
              fontFamily: _headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            Text(
              'Chưa có hoạt động',
              style: TextStyle(
                fontFamily: _bodyFont,
                color: Colors.grey.shade600,
              ),
            )
          else
            Column(
              children: logs.map(_activityItem).toList(),
            ),
        ],
      ),
    );
  }
}