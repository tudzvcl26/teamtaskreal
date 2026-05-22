import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/models/task_model.dart';
import 'package:team_task_flutter/widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TaskModel> tasks = [
      TaskModel(
        taskId: '1',
        groupId: 'group_1',
        title: 'Làm màn hình login'.tr(context),
        description: 'Thiết kế và hoàn thiện giao diện đăng nhập',
        assignedTo: null,
        status: 'todo',
        priority: 'high',
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TaskModel(
        taskId: '2',
        groupId: 'group_1',
        title: 'Kết nối Firestore'.tr(context),
        description: 'Kết nối database và test dữ liệu thật',
        assignedTo: null,
        status: 'doing',
        priority: 'medium',
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Danh sách công việc'.tr(context))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskCard(task: tasks[index], onTap: () {});
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
