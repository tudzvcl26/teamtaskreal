import 'package:flutter/material.dart';
import 'package:team_task_flutter/core/constants/app_colors.dart';

class GroupStyleData {
  static const Map<String, Color> colorMap = {
    'indigo': Color(0xFFE0E7FF),
    'green': Color(0xFFE8F5E9),
    'orange': Color(0xFFFFF3E0),
    'purple': Color(0xFFF3E5F5),
    'red': Color(0xFFFFEBEE),
    'teal': Color(0xFFE0F2F1),
  };

  static const Map<String, Color> textColorMap = {
    'indigo': AppColors.primary,
    'green': Color(0xFF2E7D32),
    'orange': Color(0xFFE65100),
    'purple': Color(0xFF6A1B9A),
    'red': Color(0xFFC62828),
    'teal': Color(0xFF00695C),
  };

  static const Map<String, IconData> iconMap = {
    'group_work': Icons.group_work_rounded,
    'palette': Icons.palette_outlined,
    'code': Icons.code_rounded,
    'campaign': Icons.campaign_rounded,
    'design': Icons.design_services_rounded,
    'school': Icons.school_rounded,
    'business': Icons.business_center_rounded,
    'task': Icons.task_alt_rounded,
  };

  static Color bgColor(String key) {
    return colorMap[key] ?? colorMap['indigo']!;
  }

  static Color textColor(String key) {
    return textColorMap[key] ?? textColorMap['indigo']!;
  }

  static IconData iconData(String key) {
    return iconMap[key] ?? iconMap['group_work']!;
  }

  static List<String> colorKeys = const [
    'indigo',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
  ];

  static List<String> iconKeys = const [
    'group_work',
    'palette',
    'code',
    'campaign',
    'design',
    'school',
    'business',
    'task',
  ];
}