import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/priority_picker_sheet.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  static Future<void> show(BuildContext context, {required String taskId}) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.cardTheme.color ?? theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) => TaskDetailContent(
          taskId: taskId,
          scrollController: scrollController,
          isInsideSheet: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TaskDetailContent(taskId: taskId);
  }
}

class TaskDetailContent extends StatefulWidget {
  final String taskId;
  final ScrollController? scrollController;
  final bool isInsideSheet;

  const TaskDetailContent({
    super.key,
    required this.taskId,
    this.scrollController,
    this.isInsideSheet = false,
  });

  @override
  State<TaskDetailContent> createState() => _TaskDetailContentState();
}

class _TaskDetailContentState extends State<TaskDetailContent> {
  final TextEditingController _descController = TextEditingController();
  final FocusNode _descFocusNode = FocusNode();
  bool _isEditingDescription = false;

  @override
  void didUpdateWidget(covariant TaskDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskId != widget.taskId && _isEditingDescription) {
      _descFocusNode.unfocus();
      _isEditingDescription = false;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _startEditingDescription(TaskModel task) {
    _descController.text = task.description;
    setState(() => _isEditingDescription = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _descFocusNode.requestFocus();
    });
  }

  void _saveDescription(TaskModel task) {
    final cleanDesc = _descController.text.trim();
    if (cleanDesc != task.description) {
      context.read<TaskProvider>().updateTask(
        task.copyWith(description: cleanDesc),
      );
    }
    _descFocusNode.unfocus();
    setState(() => _isEditingDescription = false);
  }

  void _cancelEditingDescription() {
    _descFocusNode.unfocus();
    setState(() => _isEditingDescription = false);
  }

  String _priorityLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => 'Prioritas 1',
      TaskPriority.medium => 'Prioritas 2',
      TaskPriority.low => 'Prioritas 3',
    };
  }

  Future<void> _pickDate(BuildContext context, TaskModel task) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate =
        (task.dueDate != null && !task.dueDate!.isBefore(today))
            ? task.dueDate!
            : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      helpText: 'Pilih Tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null && context.mounted) {
      context.read<TaskProvider>().updateTask(task.copyWith(dueDate: picked));
    }
  }

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('Tugas "${task.title}" akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskProvider>().deleteTask(task.id);
      if (widget.isInsideSheet) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.getTaskById(widget.taskId);

    if (task == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final priorityColor = AppTheme.priorityColor(task.priority, isDark: isDark);
    final dueColor = AppTheme.dueDateColor(context, task.dueDate);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isInsideSheet)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
          child: Row(
            children: [
              Icon(
                task.isCompleted
                    ? Icons.check_circle_outline_rounded
                    : Icons.event_note_outlined,
                size: 18,
                color: task.isCompleted
                    ? (isDark
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF058527))
                    : mutedColor,
              ),
              const SizedBox(width: 8),
              Text(
                task.isCompleted ? 'Selesai' : 'Aktif',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: task.isCompleted
                      ? (isDark
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF058527))
                      : mutedColor,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'Opsi lainnya',
                icon: Icon(Icons.more_vert_rounded, color: mutedColor),
                onSelected: (value) {
                  if (value == 'edit') {
                    TaskFormScreen.show(context, taskId: task.id);
                  } else if (value == 'delete') {
                    _confirmDelete(context, task);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Hapus tugas'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.only(bottom: 24 + keyboardInset),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => provider.toggleTaskCompletion(task.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3, right: 14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted
                                ? priorityColor
                                : priorityColor.withValues(alpha: 0.10),
                            border:
                                Border.all(color: priorityColor, width: 1.8),
                          ),
                          child: task.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            TaskFormScreen.show(context, taskId: task.id),
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? mutedColor
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isEditingDescription)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          Icons.notes_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _descController,
                              focusNode: _descFocusNode,
                              minLines: 2,
                              maxLines: 6,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.4,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tulis deskripsi...',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _cancelEditingDescription,
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Batal'),
                                ),
                                const SizedBox(width: 6),
                                FilledButton(
                                  onPressed: () => _saveDescription(task),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Simpan'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: () => _startEditingDescription(task),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.notes_rounded,
                            size: 20,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            task.description.isNotEmpty
                                ? task.description
                                : 'Deskripsi',
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.4,
                              color: task.description.isNotEmpty
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.85)
                                  : mutedColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              InkWell(
                onTap: () => _pickDate(context, task),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 20,
                        color: task.dueDate != null ? dueColor : mutedColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          task.dueDate != null
                              ? DateFormat('EEE, d MMM', 'id_ID').format(task.dueDate!)
                              : 'Tambah tanggal',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: task.dueDate != null
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: task.dueDate != null
                                ? dueColor
                                : mutedColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      if (task.dueDate != null)
                        IconButton(
                          tooltip: 'Hapus tanggal',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: mutedColor,
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            provider.updateTask(
                              task.copyWith(clearDueDate: true),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                child: Row(
                  children: [
                    _DetailChip(
                      icon: Icons.flag_rounded,
                      label: _priorityLabel(task.priority),
                      iconColor: priorityColor,
                      onTap: () async {
                        final picked = await showPriorityPickerSheet(
                          context,
                          currentPriority: task.priority,
                        );
                        if (picked != null && context.mounted) {
                          context.read<TaskProvider>().updateTask(
                            task.copyWith(priority: picked),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.82);
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor ?? textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}