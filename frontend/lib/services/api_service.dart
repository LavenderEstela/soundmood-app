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
    
    // 处理两种可能的响应格式
    if (response.data is List) {
      final List<dynamic> items = response.data;
      return items.map((item) => Music.fromJson(item)).toList();
    } else if (response.data is Map && response.data['items'] != null) {
      final List<dynamic> items = response.data['items'];
      return items.map((item) => Music.fromJson(item)).toList();
    }
    return [];
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
    // 返回的是 {is_favorite: bool}，需要获取完整音乐信息
    final music = await getMusic(id);
    return music.copyWith(isFavorite: response.data['is_favorite']);
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
    
    // 生成接口返回的是简化响应，需要获取完整信息
    final musicId = response.data['id'];
    return await getMusic(musicId);
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
    
    final musicId = response.data['id'];
    return await getMusic(musicId);
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
    
    final musicId = response.data['id'];
    return await getMusic(musicId);
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
        monthCount: response.data['monthly_count'] ?? 0,
        totalListenTime: response.data['total_duration'] ?? 0,
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

  // ============= 用户设置接口 =============

  /// 获取用户设置
  Future<Map<String, dynamic>> getUserSettings() async {
    final response = await _dio.get('/api/user/settings');
    return response.data;
  }

  /// 更新用户设置
  Future<Map<String, dynamic>> updateUserSettings(Map<String, dynamic> settings) async {
    final response = await _dio.put('/api/user/settings', data: settings);
    return response.data;
  }

  /// 增加播放次数
  Future<void> incrementPlayCount(int musicId) async {
    await _dio.post('/api/music/$musicId/play');
  }
}
