import 'package:accollect/core/shared_prefs_manager.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final savedTheme = await SharedPrefsManager.getThemeMode();
    _themeMode = savedTheme;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await SharedPrefsManager.setThemeMode(mode);
    notifyListeners();
  }
}
