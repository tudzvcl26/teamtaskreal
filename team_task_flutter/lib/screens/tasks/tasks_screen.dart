import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/widgets/empty_task_state.dart';
import 'package:team_task_flutter/widgets/task_card.dart';
import 'package:team_task_flutter/widgets/task_filter_chips.dart';
import 'package:team_task_flutter/widgets/task_search_bar.dart';
import 'package:team_task_flutter/widgets/task_summary_card.dart';

import '../../models/task_model.dart';
import '../../services/task_service.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_statistics_screen.dart';

class TasksScreen extends StatefulWidget {
  final VoidCallback? onOpenProfileTab;

  const TasksScreen({super.key, this.onOpenProfileTab});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'all';
  String _searchText = '';

  final List<Map<String, String>> _filters = const [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'todo', 'label': 'Cần làm'},
    {'value': 'doing', 'label': 'Đang làm'},
    {'value': 'done', 'label': 'Hoàn thành'},
    {'value': 'overdue', 'label': 'Quá hạn'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    final filtered = tasks.where((task) {
      if (_selectedFilter == 'overdue' && !task.isOverdue) {
        return false;
      }

      if (_selectedFilter != 'all' &&
          _selectedFilter != 'overdue' &&
          task.status != _selectedFilter) {
        return false;
      }

      if (_searchText.isNotEmpty) {
        final q = _searchText.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(q);
        final matchesDesc = task.description.toLowerCase().contains(q);

        if (!matchesTitle && !matchesDesc) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final aDueDate = a.dueDate ?? DateTime(2100);
      final bDueDate = b.dueDate ?? DateTime(2100);
      return aDueDate.compareTo(bDueDate);
    });

    return filtered;
  }

  Future<void> _openCreateTask() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );

    if (changed == true && mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã tạo công việc mới',
            style: TextStyle(fontFamily: _bodyFont),
          ),
        ),
      );
    }
  }

  void _openTaskDetail(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.taskId)),
    );
  }

  Widget _buildSummarySection({
    required int total,
    required int doing,
    required int done,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TaskSummaryCard(
            title: 'Tổng'.tr(context),
            value: '$total',
            icon: Icons.task_alt,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskSummaryCard(
            title: 'Đang làm'.tr(context),
            value: '$doing',
            icon: Icons.loop,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskSummaryCard(
            title: 'Xong'.tr(context),
            value: '$done',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(
    AsyncSnapshot<List<TaskModel>> snapshot,
    List<TaskModel> tasks,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Lỗi tải công việc: ${snapshot.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: _bodyFont,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return const EmptyTaskState(message: 'Không có công việc phù hợp');
    }

    return Column(
      children: tasks
          .map(
            (task) => TaskCard(task: task, onTap: () => _openTaskDetail(task)),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.streamAllTasks(),
      builder: (context, snapshot) {
        final allTasks = snapshot.data ?? [];
        final filteredTasks = _applyFilters(allTasks);

        final total = allTasks.length;
        final doing = allTasks.where((task) => task.status == 'doing').length;
        final done = allTasks.where((task) => task.status == 'done').length;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Công việc',
              style: TextStyle(
                fontFamily: _headlineFont,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskStatisticsScreen(tasks: allTasks),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded),
              ),
              IconButton(
                onPressed: widget.onOpenProfileTab,
                icon: const CircleAvatar(
                  radius: 14,
                  child: Icon(Icons.person, size: 16),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateTask,
            icon: const Icon(Icons.add),
            label: Text(
              'Tạo task',
              style: TextStyle(
                fontFamily: _bodyFont,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                TaskSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim();
                    });
                  },
                ),
                const SizedBox(height: 14),
                _buildSummarySection(total: total, doing: doing, done: done),
                const SizedBox(height: 14),
                TaskFilterChips(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _buildTaskList(snapshot, filteredTasks),
              ],
            ),
          ),
        );
      },
    );
  }
}
