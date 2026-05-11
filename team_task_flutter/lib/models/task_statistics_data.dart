
import 'task_model.dart';

class TaskStatisticsData {
  final int total;
  final int todo;
  final int doing;
  final int done;
  final int overdue;
  final int highPriority;
  final int mediumPriority;
  final int lowPriority;

  const TaskStatisticsData({
    required this.total,
    required this.todo,
    required this.doing,
    required this.done,
    required this.overdue,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
  });

  double get completionRate {
    if (total == 0) return 0;
    return done / total;
  }

  factory TaskStatisticsData.fromTasks(List<TaskModel> tasks) {
    int todo = 0;
    int doing = 0;
    int done = 0;
    int overdue = 0;
    int high = 0;
    int medium = 0;
    int low = 0;

    for (final task in tasks) {
      switch (task.status) {
        case 'todo':
          todo++;
          break;
        case 'doing':
          doing++;
          break;
        case 'done':
          done++;
          break;
      }

      if (task.isOverdue) overdue++;

      switch (task.priority) {
        case 'high':
          high++;
          break;
        case 'medium':
          medium++;
          break;
        case 'low':
          low++;
          break;
      }
    }

    return TaskStatisticsData(
      total: tasks.length,
      todo: todo,
      doing: doing,
      done: done,
      overdue: overdue,
      highPriority: high,
      mediumPriority: medium,
      lowPriority: low,
    );
  }
}