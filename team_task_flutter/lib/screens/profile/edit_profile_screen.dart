import 'dart:io';

import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService profileService = ProfileService();

  late TextEditingController nameController;
  late TextEditingController emailController;

  bool isLoading = false;

  late String selectedAvatar;

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.profile.name);

    emailController = TextEditingController(text: widget.profile.email);

    selectedAvatar = widget.profile.avatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message.tr(context))));
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      selectedAvatar = image.path;
    });

    showMessage('Đã chọn ảnh');
  }

  Future<void> handleSave() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      showMessage('Vui lòng nhập họ tên');
      return;
    }

    if (email.isEmpty) {
      showMessage('Vui lòng nhập email');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await profileService.updateProfile(
        name: name,
        email: email,
        avatar: selectedAvatar,
      );

      if (!mounted) return;

      showMessage('Cập nhật hồ sơ thành công');

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String message = 'Không thể cập nhật hồ sơ';

      if (e.code == 'requires-recent-login') {
        message = 'Vui lòng đăng nhập lại để đổi email';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng';
      }

      showMessage(message);
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getInitials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return 'U';

    final words = trimmed.split(' ');

    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return (words.first[0] + words.last[0]).toUpperCase();
  }

  Widget buildAvatarPreview(String name) {
    if (selectedAvatar.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(selectedAvatar),
          width: 108,
          height: 108,
          fit: BoxFit.cover,
        ),
      );
    }

    return Text(
      getInitials(name),
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewName = nameController.text.trim().isEmpty
        ? 'User'
        : nameController.text.trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      const Text(
                        'Chỉnh sửa hồ sơ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 38, height: 38),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'HỒ SƠ CÁ NHÂN',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cập nhật thông tin của bạn',
                    style: TextStyle(
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
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 108,
                              height: 108,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.10,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: buildAvatarPreview(previewName),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 4,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Họ và tên',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Nhập họ và tên'.tr(context),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Nhập email'.tr(context),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: handleSave,
                                      child: Text('Lưu thay đổi'.tr(context)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Hủy'.tr(context)),
                                    ),
                                  ),
                                ],
                              ),
                      ],
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
