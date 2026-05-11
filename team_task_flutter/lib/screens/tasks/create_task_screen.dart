import 'package:flutter/material.dart';
import 'package:team_task_flutter/models/task_model.dart';
import 'package:team_task_flutter/screens/tasks/create_edit_task_screen.dart';

class CreateTaskScreen extends StatelessWidget {
  final TaskModel? task;

  const CreateTaskScreen({
    super.key,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    return CreateEditTaskScreen(task: task);
  }
}