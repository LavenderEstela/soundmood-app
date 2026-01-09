# SoundMood Flutter 完整实现 - Part 1

## 项目配置与主题系统

> 🎨 **本部分包含**：
> - `pubspec.yaml` 依赖配置
> - 双主题系统（云端 Cloud / 星际 Space）
> - 主题切换 Provider
> - 应用入口配置

---

## 📁 完整目录结构

```
lib/
├── main.dart                           # 入口文件
├── config/
│   ├── app_config.dart                 # 应用配置
│   └── themes/
│       ├── app_theme.dart              # 主题管理
│       ├── cloud_theme.dart            # 云端主题
│       └── space_theme.dart            # 星际主题
├── models/
│   ├── user.dart                       # 用户模型
│   ├── music.dart                      # 音乐模型
│   └── journal_entry.dart              # 日记条目模型
├── services/
│   └── api_service.dart                # API 服务
├── providers/
│   ├── auth_provider.dart              # 认证状态
│   ├── music_provider.dart             # 音乐状态
│   └── theme_provider.dart             # 主题状态
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           # 登录
│   │   └── register_screen.dart        # 注册
│   ├── main/
│   │   └── main_screen.dart            # 主容器（带底部导航）
│   ├── create/
│   │   ├── create_screen.dart          # 创作主页（灵感球）
│   │   ├── text_input_screen.dart      # 文字输入
│   │   ├── voice_input_screen.dart     # 语音输入
│   │   ├── image_input_screen.dart     # 图片输入
│   │   └── generating_screen.dart      # 生成动画页
│   ├── journal/
│   │   └── journal_screen.dart         # 时间轨迹日记页
│   ├── collection/
│   │   └── collection_screen.dart      # 收藏（黑胶唱片）
│   └── player/
│       └── player_screen.dart          # 播放页
└── widgets/
    ├── backgrounds/
    │   ├── cloud_background.dart       # 云端背景
    │   └── space_background.dart       # 星际背景
    ├── orb/
    │   ├── inspiration_orb.dart        # 灵感球
    │   ├── cloud_orb.dart              # 云朵灵感球
    │   └── space_orb.dart              # 星球灵感球
    ├── vinyl/
    │   ├── vinyl_player.dart           # 黑胶播放器
    │   └── vinyl_sleeve.dart           # 黑胶唱片套
    ├── journal/
    │   ├── timeline_entry.dart         # 时间线条目
    │   └── emotion_filter.dart         # 情绪筛选器
    ├── common/
    │   ├── mood_bubble.dart            # 心情气泡
    │   ├── glass_card.dart             # 毛玻璃卡片
    │   └── themed_button.dart          # 主题按钮
    └── animations/
        ├── film_strip_animation.dart   # 胶片动画
        └── wave_visualizer.dart        # 波形可视化
```

---

## 1. 依赖配置

### 文件: `pubspec.yaml`

```yaml
name: soundmood
description: "SoundMood - AI 音乐情绪日记"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter

  # UI 相关
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0
  
  # 状态管理
  provider: ^6.1.2
  
  # 网络请求
  dio: ^5.4.0
  
  # 本地存储
  shared_preferences: ^2.2.2
  
  # 音频播放
  just_audio: ^0.9.36
  
  # 文件选择
  image_picker: ^1.0.7
  file_picker: ^6.1.1
  
  # 录音
  record: ^5.0.4
  path_provider: ^2.1.2
  
  # 权限管理
  permission_handler: ^11.3.0
  
  # 动画
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  
  # 日期处理
  intl: ^0.19.0
  
  # 缓存图片
  cached_network_image: ^3.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/animations/
    
  fonts:
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Regular.ttf
        - asset: assets/fonts/Nunito-Medium.ttf
          weight: 500
        - asset: assets/fonts/Nunito-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
```

---

## 2. 应用配置

### 文件: `lib/config/app_config.dart`

```dart
/// 应用配置
class AppConfig {
  // API 配置
  static const String baseUrl = 'http://10.0.2.2:8000';  // Android 模拟器
  // static const String baseUrl = 'http://localhost:8000';  // iOS 模拟器/Web
  // static const String baseUrl = 'http://192.168.1.100:8000';  // 真机测试

  // 音乐生成配置
  static const int defaultDuration = 30;
  static const int minDuration = 15;
  static const int maxDuration = 120;

  // 存储 Key
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // 请求超时
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;
}
```

---

## 3. 主题系统

### 文件: `lib/config/themes/cloud_theme.dart`

```dart
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
      color: softBlue.withOpacity(0.5),
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
      color: softBlue.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: softBlue.withOpacity(0.4),
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
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.9),
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
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: softBlue.withOpacity(0.3)),
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
      backgroundColor: Colors.white.withOpacity(0.95),
      selectedItemColor: textPrimary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
```

### 文件: `lib/config/themes/space_theme.dart`

```dart
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
      color: primary.withOpacity(0.9),
      blurRadius: 80,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: secondary.withOpacity(0.5),
      blurRadius: 160,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 0),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: accent.withOpacity(0.6),
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
    cardTheme: CardTheme(
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
        borderSide: BorderSide(color: primary.withOpacity(0.2)),
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
      backgroundColor: const Color(0xE6141428),
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
```

### 文件: `lib/config/themes/app_theme.dart`

```dart
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
        return Colors.white.withOpacity(0.9);
      case AppThemeType.space:
        return const Color(0xCC141428);
    }
  }
  
  /// 获取卡片边框色
  static Color getCardBorder(AppThemeType type) {
    switch (type) {
      case AppThemeType.cloud:
        return CloudTheme.softBlue.withOpacity(0.3);
      case AppThemeType.space:
        return SpaceTheme.primary.withOpacity(0.2);
    }
  }
}
```

---

## 4. 主题状态管理

### 文件: `lib/providers/theme_provider.dart`

```dart
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
```

---

## 5. 入口文件

### 文件: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/themes/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/music_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const SoundMoodApp());
}

class SoundMoodApp extends StatelessWidget {
  const SoundMoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // 根据主题更新状态栏图标颜色
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeProvider.isCloudTheme 
                  ? Brightness.dark 
                  : Brightness.light,
            ),
          );
          
          return MaterialApp(
            title: 'SoundMood',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(themeProvider.currentTheme),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

/// 根据登录状态显示不同界面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
```

---

## 📝 Part 1 完成

本部分包含了项目的基础配置和完整的双主题系统。接下来的 Part 2 将包含：

- 数据模型（User, Music, JournalEntry）
- API 服务
- 认证和音乐 Provider

请继续查看 Part 2...
