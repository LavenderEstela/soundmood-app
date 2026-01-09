import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 毛玻璃卡片组件
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: margin,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xCC1E1E32),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: isCloud
                          ? CloudTheme.softBlue.withOpacity(0.3)
                          : SpaceTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCloud
                            ? CloudTheme.softBlue.withOpacity(0.2)
                            : SpaceTheme.primary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 简单的透明卡片（无模糊效果，性能更好）
class SimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const SimpleCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: margin,
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCloud
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xCC1E1E32),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isCloud
                    ? CloudTheme.softBlue.withOpacity(0.3)
                    : SpaceTheme.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.softBlue.withOpacity(0.2)
                      : SpaceTheme.primary.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}