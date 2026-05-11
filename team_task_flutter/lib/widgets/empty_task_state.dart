import 'package:flutter/material.dart';

class EmptyTaskState extends StatelessWidget {
  final String message;

  const EmptyTaskState({
    super.key,
    this.message = 'Chưa có công việc phù hợp',
  });

  static const String _headlineFont = 'Manrope';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _headlineFont,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}