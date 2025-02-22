import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsManager {
  static const String _themeModeKey = 'theme_mode';

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Saving Theme: ${mode.toString()}');
    await prefs.setInt(_themeModeKey, mode.index);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeIndex];
    debugPrint('Loaded Theme: ${themeMode.toString()}');
    return themeMode;
  }
}
