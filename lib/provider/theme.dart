import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadThemeFromHive();
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeToHive();
  }

  void _loadThemeFromHive() {
    final box = Hive.box('settings');
    final savedTheme = box.get(themeKey, defaultValue: ThemeMode.system.toString());

    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == savedTheme,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> _saveThemeToHive() async {
    final box = Hive.box('settings');
    await box.put(themeKey, _themeMode.toString());
  }
}
