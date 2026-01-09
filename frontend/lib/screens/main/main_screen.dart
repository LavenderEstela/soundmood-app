import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import '../create/create_screen.dart';
import '../journal/journal_screen.dart';
import '../collection/collection_screen.dart';

/// 主页面 - 包含底部导航
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CreateScreen(),     // 创作
    JournalScreen(),    // 日记
    CollectionScreen(), // 收藏
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: _buildBottomNav(isCloud),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud 
            ? Colors.white.withValues(alpha: 0.95)
            : const Color(0xE6141428),
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withValues(alpha: 0.2)
                : SpaceTheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        // 修复: 只保留底部的 SafeArea，不添加额外的 top padding
        top: false,
        child: Padding(
          // 修复: 减小垂直 padding
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: '创作',
                isSelected: _currentIndex == 0,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.schedule_rounded,
                label: '日记',
                isSelected: _currentIndex == 1,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.album_rounded,
                label: '收藏',
                isSelected: _currentIndex == 2,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCloud;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCloud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isCloud 
        ? CloudTheme.textPrimary 
        : SpaceTheme.accent;
    final unselectedColor = isCloud 
        ? CloudTheme.textSecondary 
        : SpaceTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // 修复: 减小 padding 避免溢出
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCloud 
                  ? CloudTheme.softBlue.withValues(alpha: 0.3)
                  : SpaceTheme.primary.withValues(alpha: 0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              // 修复: 稍微减小图标尺寸
              size: 22,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                // 修复: 稍微减小字体
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}