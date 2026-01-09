# SoundMood Flutter 完整实现 - Part 3

## 动态背景与灵感球组件

> ✨ **本部分包含**：
> - 云端动态背景（飘动云朵、柔和光晕）
> - 星际动态背景（星星、星云、极光、流星）
> - 灵感球组件（云朵/星球两种风格）
> - 心情气泡组件

---

## 1. 云端背景组件

### 文件: `lib/widgets/backgrounds/cloud_background.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/themes/cloud_theme.dart';

/// 云端主题动态背景
class CloudBackground extends StatefulWidget {
  final Widget child;
  
  const CloudBackground({super.key, required this.child});

  @override
  State<CloudBackground> createState() => _CloudBackgroundState();
}

class _CloudBackgroundState extends State<CloudBackground>
    with TickerProviderStateMixin {
  late List<_Cloud> _clouds;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initClouds();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _initClouds() {
    final random = Random();
    _clouds = List.generate(8, (index) {
      return _Cloud(
        x: random.nextDouble() * 1.5 - 0.25,
        y: random.nextDouble() * 0.6 + 0.05,
        size: random.nextDouble() * 120 + 80,
        speed: random.nextDouble() * 0.00015 + 0.00005,
        opacity: random.nextDouble() * 0.3 + 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景渐变
        Container(
          decoration: const BoxDecoration(
            gradient: CloudTheme.backgroundGradient,
          ),
        ),
        
        // 飘动的云朵
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // 更新云朵位置
            for (var cloud in _clouds) {
              cloud.x += cloud.speed;
              if (cloud.x > 1.3) {
                cloud.x = -0.3;
              }
            }

            return CustomPaint(
              painter: _CloudPainter(clouds: _clouds),
              size: Size.infinite,
            );
          },
        ),
        
        // 柔和光晕
        ..._buildSoftGlows(),
        
        // 子内容
        widget.child,
      ],
    );
  }

  List<Widget> _buildSoftGlows() {
    return [
      // 左上角光晕
      Positioned(
        top: -100,
        left: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                CloudTheme.softBlue.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // 右下角光晕
      Positioned(
        bottom: -50,
        right: -50,
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                CloudTheme.softPink.withOpacity(0.25),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // 中央光晕
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: MediaQuery.of(context).size.width * 0.2,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                CloudTheme.accent.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _Cloud {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Cloud({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _CloudPainter extends CustomPainter {
  final List<_Cloud> clouds;

  _CloudPainter({required this.clouds});

  @override
  void paint(Canvas canvas, Size size) {
    for (var cloud in clouds) {
      _drawCloud(
        canvas,
        Offset(cloud.x * size.width, cloud.y * size.height),
        cloud.size,
        cloud.opacity,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double cloudSize, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // 绘制多个重叠的圆形成云朵形状
    final positions = [
      Offset(0, 0),
      Offset(cloudSize * 0.35, -cloudSize * 0.1),
      Offset(-cloudSize * 0.3, cloudSize * 0.05),
      Offset(cloudSize * 0.15, cloudSize * 0.15),
      Offset(-cloudSize * 0.15, -cloudSize * 0.1),
    ];

    for (var pos in positions) {
      canvas.drawCircle(
        center + pos,
        cloudSize * 0.3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => true;
}
```

---

## 2. 星际背景组件

### 文件: `lib/widgets/backgrounds/space_background.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/themes/space_theme.dart';

/// 星际主题动态背景
class SpaceBackground extends StatefulWidget {
  final Widget child;
  
  const SpaceBackground({super.key, required this.child});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late List<_Star> _stars;
  late List<_Nebula> _nebulae;
  late AnimationController _starController;
  late AnimationController _auroraController;
  late AnimationController _shootingStarController;
  
  _ShootingStar? _shootingStar;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initStars();
    _initNebulae();
    _initAnimations();
  }

  void _initStars() {
    _stars = List.generate(200, (index) {
      return _Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.5,
        twinkleDuration: Duration(milliseconds: _random.nextInt(3000) + 2000),
        twinkleDelay: Duration(milliseconds: _random.nextInt(4000)),
        color: _getStarColor(),
        isBright: _random.nextDouble() < 0.05, // 5% 是明亮大星
      );
    });
  }

  Color _getStarColor() {
    final colors = [
      Colors.white,
      Colors.white,
      Colors.white,
      const Color(0xFFFFE4E6), // 粉色
      const Color(0xFFE8E8FF), // 淡紫
      const Color(0xFFE0F7FA), // 淡蓝
      const Color(0xFFFFD700), // 金色
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _initNebulae() {
    _nebulae = [
      // 大紫色星云 - 右上
      _Nebula(
        center: const Alignment(0.7, -0.5),
        width: 0.8,
        height: 0.5,
        color: SpaceTheme.primary,
        opacity: 0.4,
      ),
      // 蓝色星云 - 左下
      _Nebula(
        center: const Alignment(-0.6, 0.6),
        width: 0.65,
        height: 0.45,
        color: SpaceTheme.blue,
        opacity: 0.35,
      ),
      // 粉色星云 - 中央偏左
      _Nebula(
        center: const Alignment(-0.2, 0.0),
        width: 0.55,
        height: 0.4,
        color: SpaceTheme.pink,
        opacity: 0.25,
      ),
      // 青色星云 - 右下
      _Nebula(
        center: const Alignment(0.5, 0.7),
        width: 0.5,
        height: 0.35,
        color: SpaceTheme.cyan,
        opacity: 0.2,
      ),
      // 金色星云 - 中央
      _Nebula(
        center: const Alignment(0.0, 0.2),
        width: 0.4,
        height: 0.3,
        color: SpaceTheme.accent,
        opacity: 0.15,
      ),
    ];
  }

  void _initAnimations() {
    // 星星闪烁动画
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // 极光动画
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // 流星动画
    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 随机决定是否生成新流星
        if (_random.nextDouble() < 0.3) {
          _createShootingStar();
        }
        _shootingStarController.reset();
        _shootingStarController.forward();
      }
    });
    _shootingStarController.forward();
  }

  void _createShootingStar() {
    _shootingStar = _ShootingStar(
      startX: _random.nextDouble() * 0.5 + 0.3,
      startY: _random.nextDouble() * 0.3,
      length: _random.nextDouble() * 100 + 50,
      angle: _random.nextDouble() * 0.5 + 0.7, // 约45度角
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    _auroraController.dispose();
    _shootingStarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 深空背景
        Container(
          decoration: const BoxDecoration(
            gradient: SpaceTheme.backgroundGradient,
          ),
        ),
        
        // 星云层
        ..._buildNebulae(),
        
        // 银河
        _buildMilkyWay(),
        
        // 极光效果
        AnimatedBuilder(
          animation: _auroraController,
          builder: (context, _) => _buildAurora(),
        ),
        
        // 星星层
        AnimatedBuilder(
          animation: _starController,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarPainter(
                stars: _stars,
                time: DateTime.now().millisecondsSinceEpoch,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // 流星
        AnimatedBuilder(
          animation: _shootingStarController,
          builder: (context, _) {
            if (_shootingStar != null) {
              return CustomPaint(
                painter: _ShootingStarPainter(
                  shootingStar: _shootingStar!,
                  progress: _shootingStarController.value,
                ),
                size: Size.infinite,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // 子内容
        widget.child,
      ],
    );
  }

  List<Widget> _buildNebulae() {
    return _nebulae.map((nebula) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: nebula.center,
              radius: nebula.width,
              colors: [
                nebula.color.withOpacity(nebula.opacity),
                nebula.color.withOpacity(nebula.opacity * 0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMilkyWay() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, _) {
        final offset = _auroraController.value * 0.1;
        return Positioned.fill(
          child: Transform.translate(
            offset: Offset(-MediaQuery.of(context).size.width * offset, 0),
            child: Transform.rotate(
              angle: -0.26, // 约 -15 度
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1.0, 0.0),
                    end: const Alignment(1.0, 0.0),
                    colors: [
                      Colors.transparent,
                      SpaceTheme.secondary.withOpacity(0.08),
                      SpaceTheme.pink.withOpacity(0.12),
                      SpaceTheme.primary.withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.35, 0.4, 0.5, 0.6, 0.65],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAurora() {
    final progress = _auroraController.value;
    final skewX = sin(progress * 2 * pi) * 0.1;
    
    return Positioned(
      top: -MediaQuery.of(context).size.height * 0.2,
      left: -MediaQuery.of(context).size.width * 0.5,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..skewX(skewX),
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 2,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                SpaceTheme.secondary.withOpacity(0.1),
                SpaceTheme.primary.withOpacity(0.15),
                SpaceTheme.pink.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final Duration twinkleDuration;
  final Duration twinkleDelay;
  final Color color;
  final bool isBright;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleDuration,
    required this.twinkleDelay,
    required this.color,
    required this.isBright,
  });
}

class _Nebula {
  final Alignment center;
  final double width;
  final double height;
  final Color color;
  final double opacity;

  _Nebula({
    required this.center,
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
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

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final int time;

  _StarPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final phase = (time + star.twinkleDelay.inMilliseconds) % 
          star.twinkleDuration.inMilliseconds;
      final twinkle = sin(phase / star.twinkleDuration.inMilliseconds * 2 * pi);
      final opacity = 0.3 + (twinkle + 1) / 2 * 0.7; // 0.3 ~ 1.0
      final currentSize = star.size * (0.8 + twinkle * 0.2);

      final paint = Paint()
        ..color = star.color.withOpacity(opacity);

      final center = Offset(star.x * size.width, star.y * size.height);

      if (star.isBright) {
        // 明亮大星带发光效果
        final glowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(center, currentSize * 3, glowPaint);
      }

      canvas.drawCircle(center, currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
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
    if (progress < 0.2 || progress > 0.4) return; // 只在特定时间显示

    final localProgress = (progress - 0.2) / 0.2; // 0 ~ 1
    final fadeIn = localProgress < 0.3 ? localProgress / 0.3 : 1.0;
    final fadeOut = localProgress > 0.7 ? (1 - localProgress) / 0.3 : 1.0;
    final opacity = fadeIn * fadeOut;

    final startX = shootingStar.startX * size.width;
    final startY = shootingStar.startY * size.height;
    final dx = cos(shootingStar.angle) * shootingStar.length * localProgress;
    final dy = sin(shootingStar.angle) * shootingStar.length * localProgress;

    final path = Path();
    path.moveTo(startX + dx, startY + dy);
    path.lineTo(startX + dx - cos(shootingStar.angle) * 30,
        startY + dy - sin(shootingStar.angle) * 30);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(
        Offset(startX + dx, startY + dy),
        Offset(startX + dx - cos(shootingStar.angle) * 30,
            startY + dy - sin(shootingStar.angle) * 30),
      ))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) => true;
}
```

---

## 3. 主题背景包装器

### 文件: `lib/widgets/backgrounds/themed_background.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import 'cloud_background.dart';
import 'space_background.dart';

/// 主题背景包装器 - 根据当前主题自动切换背景
class ThemedBackground extends StatelessWidget {
  final Widget child;
  
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: themeProvider.currentTheme == AppThemeType.cloud
              ? CloudBackground(key: const ValueKey('cloud'), child: child)
              : SpaceBackground(key: const ValueKey('space'), child: child),
        );
      },
    );
  }
}
```

---

## 4. 灵感球组件

### 文件: `lib/widgets/orb/inspiration_orb.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
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
                
                return Container(
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
                                  ? CloudTheme.softBlue.withOpacity(opacity)
                                  : SpaceTheme.primary.withOpacity(opacity),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                      
                      // 主体灵感球
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isCloud
                            ? CloudOrb(key: const ValueKey('cloud_orb'))
                            : SpaceOrb(key: const ValueKey('space_orb')),
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
                                  color: SpaceTheme.accent.withOpacity(0.6),
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
```

### 文件: `lib/widgets/orb/cloud_orb.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/themes/cloud_theme.dart';

/// 云朵灵感球
class CloudOrb extends StatefulWidget {
  const CloudOrb({super.key});

  @override
  State<CloudOrb> createState() => _CloudOrbState();
}

class _CloudOrbState extends State<CloudOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bounce = sin(_controller.value * pi * 2) * 5;
        
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 云朵形状由多个重叠的圆组成
              _CloudBlob(
                offset: Offset(0, bounce),
                size: 100,
                delay: 0,
              ),
              _CloudBlob(
                offset: Offset(35, -10 + bounce * 0.8),
                size: 70,
                delay: 0.5,
              ),
              _CloudBlob(
                offset: Offset(-35, 5 + bounce * 0.9),
                size: 65,
                delay: 1.0,
              ),
              _CloudBlob(
                offset: Offset(20, 25 + bounce * 0.7),
                size: 55,
                delay: 1.5,
              ),
              _CloudBlob(
                offset: Offset(-20, -15 + bounce * 0.6),
                size: 50,
                delay: 2.0,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CloudBlob extends StatelessWidget {
  final Offset offset;
  final double size;
  final double delay;

  const _CloudBlob({
    required this.offset,
    required this.size,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F8FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: CloudTheme.softBlue.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 30,
              offset: Offset(0, -5),
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 文件: `lib/widgets/orb/space_orb.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/themes/space_theme.dart';

/// 星球灵感球
class SpaceOrb extends StatefulWidget {
  const SpaceOrb({super.key});

  @override
  State<SpaceOrb> createState() => _SpaceOrbState();
}

class _SpaceOrbState extends State<SpaceOrb>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _orbitController]),
      builder: (context, _) {
        final glow = _glowController.value;
        
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 外层轨道
              ..._buildOrbits(),
              
              // 轨道上的粒子
              ..._buildOrbitalParticles(),
              
              // 核心星球
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.8,
                    colors: [
                      SpaceTheme.primary.withOpacity(0.4),
                      SpaceTheme.secondary.withOpacity(0.6),
                      const Color(0xFF0A0A15),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SpaceTheme.primary.withOpacity(0.9 + glow * 0.1),
                      blurRadius: 80 + glow * 20,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: SpaceTheme.secondary.withOpacity(0.5 + glow * 0.2),
                      blurRadius: 160,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              
              // 内部光点
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3 + glow * 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOrbits() {
    return [
      // 第一个轨道
      Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: SpaceTheme.accent.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      // 第二个轨道（反向）
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: SpaceTheme.accent.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOrbitalParticles() {
    final particles = <Widget>[];
    
    // 轨道1上的粒子
    for (int i = 0; i < 3; i++) {
      final angle = _orbitController.value * 2 * pi + (i * 2 * pi / 3);
      final x = cos(angle) * 90;
      final y = sin(angle) * 90;
      
      particles.add(
        Transform.translate(
          offset: Offset(x, y),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SpaceTheme.accent,
              boxShadow: [
                BoxShadow(
                  color: SpaceTheme.accent.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // 轨道2上的粒子（反向）
    for (int i = 0; i < 2; i++) {
      final angle = -_orbitController.value * 2 * pi * 0.7 + (i * pi);
      final x = cos(angle) * 100;
      final y = sin(angle) * 100;
      
      particles.add(
        Transform.translate(
          offset: Offset(x, y),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SpaceTheme.cyan,
              boxShadow: [
                BoxShadow(
                  color: SpaceTheme.cyan.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return particles;
  }
}
```

---

## 5. 心情气泡组件

### 文件: `lib/widgets/common/mood_bubble.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 漂浮的心情气泡
class MoodBubble extends StatefulWidget {
  final String emotion;
  final String label;
  final Offset offset;
  final VoidCallback? onTap;
  
  const MoodBubble({
    super.key,
    required this.emotion,
    required this.label,
    required this.offset,
    this.onTap,
  });

  @override
  State<MoodBubble> createState() => _MoodBubbleState();
}

class _MoodBubbleState extends State<MoodBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _floatOffset;

  @override
  void initState() {
    super.initState();
    _floatOffset = Random().nextDouble() * 2 * pi;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000 + Random().nextInt(2000)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final float = sin(_controller.value * pi * 2 + _floatOffset) * 10;
            
            return Transform.translate(
              offset: widget.offset + Offset(0, float),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xE6141428),
                    borderRadius: BorderRadius.circular(25),
                    border: isCloud
                        ? null
                        : Border.all(
                            color: SpaceTheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                    boxShadow: isCloud
                        ? [
                            BoxShadow(
                              color: CloudTheme.softBlue.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: SpaceTheme.primary.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isCloud
                          ? CloudTheme.textPrimary
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 心情气泡组
class MoodBubblesGroup extends StatelessWidget {
  final Function(String emotion)? onEmotionSelected;
  
  const MoodBubblesGroup({super.key, this.onEmotionSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MoodBubble(
            emotion: 'happy',
            label: '😊 开心',
            offset: const Offset(-80, -80),
            onTap: () => onEmotionSelected?.call('happy'),
          ),
          MoodBubble(
            emotion: 'calm',
            label: '😌 平静',
            offset: const Offset(85, -40),
            onTap: () => onEmotionSelected?.call('calm'),
          ),
          MoodBubble(
            emotion: 'sad',
            label: '😢 忧伤',
            offset: const Offset(-70, 80),
            onTap: () => onEmotionSelected?.call('sad'),
          ),
          MoodBubble(
            emotion: 'energetic',
            label: '⚡ 活力',
            offset: const Offset(75, 60),
            onTap: () => onEmotionSelected?.call('energetic'),
          ),
          MoodBubble(
            emotion: 'nostalgic',
            label: '🌙 思念',
            offset: const Offset(0, 110),
            onTap: () => onEmotionSelected?.call('nostalgic'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📝 Part 3 完成

本部分包含了所有动态背景和灵感球组件。接下来的 Part 4 将包含：

- 主页面容器与导航
- 创作页面（首页）
- 输入方式选择弹窗
- 文字/语音/图片输入页面

请继续查看 Part 4...
