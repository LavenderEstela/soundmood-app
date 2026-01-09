import 'package:flutter/material.dart';

/// 主题模式枚举
enum AppThemeMode { cloud, space }

/// SoundMood 主题配置
class AppTheme {
  // ==================== 云端主题 (Cloud Drift) ====================
  // 视觉感受：轻盈、治愈、柔软、呼吸感
  
  static const Color cloudWhite = Color(0xFFFFFFFF);
  static const Color cloudSky = Color(0xFFE0F7FA);
  static const Color cloudPink = Color(0xFFFFE4E6);
  static const Color cloudPeach = Color(0xFFFFECD2);
  static const Color cloudBlue = Color(0xFFB2EBF2);
  static const Color cloudMint = Color(0xFFE8F5E9);
  static const Color cloudText = Color(0xFF5D6D7E);
  static const Color cloudTextLight = Color(0xFF95A5A6);
  static const Color cloudTextDark = Color(0xFF2C3E50);
  static const Color cloudAccent = Color(0xFF80DEEA);
  static const Color cloudGlow = Color(0x66B2EBF2);

  // 云端渐变
  static const LinearGradient cloudGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cloudSky, cloudMint, cloudPeach, cloudWhite],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient cloudOrbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cloudBlue, cloudPink],
  );

  static const LinearGradient cloudButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cloudBlue, cloudPink],
  );

  // ==================== 星际主题 (Interstellar) ====================
  // 视觉感受：深邃、沉浸、科技、神秘
  
  static const Color spaceBlack = Color(0xFF0A0A12);
  static const Color spaceDeep = Color(0xFF050508);
  static const Color spaceDark = Color(0xFF0F0F1A);
  static const Color spaceGold = Color(0xFFFFD700);
  static const Color spaceAurora = Color(0xFF7B68EE);
  static const Color spacePurple = Color(0xFF9D4EDD);
  static const Color spaceCyan = Color(0xFF00FFFF);
  static const Color spacePink = Color(0xFFFF6B9D);
  static const Color spaceBlue = Color(0xFF4169E1);
  static const Color spaceText = Color(0xFFE8E8F0);
  static const Color spaceTextDim = Color(0xFF6B6B80);
  static const Color spaceGlow = Color(0x999D4EDD);
  static const Color spaceCard = Color(0xFF14142A);
  static const Color spaceSurface = Color(0xFF1E1E32);

  // 星际渐变
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [spaceDeep, spaceBlack, spaceDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient spaceOrbGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [spacePurple, spaceAurora],
  );

  static const LinearGradient spaceButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [spacePurple, spaceGold],
  );

  static const LinearGradient nebulaGradient1 = LinearGradient(
    colors: [Color(0x669D4EDD), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nebulaGradient2 = LinearGradient(
    colors: [Color(0x664169E1), Colors.transparent],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0x1A7B68EE),
      Color(0x269348DB),
      Color(0x1ABA55D3),
      Color(0x1A00FFFF),
      Colors.transparent,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== 主题数据 ====================

  /// 云端主题 ThemeData
  static ThemeData cloudTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: cloudBlue,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cloudBlue,
      brightness: Brightness.light,
      surface: cloudWhite,
      onSurface: cloudText,
    ),
    fontFamily: 'NunitoSans',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: cloudText,
      titleTextStyle: TextStyle(
        color: cloudText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NunitoSans',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cloudWhite.withOpacity(0.9),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: cloudBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NunitoSans',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cloudWhite.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cloudBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: cloudBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: cloudTextDark),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: cloudTextDark),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cloudText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cloudText),
      bodyLarge: TextStyle(fontSize: 16, color: cloudText),
      bodyMedium: TextStyle(fontSize: 14, color: cloudTextLight),
      bodySmall: TextStyle(fontSize: 12, color: cloudTextLight),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: cloudBlue,
      unselectedItemColor: cloudTextLight,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// 星际主题 ThemeData
  static ThemeData spaceTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: spacePurple,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: spacePurple,
      brightness: Brightness.dark,
      surface: spaceCard,
      onSurface: spaceText,
    ),
    fontFamily: 'NunitoSans',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: spaceText,
      titleTextStyle: TextStyle(
        color: spaceText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'NunitoSans',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: spaceCard.withOpacity(0.8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: spacePurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NunitoSans',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: spaceCard.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: spacePurple.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: spacePurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: spaceText),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: spaceText),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: spaceText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: spaceText),
      bodyLarge: TextStyle(fontSize: 16, color: spaceText),
      bodyMedium: TextStyle(fontSize: 14, color: spaceTextDim),
      bodySmall: TextStyle(fontSize: 12, color: spaceTextDim),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: spaceGold,
      unselectedItemColor: spaceTextDim,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // ==================== 辅助方法 ====================

  /// 获取当前主题的主色
  static Color getPrimaryColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudBlue : spacePurple;
  }

  /// 获取当前主题的强调色
  static Color getAccentColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudPink : spaceGold;
  }

  /// 获取当前主题的文字颜色
  static Color getTextColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudText : spaceText;
  }

  /// 获取当前主题的次要文字颜色
  static Color getSecondaryTextColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudTextLight : spaceTextDim;
  }

  /// 获取当前主题的卡片颜色
  static Color getCardColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudWhite.withOpacity(0.9) : spaceCard.withOpacity(0.8);
  }

  /// 获取当前主题的背景渐变
  static LinearGradient getBackgroundGradient(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudGradient : spaceGradient;
  }

  /// 获取当前主题的按钮渐变
  static LinearGradient getButtonGradient(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudButtonGradient : spaceButtonGradient;
  }

  /// 获取当前主题的发光颜色
  static Color getGlowColor(AppThemeMode mode) {
    return mode == AppThemeMode.cloud ? cloudGlow : spaceGlow;
  }

  /// 获取情绪标签颜色
  static Color getEmotionColor(String emotion, AppThemeMode mode) {
    final Map<String, Color> cloudColors = {
      '开心': const Color(0xFFFFECB3),
      '平静': const Color(0xFFB2EBF2),
      '忧伤': const Color(0xFFC5CAE9),
      '活力': const Color(0xFFFFCDD2),
      '思念': const Color(0xFFE1BEE7),
      '温暖': const Color(0xFFFFE0B2),
      '庆祝': const Color(0xFFF8BBD9),
      '宁静': const Color(0xFFB2DFDB),
    };

    final Map<String, Color> spaceColors = {
      '开心': const Color(0x4DFFD700),
      '平静': const Color(0x4D4169E1),
      '忧伤': const Color(0x4D7B68EE),
      '活力': const Color(0x4DFF6B9D),
      '思念': const Color(0x4D9D4EDD),
      '温暖': const Color(0x4DFFA500),
      '庆祝': const Color(0x4DFF69B4),
      '宁静': const Color(0x4D00CED1),
    };

    final colors = mode == AppThemeMode.cloud ? cloudColors : spaceColors;
    return colors[emotion] ?? (mode == AppThemeMode.cloud ? cloudBlue.withOpacity(0.3) : spacePurple.withOpacity(0.3));
  }
}