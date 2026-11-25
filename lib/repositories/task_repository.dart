import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> loadTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
}

class SharedPrefsTaskRepository implements TaskRepository {
  static const String _storageKey = 'tasks_data_v1';

  @override
  Future<List<TaskModel>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((task) => TaskModel.fromJson(task as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }

  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final List<dynamic> jsonList = tasks.map((task) => task.toJson()).toList();

    final String jsonString = jsonEncode(jsonList);

    await prefs.setString(_storageKey, jsonString);
  } 
}

