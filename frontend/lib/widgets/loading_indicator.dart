import 'package:flutter/material.dart';
import '../config/themes/app_theme.dart';

/// 加载指示器组件
class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        // 注意：不能用 const，因为 AppTheme.primaryColor 不是编译时常量
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
}

/// 全屏加载指示器
class FullScreenLoading extends StatelessWidget {
  final String? message;
  
  const FullScreenLoading({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(size: 50),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
