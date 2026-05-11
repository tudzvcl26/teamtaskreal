import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/services/group_service.dart';

class JoinGroupByCodeScreen extends StatefulWidget {
  const JoinGroupByCodeScreen({super.key});

  @override
  State<JoinGroupByCodeScreen> createState() => _JoinGroupByCodeScreenState();
}

class _JoinGroupByCodeScreenState extends State<JoinGroupByCodeScreen> {
  final GroupService groupService = GroupService();
  final TextEditingController codeController = TextEditingController();

  GroupModel? foundGroup;
  bool isSearching = false;
  bool isSubmitting = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> searchGroup() async {
    final code = codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      showMessage('Vui lòng nhập mã nhóm');
      return;
    }

    try {
      setState(() {
        isSearching = true;
        foundGroup = null;
      });

      final result = await groupService.findGroupByInviteCode(code);

      if (!mounted) return;

      setState(() {
        foundGroup = result;
      });

      if (result == null) {
        showMessage('Không tìm thấy nhóm với mã này');
      }
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  Future<void> submitRequest() async {
    try {
      setState(() {
        isSubmitting = true;
      });

      await groupService.requestToJoinByInviteCode(codeController.text);

      if (!mounted) return;

      showMessage('Đã gửi yêu cầu tham gia nhóm');
      Navigator.pop(context, true);
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tham gia nhóm bằng mã'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập mã nhóm',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sau khi gửi yêu cầu, admin hoặc leader sẽ quyết định cho bạn tham gia hay không.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã nhóm',
                      prefixIcon: Icon(Icons.key_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: searchGroup,
                            icon: const Icon(Icons.search),
                            label: const Text('Tìm nhóm'),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (foundGroup != null)
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
                      'Nhóm tìm thấy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      foundGroup!.groupName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      foundGroup!.description.isEmpty
                          ? 'Không có mô tả'
                          : foundGroup!.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: submitRequest,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Gửi yêu cầu tham gia'),
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}