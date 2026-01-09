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