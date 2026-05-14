import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/core/constants/group_style_data.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/screens/groups/create_edit_group_screen.dart';
import 'package:team_task_flutter/screens/groups/group_detail_screen.dart';
import 'package:team_task_flutter/screens/groups/join_group_by_code_screen.dart';
import 'package:team_task_flutter/services/group_service.dart';

class GroupsScreen extends StatefulWidget {
  final VoidCallback? onOpenProfileTab;

  const GroupsScreen({super.key, this.onOpenProfileTab});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService groupService = GroupService();
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> openCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditGroupScreen()),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> openJoinByCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JoinGroupByCodeScreen()),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> openGroupDetail(GroupModel group) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailScreen(groupId: group.groupId),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  void openProfileTab() {
    widget.onOpenProfileTab?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'join_group_fab',
            onPressed: openJoinByCode,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.group_add_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create_group_fab',
            onPressed: openCreateGroup,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<GroupModel>>(
          stream: groupService.getMyGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data ?? [];

            final filteredGroups = groups.where((group) {
              final keyword = searchText.toLowerCase();
              return group.groupName.toLowerCase().contains(keyword) ||
                  group.description.toLowerCase().contains(keyword);
            }).toList();

            final isSearching = searchText.trim().isNotEmpty;

            return FutureBuilder<Map<String, Map<String, int>>>(
              future: groupService.getStatsForGroups(
                filteredGroups.map((e) => e.groupId).toList(),
              ),
              builder: (context, statsSnapshot) {
                final statsMap = statsSnapshot.data ?? {};

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(),
                            const SizedBox(height: 24),
                            const Text(
                              'Không gian làm việc của bạn',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              groups.isEmpty
                                  ? 'Bạn chưa có nhóm nào. Hãy tạo nhóm hoặc xin tham gia bằng mã.'
                                  : 'Bạn đang tham gia ${groups.length} nhóm làm việc.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchText = value.trim();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm nhóm...'
                                    .tr(context)
                                    .tr(context),
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: const Color(0xFFF1F3F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _buildSummaryRow(groups.length),
                            const SizedBox(height: 28),
                            const Text(
                              'Nhóm của tôi',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                    if (groups.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.group_work_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Bạn chưa có nhóm nào',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Hãy tạo nhóm mới hoặc xin tham gia bằng mã nhóm.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (filteredGroups.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  isSearching
                                      ? 'Không tìm thấy nhóm phù hợp'
                                      : 'Chưa có nhóm phù hợp',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isSearching
                                      ? 'Hãy thử từ khóa khác.'
                                      : 'Hãy tạo một nhóm mới.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverList.separated(
                          itemCount: filteredGroups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final group = filteredGroups[index];
                            final bgColor = GroupStyleData.bgColor(
                              group.groupColor,
                            );
                            final textColor = GroupStyleData.textColor(
                              group.groupColor,
                            );
                            final iconData = GroupStyleData.iconData(
                              group.groupIcon,
                            );

                            final stats =
                                statsMap[group.groupId] ??
                                {
                                  'memberCount': 0,
                                  'taskCount': 0,
                                  'doneTaskCount': 0,
                                };

                            final memberCount = stats['memberCount'] ?? 0;
                            final taskCount = stats['taskCount'] ?? 0;

                            return GestureDetector(
                              onTap: () => openGroupDetail(group),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(iconData, color: textColor),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.groupName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            group.description.isEmpty
                                                ? 'Không có mô tả'
                                                : group.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              height: 1.4,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _StatChip(
                                                icon: Icons.people_alt_outlined,
                                                label:
                                                    '$memberCount thành viên',
                                              ),
                                              _StatChip(
                                                icon: Icons.task_alt_outlined,
                                                label: '$taskCount công việc',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
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
            Icon(Icons.group_work_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Nhóm',
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

  Widget _buildSummaryRow(int totalGroups) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_work_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalGroups',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TỔNG NHÓM',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
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
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_add_outlined,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tham gia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BẰNG MÃ NHÓM',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
