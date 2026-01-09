# SoundMood Flutter 完整实现 - Part 6

## 播放器、认证与辅助组件

> 🎶 **本部分包含**：
> - 播放器页面（黑胶唱片播放器）
> - 登录页面
> - 注册页面
> - 主题背景包装组件
> - 毛玻璃卡片组件
> - 主题按钮组件

---

## 1. 播放器页面

### 文件: `lib/screens/player/player_screen.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/music.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';

/// 播放器页面 - 黑胶唱片播放器
class PlayerScreen extends StatefulWidget {
  final Music music;
  
  const PlayerScreen({super.key, required this.music});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;
  late AnimationController _needleController;
  late AnimationController _pulseController;
  
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late Music _currentMusic;

  @override
  void initState() {
    super.initState();
    _currentMusic = widget.music;
    _initAnimations();
    _initAudioPlayer();
  }

  void _initAnimations() {
    // 唱片旋转动画
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    
    // 唱针动画
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: -0.15,
      upperBound: 0.0,
    )..value = -0.15;
    
    // 脉冲动画
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    // 监听播放状态
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
        
        if (state.playing) {
          _rotationController.repeat();
          _needleController.animateTo(0.0, curve: Curves.easeOut);
        } else {
          _rotationController.stop();
          _needleController.animateTo(-0.15, curve: Curves.easeIn);
        }
      }
    });
    
    // 监听位置
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    
    // 监听时长
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });
    
    // 加载音频
    try {
      final url = '${AppConfig.baseUrl}${_currentMusic.musicUrl}';
      await _audioPlayer.setUrl(url);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('音频加载失败'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
  }

  Future<void> _toggleFavorite() async {
    final musicProvider = context.read<MusicProvider>();
    final success = await musicProvider.toggleFavorite(_currentMusic.id);
    
    if (success && mounted) {
      setState(() {
        _currentMusic = _currentMusic.copyWith(
          isFavorite: !_currentMusic.isFavorite,
        );
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    _needleController.dispose();
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
                  // 顶部导航
                  _buildAppBar(isCloud),
                  
                  const Spacer(flex: 1),
                  
                  // 黑胶唱片
                  _buildVinylPlayer(isCloud),
                  
                  const Spacer(flex: 1),
                  
                  // 歌曲信息
                  _buildSongInfo(isCloud),
                  
                  const SizedBox(height: 24),
                  
                  // 进度条
                  _buildProgressBar(isCloud),
                  
                  const SizedBox(height: 24),
                  
                  // 控制按钮
                  _buildControls(isCloud),
                  
                  const SizedBox(height: 32),
                  
                  // AI 分析
                  if (_currentMusic.aiAnalysis != null)
                    _buildAiAnalysis(isCloud),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xCC1E1E32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '正在播放',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xCC1E1E32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _currentMusic.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _currentMusic.isFavorite
                    ? Colors.red.shade400
                    : (isCloud 
                        ? CloudTheme.textPrimary 
                        : SpaceTheme.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylPlayer(bool isCloud) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 底座光晕
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final pulse = _pulseController.value;
              return Container(
                width: 300 + pulse * 20,
                height: 300 + pulse * 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isCloud
                          ? CloudTheme.softBlue.withOpacity(0.3 + pulse * 0.1)
                          : SpaceTheme.primary.withOpacity(0.3 + pulse * 0.1),
                      blurRadius: 60 + pulse * 20,
                      spreadRadius: pulse * 10,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // 唱片
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: _buildVinylDisc(isCloud),
              );
            },
          ),
          
          // 唱针
          Positioned(
            top: 20,
            right: 50,
            child: AnimatedBuilder(
              animation: _needleController,
              builder: (context, _) {
                return Transform.rotate(
                  angle: _needleController.value,
                  alignment: Alignment.topRight,
                  child: _buildNeedle(isCloud),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylDisc(bool isCloud) {
    final emotion = _currentMusic.primaryEmotion;
    
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 唱片纹路
          CustomPaint(
            size: const Size(260, 260),
            painter: _VinylGroovesPainter(),
          ),
          
          // 中心标签
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getLabelGradient(isCloud, emotion),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getEmotionEmoji(emotion),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedle(bool isCloud) {
    return SizedBox(
      width: 120,
      height: 150,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // 唱针臂
          Positioned(
            top: 20,
            right: 0,
            child: Transform.rotate(
              angle: -0.3,
              alignment: Alignment.topRight,
              child: Container(
                width: 100,
                height: 8,
                decoration: BoxDecoration(
                  color: isCloud
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFB8860B),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 唱针头
          Positioned(
            top: 45,
            left: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 4,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // 底座
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCloud
                    ? const Color(0xFF808080)
                    : const Color(0xFF505050),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongInfo(bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            _currentMusic.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentMusic.inputTypeIcon,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '${_currentMusic.inputTypeLabel}创作',
                style: TextStyle(
                  fontSize: 14,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
              if (_currentMusic.genre != null) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _currentMusic.genre!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCloud 
                          ? CloudTheme.textPrimary 
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_currentMusic.emotionTags != null &&
              _currentMusic.emotionTags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _currentMusic.emotionTags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? CloudTheme.emotionColors[tag]?.withOpacity(0.3) ??
                            CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.emotionColors[tag]?.withOpacity(0.2) ??
                            SpaceTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCloud 
                          ? CloudTheme.textPrimary 
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isCloud) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.accent,
              inactiveTrackColor: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.3)
                  : SpaceTheme.primary.withOpacity(0.2),
              thumbColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.accent,
              overlayColor: isCloud
                  ? CloudTheme.primary.withOpacity(0.2)
                  : SpaceTheme.accent.withOpacity(0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: _seekTo,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    fontSize: 12,
                    color: isCloud 
                        ? CloudTheme.textSecondary 
                        : SpaceTheme.textSecondary,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: isCloud 
                        ? CloudTheme.textSecondary 
                        : SpaceTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 循环按钮
        GestureDetector(
          onTap: () {
            // TODO: 实现循环模式
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCloud
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xCC1E1E32),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.repeat_rounded,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 播放/暂停按钮
        GestureDetector(
          onTap: _isLoading ? null : _togglePlayPause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCloud
                  ? CloudTheme.buttonGradient
                  : SpaceTheme.buttonGradient,
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.primary.withOpacity(0.4)
                      : SpaceTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 分享按钮
        GestureDetector(
          onTap: () {
            // TODO: 实现分享功能
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCloud
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xCC1E1E32),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.share_rounded,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiAnalysis(bool isCloud) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.8)
            : const Color(0xB31E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: isCloud 
                    ? CloudTheme.primary 
                    : SpaceTheme.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 情绪解读',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentMusic.aiAnalysis!,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  LinearGradient _getLabelGradient(bool isCloud, String emotion) {
    if (isCloud) {
      return CloudTheme.buttonGradient;
    } else {
      return SpaceTheme.buttonGradient;
    }
  }

  String _getEmotionEmoji(String emotion) {
    const emojis = {
      'happy': '😊',
      'calm': '😌',
      'sad': '😢',
      'energetic': '⚡',
      'nostalgic': '🌙',
    };
    return emojis[emotion] ?? '🎵';
  }
}

class _VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 绘制纹路
    for (double r = 50; r < size.width / 2 - 10; r += 4) {
      canvas.drawCircle(center, r, paint);
    }
    
    // 光泽效果
    final glossPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    
    canvas.drawCircle(center, size.width / 2, glossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 2. 登录页面

### 文件: `lib/screens/auth/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'register_screen.dart';

/// 登录页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '登录失败'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Logo 和标题
                        _buildHeader(isCloud),
                        
                        const SizedBox(height: 50),
                        
                        // 表单
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildEmailField(isCloud),
                              const SizedBox(height: 20),
                              _buildPasswordField(isCloud),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 忘记密码
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: 忘记密码功能
                            },
                            child: Text(
                              '忘记密码？',
                              style: TextStyle(
                                color: isCloud 
                                    ? CloudTheme.primary 
                                    : SpaceTheme.accent,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 登录按钮
                        _buildLoginButton(isCloud),
                        
                        const SizedBox(height: 20),
                        
                        // 分隔线
                        _buildDivider(isCloud),
                        
                        const SizedBox(height: 20),
                        
                        // 主题切换
                        _buildThemeToggle(isCloud, themeProvider),
                        
                        const SizedBox(height: 40),
                        
                        // 注册链接
                        _buildRegisterLink(isCloud),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isCloud
                ? CloudTheme.orbGradient
                : SpaceTheme.orbGradient,
            boxShadow: isCloud
                ? CloudTheme.orbShadow
                : SpaceTheme.orbShadow,
          ),
          child: Icon(
            Icons.music_note_rounded,
            size: 48,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'SoundMood',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '让 AI 感知你的情绪，创作专属音乐',
          style: TextStyle(
            fontSize: 14,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '邮箱',
          hintText: '请输入邮箱地址',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入邮箱';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return '请输入有效的邮箱地址';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '密码',
          hintText: '请输入密码',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword 
                  ? Icons.visibility_off_outlined 
                  : Icons.visibility_outlined,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入密码';
          }
          if (value.length < 6) {
            return '密码至少6位';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton(bool isCloud) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleLogin,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: isCloud
                  ? CloudTheme.buttonGradient
                  : SpaceTheme.buttonGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.primary.withOpacity(0.4)
                      : SpaceTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(bool isCloud) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或者',
            style: TextStyle(
              fontSize: 12,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(bool isCloud, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isCloud
              ? Colors.white.withOpacity(0.9)
              : const Color(0xCC1E1E32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCloud ? Icons.cloud_rounded : Icons.nightlight_round,
              color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            ),
            const SizedBox(width: 12),
            Text(
              isCloud ? '切换到星际主题' : '切换到云端主题',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            '立即注册',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 3. 注册页面

### 文件: `lib/screens/auth/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';

/// 注册页面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('注册成功！'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? '注册失败'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      
                      // 返回按钮
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCloud
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xCC1E1E32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isCloud 
                                  ? CloudTheme.textPrimary 
                                  : SpaceTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // 标题
                      _buildHeader(isCloud),
                      
                      const SizedBox(height: 40),
                      
                      // 表单
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _usernameController,
                              label: '用户名',
                              hint: '请输入用户名',
                              icon: Icons.person_outline,
                              isCloud: isCloud,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入用户名';
                                }
                                if (value.length < 2) {
                                  return '用户名至少2个字符';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              label: '邮箱',
                              hint: '请输入邮箱地址',
                              icon: Icons.email_outlined,
                              isCloud: isCloud,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入邮箱';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return '请输入有效的邮箱地址';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _passwordController,
                              label: '密码',
                              hint: '请输入密码',
                              isCloud: isCloud,
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入密码';
                                }
                                if (value.length < 6) {
                                  return '密码至少6位';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: '确认密码',
                              hint: '请再次输入密码',
                              isCloud: isCloud,
                              obscure: _obscureConfirmPassword,
                              onToggle: () {
                                setState(() => 
                                    _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请确认密码';
                                }
                                if (value != _passwordController.text) {
                                  return '两次密码输入不一致';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 注册按钮
                      _buildRegisterButton(isCloud),
                      
                      const SizedBox(height: 24),
                      
                      // 登录链接
                      _buildLoginLink(isCloud),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud) {
    return Column(
      children: [
        Text(
          '创建账号',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '开启你的音乐情绪之旅',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isCloud,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isCloud,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure 
                  ? Icons.visibility_off_outlined 
                  : Icons.visibility_outlined,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRegisterButton(bool isCloud) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleRegister,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: isCloud
                  ? CloudTheme.buttonGradient
                  : SpaceTheme.buttonGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.primary.withOpacity(0.4)
                      : SpaceTheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '注册',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink(bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账号？',
          style: TextStyle(
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '去登录',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCloud ? CloudTheme.primary : SpaceTheme.accent,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 4. 主题背景包装组件

### 文件: `lib/widgets/backgrounds/themed_background.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import 'cloud_background.dart';
import 'space_background.dart';

/// 根据当前主题自动选择背景
class ThemedBackground extends StatelessWidget {
  final Widget child;
  
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        if (themeProvider.currentTheme == AppThemeType.cloud) {
          return CloudBackground(child: child);
        } else {
          return SpaceBackground(child: child);
        }
      },
    );
  }
}
```

---

## 5. 毛玻璃卡片组件

### 文件: `lib/widgets/common/glass_card.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 毛玻璃卡片组件
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: margin,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xCC1E1E32),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: isCloud
                          ? CloudTheme.softBlue.withOpacity(0.3)
                          : SpaceTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCloud
                            ? CloudTheme.softBlue.withOpacity(0.2)
                            : SpaceTheme.primary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 简单的透明卡片（无模糊效果，性能更好）
class SimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const SimpleCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: margin,
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCloud
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xCC1E1E32),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isCloud
                    ? CloudTheme.softBlue.withOpacity(0.3)
                    : SpaceTheme.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.softBlue.withOpacity(0.2)
                      : SpaceTheme.primary.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}
```

---

## 6. 主题按钮组件

### 文件: `lib/widgets/common/themed_button.dart`

```dart
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
```

---

## 📝 Part 6 完成

本部分包含了播放器页面、登录/注册页面和辅助组件。

## 完整代码索引

### Part 1 - 项目配置与主题系统
- `pubspec.yaml` - 依赖配置
- `lib/config/app_config.dart` - 应用配置
- `lib/config/themes/cloud_theme.dart` - 云端主题
- `lib/config/themes/space_theme.dart` - 星际主题
- `lib/config/themes/app_theme.dart` - 主题管理
- `lib/providers/theme_provider.dart` - 主题状态
- `lib/main.dart` - 入口文件

### Part 2 - 数据模型与服务层
- `lib/models/user.dart` - 用户模型
- `lib/models/music.dart` - 音乐模型
- `lib/models/journal_entry.dart` - 日记条目模型
- `lib/services/api_service.dart` - API 服务
- `lib/providers/auth_provider.dart` - 认证状态
- `lib/providers/music_provider.dart` - 音乐状态

### Part 3 - 动态背景与灵感球组件
- `lib/widgets/backgrounds/cloud_background.dart` - 云端背景
- `lib/widgets/backgrounds/space_background.dart` - 星际背景
- `lib/widgets/orb/inspiration_orb.dart` - 灵感球
- `lib/widgets/orb/cloud_orb.dart` - 云朵灵感球
- `lib/widgets/orb/space_orb.dart` - 星球灵感球
- `lib/widgets/common/mood_bubble.dart` - 心情气泡

### Part 4 - 主页面与创作功能
- `lib/screens/main/main_screen.dart` - 主页面容器
- `lib/screens/create/create_screen.dart` - 创作页面
- `lib/screens/create/input_method_sheet.dart` - 输入方式选择
- `lib/screens/create/text_input_screen.dart` - 文字输入
- `lib/screens/create/voice_input_screen.dart` - 语音输入

### Part 5 - 日记、收藏与生成动画
- `lib/screens/create/image_input_screen.dart` - 图片输入
- `lib/screens/create/generating_screen.dart` - 生成动画
- `lib/screens/journal/journal_screen.dart` - 日记页面
- `lib/widgets/journal/emotion_filter.dart` - 情绪筛选器
- `lib/widgets/journal/timeline_entry.dart` - 时间线条目
- `lib/screens/collection/collection_screen.dart` - 收藏页面
- `lib/widgets/vinyl/vinyl_sleeve.dart` - 黑胶唱片套

### Part 6 - 播放器、认证与辅助组件
- `lib/screens/player/player_screen.dart` - 播放器页面
- `lib/screens/auth/login_screen.dart` - 登录页面
- `lib/screens/auth/register_screen.dart` - 注册页面
- `lib/widgets/backgrounds/themed_background.dart` - 主题背景包装
- `lib/widgets/common/glass_card.dart` - 毛玻璃卡片
- `lib/widgets/common/themed_button.dart` - 主题按钮

---

## 使用说明

1. 按照 Part 1-6 的顺序创建所有文件
2. 确保目录结构正确
3. 运行 `flutter pub get` 安装依赖
4. 创建 `assets/images/` 和 `assets/fonts/` 目录
5. 配置 Android 权限（录音、相机、存储）
6. 运行应用测试

祝你开发顺利！🎵
