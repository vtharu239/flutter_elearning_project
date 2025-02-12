import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { system, light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeModeType _themeMode = ThemeModeType.system;
  ThemeModeType get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(ThemeModeType mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeModeType.values.firstWhere(
      (e) => e.toString().split('.').last == savedTheme,
      orElse: () => ThemeModeType.system,
    );
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString().split('.').last);
  }
}
