import 'package:flutter/material.dart';

import '../models/task_comment_model.dart';

class TaskDiscussionSection extends StatelessWidget {
  final List<TaskCommentModel> comments;
  final Future<String> Function(String userId) getUserName;
  final TextEditingController commentController;
  final bool isSendingComment;
  final VoidCallback onSendComment;

  const TaskDiscussionSection({
    super.key,
    required this.comments,
    required this.getUserName,
    required this.commentController,
    required this.isSendingComment,
    required this.onSendComment,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  Widget _commentItem(TaskCommentModel comment) {
    return FutureBuilder<String>(
      future: getUserName(comment.userId),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Người dùng';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontFamily: _bodyFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: _headlineFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: TextStyle(
                            fontFamily: _bodyFont,
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontFamily: _bodyFont,
                        height: 1.4,
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
            'Thảo luận',
            style: TextStyle(
              fontFamily: _headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                'Chưa có bình luận',
                style: TextStyle(
                  fontFamily: _bodyFont,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ...comments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _commentItem(comment),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    style: const TextStyle(fontFamily: _bodyFont),
                    decoration: const InputDecoration(
                      hintText: 'Viết bình luận...',
                      hintStyle: TextStyle(fontFamily: _bodyFont),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isSendingComment ? null : onSendComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}