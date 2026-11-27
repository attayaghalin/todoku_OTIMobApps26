import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';

Future<TaskPriority?> showPriorityPickerSheet(
  BuildContext context, {
  required TaskPriority currentPriority,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final options = [
    (
      priority: TaskPriority.high,
      label: 'Prioritas Tinggi',
      subtitle: 'Mendesak',
    ),
    (
      priority: TaskPriority.medium,
      label: 'Prioritas Sedang',
      subtitle: 'Penting',
    ),
    (
      priority: TaskPriority.low,
      label: 'Prioritas Rendah',
      subtitle: 'Santai',
    ),
  ];

  return showModalBottomSheet<TaskPriority>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  'Pilih Prioritas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...options.map((item) {
                final color = AppTheme.priorityColor(
                  item.priority,
                  isDark: isDark,
                );
                final isSelected = item.priority == currentPriority;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? color.withValues(alpha: 0.12)
                      : null,
                  leading: Icon(Icons.flag_rounded, color: color),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: color)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, item.priority),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}