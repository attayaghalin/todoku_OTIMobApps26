import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../routes/app_router.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/todoist_task_tile.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _wasWideScreen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _headerTitle(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => 'Semua ',
      TaskFilter.active => 'Aktif',
      TaskFilter.completed => 'Selesai',
    };
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<TaskProvider>().setSearchQuery('');
      }
    });
  }

  void _deleteWithUndo(BuildContext context, TaskModel task) {
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${task.title}" dihapus'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => provider.undoDelete(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = context.select<TaskProvider, TaskFilter>(
      (p) => p.activeFilter,
    );
    final isDarkMode = context.select<ThemeProvider, bool>(
      (p) => p.isDarkMode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_headerTitle(activeFilter)),
        actions: [
          IconButton(
            tooltip: _isSearching ? 'Tutup Pencarian' : 'Cari Tugas',
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          IconButton(
            tooltip: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme(!isDarkMode);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 600;

          if (isWideScreen && !_wasWideScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.popUntil(context, ModalRoute.withName(AppRouter.home));
              }
            });
          }
          _wasWideScreen = isWideScreen;

          if (isWideScreen) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTaskListPane(isWideScreen: true),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 3,
                  child: _buildWideDetailPane(),
                ),
              ],
            );
          }

          return _buildTaskListPane(isWideScreen: false);
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Tugas',
        onPressed: () => TaskFormScreen.show(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeFilter.index,
        onDestinationSelected: (index) {
          context.read<TaskProvider>().setFilter(TaskFilter.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Semua',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Aktif',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Selesai',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListPane({required bool isWideScreen}) {
    return Builder(
      builder: (context) {
        final isLoading = context.select<TaskProvider, bool>((p) => p.isLoading);
        final totalCount = context.select<TaskProvider, int>((p) => p.totalCount);
        final selectedTaskId = context.select<TaskProvider, String?>(
          (p) => p.selectedTaskId,
        );
        final taskIds = context.select<TaskProvider, List<String>>(
          (p) => p.tasks.map((t) => t.id).toList(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) =>
                      context.read<TaskProvider>().setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau deskripsi...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (_, value, __) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<TaskProvider>().setSearchQuery('');
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
  
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (taskIds.isEmpty) {
                    return TaskEmptyState(
                      icon: totalCount == 0
                          ? Icons.checklist_outlined
                          : Icons.search_off_rounded,
                      title: totalCount == 0
                          ? 'Belum ada tugas'
                          : 'Tidak ada tugas yang cocok',
                      subtitle: totalCount == 0
                          ? 'Ketuk tombol + di pojok kanan bawah untuk mencatat tugas pertamamu.'
                          : 'Coba ubah tab filter di bawah atau gunakan kata kunci lain.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: taskIds.length,
                    itemBuilder: (context, index) {
                      final taskId = taskIds[index];
                      final isFirst = index == 0;
                      final isLast = index == taskIds.length - 1;

                      return Selector<TaskProvider, TaskModel?>(
                        selector: (_, provider) => provider.getTaskById(taskId),
                        builder: (context, task, _) {
                          if (task == null) return const SizedBox.shrink();

                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.vertical(
                                  top: isFirst
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  bottom: isLast
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _deleteWithUndo(context, task),
                            child: TodoistTaskTile(
                              task: task,
                              isFirst: isFirst,
                              isLast: isLast,
                              isSelected:
                                  isWideScreen && selectedTaskId == task.id,
                              onToggle: () => context
                                  .read<TaskProvider>()
                                  .toggleTaskCompletion(task.id),
                              onTap: () {
                                if (isWideScreen) {
                                  context
                                      .read<TaskProvider>()
                                      .selectTask(task.id);
                                } else {
                                  TaskDetailScreen.show(context, taskId: task.id);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWideDetailPane() {
    return Builder(
      builder: (context) {
        final selectedTask = context.select<TaskProvider, TaskModel?>(
          (p) => p.selectedTask,
        );

        if (selectedTask == null) {
          return const TaskEmptyState(
            icon: Icons.touch_app_outlined,
            title: 'Pilih salah satu tugas',
            subtitle:
                'Ketuk tugas di panel sebelah kiri untuk melihat rinciannya.',
          );
        }

        return TaskDetailContent(taskId: selectedTask.id);
      },
    );
  }
}