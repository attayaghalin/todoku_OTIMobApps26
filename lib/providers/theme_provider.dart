import 'package:flutter/material.dart';
import '../repositories/setting_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingRepository _repository;
  ThemeProvider(this._repository);

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    try {
      _isDarkMode = await _repository.loadDarkMode();
    } catch (e) {
      debugPrint('Gagal memuat pengaturan tema: $e');
      _isDarkMode = false;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();

    try {
      await _repository.saveDarkMode(_isDarkMode);
    } catch (e) {
      debugPrint('Gagal menyimpan pengaturan tema: $e');
    }
  }
}