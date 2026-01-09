import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 主题按钮类型
enum ThemedButtonType {
  primary,   // 主按钮
  secondary, // 次按钮
  outline,   // 轮廓按钮
  text,      // 文字按钮
}

/// 主题按钮组件
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ThemedButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const ThemedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ThemedButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        switch (type) {
          case ThemedButtonType.primary:
            return _buildPrimaryButton(isCloud);
          case ThemedButtonType.secondary:
            return _buildSecondaryButton(isCloud);
          case ThemedButtonType.outline:
            return _buildOutlineButton(isCloud);
          case ThemedButtonType.text:
            return _buildTextButton(isCloud);
        }
      },
    );
  }

  Widget _buildPrimaryButton(bool isCloud) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: isCloud
              ? CloudTheme.buttonGradient
              : SpaceTheme.buttonGradient,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: isCloud
                  ? CloudTheme.primary.withOpacity(0.4)
                  : SpaceTheme.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _buildContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(bool isCloud) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: _buildContent(
          isCloud ? CloudTheme.textPrimary : SpaceTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildOutlineButton(bool isCloud) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            width: 2,
          ),
        ),
        child: _buildContent(
          isCloud ? CloudTheme.primary : SpaceTheme.accent,
        ),
      ),
    );
  }

  Widget _buildTextButton(bool isCloud) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildContent(
          isCloud ? CloudTheme.primary : SpaceTheme.accent,
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}