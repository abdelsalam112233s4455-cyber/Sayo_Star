import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // تحميل الثيم المحفوظ
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedTheme = prefs.getString('theme_mode');

    if (savedTheme == null) {
      _themeMode = ThemeMode.system;
    } else {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;

        case 'dark':
          _themeMode = ThemeMode.dark;
          break;

        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }

    notifyListeners();
  }

  // تغيير وحفظ الثيم
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    String themeValue;

    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;

      case ThemeMode.dark:
        themeValue = 'dark';
        break;

      case ThemeMode.system:
        themeValue = 'system';
        break;
    }

    await prefs.setString('theme_mode', themeValue);
  }
}