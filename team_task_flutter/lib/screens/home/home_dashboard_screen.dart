import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/models/dashboard_data.dart';
import 'package:team_task_flutter/screens/groups/create_edit_group_screen.dart';
import 'package:team_task_flutter/screens/groups/group_detail_screen.dart';
import 'package:team_task_flutter/screens/groups/groups_screen.dart';
import 'package:team_task_flutter/services/dashboard_service.dart';
import 'package:team_task_flutter/widgets/dashboard_stat_card.dart';
import 'package:team_task_flutter/widgets/recent_group_card.dart';
import 'package:team_task_flutter/widgets/today_task_tile.dart';
import 'package:team_task_flutter/widgets/upcoming_deadline_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onOpenProfileTab;

  const HomeDashboardScreen({
    super.key,
    this.onOpenProfileTab,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final DashboardService dashboardService = DashboardService();

  Future<DashboardData>? dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = dashboardService.getDashboardData();
  }

  Future<void> refreshDashboard() async {
    setState(() {
      dashboardFuture = dashboardService.getDashboardData();
    });
  }

  Future<void> openCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateEditGroupScreen(),
      ),
    );

    if (result == true) {
      refreshDashboard();
    }
  }

  void openGroupsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupsScreen(
          onOpenProfileTab: widget.onOpenProfileTab,
        ),
      ),
    );
  }

  void openGroupDetail(String groupId) {
    if (groupId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailScreen(groupId: groupId),
      ),
    );
  }

  void openProfileTab() {
    widget.onOpenProfileTab?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateGroup,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: FutureBuilder<DashboardData>(
          future: dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Không tải được dữ liệu dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: refreshDashboard,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Không có dữ liệu'),
              );
            }

            final dashboard = snapshot.data!;

            return RefreshIndicator(
              onRefresh: refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildGreeting(dashboard),
                    const SizedBox(height: 18),
                    _buildSearchBox(),
                    const SizedBox(height: 22),
                    _buildStatsGrid(dashboard),
                    const SizedBox(height: 28),
                    _buildRecentGroups(dashboard),
                    const SizedBox(height: 28),
                    _buildTodayTasks(dashboard),
                    const SizedBox(height: 28),
                    const Text(
                      'Hạn chót sắp tới',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    dashboard.todayTasks.isNotEmpty
                        ? UpcomingDeadlineCard(
                            dayText: 'Hôm nay',
                            title: dashboard.todayTasks.first['title'] ?? '',
                          )
                        : const UpcomingDeadlineCard(
                            dayText: 'Chưa có',
                            title: 'Không có hạn chót gần nhất',
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.menu, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Team Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: openProfileTab,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào ${dashboard.userName}!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bạn có ${dashboard.totalTasks} công việc hiện tại.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm công việc, nhóm...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardData dashboard) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardStatCard(
          icon: Icons.group_work_outlined,
          value: dashboard.totalGroups.toString(),
          label: 'Tổng nhóm',
          bgColor: Colors.white,
          iconBgColor: const Color(0xFFE0E7FF),
          textColor: AppColors.primary,
        ),
        DashboardStatCard(
          icon: Icons.format_list_bulleted,
          value: dashboard.totalTasks.toString(),
          label: 'Tổng công việc',
          bgColor: Colors.white,
          iconBgColor: const Color(0xFFE0E7FF),
          textColor: AppColors.primary,
        ),
        DashboardStatCard(
          icon: Icons.check_circle,
          value: dashboard.completedTasks.toString(),
          label: 'Hoàn thành',
          bgColor: const Color(0xFFE8F5E9),
          iconBgColor: const Color(0xFFC8E6C9),
          textColor: const Color(0xFF2E7D32),
        ),
        DashboardStatCard(
          icon: Icons.priority_high,
          value: dashboard.overdueTasks.toString(),
          label: 'Quá hạn',
          bgColor: const Color(0xFFFFEBEE),
          iconBgColor: const Color(0xFFFFCDD2),
          textColor: const Color(0xFFC62828),
        ),
      ],
    );
  }

  Widget _buildRecentGroups(DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nhóm gần đây',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            GestureDetector(
              onTap: openGroupsScreen,
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        dashboard.recentGroups.isEmpty
            ? const Text(
                'Chưa có nhóm nào',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dashboard.recentGroups.length,
                  itemBuilder: (context, index) {
                    final group = dashboard.recentGroups[index];
                    final groupId = (group['groupId'] ?? '').toString();
                    final groupName = (group['groupName'] ?? '').toString();
                    final initials = _getInitials(groupName);

                    return GestureDetector(
                      onTap: () => openGroupDetail(groupId),
                      child: RecentGroupCard(
                        initials: initials,
                        groupName: groupName,
                        memberCount: 'Nhóm làm việc',
                        avatarBg: const Color(0xFFE8EAF6),
                        avatarTextColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildTodayTasks(DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Công việc hôm nay',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Icon(Icons.more_horiz, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 14),
        dashboard.todayTasks.isEmpty
            ? const Text(
                'Hôm nay không có công việc nào',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : Column(
                children: dashboard.todayTasks.map((task) {
                  final title = (task['title'] ?? '').toString();
                  final priority = (task['priority'] ?? 'Normal').toString();
                  final dueDate = task['dueDate'] as DateTime?;

                  final subtitle = dueDate != null
                      ? 'Hạn: ${_formatTime(dueDate)}'
                      : 'Chưa có hạn';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TodayTaskTile(
                      title: title,
                      subtitle: subtitle,
                      priority: priority,
                      priorityBg: _priorityBg(priority),
                      priorityText: _priorityText(priority),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getInitials(String text) {
    if (text.trim().isEmpty) return 'TT';
    final words = text.trim().split(' ');
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  Color _priorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFFCCBC);
      case 'medium':
        return const Color(0xFFFFE0B2);
      default:
        return const Color(0xFFC8E6C9);
    }
  }

  Color _priorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFBF360C);
      case 'medium':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF1B5E20);
    }
  }
}