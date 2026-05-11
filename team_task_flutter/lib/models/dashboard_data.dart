class DashboardData {
  final String userName;
  final int totalGroups;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final List<Map<String, dynamic>> recentGroups;
  final List<Map<String, dynamic>> todayTasks;

  DashboardData({
    required this.userName,
    required this.totalGroups,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.recentGroups,
    required this.todayTasks,
  });
}