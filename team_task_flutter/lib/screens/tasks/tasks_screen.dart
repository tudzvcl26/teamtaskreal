import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  const TasksScreen({
    super.key,
    this.onOpenProfileTab,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _myGroupIds = [];
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
  void initState() {
    super.initState();
    _loadMyGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMyGroups() async {
    final ids = await _taskService.getMyGroupIds();
    if (mounted) {
      setState(() => _myGroupIds = ids);
    }
  }

  bool _belongsToMe(TaskModel task, String currentUserId) {
    return _myGroupIds.contains(task.groupId) ||
        task.assignedTo == currentUserId ||
        task.createdBy == currentUserId;
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final filtered = tasks.where((task) {
      if (!_belongsToMe(task, uid)) return false;

      if (_selectedFilter == 'overdue' && !task.isOverdue) return false;
      if (_selectedFilter != 'all' &&
          _selectedFilter != 'overdue' &&
          task.status != _selectedFilter) {
        return false;
      }

      if (_searchText.isNotEmpty) {
        final q = _searchText.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(q);
        final matchesDesc = task.description.toLowerCase().contains(q);
        if (!matchesTitle && !matchesDesc) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final aDue = a.dueDate ?? DateTime(2100);
      final bDue = b.dueDate ?? DateTime(2100);
      return aDue.compareTo(bDue);
    });

    return filtered;
  }

  Future<void> _openCreateTask() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateTaskScreen(),
      ),
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(taskId: task.taskId),
      ),
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
            title: 'Tổng',
            value: '$total',
            icon: Icons.task_alt,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskSummaryCard(
            title: 'Đang làm',
            value: '$doing',
            icon: Icons.loop,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TaskSummaryCard(
            title: 'Xong',
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
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (tasks.isEmpty) {
      return const EmptyTaskState();
    }

    return Column(
      children: tasks
          .map(
            (task) => TaskCard(
              task: task,
              onTap: () => _openTaskDetail(task),
            ),
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
        final tasks = _applyFilters(allTasks);

        final total = tasks.length;
        final doing = tasks.where((e) => e.status == 'doing').length;
        final done = tasks.where((e) => e.status == 'done').length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
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
                      builder: (_) => TaskStatisticsScreen(tasks: tasks),
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
            label: const Text(
              'Tạo task',
              style: TextStyle(
                fontFamily: _bodyFont,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _loadMyGroups,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                TaskSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchText = value.trim());
                  },
                ),
                const SizedBox(height: 14),
                _buildSummarySection(
                  total: total,
                  doing: doing,
                  done: done,
                ),
                const SizedBox(height: 14),
                TaskFilterChips(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onSelected: (value) {
                    setState(() => _selectedFilter = value);
                  },
                ),
                const SizedBox(height: 18),
                _buildTaskList(snapshot, tasks),
              ],
            ),
          ),
        );
      },
    );
  }
}