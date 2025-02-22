import 'package:accollect/core/shared_prefs_manager.dart';
import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  SettingsViewModel() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() async {
    _themeMode = await SharedPrefsManager.getThemeMode();
    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await SharedPrefsManager.setThemeMode(mode);
      notifyListeners();
    }
  }
}
