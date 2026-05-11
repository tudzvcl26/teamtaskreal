import 'package:flutter/material.dart';

import '../../models/attachment_model.dart';
import '../../models/task_activity_log_model.dart';
import '../../models/task_comment_model.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/task_activity_section.dart';
import '../../widgets/task_attachments_section.dart';
import '../../widgets/task_discussion_section.dart';
import 'create_edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskService _taskService = TaskService();
  final TextEditingController _commentController = TextEditingController();

  final Map<String, String> _userNameCache = {};
  final Map<String, String> _groupNameCache = {};

  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String> _getUserName(String userId) async {
    if (userId.isEmpty) return 'Chưa giao';
    if (_userNameCache.containsKey(userId)) return _userNameCache[userId]!;
    final name = await _taskService.getUserName(userId);
    _userNameCache[userId] = name;
    return name;
  }

  Future<String> _getGroupName(String groupId) async {
    if (_groupNameCache.containsKey(groupId)) return _groupNameCache[groupId]!;
    final name = await _taskService.getGroupName(groupId);
    _groupNameCache[groupId] = name;
    return name;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'todo':
        return 'Cần làm';
      case 'doing':
        return 'Đang thực hiện';
      case 'done':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'low':
        return 'Ưu tiên thấp';
      case 'medium':
        return 'Ưu tiên vừa';
      case 'high':
        return 'Ưu tiên cao';
      default:
        return priority;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'todo':
        return Colors.orange.shade100;
      case 'doing':
        return Colors.blue.shade100;
      case 'done':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case 'todo':
        return Colors.orange.shade900;
      case 'doing':
        return Colors.blue.shade900;
      case 'done':
        return Colors.green.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _priorityBg(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.amber.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _priorityText(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade900;
      case 'medium':
        return Colors.amber.shade900;
      case 'low':
        return Colors.green.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa có';
    return '${date.day}/${date.month}/${date.year}';
  }

  double _progress(TaskModel task) {
    switch (task.status) {
      case 'todo':
        return 0.2;
      case 'doing':
        return 0.6;
      case 'done':
        return 1.0;
      default:
        return 0;
    }
  }

  Future<void> _sendComment(TaskModel task) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSendingComment = true);

    try {
      await _taskService.addComment(
        taskId: task.taskId,
        content: content,
        groupId: task.groupId,
      );
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi bình luận thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }

  Future<void> _openEdit(TaskModel task) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditTaskScreen(task: task),
      ),
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật công việc')),
      );
    }
  }

  Future<void> _markDone(TaskModel task) async {
    try {
      await _taskService.markTaskDone(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chuyển sang hoàn thành')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thất bại: $e')),
      );
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa công việc'),
        content: const Text('Bạn có chắc muốn xóa công việc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _taskService.deleteTask(task);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa công việc thất bại: $e')),
      );
    }
  }

  Future<void> _showAddAttachmentDialog(TaskModel task) async {
    final fileNameController = TextEditingController();
    final fileUrlController = TextEditingController();
    final fileTypeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm tệp đính kèm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên file',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fileUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link file / URL',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fileTypeController,
                decoration: const InputDecoration(
                  labelText: 'Loại file (pdf, image, docx...)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final fileName = fileNameController.text.trim();
              final fileUrl = fileUrlController.text.trim();
              final fileType = fileTypeController.text.trim();

              if (fileName.isEmpty || fileUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên file và URL'),
                  ),
                );
                return;
              }

              await _taskService.addAttachment(
                taskId: task.taskId,
                fileName: fileName,
                fileUrl: fileUrl,
                fileType: fileType.isEmpty ? 'file' : fileType,
              );

              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    fileNameController.dispose();
    fileUrlController.dispose();
    fileTypeController.dispose();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm tệp đính kèm')),
      );
    }
  }

  Future<void> _deleteAttachment(TaskModel task, AttachmentModel attachment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tệp đính kèm'),
        content: Text('Bạn có chắc muốn xóa "${attachment.fileName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _taskService.deleteAttachment(
      attachment: attachment,
      groupId: task.groupId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa tệp đính kèm')),
    );
  }

  void _openAttachment(AttachmentModel attachment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link file: ${attachment.fileUrl}'),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: _bodyFont,
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskModel?>(
      stream: _taskService.streamTaskById(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = snapshot.data;
        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy công việc')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Chi tiết công việc',
              style: TextStyle(
                fontFamily: _headlineFont,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _openEdit(task);
                  if (value == 'delete') _deleteTask(task);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Sửa công việc'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa công việc'),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            children: [
              FutureBuilder<String>(
                future: _getGroupName(task.groupId),
                builder: (context, snapshot) {
                  final groupName = snapshot.data ?? 'Nhóm';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                              groupName.toUpperCase(),
                              Colors.grey.shade200,
                              Colors.black87,
                            ),
                            _chip(
                              _statusLabel(task.status),
                              _statusBg(task.status),
                              _statusText(task.status),
                            ),
                            _chip(
                              _priorityLabel(task.priority),
                              _priorityBg(task.priority),
                              _priorityText(task.priority),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontFamily: _headlineFont,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FutureBuilder<String>(
                          future: _getUserName(task.assignedTo ?? ''),
                          builder: (context, userSnapshot) {
                            final assignee = userSnapshot.data ?? 'Chưa giao';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    child: Text(
                                      assignee.isNotEmpty
                                          ? assignee[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontFamily: _bodyFont,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Giao cho',
                                          style: TextStyle(
                                            fontFamily: _bodyFont,
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          assignee,
                                          style: const TextStyle(
                                            fontFamily: _headlineFont,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        fontFamily: _headlineFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.description.trim().isEmpty
                          ? 'Chưa có mô tả'
                          : task.description,
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(height: 10),
                          const Text(
                            'Ngày bắt đầu',
                            style: TextStyle(
                              fontFamily: _bodyFont,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(task.startDate),
                            style: const TextStyle(
                              fontFamily: _headlineFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.event_busy_outlined),
                          const SizedBox(height: 10),
                          const Text(
                            'Hạn chót',
                            style: TextStyle(
                              fontFamily: _bodyFont,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(task.dueDate),
                            style: const TextStyle(
                              fontFamily: _headlineFont,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến độ',
                      style: TextStyle(
                        fontFamily: _headlineFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progress(task),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusLabel(task.status),
                      style: const TextStyle(fontFamily: _bodyFont),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<AttachmentModel>>(
                stream: _taskService.streamAttachments(task.taskId),
                builder: (context, snapshot) {
                  final attachments = snapshot.data ?? [];

                  return TaskAttachmentsSection(
                    attachments: attachments,
                    getUserName: _getUserName,
                    onAddPressed: () => _showAddAttachmentDialog(task),
                    onDelete: (attachment) =>
                        _deleteAttachment(task, attachment),
                    onTapAttachment: _openAttachment,
                  );
                },
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<TaskCommentModel>>(
                stream: _taskService.streamComments(task.taskId),
                builder: (context, snapshot) {
                  final comments = snapshot.data ?? [];

                  return TaskDiscussionSection(
                    comments: comments,
                    getUserName: _getUserName,
                    commentController: _commentController,
                    isSendingComment: _isSendingComment,
                    onSendComment: () => _sendComment(task),
                  );
                },
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<TaskActivityLogModel>>(
                stream: _taskService.streamActivityLogs(task.taskId),
                builder: (context, snapshot) {
                  final logs = snapshot.data ?? [];

                  return TaskActivitySection(
                    logs: logs,
                    getUserName: _getUserName,
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openEdit(task),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Sửa công việc',
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: task.isDone ? null : () => _markDone(task),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      task.isDone ? 'Đã hoàn thành' : 'Hoàn thành',
                      style: const TextStyle(
                        fontFamily: _bodyFont,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}