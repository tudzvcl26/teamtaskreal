import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';

class RecentGroupCard extends StatelessWidget {
  final String initials;
  final String groupName;
  final String memberCount;
  final Color avatarBg;
  final Color avatarTextColor;

  const RecentGroupCard({
    super.key,
    required this.initials,
    required this.groupName,
    required this.memberCount,
    required this.avatarBg,
    required this.avatarTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: avatarTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            groupName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            memberCount,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}