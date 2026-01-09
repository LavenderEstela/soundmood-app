import 'package:flutter/material.dart';
import 'cloud_theme.dart';
import 'space_theme.dart';

/// 主题类型枚举
enum AppThemeType {
  cloud,  // 云端主题
  space,  // 星际主题
}

/// 应用主题管理
class AppTheme {
  // ==================== 静态属性 (解决 undefined_getter 错误) ====================
  
  /// 主色 - 默认使用云端主题的主色
  static Color get primaryColor => CloudTheme.primary;
  
  /// 强调色 - 默认使用云端主题的强调色
  static Color get accentColor => CloudTheme.accent;
  
  /// 主渐变
  static LinearGradient get primaryGradient => CloudTheme.buttonGradient;
  
  /// 次要渐变
  static LinearGradient get secondaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE4E6), Color(0xFFB2EBF2)],
  );
  
  // ==================== 主题获取方法 ====================
  
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.themeData;
      case AppThemeType.space:
        return SpaceTheme.themeData;
    }
  }
  
  /// 获取背景渐变
  static LinearGradient getBackgroundGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.backgroundGradient;
      case AppThemeType.space:
        return SpaceTheme.backgroundGradient;
    }
  }
  
  /// 获取主色
  static Color getPrimaryColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.primary;
      case AppThemeType.space:
        return SpaceTheme.primary;
    }
  }
  
  /// 获取强调色
  static Color getAccentColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.accent;
      case AppThemeType.space:
        return SpaceTheme.accent;
    }
  }
  
  /// 获取主文字颜色
  static Color getTextPrimaryColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.textPrimary;
      case AppThemeType.space:
        return SpaceTheme.textPrimary;
    }
  }
  
  /// 获取次要文字颜色
  static Color getTextSecondaryColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.textSecondary;
      case AppThemeType.space:
        return SpaceTheme.textSecondary;
    }
  }
  
  /// 获取情绪颜色
  static Color getEmotionColor(AppThemeType type, String emotion) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.emotionColors[emotion] ?? CloudTheme.primary;
      case AppThemeType.space:
        return SpaceTheme.emotionColors[emotion] ?? SpaceTheme.primary;
    }
  }
  
  /// 获取灵感球渐变
  static LinearGradient getOrbGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.orbGradient;
      case AppThemeType.space:
        return SpaceTheme.orbGradient;
    }
  }
  
  /// 获取灵感球阴影
  static List<BoxShadow> getOrbShadow(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.orbShadow;
      case AppThemeType.space:
        return SpaceTheme.orbShadow;
    }
  }
  
  /// 获取卡片阴影
  static List<BoxShadow> getCardShadow(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.cardShadow;
      case AppThemeType.space:
        return SpaceTheme.cardShadow;
    }
  }
  
  /// 获取按钮渐变
  static LinearGradient getButtonGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.buttonGradient;
      case AppThemeType.space:
        return SpaceTheme.buttonGradient;
    }
  }
  
  /// 获取时间线渐变
  static LinearGradient getTimelineGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.timelineGradient;
      case AppThemeType.space:
        return SpaceTheme.timelineGradient;
    }
  }
  
  /// 获取卡片背景色
  static Color getCardBackground(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return Colors.white.withValues(alpha: 0.9);
      case AppThemeType.space:
        return const Color(0xCC141428);
    }
  }
  
  /// 获取卡片边框色
  static Color getCardBorder(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.softBlue.withValues(alpha: 0.3);
      case AppThemeType.space:
        return SpaceTheme.primary.withValues(alpha: 0.2);
    }
  }
}
