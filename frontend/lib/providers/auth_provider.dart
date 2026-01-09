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
