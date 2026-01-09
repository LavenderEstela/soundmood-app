import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';

/// 个人资料页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        final user = authProvider.user;

        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 头像区域
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 修复: 使用条件判断获取渐变
                        gradient: isCloud
                            ? CloudTheme.buttonGradient
                            : SpaceTheme.buttonGradient,
                        boxShadow: [
                          BoxShadow(
                            color: isCloud
                                ? CloudTheme.primary.withValues(alpha: 0.4)
                                : SpaceTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
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
                      user?.username ?? '未登录',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCloud
                            ? CloudTheme.textPrimary
                            : SpaceTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 邮箱
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCloud
                            ? CloudTheme.textSecondary
                            : SpaceTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 主题切换
                    _buildSettingItem(
                      context: context,
                      isCloud: isCloud,
                      icon: Icons.palette_outlined,
                      title: '主题风格',
                      subtitle: isCloud ? '云端主题' : '星际主题',
                      trailing: Switch(
                        value: !isCloud,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeColor: SpaceTheme.accent,
                        inactiveThumbColor: CloudTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 其他设置项
                    _buildSettingItem(
                      context: context,
                      isCloud: isCloud,
                      icon: Icons.notifications_outlined,
                      title: '通知设置',
                      subtitle: '管理推送通知',
                      onTap: () {
                        // TODO: 跳转到通知设置
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSettingItem(
                      context: context,
                      isCloud: isCloud,
                      icon: Icons.help_outline,
                      title: '帮助与反馈',
                      subtitle: '常见问题、联系我们',
                      onTap: () {
                        // TODO: 跳转到帮助页面
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSettingItem(
                      context: context,
                      isCloud: isCloud,
                      icon: Icons.info_outline,
                      title: '关于',
                      subtitle: 'SoundMood v1.0.0',
                      onTap: () {
                        // TODO: 跳转到关于页面
                      },
                    ),

                    const SizedBox(height: 32),

                    // 退出登录按钮
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context, authProvider),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required bool isCloud,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCloud
              ? Colors.white.withValues(alpha: 0.9)
              : const Color(0xCC1E1E32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCloud
                ? CloudTheme.softBlue.withValues(alpha: 0.3)
                : SpaceTheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isCloud
                    ? CloudTheme.buttonGradient
                    : SpaceTheme.buttonGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCloud
                          ? CloudTheme.textPrimary
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCloud
                          ? CloudTheme.textSecondary
                          : SpaceTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: isCloud
                    ? CloudTheme.textSecondary
                    : SpaceTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final isCloud = context.read<ThemeProvider>().isCloudTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isCloud ? Colors.white : const Color(0xFF1E1E32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '确认退出',
          style: TextStyle(
            color: isCloud ? CloudTheme.textPrimary : SpaceTheme.textPrimary,
          ),
        ),
        content: Text(
          '确定要退出登录吗？',
          style: TextStyle(
            color: isCloud ? CloudTheme.textSecondary : SpaceTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: isCloud ? CloudTheme.textSecondary : SpaceTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            child: const Text(
              '退出',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}