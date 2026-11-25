import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingRepository {
  Future<bool> loadDarkMode();
  Future<void> saveDarkMode(bool isDarkMode);
}

class SharedPrefsSettingRepository implements SettingRepository {
  static const _darkModeKey = 'setting_is_dark_mode';

  @override
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }  

  @override
  Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDarkMode);
  }
}