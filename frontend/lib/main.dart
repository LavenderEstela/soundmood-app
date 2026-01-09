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