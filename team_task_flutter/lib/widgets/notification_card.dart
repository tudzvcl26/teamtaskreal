import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  IconData _iconForType(String type) {
    switch (type) {
      case 'assign':
        return Icons.assignment_ind_outlined;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'status':
        return Icons.check_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'group_invite':
        return Icons.group_add_outlined;
      case 'group_join_request':
        return Icons.how_to_reg_outlined;
      case 'group_join_result':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'assign':
        return Colors.indigo;
      case 'comment':
        return Colors.blue;
      case 'status':
        return Colors.green;
      case 'update':
        return Colors.orange;
      case 'group_invite':
        return Colors.deepPurple;
      case 'group_join_request':
        return Colors.teal;
      case 'group_join_result':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  String _statusLabel() {
    switch ((notification.invitationStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return 'Đã chấp nhận';
      case 'declined':
        return 'Đã từ chối';
      default:
        return 'Đang chờ phản hồi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                notification.isRead ? Colors.grey.shade200 : color.withOpacity(0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.14),
              child: Icon(_iconForType(notification.type), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _headlineFont,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontFamily: _bodyFont,
                      height: 1.4,
                    ),
                  ),
                  if (notification.type == 'group_invite' ||
                      notification.type == 'group_join_request' ||
                      notification.type == 'group_join_result') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}