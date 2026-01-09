import 'package:flutter/material.dart';

/// 云端主题 - 柔软浪漫
class CloudTheme {
  // ==================== 颜色定义 ====================
  
  // 背景色
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color skyBlue = Color(0xFFE0F7FA);
  static const Color skyGreen = Color(0xFFE8F5E9);
  static const Color skyPeach = Color(0xFFFFF8E1);
  
  // 主色调
  static const Color primary = Color(0xFFB2EBF2);       // 天空蓝
  static const Color secondary = Color(0xFFFFE4E6);     // 浅粉红
  static const Color accent = Color(0xFFFFECD2);        // 蜜桃橙
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF5D6D7E);
  static const Color textSecondary = Color(0xFF95A5A6);
  
  // 特效颜色
  static const Color cloudWhite = Color(0xFFFFFFFF);
  static const Color softPink = Color(0xFFFFE4E6);
  static const Color softBlue = Color(0xFFB2EBF2);
  
  // ==================== 渐变定义 ====================
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue, skyGreen, skyPeach, backgroundColor],
    stops: [0.0, 0.3, 0.6, 1.0],
  );
  
  static const LinearGradient orbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cloudWhite, Color(0xFFF0F8FF)],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softBlue, softPink],
  );
  
  static const LinearGradient timelineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softBlue, softPink, Colors.transparent],
  );
  
  // ==================== 阴影定义 ====================
  
  static List<BoxShadow> get orbShadow => [
    BoxShadow(
      color: softBlue.withValues(alpha: 0.5),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
    const BoxShadow(
      color: Colors.white,
      blurRadius: 30,
      offset: Offset(0, -5),
      blurStyle: BlurStyle.inner,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: softBlue.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: softBlue.withValues(alpha: 0.4),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ==================== 情绪标签颜色 ====================
  
  static const Map<String, Color> emotionColors = {
    'happy': Color(0xFFFFECB3),     // 开心 - 暖黄
    'calm': Color(0xFFB2EBF2),      // 平静 - 天蓝
    'sad': Color(0xFFC5CAE9),       // 忧伤 - 淡紫
    'energetic': Color(0xFFFFCDD2), // 活力 - 粉红
    'nostalgic': Color(0xFFD7CCC8), // 思念 - 米灰
  };
  
  // ==================== 输入类型图标背景 ====================
  
  static const LinearGradient voiceIconGradient = LinearGradient(
    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
  );
  
  static const LinearGradient textIconGradient = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
  );
  
  static const LinearGradient imageIconGradient = LinearGradient(
    colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
  );
  
  // ==================== ThemeData ====================
  
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
      ),
    ),
    // 修复: CardTheme 改为 CardThemeData
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withValues(alpha: 0.9),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: softBlue.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      selectedItemColor: textPrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}