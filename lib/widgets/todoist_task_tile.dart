import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'priority_checkbox.dart';

class TodoistTaskTile extends StatelessWidget {
  final TaskModel task;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TodoistTaskTile({
    super.key,
    required this.task,
    this.isFirst = false,
    this.isLast = false,
    this.isSelected = false,
    required this.onToggle,
    required this.onTap,
  });

  String _formatDueDate(DateTime dueDate) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(dueDate);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Hari ini';
    if (diffDays == 1) return 'Besok';
    if (diffDays == -1) return 'Kemarin';
    return DateFormat('EEEE, d MMM', 'id_ID').format(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;
    final dueColor = AppTheme.dueDateColor(context, task.dueDate);

    final borderRadius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.10)
          : cardColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PriorityCheckbox(
                    priority: task.priority,
                    isCompleted: task.isCompleted,
                    onToggle: onToggle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                                : theme.colorScheme.onSurface,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 14,
                                color: task.isCompleted
                                    ? dueColor.withValues(alpha: 0.5)
                                    : dueColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatDueDate(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: task.isCompleted
                                      ? dueColor.withValues(alpha: 0.5)
                                      : dueColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.only(left: 52),
                child: Divider(height: 1),
              ),
          ],
        ),
      ),
    );
  }
}