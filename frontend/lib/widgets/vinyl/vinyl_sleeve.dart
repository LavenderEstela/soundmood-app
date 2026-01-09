import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/music.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 黑胶唱片套
class VinylSleeve extends StatefulWidget {
  final Music music;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const VinylSleeve({
    super.key,
    required this.music,
    this.isExpanded = false,
    this.onTap,
    this.onPlay,
  });

  @override
  State<VinylSleeve> createState() => _VinylSleeveState();
}

class _VinylSleeveState extends State<VinylSleeve>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    if (widget.isExpanded) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VinylSleeve oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _rotationController.repeat();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: widget.onTap,
          child: Column(
            children: [
              // 唱片和封套
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 封套
                    _buildSleeve(isCloud),
                    
                    // 唱片（展开时显示）
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      top: widget.isExpanded ? -20 : 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: widget.isExpanded ? 1 : 0,
                        child: _buildVinyl(isCloud),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 标题
              Text(
                widget.music.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleeve(bool isCloud) {
    final emotion = widget.music.primaryEmotion;
    final gradient = _getEmotionGradient(isCloud, emotion ?? 'calm');
    final emoji = _getEmotionEmoji(emotion ?? 'calm');
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildVinyl(bool isCloud) {
    return GestureDetector(
      onTap: widget.onPlay,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * pi,
            child: Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 纹理
                  CustomPaint(
                    size: const Size(70, 70),
                    painter: _VinylGroovesPainter(),
                  ),
                  // 标签
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCloud
                          ? CloudTheme.buttonGradient
                          : SpaceTheme.buttonGradient,
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  LinearGradient _getEmotionGradient(bool isCloud, String emotion) {
    if (isCloud) {
      switch (emotion) {
        case 'happy':
          return const LinearGradient(
            colors: [Color(0xFFFFE4B5), Color(0xFFFFD700)],
          );
        case 'calm':
          return const LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFF80DEEA)],
          );
        case 'sad':
          return const LinearGradient(
            colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
          );
        case 'energetic':
          return const LinearGradient(
            colors: [Color(0xFFFFCDD2), Color(0xFFEF9A9A)],
          );
        case 'nostalgic':
          return const LinearGradient(
            colors: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
          );
        default:
          return const LinearGradient(
            colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
          );
      }
    } else {
      switch (emotion) {
        case 'happy':
          return const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          );
        case 'calm':
          return const LinearGradient(
            colors: [Color(0xFF4169E1), Color(0xFF00CED1)],
          );
        case 'sad':
          return const LinearGradient(
            colors: [Color(0xFF9370DB), Color(0xFF8A2BE2)],
          );
        case 'energetic':
          return const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)],
          );
        case 'nostalgic':
          return const LinearGradient(
            colors: [Color(0xFF708090), Color(0xFF4A4A6A)],
          );
        default:
          return const LinearGradient(
            colors: [Color(0xFF404040), Color(0xFF303030)],
          );
      }
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'happy':
        return '☀️';
      case 'calm':
        return '🌊';
      case 'sad':
        return '🌧️';
      case 'energetic':
        return '⚡';
      case 'nostalgic':
        return '🌙';
      default:
        return '🎵';
    }
  }
}

class _VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 绘制纹路圆环
    for (double r = 15; r < size.width / 2 - 5; r += 3) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}