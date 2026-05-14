import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';
import 'package:team_task_flutter/screens/auth/login_screen.dart';
import 'package:team_task_flutter/widgets/onboarding_indicator.dart';
import 'package:team_task_flutter/widgets/onboarding_page_item.dart';
import 'package:team_task_flutter/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.groups_rounded,
      'title': 'Tạo nhóm và quản lý thành viên',
      'description':
          'Tập hợp sức mạnh trí tuệ tập thể. Tổ chức nhóm, phòng ban hoặc dự án trong giây lát.',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.task_alt_rounded,
      'title': 'Giao việc và quản lý deadline',
      'description':
          'Theo dõi công việc rõ ràng, phân công đúng người và hoàn thành đúng thời hạn.',
      'color': Colors.green,
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'Theo dõi tiến độ và nhận thông báo',
      'description':
          'Luôn cập nhật tiến độ nhóm với thông báo thời gian thực và trạng thái công việc rõ ràng.',
      'color': Colors.orange,
    },
  ];

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentIndex == onboardingData.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Team Task',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: goToLogin,
                    child: Text('Bỏ qua'.tr(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = onboardingData[index];
                  return OnboardingPageItem(
                    icon: item['icon'],
                    title: item['title'],
                    description: item['description'],
                    color: item['color'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  OnboardingIndicator(
                    currentIndex: currentIndex,
                    itemCount: onboardingData.length,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: isLastPage ? 'Bắt đầu' : 'Tiếp theo',
                    onPressed: nextPage,
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
