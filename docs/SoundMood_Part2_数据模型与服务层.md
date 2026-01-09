# SoundMood Flutter 完整实现 - Part 2

## 数据模型与服务层

> 🔧 **本部分包含**：
> - 数据模型（User, Music, JournalEntry）
> - API 服务（包含日记相关新接口）
> - 认证 Provider
> - 音乐 Provider

---

## 1. 数据模型

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
  final String? inputContent;     // 文字内容或语音转文字
  final String? inputImageUrl;    // 图片URL（如果是图片输入）
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
  final bool isFavorite;          // 是否收藏
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
    this.inputImageUrl,
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
    this.isFavorite = false,
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
      inputImageUrl: json['input_image_url'],
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
      isFavorite: json['is_favorite'] ?? false,
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

  String get inputTypeString {
    switch (inputType) {
      case InputType.voice:
        return 'voice';
      case InputType.text:
        return 'text';
      case InputType.image:
        return 'image';
    }
  }

  String get inputTypeIcon {
    switch (inputType) {
      case InputType.voice:
        return '🎤';
      case InputType.text:
        return '✍️';
      case InputType.image:
        return '🖼️';
    }
  }

  String get inputTypeLabel {
    switch (inputType) {
      case InputType.voice:
        return '语音';
      case InputType.text:
        return '文字';
      case InputType.image:
        return '图片';
    }
  }

  String get durationString {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get primaryEmotion {
    if (emotionTags != null && emotionTags!.isNotEmpty) {
      return emotionTags!.first;
    }
    return 'calm';
  }

  Music copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    InputType? inputType,
    String? inputContent,
    String? inputImageUrl,
    List<String>? emotionTags,
    String? aiAnalysis,
    String? musicUrl,
    String? musicFormat,
    int? duration,
    int? fileSize,
    int? bpm,
    String? genre,
    List<String>? instruments,
    MusicStatus? status,
    bool? isPublic,
    bool? isFavorite,
    int? playCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Music(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      inputType: inputType ?? this.inputType,
      inputContent: inputContent ?? this.inputContent,
      inputImageUrl: inputImageUrl ?? this.inputImageUrl,
      emotionTags: emotionTags ?? this.emotionTags,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      musicUrl: musicUrl ?? this.musicUrl,
      musicFormat: musicFormat ?? this.musicFormat,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      bpm: bpm ?? this.bpm,
      genre: genre ?? this.genre,
      instruments: instruments ?? this.instruments,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### 文件: `lib/models/journal_entry.dart`

```dart
import 'music.dart';

/// 日记条目模型 - 用于时间轨迹页面
class JournalEntry {
  final int id;
  final Music music;
  final DateTime date;
  
  JournalEntry({
    required this.id,
    required this.music,
    required this.date,
  });
  
  factory JournalEntry.fromMusic(Music music) {
    return JournalEntry(
      id: music.id,
      music: music,
      date: music.createdAt,
    );
  }
  
  /// 获取日期字符串 (用于分组)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 获取友好的日期显示
  String get friendlyDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference 天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
  
  /// 获取时间字符串
  String get timeString {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// 按日期分组的日记
class JournalGroup {
  final String dateKey;
  final String displayDate;
  final List<JournalEntry> entries;
  
  JournalGroup({
    required this.dateKey,
    required this.displayDate,
    required this.entries,
  });
  
  int get count => entries.length;
}

/// 日记统计数据
class JournalStats {
  final int totalCount;
  final int monthCount;
  final int totalListenTime; // 秒
  
  JournalStats({
    required this.totalCount,
    required this.monthCount,
    required this.totalListenTime,
  });
  
  String get listenTimeString {
    final hours = totalListenTime ~/ 3600;
    final minutes = (totalListenTime % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours 小时';
    }
    return '$minutes 分钟';
  }
}
```

---

## 2. API 服务

### 文件: `lib/services/api_service.dart`

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/music.dart';
import '../models/journal_entry.dart';

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
  Future<List<Music>> getMusics({
    int skip = 0,
    int limit = 20,
    String? emotion,
    bool? isFavorite,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (emotion != null) queryParams['emotion'] = emotion;
    if (isFavorite != null) queryParams['is_favorite'] = isFavorite;

    final response = await _dio.get('/api/music/', queryParameters: queryParams);
    final List<dynamic> items = response.data['items'];
    return items.map((item) => Music.fromJson(item)).toList();
  }

  /// 获取收藏音乐列表
  Future<List<Music>> getFavoriteMusics({int skip = 0, int limit = 20}) async {
    return getMusics(skip: skip, limit: limit, isFavorite: true);
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

  /// 切换收藏状态
  Future<Music> toggleFavorite(int id) async {
    final response = await _dio.post('/api/music/$id/favorite');
    return Music.fromJson(response.data);
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

  // ============= 日记/统计接口 =============

  /// 获取日记统计
  Future<JournalStats> getJournalStats() async {
    try {
      final response = await _dio.get('/api/music/stats');
      return JournalStats(
        totalCount: response.data['total_count'] ?? 0,
        monthCount: response.data['month_count'] ?? 0,
        totalListenTime: response.data['total_listen_time'] ?? 0,
      );
    } catch (e) {
      // 如果接口不存在，使用本地计算
      return JournalStats(totalCount: 0, monthCount: 0, totalListenTime: 0);
    }
  }

  /// 获取按日期分组的音乐（用于日记时间线）
  Future<List<JournalGroup>> getJournalEntries({
    String? emotion,
    int limit = 50,
  }) async {
    final musics = await getMusics(limit: limit, emotion: emotion);

    // 按日期分组
    final Map<String, List<JournalEntry>> grouped = {};
    for (final music in musics) {
      final entry = JournalEntry.fromMusic(music);
      if (!grouped.containsKey(entry.dateKey)) {
        grouped[entry.dateKey] = [];
      }
      grouped[entry.dateKey]!.add(entry);
    }

    // 转换为 JournalGroup 列表并按日期排序
    final groups = grouped.entries.map((e) {
      final firstEntry = e.value.first;
      return JournalGroup(
        dateKey: e.key,
        displayDate: firstEntry.friendlyDate,
        entries: e.value..sort((a, b) => b.date.compareTo(a.date)),
      );
    }).toList();

    // 按日期倒序排列
    groups.sort((a, b) => b.dateKey.compareTo(a.dateKey));

    return groups;
  }
}
```

---

## 3. 认证 Provider

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

---

## 4. 音乐 Provider

### 文件: `lib/providers/music_provider.dart`

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/music.dart';
import '../models/journal_entry.dart';

class MusicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 音乐列表
  List<Music> _musics = [];
  List<Music> _favorites = [];

  // 日记数据
  List<JournalGroup> _journalGroups = [];
  JournalStats? _stats;

  // 当前筛选
  String? _currentEmotionFilter;

  // 状态
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingJournal = false;
  String? _error;

  // Getters
  List<Music> get musics => _musics;
  List<Music> get favorites => _favorites;
  List<JournalGroup> get journalGroups => _journalGroups;
  JournalStats? get stats => _stats;
  String? get currentEmotionFilter => _currentEmotionFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingJournal => _isLoadingJournal;
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

  /// 加载收藏列表
  Future<void> loadFavorites({bool refresh = false}) async {
    if (_isLoadingFavorites) return;

    _isLoadingFavorites = true;
    notifyListeners();

    try {
      _favorites = await _apiService.getFavoriteMusics();
      _isLoadingFavorites = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// 加载日记数据
  Future<void> loadJournal({String? emotion}) async {
    if (_isLoadingJournal) return;

    _isLoadingJournal = true;
    _currentEmotionFilter = emotion;
    notifyListeners();

    try {
      // 加载统计数据
      _stats = await _apiService.getJournalStats();

      // 加载分组数据
      _journalGroups = await _apiService.getJournalEntries(emotion: emotion);

      // 如果没有从服务器获取统计，本地计算
      if (_stats?.totalCount == 0 && _journalGroups.isNotEmpty) {
        int total = 0;
        int monthTotal = 0;
        int listenTime = 0;
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 1);

        for (final group in _journalGroups) {
          for (final entry in group.entries) {
            total++;
            listenTime += entry.music.duration;
            if (entry.date.isAfter(thisMonth)) {
              monthTotal++;
            }
          }
        }

        _stats = JournalStats(
          totalCount: total,
          monthCount: monthTotal,
          totalListenTime: listenTime,
        );
      }

      _isLoadingJournal = false;
      notifyListeners();
    } catch (e) {
      _isLoadingJournal = false;
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
      _favorites.removeWhere((m) => m.id == id);

      // 更新日记分组
      for (final group in _journalGroups) {
        group.entries.removeWhere((e) => e.id == id);
      }
      _journalGroups.removeWhere((g) => g.entries.isEmpty);

      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除失败';
      notifyListeners();
      return false;
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(int id) async {
    try {
      final updatedMusic = await _apiService.toggleFavorite(id);

      // 更新音乐列表
      final index = _musics.indexWhere((m) => m.id == id);
      if (index != -1) {
        _musics[index] = updatedMusic;
      }

      // 更新收藏列表
      if (updatedMusic.isFavorite) {
        if (!_favorites.any((m) => m.id == id)) {
          _favorites.insert(0, updatedMusic);
        }
      } else {
        _favorites.removeWhere((m) => m.id == id);
      }

      // 更新日记中的条目
      for (final group in _journalGroups) {
        for (int i = 0; i < group.entries.length; i++) {
          if (group.entries[i].id == id) {
            group.entries[i] = JournalEntry.fromMusic(updatedMusic);
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = '操作失败';
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

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

---

## 📝 Part 2 完成

本部分包含了所有数据模型和服务层代码。接下来的 Part 3 将包含：

- 动态背景组件（云端背景、星际背景）
- 灵感球组件
- 通用 UI 组件

请继续查看 Part 3...
