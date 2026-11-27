import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class PriorityCheckbox extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompleted;
  final VoidCallback onToggle;

  const PriorityCheckbox({
    super.key,
    required this.priority,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = AppTheme.priorityColor(priority, isDark: isDark);

    return InkWell(
      onTap: onToggle,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? ringColor : Colors.transparent,
            border: Border.all(
              color: ringColor,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}