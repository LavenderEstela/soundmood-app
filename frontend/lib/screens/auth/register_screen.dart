import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';

/// 注册页面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('注册成功！'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? '注册失败'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      
                      // 返回按钮
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCloud
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xCC1E1E32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isCloud 
                                  ? CloudTheme.textPrimary 
                                  : SpaceTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // 标题
                      _buildHeader(isCloud),
                      
                      const SizedBox(height: 40),
                      
                      // 表单
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _usernameController,
                              label: '用户名',
                              hint: '请输入用户名',
                              icon: Icons.person_outline,
                              isCloud: isCloud,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入用户名';
                                }
                                if (value.length < 2) {
                                  return '用户名至少2个字符';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              label: '邮箱',
                              hint: '请输入邮箱地址',
                              icon: Icons.email_outlined,
                              isCloud: isCloud,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入邮箱';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return '请输入有效的邮箱地址';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _passwordController,
                              label: '密码',
                              hint: '请输入密码',
                              isCloud: isCloud,
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
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
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: '确认密码',
                              hint: '请再次输入密码',
                              isCloud: isCloud,
                              obscure: _obscureConfirmPassword,
                              onToggle: () {
                                setState(() => 
                                    _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请确认密码';
                                }
                                if (value != _passwordController.text) {
                                  return '两次密码输入不一致';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 注册按钮
                      _buildRegisterButton(isCloud),
                      
                      const SizedBox(height: 24),
                      
                      // 登录链接
                      _buildLoginLink(isCloud),
                      
                      const SizedBox(height: 40),
                    ],
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
        Text(
          '创建账号',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '开启你的音乐情绪之旅',
          style: TextStyle(
            fontSize: 14,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isCloud,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isCloud,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
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
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure 
                  ? Icons.visibility_off_outlined 
                  : Icons.visibility_outlined,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton(bool isCloud) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleRegister,
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
                      '注册',
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

  Widget _buildLoginLink(bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账号？',
          style: TextStyle(
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '去登录',
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