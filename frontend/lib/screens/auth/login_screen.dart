import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'register_screen.dart';

/// 登录页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '登录失败'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Logo 和标题
                        _buildHeader(isCloud),
                        
                        const SizedBox(height: 50),
                        
                        // 表单
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildEmailField(isCloud),
                              const SizedBox(height: 20),
                              _buildPasswordField(isCloud),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 忘记密码
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: 忘记密码功能
                            },
                            child: Text(
                              '忘记密码？',
                              style: TextStyle(
                                color: isCloud 
                                    ? CloudTheme.primary 
                                    : SpaceTheme.accent,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 登录按钮
                        _buildLoginButton(isCloud),
                        
                        const SizedBox(height: 20),
                        
                        // 分隔线
                        _buildDivider(isCloud),
                        
                        const SizedBox(height: 20),
                        
                        // 主题切换
                        _buildThemeToggle(isCloud, themeProvider),
                        
                        const SizedBox(height: 40),
                        
                        // 注册链接
                        _buildRegisterLink(isCloud),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isCloud
                ? CloudTheme.orbGradient
                : SpaceTheme.orbGradient,
            boxShadow: isCloud
                ? CloudTheme.orbShadow
                : SpaceTheme.orbShadow,
          ),
          child: Icon(
            Icons.music_note_rounded,
            size: 48,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'SoundMood',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '让 AI 感知你的情绪，创作专属音乐',
          style: TextStyle(
            fontSize: 14,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '邮箱',
          hintText: '请输入邮箱地址',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入邮箱';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return '请输入有效的邮箱地址';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '密码',
          hintText: '请输入密码',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword 
                  ? Icons.visibility_off_outlined 
                  : Icons.visibility_outlined,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入密码';
          }
          if (value.length < 6) {
            return '密码至少6位';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton(bool isCloud) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleLogin,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: isCloud
                  ? CloudTheme.buttonGradient
                  : SpaceTheme.buttonGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.primary.withOpacity(0.4)
                      : SpaceTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(bool isCloud) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或者',
            style: TextStyle(
              fontSize: 12,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(bool isCloud, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isCloud
              ? Colors.white.withOpacity(0.9)
              : const Color(0xCC1E1E32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCloud ? Icons.cloud_rounded : Icons.nightlight_round,
              color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            ),
            const SizedBox(width: 12),
            Text(
              isCloud ? '切换到星际主题' : '切换到云端主题',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            '立即注册',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            ),
          ),
        ),
      ],
    );
  }
}