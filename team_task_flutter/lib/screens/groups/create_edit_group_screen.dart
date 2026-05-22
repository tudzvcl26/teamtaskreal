import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/core/constants/group_style_data.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/services/group_service.dart';

class CreateEditGroupScreen extends StatefulWidget {
  final GroupModel? group;

  const CreateEditGroupScreen({super.key, this.group});

  @override
  State<CreateEditGroupScreen> createState() => _CreateEditGroupScreenState();
}

class _CreateEditGroupScreenState extends State<CreateEditGroupScreen> {
  final GroupService groupService = GroupService();

  late TextEditingController groupNameController;
  late TextEditingController descriptionController;

  bool isLoading = false;
  late String selectedColor;
  late String selectedIcon;

  bool get isEdit => widget.group != null;

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController(
      text: widget.group?.groupName ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.group?.description ?? '',
    );
    selectedColor = widget.group?.groupColor ?? 'indigo';
    selectedIcon = widget.group?.groupIcon ?? 'group_work';
  }

  @override
  void dispose() {
    groupNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message.tr(context))));
  }

  Future<void> handleSave() async {
    final groupName = groupNameController.text.trim();
    final description = descriptionController.text.trim();

    if (groupName.isEmpty) {
      showMessage('Vui lòng nhập tên nhóm');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      if (isEdit) {
        await groupService.updateGroup(
          groupId: widget.group!.groupId,
          groupName: groupName,
          description: description,
          groupColor: selectedColor,
          groupIcon: selectedIcon,
        );
        showMessage('Cập nhật nhóm thành công');
      } else {
        await groupService.createGroup(
          groupName: groupName,
          description: description,
          groupColor: selectedColor,
          groupIcon: selectedIcon,
        );
        showMessage('Tạo nhóm thành công');
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      showMessage('Có lỗi xảy ra, vui lòng thử lại');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> copyInviteCode() async {
    final code = widget.group?.inviteCode ?? '';
    if (code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    showMessage('Đã sao chép mã mời');
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Chỉnh sửa Nhóm' : 'Tạo Nhóm';
    final previewBg = GroupStyleData.bgColor(selectedColor);
    final previewText = GroupStyleData.textColor(selectedColor);
    final previewIcon = GroupStyleData.iconData(selectedIcon);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9).withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
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
                            Icons.person,
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
                          'CÀI ĐẶT KHÔNG GIAN LÀM VIỆC',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEdit
                              ? 'Hoàn thiện bản sắc của nhóm bạn'
                              : 'Tạo một nhóm làm việc mới',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hình ảnh nhóm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: previewBg,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      previewIcon,
                                      size: 42,
                                      color: previewText,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Màu chủ đạo',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: GroupStyleData.colorKeys
                                              .map((key) {
                                                final color =
                                                    GroupStyleData.bgColor(key);
                                                final selected =
                                                    selectedColor == key;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedColor = key;
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 34,
                                                    height: 34,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: selected
                                                            ? AppColors.primary
                                                            : Colors
                                                                  .transparent,
                                                        width: 3,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Biểu tượng nhóm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: GroupStyleData.iconKeys.map((key) {
                                  final icon = GroupStyleData.iconData(key);
                                  final selected = selectedIcon == key;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIcon = key;
                                      });
                                    },
                                    child: Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? previewBg
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: selected
                                              ? previewText
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: selected
                                            ? previewText
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'Tên nhóm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: groupNameController,
                                decoration: InputDecoration(
                                  hintText: 'Nhập tên nhóm'
                                      .tr(context)
                                      .tr(context),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Mô tả',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: descriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Nhập mô tả nhóm'
                                      .tr(context)
                                      .tr(context),
                                ),
                              ),
                              if (isEdit) ...[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Mã mời',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.group?.inviteCode ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: copyInviteCode,
                                        icon: const Icon(Icons.copy_rounded),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 26),
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            onPressed: handleSave,
                                            child: Text(
                                              isEdit
                                                  ? 'Lưu thay đổi'
                                                  : 'Tạo nhóm',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Hủy'.tr(context)),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 26),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFC62828),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Vùng nguy hiểm',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFC62828),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Xóa hoặc lưu trữ nhóm sẽ ảnh hưởng đến công việc và thành viên trong nhóm. Hãy cân nhắc kỹ trước khi thao tác.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.45,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}
