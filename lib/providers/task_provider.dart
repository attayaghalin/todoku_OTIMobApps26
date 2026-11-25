import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

enum TaskFilter { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider(this._repository);

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  TaskFilter _activeFilter = TaskFilter.all;
  String _searchQuery = '';

  Timer? _saveTimer;
  UnmodifiableListView<TaskModel> _cachedFilteredTasks = UnmodifiableListView([]);

  UnmodifiableListView<TaskModel> get tasks => _cachedFilteredTasks;
  bool get isLoading => _isLoading;
  TaskFilter get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.loadTasks();
      _recomputeFilteredTasks();
    } catch (e) {
      debugPrint('Gagal memuat tugas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTask(TaskModel newTask) {
    _tasks.insert(0, newTask);
    _commitChanges();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    _tasks[index] = oldTask.copyWith(isCompleted: !oldTask.isCompleted);

    _commitChanges();
  }

  void updateTask(TaskModel updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;

    _tasks[index] = updatedTask;

    _commitChanges();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);

    _commitChanges();
  }

  void setFilter(TaskFilter filter) {
    _activeFilter = filter;
    _recomputeFilteredTasks();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _recomputeFilteredTasks();
    notifyListeners();
  }

  void _commitChanges() {
    _recomputeFilteredTasks();
    notifyListeners();
    _scheduleSave();
  }

  void _recomputeFilteredTasks() {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _tasks.where((task) {
      final matchesFilter = switch (_activeFilter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.isCompleted,
        TaskFilter.completed => task.isCompleted
      };

      final matchesQuery = query.isEmpty || task.title.toLowerCase().contains(query) || task.description.toLowerCase().contains(query);

      return matchesFilter && matchesQuery;
    }).toList();

    _cachedFilteredTasks = UnmodifiableListView(filtered);
  }

  void _scheduleSave() {
    _saveTimer?.cancel();

    _saveTimer = Timer(const Duration(milliseconds: 350), () async {
      await _repository.saveTasks(_tasks);
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}