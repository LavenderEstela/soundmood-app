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