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