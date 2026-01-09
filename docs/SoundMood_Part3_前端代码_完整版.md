# SoundMood Flutter 前端完整代码

> ⚠️ **重要说明**: 此文档是完整版，包含原文档缺失的所有核心文件：
> - `pubspec.yaml` 依赖配置
> - `main.dart` 入口文件
> - `app_config.dart` 应用配置
> - `theme.dart` 主题配置
> - `models/` 数据模型
> - `services/` API 服务
> - `providers/` 状态管理
> - `screens/` 所有界面
> - `widgets/` 通用组件

---

## 📁 完整目录结构

```
frontend/
├── lib/
│   ├── main.dart                      ← 入口文件
│   ├── config/
│   │   ├── app_config.dart            ← 应用配置
│   │   └── theme.dart                 ← 主题配置
│   ├── models/
│   │   ├── user.dart                  ← 用户模型
│   │   └── music.dart                 ← 音乐模型
│   ├── services/
│   │   └── api_service.dart           ← API 服务
│   ├── providers/
│   │   ├── auth_provider.dart         ← 认证状态
│   │   └── music_provider.dart        ← 音乐状态
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart      ← 登录
│   │   │   └── register_screen.dart   ← 注册
│   │   ├── home/
│   │   │   └── home_screen.dart       ← 主屏幕
│   │   ├── library/
│   │   │   └── library_screen.dart    ← 音乐库
│   │   ├── generate/
│   │   │   ├── generate_screen.dart   ← 创作选择
│   │   │   ├── text_input_screen.dart ← 文字输入
│   │   │   ├── voice_input_screen.dart← 语音输入
│   │   │   └── image_input_screen.dart← 图片输入
│   │   └── profile/
│   │       └── profile_screen.dart    ← 个人中心
│   └── widgets/
│       ├── music_card.dart            ← 音乐卡片
│       └── loading_indicator.dart     ← 加载指示器
├── pubspec.yaml                        ← 依赖配置
└── android/app/src/main/AndroidManifest.xml ← 权限配置
```

---

## 1. 依赖配置

### 文件: `frontend/pubspec.yaml`

```yaml
name: soundmood
description: "SoundMood - AI 音乐生成应用"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter

  # UI 相关
  cupertino_icons: ^1.0.8
  
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

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
```

### 创建资源目录

```bash
# 在 frontend 目录下执行
mkdir -p assets/images
```

---

## 2. 入口文件

### 文件: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/music_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: MaterialApp(
        title: 'SoundMood',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
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
        // 检查登录状态
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
```

---

## 3. 配置文件

### 文件: `lib/config/app_config.dart`

```dart
/// 应用配置
class AppConfig {
  // API 配置
  static const String baseUrl = 'http://10.0.2.2:8000';  // Android 模拟器
  // static const String baseUrl = 'http://localhost:8000';  // iOS 模拟器/Web
  // static const String baseUrl = 'http://192.168.1.100:8000';  // 真机测试（改成你的电脑IP）
  
  // 音乐生成配置
  static const int defaultDuration = 30;
  static const int minDuration = 15;
  static const int maxDuration = 120;
  
  // 存储 Key
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // 请求超时
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;
}
```

### 文件: `lib/config/theme.dart`

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFEC4899);
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF0F172A);
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  
  // 渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
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
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
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
  );

  // 深色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: darkBackgroundColor,
      foregroundColor: textPrimaryDark,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: darkSurfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondaryDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondaryDark,
      ),
    ),
  );
}
```

---

## 4. 数据模型

### 文件: `lib/models/user.dart`

```dart
class User {
  final int id;
  final String email;
  final String username;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### 文件: `lib/models/music.dart`

```dart
enum InputType { voice, text, image }

enum MusicStatus { generating, completed, failed }

class Music {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final InputType inputType;
  final String? inputContent;
  final List<String>? emotionTags;
  final String? aiAnalysis;
  final String musicUrl;
  final String musicFormat;
  final int duration;
  final int fileSize;
  final int bpm;
  final String? genre;
  final List<String>? instruments;
  final MusicStatus status;
  final bool isPublic;
  final int playCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Music({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.inputType,
    this.inputContent,
    this.emotionTags,
    this.aiAnalysis,
    required this.musicUrl,
    required this.musicFormat,
    required this.duration,
    required this.fileSize,
    required this.bpm,
    this.genre,
    this.instruments,
    required this.status,
    required this.isPublic,
    required this.playCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      inputType: _parseInputType(json['input_type']),
      inputContent: json['input_content'],
      emotionTags: json['emotion_tags'] != null
          ? List<String>.from(json['emotion_tags'])
          : null,
      aiAnalysis: json['ai_analysis'],
      musicUrl: json['music_url'] ?? '',
      musicFormat: json['music_format'] ?? 'mp3',
      duration: json['duration'] ?? 0,
      fileSize: json['file_size'] ?? 0,
      bpm: json['bpm'] ?? 120,
      genre: json['genre'],
      instruments: json['instruments'] != null
          ? List<String>.from(json['instruments'])
          : null,
      status: _parseStatus(json['status']),
      isPublic: json['is_public'] ?? false,
      playCount: json['play_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static InputType _parseInputType(String? type) {
    switch (type) {
      case 'voice':
        return InputType.voice;
      case 'text':
        return InputType.text;
      case 'image':
        return InputType.image;
      default:
        return InputType.text;
    }
  }

  static MusicStatus _parseStatus(String? status) {
    switch (status) {
      case 'generating':
        return MusicStatus.generating;
      case 'completed':
        return MusicStatus.completed;
      case 'failed':
        return MusicStatus.failed;
      default:
        return MusicStatus.generating;
    }
  }
}
```

---

## 5. API 服务

### 文件: `lib/services/api_service.dart`

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/music.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _token;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证 token
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        print('📤 ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ${error.response?.statusCode} ${error.message}');
        return handler.next(error);
      },
    ));
    
    // 加载保存的 token
    _loadToken();
  }
  
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
  }
  
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }
  
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
  }
  
  bool get hasToken => _token != null;

  // ============= 认证接口 =============
  
  /// 注册
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _dio.post('/api/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    return response.data;
  }
  
  /// 登录
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
  
  /// 获取当前用户信息
  Future<User> getCurrentUser() async {
    final response = await _dio.get('/api/auth/me');
    return User.fromJson(response.data);
  }

  // ============= 音乐接口 =============
  
  /// 获取音乐列表
  Future<List<Music>> getMusics({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/api/music/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    final List<dynamic> items = response.data['items'];
    return items.map((item) => Music.fromJson(item)).toList();
  }
  
  /// 获取音乐详情
  Future<Music> getMusic(int id) async {
    final response = await _dio.get('/api/music/$id');
    return Music.fromJson(response.data);
  }
  
  /// 删除音乐
  Future<void> deleteMusic(int id) async {
    await _dio.delete('/api/music/$id');
  }

  // ============= 生成接口 =============
  
  /// 从文本生成音乐
  Future<Music> generateFromText({
    required String title,
    required String text,
    required int duration,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'text': text,
      'duration': duration,
    });
    final response = await _dio.post('/api/generate/text', data: formData);
    return Music.fromJson(response.data);
  }
  
  /// 从语音生成音乐
  Future<Music> generateFromVoice({
    required String title,
    required File audioFile,
    required int duration,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
      'duration': duration,
    });
    final response = await _dio.post('/api/generate/voice', data: formData);
    return Music.fromJson(response.data);
  }
  
  /// 从图片生成音乐
  Future<Music> generateFromImage({
    required String title,
    required File imageFile,
    required int duration,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'duration': duration,
    });
    final response = await _dio.post('/api/generate/image', data: formData);
    return Music.fromJson(response.data);
  }
  
  /// 查询生成状态
  Future<Music> getGenerationStatus(int musicId) async {
    final response = await _dio.get('/api/generate/status/$musicId');
    return Music.fromJson(response.data);
  }
}
```

---

## 6. 状态管理 (Providers)

### 文件: `lib/providers/auth_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // 尝试恢复登录状态
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    if (_apiService.hasToken) {
      try {
        _user = await _apiService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        // Token 无效，清除
        await _apiService.clearToken();
      }
    }
  }

  /// 注册
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        email: email,
        username: username,
        password: password,
      );
      
      // 保存 token
      await _apiService.setToken(response['access_token']);
      
      // 解析用户信息
      _user = User.fromJson(response['user']);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      // 保存 token
      await _apiService.setToken(response['access_token']);
      
      // 解析用户信息
      _user = User.fromJson(response['user']);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    await _apiService.clearToken();
    _user = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('400')) {
      return '该邮箱已被注册';
    } else if (e.toString().contains('401')) {
      return '邮箱或密码错误';
    } else if (e.toString().contains('SocketException')) {
      return '网络连接失败，请检查网络';
    }
    return '操作失败，请重试';
  }
}
```

### 文件: `lib/providers/music_provider.dart`

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/music.dart';

class MusicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Music> _musics = [];
  bool _isLoading = false;
  String? _error;
  
  List<Music> get musics => _musics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载音乐列表
  Future<void> loadMusics({bool refresh = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _musics = await _apiService.getMusics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 从文本生成
  Future<Music?> generateFromText({
    required String title,
    required String text,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromText(
        title: title,
        text: text,
        duration: duration,
      );
      
      // 添加到列表开头
      _musics.insert(0, music);
      notifyListeners();
      
      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 从语音生成
  Future<Music?> generateFromVoice({
    required String title,
    required File audioFile,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromVoice(
        title: title,
        audioFile: audioFile,
        duration: duration,
      );
      
      _musics.insert(0, music);
      notifyListeners();
      
      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 从图片生成
  Future<Music?> generateFromImage({
    required String title,
    required File imageFile,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromImage(
        title: title,
        imageFile: imageFile,
        duration: duration,
      );
      
      _musics.insert(0, music);
      notifyListeners();
      
      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 删除音乐
  Future<bool> deleteMusic(int id) async {
    try {
      await _apiService.deleteMusic(id);
      _musics.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除失败';
      notifyListeners();
      return false;
    }
  }

  /// 刷新单个音乐状态
  Future<void> refreshMusicStatus(int id) async {
    try {
      final music = await _apiService.getGenerationStatus(id);
      final index = _musics.indexWhere((m) => m.id == id);
      if (index != -1) {
        _musics[index] = music;
        notifyListeners();
      }
    } catch (e) {
      // 忽略错误
    }
  }
}
```

---

## 7. 界面 - 登录注册

### 文件: `lib/screens/auth/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '登录失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo 和标题
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SoundMood',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '用 AI 创作属于你的音乐',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // 邮箱输入
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 密码输入
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // 登录按钮
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('登录'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // 注册链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('立即注册'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 文件: `lib/screens/auth/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('两次输入的密码不一致'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '注册失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  '创建账号',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '填写以下信息开始创作',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // 邮箱
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 用户名
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '设置一个用户名',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (value.length < 2) {
                      return '用户名至少 2 个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 密码
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '至少 6 位',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码至少 6 位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 确认密码
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '再次输入密码',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请再次输入密码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // 注册按钮
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('注册'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 8. 界面 - 主屏幕

### 文件: `lib/screens/home/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../library/library_screen.dart';
import '../generate/generate_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    GenerateScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              activeIcon: Icon(Icons.library_music),
              label: '音乐库',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: '创作',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. 界面 - 音乐库

### 文件: `lib/screens/library/library_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_provider.dart';
import '../../widgets/music_card.dart';
import '../../widgets/loading_indicator.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MusicProvider>().loadMusics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MusicProvider>().loadMusics(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, _) {
          if (musicProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (musicProvider.musics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有音乐作品',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击 "创作" 开始生成你的第一首音乐',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => musicProvider.loadMusics(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: musicProvider.musics.length,
              itemBuilder: (context, index) {
                final music = musicProvider.musics[index];
                return MusicCard(music: music);
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 10. 界面 - 创作

### 文件: `lib/screens/generate/generate_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'text_input_screen.dart';
import 'voice_input_screen.dart';
import 'image_input_screen.dart';

class GenerateScreen extends StatelessWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 音乐创作'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '选择创作方式',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '从文字、语音或图片生成独特的音乐',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 文字输入
            _GenerateMethodCard(
              title: '文字描述',
              subtitle: '用文字描述你的情感或场景',
              icon: Icons.text_fields_rounded,
              gradient: AppTheme.primaryGradient,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TextInputScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 语音输入
            _GenerateMethodCard(
              title: '语音录制',
              subtitle: '说出你的感受，让AI理解你的情绪',
              icon: Icons.mic_rounded,
              gradient: AppTheme.secondaryGradient,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 图片输入
            _GenerateMethodCard(
              title: '图片灵感',
              subtitle: '上传图片，AI 将捕捉其中的情感',
              icon: Icons.image_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImageInputScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GenerateMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
```

### 文件: `lib/screens/generate/text_input_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  int _duration = AppConfig.defaultDuration;
  bool _isGenerating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromText(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (music != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音乐生成已开始，请稍候...'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(musicProvider.error ?? '生成失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文字创作')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '音乐标题',
                  hintText: '给你的音乐起个名字',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入标题';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '情感描述',
                  hintText: '描述你的情感、心情或想要的场景...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入描述';
                  if (value.length < 10) return '描述至少 10 个字符';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                '音乐时长: $_duration 秒',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _duration.toDouble(),
                min: AppConfig.minDuration.toDouble(),
                max: AppConfig.maxDuration.toDouble(),
                divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
                label: '$_duration 秒',
                onChanged: (value) => setState(() => _duration = value.toInt()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isGenerating ? null : _handleGenerate,
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始生成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 文件: `lib/screens/generate/voice_input_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recorder = AudioRecorder();
  
  int _duration = AppConfig.defaultDuration;
  bool _isRecording = false;
  bool _isGenerating = false;
  String? _recordedPath;

  @override
  void dispose() {
    _titleController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 停止录音
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } else {
      // 开始录音
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        setState(() => _isRecording = true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要麦克风权限'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_recordedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先录制语音'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromVoice(
      title: _titleController.text.trim(),
      audioFile: File(_recordedPath!),
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (music != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音乐生成已开始，请稍候...'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(musicProvider.error ?? '生成失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('语音创作')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '音乐标题',
                  hintText: '给你的音乐起个名字',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入标题';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // 录音按钮
              Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isRecording
                          ? AppTheme.secondaryGradient
                          : AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor)
                              .withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? '录音中...点击停止'
                    : (_recordedPath != null ? '录音完成 ✓' : '点击开始录音'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              Text(
                '音乐时长: $_duration 秒',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _duration.toDouble(),
                min: AppConfig.minDuration.toDouble(),
                max: AppConfig.maxDuration.toDouble(),
                divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
                label: '$_duration 秒',
                onChanged: (value) => setState(() => _duration = value.toInt()),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: (_isGenerating || _isRecording) ? null : _handleGenerate,
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始生成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 文件: `lib/screens/generate/image_input_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';

class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({super.key});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _picker = ImagePicker();
  
  int _duration = AppConfig.defaultDuration;
  bool _isGenerating = false;
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择图片'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromImage(
      title: _titleController.text.trim(),
      imageFile: _selectedImage!,
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (music != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音乐生成已开始，请稍候...'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(musicProvider.error ?? '生成失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片创作')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '音乐标题',
                  hintText: '给你的音乐起个名字',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入标题';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // 图片选择
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 48,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击选择图片',
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                '音乐时长: $_duration 秒',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _duration.toDouble(),
                min: AppConfig.minDuration.toDouble(),
                max: AppConfig.maxDuration.toDouble(),
                divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
                label: '$_duration 秒',
                onChanged: (value) => setState(() => _duration = value.toInt()),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isGenerating ? null : _handleGenerate,
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始生成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 11. 界面 - 个人中心

### 文件: `lib/screens/profile/profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 头像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user?.username.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 用户名
                Text(
                  user?.username ?? '用户',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                
                // 菜单列表
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: '设置',
                  onTap: () {
                    // TODO: 设置页面
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {
                    // TODO: 帮助页面
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: '关于',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'SoundMood',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 SoundMood',
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // 退出登录
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('退出登录'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

---

## 12. 通用组件

### 文件: `lib/widgets/music_card.dart`

```dart
import 'package:flutter/material.dart';
import '../models/music.dart';
import '../config/theme.dart';

class MusicCard extends StatelessWidget {
  final Music music;

  const MusicCard({super.key, required this.music});

  String _getStatusText() {
    switch (music.status) {
      case MusicStatus.generating:
        return '生成中...';
      case MusicStatus.completed:
        return '已完成';
      case MusicStatus.failed:
        return '生成失败';
    }
  }

  Color _getStatusColor() {
    switch (music.status) {
      case MusicStatus.generating:
        return AppTheme.accentColor;
      case MusicStatus.completed:
        return Colors.green;
      case MusicStatus.failed:
        return Colors.red;
    }
  }

  IconData _getInputTypeIcon() {
    switch (music.inputType) {
      case InputType.voice:
        return Icons.mic_rounded;
      case InputType.text:
        return Icons.text_fields_rounded;
      case InputType.image:
        return Icons.image_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: music.status == MusicStatus.completed
            ? () {
                // TODO: 播放音乐
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getInputTypeIcon(),
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${music.duration}s',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (music.status == MusicStatus.completed)
                    const Icon(Icons.play_circle_filled, 
                      color: AppTheme.primaryColor, 
                      size: 40,
                    ),
                ],
              ),
              if (music.emotionTags != null && music.emotionTags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: music.emotionTags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 文件: `lib/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }
}
```

---

## 13. 权限配置 (Android)

### 文件: `android/app/src/main/AndroidManifest.xml`

在 `<manifest>` 标签内添加权限：

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

---

## 14. 快速启动

### 14.1 安装依赖

```bash
cd frontend
flutter pub get
```

### 14.2 创建目录结构

```bash
mkdir -p lib/config lib/models lib/services lib/providers
mkdir -p lib/screens/auth lib/screens/home lib/screens/library
mkdir -p lib/screens/generate lib/screens/profile lib/widgets
mkdir -p assets/images
```

### 14.3 运行应用

```bash
# 确保后端已启动 (http://localhost:8000)

# Web 测试
flutter run -d chrome

# Android 测试
flutter run -d android
```

---

## ✅ 完整文件清单

| 文件路径 | 状态 |
|---------|------|
| `pubspec.yaml` | ✅ |
| `lib/main.dart` | ✅ |
| `lib/config/app_config.dart` | ✅ |
| `lib/config/theme.dart` | ✅ |
| `lib/models/user.dart` | ✅ |
| `lib/models/music.dart` | ✅ |
| `lib/services/api_service.dart` | ✅ |
| `lib/providers/auth_provider.dart` | ✅ |
| `lib/providers/music_provider.dart` | ✅ |
| `lib/screens/auth/login_screen.dart` | ✅ |
| `lib/screens/auth/register_screen.dart` | ✅ |
| `lib/screens/home/home_screen.dart` | ✅ |
| `lib/screens/library/library_screen.dart` | ✅ |
| `lib/screens/generate/generate_screen.dart` | ✅ |
| `lib/screens/generate/text_input_screen.dart` | ✅ |
| `lib/screens/generate/voice_input_screen.dart` | ✅ |
| `lib/screens/generate/image_input_screen.dart` | ✅ |
| `lib/screens/profile/profile_screen.dart` | ✅ |
| `lib/widgets/music_card.dart` | ✅ |
| `lib/widgets/loading_indicator.dart` | ✅ |

---

**文档版本**: 完整版 2.0  
**更新日期**: 2025年1月
