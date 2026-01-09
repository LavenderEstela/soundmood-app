import 'package:flutter/material.dart';

/// 星际主题 - 神秘梦幻
class SpaceTheme {
  // ==================== 颜色定义 ====================
  
  // 背景色
  static const Color backgroundColor = Color(0xFF0A0A12);
  static const Color deepSpace = Color(0xFF050508);
  static const Color darkPurple = Color(0xFF0F0F1A);
  
  // 主色调
  static const Color primary = Color(0xFF9D4EDD);       // 极光紫
  static const Color secondary = Color(0xFF7B68EE);     // 星云紫
  static const Color accent = Color(0xFFFFD700);        // 星光金
  
  // 辅助色
  static const Color cyan = Color(0xFF00FFFF);          // 青色
  static const Color pink = Color(0xFFFF6B9D);          // 粉红
  static const Color blue = Color(0xFF4169E1);          // 皇家蓝
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF6B6B80);
  
  // ==================== 渐变定义 ====================
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepSpace, backgroundColor, darkPurple],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const RadialGradient nebulaGradient1 = RadialGradient(
    center: Alignment(0.6, -0.4),
    radius: 0.8,
    colors: [
      Color(0x669D4EDD),
      Colors.transparent,
    ],
  );
  
  static const RadialGradient nebulaGradient2 = RadialGradient(
    center: Alignment(-0.5, 0.6),
    radius: 0.7,
    colors: [
      Color(0x594169E1),
      Colors.transparent,
    ],
  );
  
  static const RadialGradient nebulaGradient3 = RadialGradient(
    center: Alignment(0.0, 0.0),
    radius: 0.6,
    colors: [
      Color(0x40FF6B9D),
      Colors.transparent,
    ],
  );
  
  static const LinearGradient orbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x669D4EDD),
      Color(0x994B0082),
      Color(0xFF0A0A15),
    ],
    stops: [0.0, 0.3, 1.0],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFFA500)],
  );
  
  static const LinearGradient timelineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, accent, Colors.transparent],
  );
  
  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A7B68EE),
      Color(0x269370DB),
      Color(0x1ABA55D3),
      Color(0x26EE82EE),
      Color(0x1A9370DB),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  // ==================== 阴影定义 ====================
  
  static List<BoxShadow> get orbShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.9),
      blurRadius: 80,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: secondary.withValues(alpha: 0.5),
      blurRadius: 160,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 0),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: accent.withValues(alpha: 0.6),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];
  
  // ==================== 情绪标签颜色 ====================
  
  static const Map<String, Color> emotionColors = {
    'happy': Color(0x4DFFD700),     // 开心 - 金色
    'calm': Color(0x4D4169E1),      // 平静 - 蓝色
    'sad': Color(0x4D7B68EE),       // 忧伤 - 紫色
    'energetic': Color(0x4DFF6B9D), // 活力 - 粉色
    'nostalgic': Color(0x4D00FFFF), // 思念 - 青色
  };
  
  // ==================== 输入类型图标背景 ====================
  
  static const LinearGradient voiceIconGradient = LinearGradient(
    colors: [Color(0x4D00FFFF), Color(0x4D4169E1)],
  );
  
  static const LinearGradient textIconGradient = LinearGradient(
    colors: [Color(0x4DFFD700), Color(0x4DFFA500)],
  );
  
  static const LinearGradient imageIconGradient = LinearGradient(
    colors: [Color(0x4DFF6B9D), Color(0x4D9D4EDD)],
  );
  
  // ==================== ThemeData ====================
  
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
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
      color: const Color(0xCC141428),
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
      fillColor: const Color(0xFF1E1E32),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xE6141428),
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}