import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String taskForm = '/task-form';
  static const String taskDetail = '/task-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case taskForm:
        final taskId = settings.arguments is String
            ? settings.arguments as String
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(taskId == null ? 'Tugas Baru' : 'Edit Tugas'),
            ),
            body: Align(
              alignment: Alignment.bottomCenter,
              child: TaskFormScreen(taskId: taskId),
            ),
          ),
        );

      case taskDetail:
        final args = settings.arguments;
        if (args is! String || args.isEmpty) {
          return _errorRoute(settings, 'ID tugas tidak ditemukan.');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: TaskDetailScreen(taskId: args),
          ),
        );

      default:
        return _errorRoute(settings, 'Halaman "${settings.name}" tidak tersedia.');
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}