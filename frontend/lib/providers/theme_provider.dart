import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../config/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.cloud;
  
  AppThemeType get currentTheme => _currentTheme;
  bool get isCloudTheme => _currentTheme == AppThemeType.cloud;
  bool get isSpaceTheme => _currentTheme == AppThemeType.space;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  /// 加载保存的主题
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConfig.themeKey) ?? 0;
      _currentTheme = AppThemeType.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // 使用默认主题
    }
  }
  
  /// 切换主题
  Future<void> toggleTheme() async {
    _currentTheme = _currentTheme == AppThemeType.cloud 
        ? AppThemeType.space 
        : AppThemeType.cloud;
    
    await _saveTheme();
    notifyListeners();
  }
  
  /// 设置特定主题
  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme == theme) return;
    
    _currentTheme = theme;
    await _saveTheme();
    notifyListeners();
  }
  
  /// 保存主题设置
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConfig.themeKey, _currentTheme.index);
    } catch (e) {
      // 忽略保存错误
    }
  }
}