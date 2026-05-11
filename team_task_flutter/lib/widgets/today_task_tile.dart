import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';

class TodayTaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priority;
  final Color priorityBg;
  final Color priorityText;

  const TodayTaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.priorityBg,
    required this.priorityText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: priorityBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              priority,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: priorityText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}