import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  
  AppThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  bool get isLightMode => !isDarkMode;
  
  Future<void> initTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 2; // Default to system
      _themeMode = AppThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // Default to system theme if there's an error
      _themeMode = AppThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      // Handle error silently
    }
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.light) {
      await setThemeMode(AppThemeMode.dark);
    } else if (_themeMode == AppThemeMode.dark) {
      await setThemeMode(AppThemeMode.system);
    } else {
      await setThemeMode(AppThemeMode.light);
    }
  }
  
  String get currentThemeName {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
  
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
