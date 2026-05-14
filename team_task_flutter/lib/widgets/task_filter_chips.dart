import 'package:flutter/material.dart';
import 'package:team_task_flutter/l10n/app_localizations.dart';

class TaskFilterChips extends StatelessWidget {
  final List<Map<String, String>> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const TaskFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  static const String _bodyFont = 'Inter';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = filters[index];
          final value = item['value'] ?? '';
          final label = item['label'] ?? '';
          final selected = selectedFilter == value;

          return ChoiceChip(
            label: Text(
              label.tr(context),
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            onSelected: (_) => onSelected(value),
          );
        },
      ),
    );
  }
}
