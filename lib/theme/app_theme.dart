import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AppTheme {
  static const Color todoistRedLightMode = Color(0xFFD1453B);
  static const Color todoistRedDarkMode = Color(0xFFDC4C3E);
  static const Color todoistCoralActive = Color(0xFFFF6B5B);

  static const Color priorityHighLight = Color(0xFFD1453B);
  static const Color priorityHighDark = Color(0xFFE05A4F);
  static const Color priorityMediumOrange = Color(0xFFEB8909);
  static const Color priorityLowBlue = Color(0xFF4073FF);

  static const Color dueDatePurpleLight = Color(0xFF6941C6);
  static const Color dueDateLavenderDark = Color(0xFFA882DD);

  static const Color _lightScaffold = Color(0xFFFAF6F0);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightNavBar = Color(0xFFF3EDE4);
  static const Color _lightIndicator = Color(0xFFF8E0DC);
  static const Color _lightTextPrimary = Color(0xFF1F1D1A);
  static const Color _lightTextSecondary = Color(0xFF5C5852);

  static const Color _darkScaffold = Color(0xFF1E1E1E);
  static const Color _darkNavBar = Color(0xFF242426);
  static const Color _darkCard = Color(0xFF28282A);
  static const Color _darkIndicator = Color(0xFF4A2525);
  static const Color _darkTextPrimary = Color(0xFFEAEAEA);
  static const Color _darkTextSecondary = Color(0xFF9E9E9E);

  static Color priorityColor(TaskPriority priority, {bool isDark = false}) {
    return switch (priority) {
      TaskPriority.high => isDark ? priorityHighDark : priorityHighLight,
      TaskPriority.medium => priorityMediumOrange,
      TaskPriority.low => priorityLowBlue,
    };
  }

  static Color dueDateColor(BuildContext context, [DateTime? dueDate]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dueDate == null) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final target = DateUtils.dateOnly(dueDate);
    final diffDays = target.difference(today).inDays;

    if (diffDays <= 0) {
      return isDark ? const Color(0xFFFF6B6B) : const Color(0xFFD1453B);
    }

    if (diffDays == 1) {
      return isDark ? const Color(0xFFFFCA28) : const Color(0xFFC97A00);
    }

    if (diffDays <= 7) {
      return isDark ? const Color(0xFF4ADE80) : const Color(0xFF058527);
    }

    return isDark ? const Color(0xFFC084FC) : const Color(0xFF7B3FE4);
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: todoistRedLightMode,
      brightness: Brightness.light,
      primary: todoistRedLightMode,
      onPrimary: Colors.white,
      surface: _lightScaffold,
      onSurface: _lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightScaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightScaffold,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightCard,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: todoistRedLightMode,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightNavBar,
        indicatorColor: _lightIndicator,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: todoistRedLightMode);
          }
          return const IconThemeData(color: _lightTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: todoistRedLightMode,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: _lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5DFD5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5DFD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: todoistRedLightMode, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0EAE1),
        thickness: 0.8,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: todoistRedDarkMode,
      brightness: Brightness.dark,
      primary: todoistCoralActive,
      onPrimary: Colors.black,
      surface: _darkScaffold,
      surfaceContainer: _darkCard,
      onSurface: _darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkScaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkScaffold,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCard,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: todoistRedDarkMode,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkNavBar,
        indicatorColor: _darkIndicator,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: todoistCoralActive);
          }
          return const IconThemeData(color: _darkTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: todoistCoralActive,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: _darkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: todoistCoralActive, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 0.6,
        space: 1,
      ),
    );
  }
}