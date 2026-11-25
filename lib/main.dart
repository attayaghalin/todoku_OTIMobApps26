import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'repositories/setting_repository.dart';
import 'repositories/task_repository.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  final taskRepository = SharedPrefsTaskRepository();
  final settingRepository = SharedPrefsSettingRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(settingRepository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskRepository)..init(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}