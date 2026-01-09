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