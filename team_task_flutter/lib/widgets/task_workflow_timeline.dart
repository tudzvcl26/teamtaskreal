import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/models/attachment_model.dart';
import 'package:team_task_flutter/models/task_activity_log_model.dart';
import 'package:team_task_flutter/models/task_comment_model.dart';
import 'package:team_task_flutter/models/task_model.dart';

class TaskWorkflowStep {
  const TaskWorkflowStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.icon,
    this.time,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final IconData icon;
  final DateTime? time;
}

class TaskWorkflowTimeline extends StatelessWidget {
  const TaskWorkflowTimeline({
    super.key,
    required this.task,
    required this.creatorName,
    required this.assigneeName,
    required this.comments,
    required this.attachments,
    required this.activityLogs,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskModel task;
  final String creatorName;
  final String assigneeName;
  final List<TaskCommentModel> comments;
  final List<AttachmentModel> attachments;
  final List<TaskActivityLogModel> activityLogs;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(context);
    final completedCount = steps.where((step) => step.isCompleted).length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(
                    alpha: isDark ? 0.22 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ'.tr(context),
                      style: TextStyle(
                        fontFamily: _headlineFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$completedCount/${steps.length} ${'bước đã hoàn thành'.tr(context)}',
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Column(
              key: ValueKey(completedCount),
              children: [
                for (var index = 0; index < steps.length; index++)
                  _TimelineStepTile(
                    step: steps[index],
                    isFirst: index == 0,
                    isLast: index == steps.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TaskWorkflowStep> _buildSteps(BuildContext context) {
    final assigned = task.assignedTo != null && task.assignedTo!.isNotEmpty;
    final received = task.status == 'doing' || task.status == 'done';
    final doing = task.status == 'doing' || task.status == 'done';
    final hasDiscussion = comments.isNotEmpty;
    final hasAttachment = attachments.isNotEmpty;
    final done = task.status == 'done';

    final firstCommentAt = _firstDate(
      comments.map((comment) => comment.createdAt),
    );
    final firstAttachmentAt = _firstDate(
      attachments.map((attachment) => attachment.uploadedAt),
    );
    final doneAt =
        _firstLogDate(['mark_done']) ?? (done ? task.updatedAt : null);
    final updatedAt = task.updatedAt;

    return [
      TaskWorkflowStep(
        title: 'Người tạo đã tạo công việc',
        subtitle: creatorName,
        isCompleted: true,
        icon: Icons.add_task_rounded,
        time: task.createdAt,
      ),
      TaskWorkflowStep(
        title: 'Đã giao cho thành viên',
        subtitle: assigned ? assigneeName : 'Chưa giao',
        isCompleted: assigned,
        icon: Icons.assignment_ind_outlined,
        time: assigned ? updatedAt ?? task.createdAt : null,
      ),
      TaskWorkflowStep(
        title: 'Thành viên đã nhận công việc',
        subtitle: assigned ? assigneeName : 'Đang chờ người nhận',
        isCompleted: received,
        icon: Icons.inventory_2_outlined,
        time: received ? updatedAt ?? task.createdAt : null,
      ),
      TaskWorkflowStep(
        title: 'Thành viên đang thực hiện',
        subtitle: doing ? assigneeName : 'Chưa bắt đầu',
        isCompleted: doing,
        icon: Icons.engineering_outlined,
        time: doing ? updatedAt ?? task.createdAt : null,
      ),
      TaskWorkflowStep(
        title: 'Có thảo luận',
        subtitle: hasDiscussion
            ? '${comments.length} ${'bình luận'.tr(context)}'
            : 'Chưa có bình luận',
        isCompleted: hasDiscussion,
        icon: Icons.forum_outlined,
        time: firstCommentAt,
      ),
      TaskWorkflowStep(
        title: 'Có tệp đính kèm',
        subtitle: hasAttachment
            ? '${attachments.length} ${'tệp'.tr(context)}'
            : 'Chưa có tệp đính kèm',
        isCompleted: hasAttachment,
        icon: Icons.attach_file_rounded,
        time: firstAttachmentAt,
      ),
      TaskWorkflowStep(
        title: 'Công việc hoàn thành',
        subtitle: done ? assigneeName : 'Đang chờ hoàn thành',
        isCompleted: done,
        icon: Icons.verified_rounded,
        time: doneAt,
      ),
    ];
  }

  DateTime? _firstLogDate(List<String> actions) {
    final matched = activityLogs
        .where((log) => actions.contains(log.action))
        .map((log) => log.createdAt);

    return _firstDate(matched);
  }

  DateTime? _firstDate(Iterable<DateTime> dates) {
    DateTime? first;
    for (final date in dates) {
      if (first == null || date.isBefore(first)) {
        first = date;
      }
    }
    return first;
  }
}

class _TimelineStepTile extends StatelessWidget {
  const _TimelineStepTile({
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskWorkflowStep step;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = AppColors.secondary;
    final inactiveColor = isDark ? Colors.white30 : Colors.grey.shade400;
    final lineColor = step.isCompleted ? activeColor : inactiveColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : lineColor.withValues(alpha: 0.45),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: step.isCompleted ? activeColor : inactiveColor,
                    shape: BoxShape.circle,
                    boxShadow: step.isCompleted
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    step.isCompleted ? Icons.check_rounded : step.icon,
                    size: 18,
                    color: step.isCompleted
                        ? Colors.white
                        : (isDark ? Colors.black87 : Colors.white),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : lineColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? activeColor.withValues(alpha: isDark ? 0.18 : 0.08)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: step.isCompleted
                        ? activeColor.withValues(alpha: 0.22)
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            step.title.tr(context),
                            style: TextStyle(
                              fontFamily: _headlineFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: step.isCompleted
                                  ? (isDark
                                        ? Colors.white
                                        : AppColors.textPrimary)
                                  : (isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary),
                            ),
                          ),
                        ),
                        if (step.time != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(step.time!),
                            style: TextStyle(
                              fontFamily: _bodyFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.subtitle.tr(context),
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        fontSize: 12,
                        height: 1.35,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.day}/${date.month}';
  }
}
