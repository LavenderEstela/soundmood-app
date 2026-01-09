import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/themes/space_theme.dart';

/// 星际主题动态背景 - 优化版
class SpaceBackground extends StatefulWidget {
  final Widget child;
  
  const SpaceBackground({super.key, required this.child});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late List<_Star> _stars;
  late List<_GlowOrb> _glowOrbs;
  late AnimationController _twinkleController;
  late AnimationController _floatController;
  late AnimationController _shootingStarController;
  
  _ShootingStar? _currentShootingStar;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initStars();
    _initGlowOrbs();
    _initAnimations();
  }

  void _initStars() {
    _stars = List.generate(150, (index) {
      final isBright = _random.nextDouble() < 0.08;
      return _Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: isBright 
            ? _random.nextDouble() * 2.0 + 1.5 
            : _random.nextDouble() * 1.2 + 0.3,
        baseOpacity: isBright 
            ? _random.nextDouble() * 0.3 + 0.7 
            : _random.nextDouble() * 0.4 + 0.2,
        twinkleSpeed: _random.nextDouble() * 2 + 1,
        twinkleOffset: _random.nextDouble() * pi * 2,
        color: _getStarColor(isBright),
        isBright: isBright,
      );
    });
  }

  Color _getStarColor(bool isBright) {
    if (isBright) {
      final colors = [
        const Color(0xFFFFFFFF),
        const Color(0xFFE8F4FF), // 冷白
        const Color(0xFFFFF8E8), // 暖白
        const Color(0xFFFFE8F0), // 粉白
        const Color(0xFFE8E8FF), // 蓝白
      ];
      return colors[_random.nextInt(colors.length)];
    }
    return Colors.white;
  }

  void _initGlowOrbs() {
    _glowOrbs = [
      // 主星云 - 紫色，右上方
      _GlowOrb(
        center: const Offset(0.75, 0.15),
        radius: 0.4,
        color: const Color(0xFF9D4EDD),
        opacity: 0.15,
        blurAmount: 80,
      ),
      // 次星云 - 蓝色，左下方
      _GlowOrb(
        center: const Offset(0.2, 0.7),
        radius: 0.35,
        color: const Color(0xFF4169E1),
        opacity: 0.12,
        blurAmount: 70,
      ),
      // 点缀星云 - 粉色，中央
      _GlowOrb(
        center: const Offset(0.5, 0.4),
        radius: 0.25,
        color: const Color(0xFFFF6B9D),
        opacity: 0.08,
        blurAmount: 60,
      ),
      // 点缀星云 - 青色，右下
      _GlowOrb(
        center: const Offset(0.85, 0.65),
        radius: 0.2,
        color: const Color(0xFF00D4FF),
        opacity: 0.1,
        blurAmount: 50,
      ),
    ];
  }

  void _initAnimations() {
    // 闪烁动画
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    // 星云漂浮动画
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 流星动画
    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _currentShootingStar = null);
        // 随机延迟后可能产生新流星
        Future.delayed(Duration(seconds: _random.nextInt(8) + 4), () {
          if (mounted && _random.nextDouble() < 0.6) {
            _createShootingStar();
          }
        });
      }
    });

    // 初始延迟后开始第一颗流星
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _createShootingStar();
    });
  }

  void _createShootingStar() {
    _currentShootingStar = _ShootingStar(
      startX: _random.nextDouble() * 0.6 + 0.2,
      startY: _random.nextDouble() * 0.3 + 0.05,
      length: _random.nextDouble() * 80 + 60,
      angle: _random.nextDouble() * 0.4 + 0.5, // 30-50度角
    );
    _shootingStarController.forward(from: 0);
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _floatController.dispose();
    _shootingStarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // 深空渐变背景
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF050510), // 深邃的深蓝黑
                Color(0xFF0A0A18), // 稍微亮一点
                Color(0xFF0D0D20), // 带一点紫调
                Color(0xFF080815), // 底部略深
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        
        // 动态星云层
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, _) {
            return CustomPaint(
              painter: _NebulaPainter(
                glowOrbs: _glowOrbs,
                animationValue: _floatController.value,
                screenSize: size,
              ),
              size: size,
            );
          },
        ),

        // 星星层
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarFieldPainter(
                stars: _stars,
                time: DateTime.now().millisecondsSinceEpoch / 1000.0,
              ),
              size: size,
            );
          },
        ),

        // 流星层
        if (_currentShootingStar != null)
          AnimatedBuilder(
            animation: _shootingStarController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ShootingStarPainter(
                  shootingStar: _currentShootingStar!,
                  progress: _shootingStarController.value,
                ),
                size: size,
              );
            },
          ),

        // 顶部微弱的极光效果
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.4,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) {
              final wave = sin(_floatController.value * pi * 2) * 0.02;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.5 + wave, -1),
                    end: Alignment(0.5 + wave, 1),
                    colors: [
                      const Color(0xFF9D4EDD).withValues(alpha: 0.05),
                      const Color(0xFF4169E1).withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 子内容
        widget.child,
      ],
    );
  }
}

// ==================== 数据类 ====================

class _Star {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double twinkleSpeed;
  final double twinkleOffset;
  final Color color;
  final bool isBright;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
    required this.isBright,
  });
}

class _GlowOrb {
  final Offset center;
  final double radius;
  final Color color;
  final double opacity;
  final double blurAmount;

  _GlowOrb({
    required this.center,
    required this.radius,
    required this.color,
    required this.opacity,
    required this.blurAmount,
  });
}

class _ShootingStar {
  final double startX;
  final double startY;
  final double length;
  final double angle;

  _ShootingStar({
    required this.startX,
    required this.startY,
    required this.length,
    required this.angle,
  });
}

// ==================== 绘制器 ====================

class _NebulaPainter extends CustomPainter {
  final List<_GlowOrb> glowOrbs;
  final double animationValue;
  final Size screenSize;

  _NebulaPainter({
    required this.glowOrbs,
    required this.animationValue,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in glowOrbs) {
      // 添加微妙的漂浮动画
      final floatX = sin(animationValue * pi * 2 + orb.center.dx * 10) * 0.02;
      final floatY = cos(animationValue * pi * 2 + orb.center.dy * 10) * 0.02;
      
      final center = Offset(
        (orb.center.dx + floatX) * size.width,
        (orb.center.dy + floatY) * size.height,
      );
      
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withValues(alpha: orb.opacity),
            orb.color.withValues(alpha: orb.opacity * 0.5),
            orb.color.withValues(alpha: orb.opacity * 0.2),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ).createShader(Rect.fromCircle(
          center: center,
          radius: orb.radius * size.width,
        ))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.blurAmount);

      canvas.drawCircle(center, orb.radius * size.width, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double time;

  _StarFieldPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // 计算闪烁
      final twinkle = sin(time * star.twinkleSpeed + star.twinkleOffset);
      final opacity = star.baseOpacity + twinkle * 0.2;
      final currentSize = star.size * (1 + twinkle * 0.15);
      
      final center = Offset(star.x * size.width, star.y * size.height);

      if (star.isBright) {
        // 亮星 - 添加光晕效果
        final glowPaint = Paint()
          ..color = star.color.withValues(alpha: opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(center, currentSize * 2.5, glowPaint);
        
        // 十字光芒效果
        final crossPaint = Paint()
          ..color = star.color.withValues(alpha: opacity * 0.4)
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round;
        
        final crossLength = currentSize * 3;
        canvas.drawLine(
          center - Offset(crossLength, 0),
          center + Offset(crossLength, 0),
          crossPaint,
        );
        canvas.drawLine(
          center - Offset(0, crossLength),
          center + Offset(0, crossLength),
          crossPaint,
        );
      }

      // 星星主体
      final paint = Paint()
        ..color = star.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(center, currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) => true;
}

class _ShootingStarPainter extends CustomPainter {
  final _ShootingStar shootingStar;
  final double progress;

  _ShootingStarPainter({
    required this.shootingStar,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 缓动效果
    final easedProgress = Curves.easeOut.transform(progress);
    
    // 淡入淡出
    double opacity;
    if (progress < 0.2) {
      opacity = progress / 0.2;
    } else if (progress > 0.7) {
      opacity = (1 - progress) / 0.3;
    } else {
      opacity = 1.0;
    }

    final startX = shootingStar.startX * size.width;
    final startY = shootingStar.startY * size.height;
    
    // 流星头部位置
    final headX = startX + cos(shootingStar.angle) * shootingStar.length * easedProgress;
    final headY = startY + sin(shootingStar.angle) * shootingStar.length * easedProgress;
    
    // 尾巴长度（随进度变化）
    final tailLength = min(shootingStar.length * 0.6, shootingStar.length * easedProgress);
    final tailX = headX - cos(shootingStar.angle) * tailLength;
    final tailY = headY - sin(shootingStar.angle) * tailLength;

    // 绘制流星尾巴（渐变）
    final tailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.6),
          Colors.white.withValues(alpha: opacity * 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 1.0],
      ).createShader(Rect.fromPoints(
        Offset(headX, headY),
        Offset(tailX, tailY),
      ))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(headX, headY), Offset(tailX, tailY), tailPaint);

    // 绘制流星头部光晕
    final headGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(headX, headY), 3, headGlowPaint);

    // 流星头部核心
    final headPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity);
    canvas.drawCircle(Offset(headX, headY), 1.5, headPaint);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}