import 'package:flutter/foundation.dart';
import '../repositories/setting_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingRepository _repository;
  ThemeProvider(this._repository);

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    _isDarkMode = await _repository.loadDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _repository.saveDarkMode(_isDarkMode);
  }
}