import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/core/theme/theme_controller.dart';
import 'package:team_task_flutter/screens/auth/login_screen.dart';
import 'package:team_task_flutter/screens/profile/change_password_screen.dart';
import 'package:team_task_flutter/screens/profile/edit_profile_screen.dart';
import 'package:team_task_flutter/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService profileService = ProfileService();

  late Future<ProfileData> profileFuture;

  String selectedLanguage = 'Tiếng Việt';

  final List<String> languages = const [
    'Tiếng Việt',
    'English',
    '日本語',
  ];

  @override
  void initState() {
    super.initState();
    profileFuture = profileService.getProfileData();
  }

  Future<void> refreshProfile() async {
    setState(() {
      profileFuture = profileService.getProfileData();
    });
  }

  Future<void> openEditProfile(ProfileData profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );

    if (result == true && mounted) {
      refreshProfile();
    }
  }

  Future<void> openChangePassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );

    if (result == true && mounted) {
      refreshProfile();
    }
  }

  Future<void> openLanguagePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chọn ngôn ngữ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...languages.map(
                  (language) {
                    final isSelected = selectedLanguage == language;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          selectedLanguage = language;
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn $language'),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0E7FF)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                language,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> handleLogout() async {
    await profileService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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

  Widget buildAvatar(ProfileData profile) {
    if (profile.avatar.isNotEmpty) {
      return Text(
        profile.avatar,
        style: const TextStyle(fontSize: 34),
      );
    }

    return Text(
      getInitials(profile.name),
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget buildMenuButton({
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
    Color iconBg = const Color(0xFFE0E7FF),
    Color iconColor = AppColors.primary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<ProfileData>(
          future: profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Không tải được hồ sơ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: refreshProfile,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            final profile = snapshot.data!;

            return ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeMode,
              builder: (context, themeMode, _) {
                final isDarkMode = themeMode == ThemeMode.dark;

                return RefreshIndicator(
                  onRefresh: refreshProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 24),
                        _buildHeader(profile),
                        const SizedBox(height: 28),
                        _buildStats(profile),
                        const SizedBox(height: 28),
                        _buildSettings(profile, isDarkMode),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
                        const SizedBox(height: 26),
                        const Text(
                          'Team Task v2.4.0 • Xây dựng cho Flow',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
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
        SizedBox(width: 38, height: 38),
      ],
    );
  }

  Widget _buildHeader(ProfileData profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: buildAvatar(profile),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
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
          ],
        ),
        const SizedBox(height: 18),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.email,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ProfileData profile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Text(
                  '${profile.activeTasks}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CÔNG VIỆC ĐANG LÀM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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
              children: [
                Text(
                  '${profile.completedTasks}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ĐÃ HOÀN THÀNH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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

  Widget _buildSettings(ProfileData profile, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'CÀI ĐẶT CHUNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        buildMenuButton(
          icon: Icons.person_outline,
          title: 'Chỉnh sửa hồ sơ',
          onTap: () => openEditProfile(profile),
        ),
        const SizedBox(height: 10),
        buildMenuButton(
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          onTap: openChangePassword,
          iconBg: const Color(0xFFF3F4F6),
          iconColor: AppColors.textSecondary,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Chế độ tối',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ThemeController.setDarkMode(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        buildMenuButton(
          icon: Icons.language,
          title: 'Ngôn ngữ',
          trailingText: selectedLanguage,
          iconBg: const Color(0xFFF3F4F6),
          iconColor: AppColors.textSecondary,
          onTap: openLanguagePicker,
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: handleLogout,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCDD2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}