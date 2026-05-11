import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/core/constants/group_style_data.dart';
import 'package:team_task_flutter/models/group_member_model.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/screens/groups/add_member_screen.dart';
import 'package:team_task_flutter/screens/groups/create_edit_group_screen.dart';
import 'package:team_task_flutter/services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService groupService = GroupService();

  late Future<Map<String, dynamic>> _groupDataFuture;

  @override
  void initState() {
    super.initState();
    _groupDataFuture = loadGroupData();
  }

  Future<Map<String, dynamic>> loadGroupData() async {
    final group = await groupService.getGroupById(widget.groupId);
    final stats = await groupService.getGroupStats(widget.groupId);
    final members = await groupService.getGroupMembersPreview(widget.groupId);
    final myRole = await groupService.getMyRoleInGroup(widget.groupId);
    final canManage = myRole == 'admin' || myRole == 'leader';

    return {
      'group': group,
      'memberCount': stats['memberCount'] ?? 0,
      'taskCount': stats['taskCount'] ?? 0,
      'doneTaskCount': stats['doneTaskCount'] ?? 0,
      'members': members,
      'myRole': myRole,
      'canManage': canManage,
    };
  }

  Future<void> refreshScreen() async {
    setState(() {
      _groupDataFuture = loadGroupData();
    });
  }

  Future<void> openEditGroup(GroupModel group) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditGroupScreen(group: group),
      ),
    );

    if (result == true && mounted) {
      await refreshScreen();
    }
  }

  Future<void> openAddMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberScreen(groupId: widget.groupId),
      ),
    );

    if (result == true && mounted) {
      await refreshScreen();
    }
  }

  Future<void> copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép mã mời')),
    );
  }

  void showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> archiveGroup(String groupId) async {
    try {
      await groupService.archiveGroup(groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu trữ nhóm')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      showError(e);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await groupService.deleteGroup(groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa nhóm')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      showError(e);
    }
  }

  Future<void> confirmArchive(GroupModel group) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lưu trữ nhóm'),
        content: Text('Bạn có muốn lưu trữ nhóm "${group.groupName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu trữ'),
          ),
        ],
      ),
    );

    if (result == true) {
      await archiveGroup(group.groupId);
    }
  }

  Future<void> confirmDelete(GroupModel group) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa nhóm'),
        content: Text(
          'Bạn có chắc muốn xóa nhóm "${group.groupName}" không?\nThao tác này sẽ xóa luôn task, comment, file đính kèm, thông báo và lịch sử liên quan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result == true) {
      await deleteGroup(group.groupId);
    }
  }

  Widget _statBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getInitial(String name) {
    if (name.trim().isEmpty) return 'U';
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _groupDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Không tải được thông tin nhóm'),
              );
            }

            final group = snapshot.data!['group'] as GroupModel;
            final memberCount = snapshot.data!['memberCount'] as int;
            final taskCount = snapshot.data!['taskCount'] as int;
            final doneTaskCount = snapshot.data!['doneTaskCount'] as int;
            final members = snapshot.data!['members'] as List<GroupMemberModel>;
            final myRole = (snapshot.data!['myRole'] ?? '').toString();
            final canManage = snapshot.data!['canManage'] == true;

            final progress =
                taskCount == 0 ? 0.0 : (doneTaskCount / taskCount).clamp(0.0, 1.0);

            final bgColor = GroupStyleData.bgColor(group.groupColor);
            final textColor = GroupStyleData.textColor(group.groupColor);
            final iconData = GroupStyleData.iconData(group.groupIcon);

            return RefreshIndicator(
              onRefresh: refreshScreen,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const Text(
                            'Chi tiết Nhóm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(19),
                            ),
                            child: const Icon(
                              Icons.group_work_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KHÔNG GIAN LÀM VIỆC',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tổng quan nhóm của bạn',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    iconData,
                                    size: 42,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  group.groupName,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  group.description.isEmpty
                                      ? 'Chưa có mô tả cho nhóm này.'
                                      : group.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        myRole.isEmpty ? 'member' : myRole,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (group.isArchived)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Đã lưu trữ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                GestureDetector(
                                  onTap: group.inviteCode.isEmpty
                                      ? null
                                      : () => copyInviteCode(group.inviteCode),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FC),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.key_rounded,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            group.inviteCode.isEmpty
                                                ? 'Không có mã mời'
                                                : 'Mã mời: ${group.inviteCode}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _statBox(
                                icon: Icons.people_alt_outlined,
                                label: 'Thành viên',
                                value: '$memberCount',
                              ),
                              const SizedBox(width: 12),
                              _statBox(
                                icon: Icons.task_alt_outlined,
                                label: 'Công việc',
                                value: '$taskCount',
                              ),
                              const SizedBox(width: 12),
                              _statBox(
                                icon: Icons.check_circle_outline,
                                label: 'Hoàn thành',
                                value: '$doneTaskCount',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tiến độ nhóm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(progress * 100).round()}% hoàn thành',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thành viên nổi bật',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                if (members.isEmpty)
                                  const Text(
                                    'Chưa có thành viên nào',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                else
                                  ...members.map((member) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F8FC),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E7FF),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getInitial(member.name),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
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
                                                  member.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  member.email,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              member.role,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                          if (canManage) ...[
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: openAddMember,
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('Mời thành viên'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () => openEditGroup(group),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Chỉnh sửa nhóm'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Khu vực quản trị',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Các thao tác dưới đây sẽ ảnh hưởng trực tiếp đến dữ liệu của nhóm.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: group.isArchived
                                          ? null
                                          : () => confirmArchive(group),
                                      icon: const Icon(Icons.archive_outlined),
                                      label: const Text('Lưu trữ nhóm'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: () => confirmDelete(group),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Xóa nhóm'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}