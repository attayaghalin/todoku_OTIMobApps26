import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'priority_checkbox.dart';

class TaskDetailPane extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailPane({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  String _priorityLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => 'Prioritas Tinggi',
      TaskPriority.medium => 'Prioritas Sedang',
      TaskPriority.low => 'Prioritas Rendah',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = AppTheme.priorityColor(task.priority, isDark: isDark);
    final dueColor = AppTheme.dueDateColor(context, task.dueDate);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_rounded, size: 15, color: priorityColor),
                  const SizedBox(width: 5),
                  Text(
                    _priorityLabel(task.priority),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              task.isCompleted ? 'Selesai' : 'Aktif',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? Colors.green
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: PriorityCheckbox(
                priority: task.priority,
                isCompleted: task.isCompleted,
                onToggle: onToggleComplete,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (task.dueDate != null) ...[
          Row(
            children: [
              Icon(Icons.event_outlined, size: 18, color: dueColor),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(task.dueDate!),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: dueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description.trim().isEmpty
                    ? 'Tidak ada deskripsi tambahan.'
                    : task.description,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  fontStyle: task.description.trim().isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: task.description.trim().isEmpty
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}