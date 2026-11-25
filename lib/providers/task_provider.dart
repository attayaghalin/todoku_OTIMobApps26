import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

enum TaskFilter { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  final Uuid _uuid = const Uuid();

  TaskProvider(this._repository);

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  TaskFilter _activeFilter = TaskFilter.all;
  String _searchQuery = '';
  String? _selectedTaskId;
  String? _storageError;
  bool _isProfilingSeeded = false;

  TaskModel? _lastDeletedTask;
  int? _lastDeletedIndex;

  Timer? _saveTimer;
  UnmodifiableListView<TaskModel> _cachedFilteredTasks =
      UnmodifiableListView(const []);

  UnmodifiableListView<TaskModel> get tasks => _cachedFilteredTasks;
  bool get isLoading => _isLoading;
  TaskFilter get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  String? get selectedTaskId => _selectedTaskId;
  String? get storageError => _storageError;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  double get progress => totalCount == 0 ? 0.0 : completedCount / totalCount;

  TaskModel? get selectedTask =>
      _tasks.where((t) => t.id == _selectedTaskId).firstOrNull;

  TaskModel? getTaskById(String id) =>
      _tasks.where((t) => t.id == id).firstOrNull;

  Future<void> init({bool seedForProfiling = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (seedForProfiling) {
        seedDummyTasksForProfiling();
      } else {
        _tasks = await _repository.loadTasks();
        _recomputeFilteredTasks();
      }
    } catch (e) {
      debugPrint('Gagal memuat tugas: $e');
      _tasks = [];
      _storageError = 'Data lokal rusak, memulai dengan daftar kosong.';
      _recomputeFilteredTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTask(TaskModel newTask) {
    final normalizedTask = newTask.dueDate != null
        ? newTask.copyWith(dueDate: DateUtils.dateOnly(newTask.dueDate!))
        : newTask;

    _tasks.insert(0, normalizedTask);
    _selectedTaskId = normalizedTask.id;
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

    final normalizedTask = updatedTask.dueDate != null
        ? updatedTask.copyWith(dueDate: DateUtils.dateOnly(updatedTask.dueDate!))
        : updatedTask;

    _tasks[index] = normalizedTask;
    _commitChanges();
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _lastDeletedIndex = index;
    _lastDeletedTask = _tasks[index];
    _tasks.removeAt(index);

    if (_selectedTaskId == id) {
      _selectedTaskId = null;
    }

    _commitChanges();
  }

  void undoDelete() {
    if (_lastDeletedTask == null || _lastDeletedIndex == null) return;

    final safeIndex = _lastDeletedIndex!.clamp(0, _tasks.length);
    _tasks.insert(safeIndex, _lastDeletedTask!);

    _lastDeletedTask = null;
    _lastDeletedIndex = null;

    _commitChanges();
  }

  void selectTask(String? id) {
    if (_selectedTaskId == id) return;
    _selectedTaskId = id;
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    _recomputeFilteredTasks();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
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
        TaskFilter.completed => task.isCompleted,
      };

      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      return matchesFilter && matchesQuery;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.dueDate != null && b.dueDate != null) {
          final dateCompare = a.dueDate!.compareTo(b.dueDate!);
          if (dateCompare != 0) return dateCompare;
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }
        return b.priority.index.compareTo(a.priority.index);
      });

    _cachedFilteredTasks = UnmodifiableListView(filtered);
  }

  void _scheduleSave() {
    if (_isProfilingSeeded) return;

    _saveTimer?.cancel();
    final snapshot = List<TaskModel>.unmodifiable(_tasks);

    _saveTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        await _repository.saveTasks(snapshot);
        if (_storageError != null) {
          _storageError = null;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Gagal menyimpan tugas: $e');
        _storageError = 'Gagal menyimpan perubahan ke penyimpanan lokal.';
        notifyListeners();
      }
    });
  }

  void seedDummyTasksForProfiling([int count = 1000]) {
    _isProfilingSeeded = true;
    final today = DateUtils.dateOnly(DateTime.now());

    _tasks = List.generate(
      count,
      (i) => TaskModel(
        id: _uuid.v4(),
        title: 'Tugas Pengujian Performa #${i + 1}',
        description: 'Deskripsi sampel untuk menguji rendering ListView.builder',
        dueDate: i % 5 == 0 ? null : today.add(Duration(days: (i % 7) - 2)),
        priority: TaskPriority.values[i % TaskPriority.values.length],
        isCompleted: i % 3 == 0,
      ),
    );

    _recomputeFilteredTasks();
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}