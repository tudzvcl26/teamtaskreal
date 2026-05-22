import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';

import '../models/task_activity_log_model.dart';

class TaskActivitySection extends StatelessWidget {
  final List<TaskActivityLogModel> logs;
  final Future<String> Function(String userId)? getUserName;

  const TaskActivitySection({super.key, required this.logs, this.getUserName});

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  String _actionLabel(String action) {
    switch (action) {
      case 'create_task':
        return 'Đã tạo công việc';
      case 'update_task':
        return 'Đã cập nhật công việc';
      case 'delete_task':
        return 'Đã xóa công việc';
      case 'mark_done':
        return 'Đã hoàn thành công việc';
      case 'comment':
        return 'Đã thêm bình luận';
      case 'add_attachment':
        return 'Đã thêm tệp đính kèm';
      case 'delete_attachment':
        return 'Đã xóa tệp đính kèm';
      default:
        return action;
    }
  }

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'vừa xong';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildLogItem(TaskActivityLogModel log, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF001B6E),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 58, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _actionLabel(log.action),
                  style: const TextStyle(
                    fontFamily: _headlineFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                if (getUserName != null)
                  FutureBuilder<String>(
                    future: getUserName!(log.userId),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? 'Người dùng';

                      return Text(
                        'bởi $name • ${_timeAgo(log.createdAt)}',
                        style: TextStyle(
                          fontFamily: _bodyFont,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  )
                else
                  Text(
                    _timeAgo(log.createdAt),
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Chưa có hoạt động',
          style: TextStyle(fontFamily: _bodyFont, color: Colors.grey.shade600),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == logs.length - 1;

            return _buildLogItem(log, isLast);
          }),
        ],
      ),
    );
  }
}
