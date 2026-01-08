/// 应用配置
class AppConfig {
  // API 配置
  // static const String baseUrl = 'http://10.0.2.2:8000';  // Android 模拟器
  static const String baseUrl = 'http://localhost:8000';  // iOS 模拟器/Web ← 用这个！
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