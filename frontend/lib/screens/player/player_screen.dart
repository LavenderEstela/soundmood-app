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
              gradient: _getLabelGradient(isCloud, emotion ?? 'calm'),
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
                    _getEmotionEmoji(emotion ?? 'calm'),
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