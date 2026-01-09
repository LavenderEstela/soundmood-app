import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import 'cloud_background.dart';
import 'space_background.dart';

/// 根据当前主题自动选择背景
class ThemedBackground extends StatelessWidget {
  final Widget child;
  
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        if (themeProvider.currentTheme == AppThemeType.cloud) {
          return CloudBackground(child: child);
        } else {
          return SpaceBackground(child: child);
        }
      },
    );
  }
}