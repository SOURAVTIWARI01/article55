import 'package:flutter/material.dart';

/// Manages the app-wide theme mode (light/dark).
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark mode.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set a specific theme mode.
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
