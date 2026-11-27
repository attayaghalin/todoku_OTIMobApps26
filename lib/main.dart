import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/setting_repository.dart';
import 'repositories/task_repository.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (provider) => provider.themeMode,
    );

    return MaterialApp(
      title: 'Todoist MVVM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  const isProfilingSeed = bool.fromEnvironment('SEED');

  final taskRepository = SharedPrefsTaskRepository();
  final settingRepository = SharedPrefsSettingRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(settingRepository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TaskProvider(taskRepository)..init(seedForProfiling: isProfilingSeed),
        ),
      ],
      child: const MyApp(),
    ),
  );
}