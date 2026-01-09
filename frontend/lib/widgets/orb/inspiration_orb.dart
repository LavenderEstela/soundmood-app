import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
// 添加缺少的 import
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import 'cloud_orb.dart';
import 'space_orb.dart';

/// 灵感球 - 根据主题自动切换风格
class InspirationOrb extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String mainText;
  final String subText;
  
  const InspirationOrb({
    super.key,
    this.onTap,
    this.onLongPress,
    this.mainText = '开始创作',
    this.subText = '点击输入灵感',
  });

  @override
  State<InspirationOrb> createState() => _InspirationOrbState();
}

class _InspirationOrbState extends State<InspirationOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = _pulseController.value;
                
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 外圈光环
                      ...List.generate(2, (index) {
                        final delay = index * 0.5;
                        final scale = 1.0 + (pulse + delay) % 1.0 * 0.3;
                        final opacity = (1 - (pulse + delay) % 1.0) * 0.3;
                        
                        return Container(
                          width: 200 * scale,
                          height: 200 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCloud
                                  ? CloudTheme.softBlue.withValues(alpha: opacity)
                                  : SpaceTheme.primary.withValues(alpha: opacity),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                      
                      // 主体灵感球
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isCloud
                            ? const CloudOrb(key: ValueKey('cloud_orb'))
                            : const SpaceOrb(key: ValueKey('space_orb')),
                      ),
                      
                      // 文字
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.mainText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                              color: isCloud
                                  ? CloudTheme.textPrimary
                                  : SpaceTheme.textPrimary,
                              shadows: isCloud ? null : [
                                Shadow(
                                  color: SpaceTheme.accent.withValues(alpha: 0.6),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subText,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              color: isCloud
                                  ? CloudTheme.textSecondary
                                  : SpaceTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}