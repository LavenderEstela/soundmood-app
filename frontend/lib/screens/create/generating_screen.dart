import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/music.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import '../player/player_screen.dart';

/// 生成动画页面 - 灵感球变形为胶片卷轴
class GeneratingScreen extends StatefulWidget {
  final Music music;
  
  const GeneratingScreen({super.key, required this.music});

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _filmController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  
  late Animation<double> _morphAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isCompleted = false;
  double _progress = 0.0;
  
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
    _startGeneration();
  }

  void _initAnimations() {
    // 变形动画控制器
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _morphAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOutCubic),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _morphController, curve: Curves.easeInOut));
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    // 胶片转动动画
    _filmController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 粒子动画
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // 脉冲动画
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _initParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * 2 * pi,
        distance: _random.nextDouble() * 50 + 100,
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.02 + 0.01,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  void _startGeneration() async {
    // 开始变形动画
    await Future.delayed(const Duration(milliseconds: 500));
    _morphController.forward();
    
    // 模拟生成进度
    _simulateProgress();
  }

  void _simulateProgress() async {
    while (_progress < 1.0 && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        setState(() {
          _progress += _random.nextDouble() * 0.03 + 0.01;
          if (_progress > 1.0) _progress = 1.0;
        });
      }
      
      // 检查实际生成状态
      if (_progress > 0.5) {
        final musicProvider = context.read<MusicProvider>();
        await musicProvider.refreshMusicStatus(widget.music.id);
        
        final updatedMusic = musicProvider.musics.firstWhere(
          (m) => m.id == widget.music.id,
          orElse: () => widget.music,
        );
        
        if (updatedMusic.status == MusicStatus.completed) {
          setState(() {
            _progress = 1.0;
            _isCompleted = true;
          });
          await Future.delayed(const Duration(milliseconds: 800));
          _navigateToPlayer(updatedMusic);
          return;
        }
      }
    }
    
    if (_progress >= 1.0 && mounted && !_isCompleted) {
      setState(() => _isCompleted = true);
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToPlayer(widget.music);
    }
  }

  void _navigateToPlayer(Music music) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return PlayerScreen(music: music);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _filmController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // 变形动画区域
                  _buildMorphingAnimation(isCloud),
                  
                  const SizedBox(height: 40),
                  
                  // 状态文字
                  _buildStatusText(isCloud),
                  
                  const SizedBox(height: 24),
                  
                  // 进度条
                  _buildProgressBar(isCloud),
                  
                  const Spacer(flex: 3),
                  
                  // 提示文字
                  _buildHintText(isCloud),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMorphingAnimation(bool isCloud) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _morphController,
        _filmController,
        _particleController,
        _pulseController,
      ]),
      builder: (context, _) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 粒子效果
              ..._buildParticles(isCloud),
              
              // 主体变形
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * (1 - _morphAnimation.value),
                  child: _morphAnimation.value < 0.5
                      ? _buildOrb(isCloud)
                      : _buildFilmReel(isCloud),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles(bool isCloud) {
    return _particles.map((particle) {
      final angle = particle.angle + _particleController.value * particle.speed * 2 * pi;
      final x = cos(angle) * particle.distance * (0.8 + _pulseController.value * 0.2);
      final y = sin(angle) * particle.distance * (0.8 + _pulseController.value * 0.2);
      
      return Positioned(
        left: 140 + x - particle.size / 2,
        top: 140 + y - particle.size / 2,
        child: Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(particle.opacity)
                : SpaceTheme.accent.withOpacity(particle.opacity),
            boxShadow: [
              BoxShadow(
                color: isCloud
                    ? CloudTheme.softBlue.withOpacity(particle.opacity * 0.5)
                    : SpaceTheme.accent.withOpacity(particle.opacity * 0.5),
                blurRadius: particle.size * 2,
                spreadRadius: particle.size * 0.5,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildOrb(bool isCloud) {
    final pulse = _pulseController.value;
    
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isCloud
              ? [
                  Colors.white,
                  CloudTheme.softBlue.withOpacity(0.8),
                  CloudTheme.softPink.withOpacity(0.6),
                ]
              : [
                  SpaceTheme.secondary,
                  SpaceTheme.primary.withOpacity(0.8),
                  const Color(0xFF0A0A15),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.5 + pulse * 0.2)
                : SpaceTheme.primary.withOpacity(0.6 + pulse * 0.2),
            blurRadius: 60 + pulse * 20,
            spreadRadius: pulse * 10,
          ),
        ],
      ),
    );
  }

  Widget _buildFilmReel(bool isCloud) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈
          Transform.rotate(
            angle: _filmController.value * 2 * pi,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCloud
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFF2A2A2A),
                boxShadow: [
                  BoxShadow(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.4)
                        : SpaceTheme.primary.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _FilmReelPainter(
                  isCloud: isCloud,
                  progress: _filmController.value,
                ),
              ),
            ),
          ),
          
          // 中心标签
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCloud
                  ? CloudTheme.buttonGradient
                  : SpaceTheme.buttonGradient,
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(bool isCloud) {
    final statusTexts = [
      '正在感知情绪...',
      '分析音乐元素...',
      '编织旋律...',
      '调整音色...',
      '完善细节...',
      '即将完成...',
    ];
    
    final index = (_progress * (statusTexts.length - 1)).floor();
    final text = _isCompleted ? '生成完成！' : statusTexts[index.clamp(0, statusTexts.length - 1)];
    
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.music.title,
          style: TextStyle(
            fontSize: 14,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.2)
                  : SpaceTheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCloud ? CloudTheme.primary : SpaceTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintText(bool isCloud) {
    return Text(
      'AI 正在为你创作独一无二的音乐',
      style: TextStyle(
        fontSize: 13,
        color: isCloud 
            ? CloudTheme.textSecondary.withOpacity(0.7)
            : SpaceTheme.textSecondary.withOpacity(0.7),
      ),
    );
  }
}

class _Particle {
  double angle;
  double distance;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _FilmReelPainter extends CustomPainter {
  final bool isCloud;
  final double progress;

  _FilmReelPainter({required this.isCloud, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    
    // 胶片孔
    final holePaint = Paint()..color = Colors.black45;
    const holeCount = 8;
    const holeRadius = 8.0;
    const holeDistance = 0.85;
    
    for (int i = 0; i < holeCount; i++) {
      final angle = (i / holeCount) * 2 * pi;
      final x = center.dx + cos(angle) * radius * holeDistance;
      final y = center.dy + sin(angle) * radius * holeDistance;
      canvas.drawCircle(Offset(x, y), holeRadius, holePaint);
    }
    
    // 纹理线条
    final linePaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * pi;
      final startX = center.dx + cos(angle) * radius * 0.35;
      final startY = center.dy + sin(angle) * radius * 0.35;
      final endX = center.dx + cos(angle) * radius * 0.7;
      final endY = center.dy + sin(angle) * radius * 0.7;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilmReelPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}