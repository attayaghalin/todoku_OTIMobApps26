import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/priority_picker_sheet.dart';

class TaskFormScreen extends StatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});
  static Future<void> show(BuildContext context, {String? taskId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormScreen(taskId: taskId),
    );
  }

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  TaskModel? _existingTask;
  bool _showDescriptionField = false;
  bool _canSubmit = false;

  bool get _isEditMode => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _existingTask = context.read<TaskProvider>().getTaskById(widget.taskId!);
      if (_existingTask != null) {
        _titleController.text = _existingTask!.title;
        _descController.text = _existingTask!.description;
        _selectedPriority = _existingTask!.priority;
        _selectedDueDate = _existingTask!.dueDate;
        _showDescriptionField = _existingTask!.description.trim().isNotEmpty;
      }
    }
    _canSubmit = _titleController.text.trim().isNotEmpty;
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    final valid = _titleController.text.trim().isNotEmpty;
    if (valid != _canSubmit) {
      setState(() => _canSubmit = valid);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final initialDate =
        (_selectedDueDate != null && !_selectedDueDate!.isBefore(today))
            ? _selectedDueDate!
            : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      helpText: 'Pilih Tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      fieldLabelText: 'Masukkan tanggal',
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final cleanTitle = _titleController.text.trim();
    final provider = context.read<TaskProvider>();
    final cleanDesc = _showDescriptionField ? _descController.text.trim() : '';

    if (_isEditMode && _existingTask != null) {
      final updated = _existingTask!.copyWith(
        title: cleanTitle,
        description: cleanDesc,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        clearDueDate: _selectedDueDate == null,
      );
      provider.updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: const Uuid().v4(),
        title: cleanTitle,
        description: cleanDesc,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      provider.addTask(newTask);
    }

    Navigator.pop(context);
  }

  String _priorityShortLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.high => 'Prioritas tinggi',
      TaskPriority.medium => 'Prioritas sedang',
      TaskPriority.low => 'Prioritas rendah',
    };
  }

  String _formatChipDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(date);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    return DateFormat('EEE, d MMM', 'id_ID').format(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor =
        theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;
    final priorityColor =
        AppTheme.priorityColor(_selectedPriority, isDark: isDark);
    final dueColor = AppTheme.dueDateColor(context, _selectedDueDate);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveTask(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tugas tidak boleh kosong';
                    }
                    return null;
                  },
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: _isEditMode ? 'Edit task name' : 'Task name',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    isDense: true,
                  ),
                ),

                if (_showDescriptionField)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      controller: _descController,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Deskripsi',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.38),
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        isDense: true,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Flexible(
                      child: _QuickActionChip(
                        icon: Icons.notes_rounded,
                        iconColor: _showDescriptionField
                            ? theme.colorScheme.primary
                            : null,
                        label: 'Deskripsi',
                        labelColor: _showDescriptionField
                            ? theme.colorScheme.primary
                            : null,
                        onTap: () {
                          setState(
                            () =>
                                _showDescriptionField = !_showDescriptionField,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    _QuickActionChip(
                      icon: Icons.flag_outlined,
                      iconColor: priorityColor,
                      label: _priorityShortLabel(_selectedPriority),
                      onTap: () async {
                        final picked = await showPriorityPickerSheet(
                          context,
                          currentPriority: _selectedPriority,
                        );
                        if (picked != null) {
                          setState(() => _selectedPriority = picked);
                        }
                      },
                    ),
                    const SizedBox(width: 8),

                    Flexible(
                      child: _QuickActionChip(
                        icon: Icons.event_outlined,
                        iconColor: _selectedDueDate != null ? dueColor : null,
                        label: _selectedDueDate == null
                            ? 'Tenggat'
                            : _formatChipDate(_selectedDueDate!),
                        labelColor: _selectedDueDate != null ? dueColor : null,
                        onTap: _pickDueDate,
                        onClear: _selectedDueDate != null
                            ? () => setState(() => _selectedDueDate = null)
                            : null,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Material(
                      color: _canSubmit
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _saveTask,
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 42,
                          height: 38,
                          child: Icon(
                            Icons.send_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _QuickActionChip({
    required this.icon,
    this.iconColor,
    required this.label,
    this.labelColor,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5DFD5);
    final defaultTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.78);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor ?? defaultTextColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? defaultTextColor,
                ),
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: labelColor ?? defaultTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}