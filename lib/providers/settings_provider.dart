// providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // 默认主题
  bool _notificationsEnabled = true; // 默认启用通知
  bool _anniversaryRemindersEnabled = true; // 默认启用纪念日提醒
  // String _reminderTime = '1 day before';   // 可以添加更多设置项
  // Locale? _locale;  // 如果要支持多语言

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get anniversaryRemindersEnabled => _anniversaryRemindersEnabled;

  SettingsProvider() {
    _loadSettings(); // 在构造函数中加载设置
  }

  // 从 SharedPreferences 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode');
    _themeMode = _stringToThemeMode(theme);
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _anniversaryRemindersEnabled = prefs.getBool('anniversaryRemindersEnabled') ?? true;

    notifyListeners();
  }
  // 将字符串转换为 ThemeMode
  ThemeMode _stringToThemeMode(String? theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  // 切换主题
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(_themeMode));
  }

  // 切换通知启用状态
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }
  //切换纪念日提醒
  Future<void> setAnniversaryRemindersEnabled(bool enabled) async {
    _anniversaryRemindersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('anniversaryRemindersEnabled', enabled);
  }

// 可以添加更多设置项的 setter 方法...
}