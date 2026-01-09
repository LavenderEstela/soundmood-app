# SoundMood Flutter 完整实现 - Part 5

## 日记、收藏与生成动画

> 📚 **本部分包含**：
> - 图片输入页面
> - 生成动画页面（灵感球→胶片变形）
> - 日记页面（时间轨迹）
> - 情绪筛选器组件
> - 收藏页面（黑胶唱片箱）

---

## 1. 图片输入页面

### 文件: `lib/screens/create/image_input_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'generating_screen.dart';

/// 图片输入页面
class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({super.key});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  File? _selectedImage;
  int _duration = AppConfig.defaultDuration;
  bool _isGenerating = false;
  
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('无法访问图片，请检查权限设置');
    }
  }

  void _showImageSourceDialog() {
    final isCloud = context.read<ThemeProvider>().isCloudTheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isCloud 
              ? Colors.white 
              : const Color(0xFF1E1E32),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isCloud
                    ? CloudTheme.textSecondary.withOpacity(0.3)
                    : SpaceTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '选择图片来源',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: '拍照',
                  isCloud: isCloud,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: '相册',
                  isCloud: isCloud,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required bool isCloud,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: isCloud
                  ? CloudTheme.imageIconGradient
                  : SpaceTheme.buttonGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.softPink.withOpacity(0.4)
                      : SpaceTheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isCloud ? CloudTheme.textPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
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
    );
  }

  Future<void> _handleGenerate() async {
    if (_selectedImage == null) {
      _showError('请先选择一张图片');
      return;
    }
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromImage(
      title: _titleController.text.trim(),
      imageFile: _selectedImage!,
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (music != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratingScreen(music: music),
        ),
      );
    } else if (mounted) {
      _showError(musicProvider.error ?? '生成失败，请重试');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                  _buildAppBar(isCloud),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 图片选择区域
                            _buildImageSelector(isCloud),
                            
                            const SizedBox(height: 24),
                            
                            // 标题输入
                            _buildTitleField(isCloud),
                            
                            const SizedBox(height: 24),
                            
                            // 时长选择
                            _buildDurationSelector(isCloud),
                            
                            const SizedBox(height: 32),
                            
                            // 生成按钮
                            _buildGenerateButton(isCloud),
                          ],
                        ),
                      ),
                    ),
                  ),
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
          const Spacer(),
          Text(
            '图片创作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildImageSelector(bool isCloud) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 280,
        decoration: BoxDecoration(
          color: isCloud
              ? Colors.white.withOpacity(0.9)
              : const Color(0xCC1E1E32),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.2)
                  : SpaceTheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: _selectedImage != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                    // 渐变遮罩
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '点击更换图片',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildPlaceholder(isCloud),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isCloud) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 装饰背景
            CustomPaint(
              size: const Size.square(200),
              painter: _ImagePlaceholderPainter(
                progress: _shimmerController.value,
                isCloud: isCloud,
              ),
            ),
            // 内容
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: isCloud
                        ? CloudTheme.imageIconGradient
                        : SpaceTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isCloud
                            ? CloudTheme.softPink.withOpacity(0.4)
                            : SpaceTheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 40,
                    color: isCloud ? CloudTheme.textPrimary : Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '选择一张图片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isCloud 
                        ? CloudTheme.textPrimary 
                        : SpaceTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI 将感知图片情绪，创作专属音乐',
                  style: TextStyle(
                    fontSize: 14,
                    color: isCloud 
                        ? CloudTheme.textSecondary 
                        : SpaceTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _titleController,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '音乐标题',
          hintText: '给你的音乐起个名字',
          prefixIcon: Icon(
            Icons.music_note_rounded,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '请输入标题';
          return null;
        },
      ),
    );
  }

  Widget _buildDurationSelector(bool isCloud) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '音乐时长',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isCloud
                      ? CloudTheme.buttonGradient
                      : SpaceTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_duration 秒',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.primary,
              inactiveTrackColor: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.3)
                  : SpaceTheme.primary.withOpacity(0.2),
              thumbColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.accent,
            ),
            child: Slider(
              value: _duration.toDouble(),
              min: AppConfig.minDuration.toDouble(),
              max: AppConfig.maxDuration.toDouble(),
              divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
              onChanged: (value) => setState(() => _duration = value.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isCloud) {
    return GestureDetector(
      onTap: _isGenerating ? null : _handleGenerate,
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
          child: _isGenerating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '开始生成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 图片占位符装饰画笔
class _ImagePlaceholderPainter extends CustomPainter {
  final double progress;
  final bool isCloud;

  _ImagePlaceholderPainter({
    required this.progress,
    required this.isCloud,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制装饰圆环
    for (int i = 0; i < 3; i++) {
      final radius = 60.0 + i * 25.0;
      final opacity = (1 - i * 0.3) * (0.3 + 0.2 * (1 + sin(progress * 2 * 3.14159 + i)));
      
      paint.color = isCloud
          ? CloudTheme.softPink.withOpacity(opacity)
          : SpaceTheme.primary.withOpacity(opacity);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ImagePlaceholderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

---

## 2. 生成动画页面

### 文件: `lib/screens/create/generating_screen.dart`

```dart
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
```

---

## 3. 日记页面（时间轨迹）

### 文件: `lib/screens/journal/journal_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/journal_entry.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/journal/emotion_filter.dart';
import '../../widgets/journal/timeline_entry.dart';
import '../player/player_screen.dart';

/// 日记页面 - 时间轨迹
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedEmotion;
  bool _isListView = true; // true: 列表视图, false: 日历视图

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadJournal();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onEmotionSelected(String? emotion) {
    setState(() => _selectedEmotion = emotion);
    context.read<MusicProvider>().loadJournal(emotion: emotion);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, MusicProvider>(
      builder: (context, themeProvider, musicProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SafeArea(
          child: Column(
            children: [
              // 头部区域
              _buildHeader(isCloud, themeProvider),
              
              // 统计卡片
              _buildStatsCard(isCloud, musicProvider.stats),
              
              // 情绪筛选器
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: EmotionFilter(
                  selectedEmotion: _selectedEmotion,
                  onEmotionSelected: _onEmotionSelected,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 视图切换
              _buildViewToggle(isCloud),
              
              const SizedBox(height: 8),
              
              // 内容区域
              Expanded(
                child: musicProvider.isLoadingJournal
                    ? _buildLoading(isCloud)
                    : musicProvider.journalGroups.isEmpty
                        ? _buildEmpty(isCloud)
                        : _buildJournalList(isCloud, musicProvider.journalGroups),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '时间轨迹',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '记录每一刻的心情旋律',
                style: TextStyle(
                  fontSize: 14,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
            ],
          ),
          // 主题切换按钮
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xCC1E1E32),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isCloud ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isCloud, JournalStats? stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.2)
                : SpaceTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            isCloud: isCloud,
            value: '${stats?.totalCount ?? 0}',
            label: '总创作',
            icon: Icons.music_note_rounded,
          ),
          _buildStatDivider(isCloud),
          _buildStatItem(
            isCloud: isCloud,
            value: '${stats?.monthCount ?? 0}',
            label: '本月',
            icon: Icons.calendar_today_rounded,
          ),
          _buildStatDivider(isCloud),
          _buildStatItem(
            isCloud: isCloud,
            value: stats?.listenTimeString ?? '0分钟',
            label: '聆听',
            icon: Icons.headphones_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isCloud,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isCloud
                ? CloudTheme.buttonGradient
                : SpaceTheme.buttonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isCloud) {
    return Container(
      width: 1,
      height: 60,
      color: isCloud
          ? CloudTheme.softBlue.withOpacity(0.3)
          : SpaceTheme.primary.withOpacity(0.2),
    );
  }

  Widget _buildViewToggle(bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0x991E1E32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isListView = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isListView
                              ? (isCloud
                                  ? CloudTheme.softBlue.withOpacity(0.5)
                                  : SpaceTheme.primary.withOpacity(0.4))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_list_rounded,
                              size: 18,
                              color: isCloud
                                  ? CloudTheme.textPrimary
                                  : SpaceTheme.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '时间线',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _isListView 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: isCloud
                                    ? CloudTheme.textPrimary
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isListView = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isListView
                              ? (isCloud
                                  ? CloudTheme.softBlue.withOpacity(0.5)
                                  : SpaceTheme.primary.withOpacity(0.4))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_view_month_rounded,
                              size: 18,
                              color: isCloud
                                  ? CloudTheme.textPrimary
                                  : SpaceTheme.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '日历',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_isListView 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: isCloud
                                    ? CloudTheme.textPrimary
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildLoading(bool isCloud) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isCloud ? CloudTheme.primary : SpaceTheme.accent,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isCloud) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 80,
            color: isCloud 
                ? CloudTheme.textSecondary.withOpacity(0.3)
                : SpaceTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有创作记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去创作页面开始你的第一首音乐吧',
            style: TextStyle(
              fontSize: 14,
              color: isCloud 
                  ? CloudTheme.textSecondary.withOpacity(0.7)
                  : SpaceTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(bool isCloud, List<JournalGroup> groups) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCloud 
                          ? CloudTheme.primary 
                          : SpaceTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    group.displayDate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCloud 
                          ? CloudTheme.textPrimary 
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCloud
                          ? CloudTheme.softBlue.withOpacity(0.3)
                          : SpaceTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${group.count}首',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCloud 
                            ? CloudTheme.textSecondary 
                            : SpaceTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 条目列表
            ...group.entries.asMap().entries.map((entry) {
              final index = entry.key;
              final journalEntry = entry.value;
              final isLast = index == group.entries.length - 1;
              
              return TimelineEntry(
                entry: journalEntry,
                isLast: isLast,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        music: journalEntry.music,
                      ),
                    ),
                  );
                },
              );
            }),
            
            if (groupIndex < groups.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
```

---

## 4. 情绪筛选器组件

### 文件: `lib/widgets/journal/emotion_filter.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 情绪筛选器
class EmotionFilter extends StatelessWidget {
  final String? selectedEmotion;
  final Function(String?) onEmotionSelected;

  const EmotionFilter({
    super.key,
    this.selectedEmotion,
    required this.onEmotionSelected,
  });

  static const List<Map<String, String>> emotions = [
    {'key': 'all', 'label': '全部', 'emoji': '✨'},
    {'key': 'happy', 'label': '开心', 'emoji': '😊'},
    {'key': 'calm', 'label': '平静', 'emoji': '😌'},
    {'key': 'sad', 'label': '忧伤', 'emoji': '😢'},
    {'key': 'energetic', 'label': '活力', 'emoji': '⚡'},
    {'key': 'nostalgic', 'label': '思念', 'emoji': '🌙'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              final emotion = emotions[index];
              final isSelected = (emotion['key'] == 'all' && selectedEmotion == null) ||
                  emotion['key'] == selectedEmotion;
              
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == emotions.length - 1 ? 0 : 0,
                ),
                child: _EmotionPill(
                  emoji: emotion['emoji']!,
                  label: emotion['label']!,
                  isSelected: isSelected,
                  isCloud: isCloud,
                  onTap: () {
                    onEmotionSelected(
                      emotion['key'] == 'all' ? null : emotion['key'],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EmotionPill extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final bool isCloud;
  final VoidCallback onTap;

  const _EmotionPill({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isCloud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCloud
                  ? CloudTheme.softBlue.withOpacity(0.6)
                  : SpaceTheme.primary.withOpacity(0.4))
              : (isCloud
                  ? Colors.white.withOpacity(0.8)
                  : const Color(0x991E1E32)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? (isCloud ? CloudTheme.primary : SpaceTheme.accent)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
}
```

---

## 5. 时间线条目组件

### 文件: `lib/widgets/journal/timeline_entry.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/journal_entry.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 时间线条目
class TimelineEntry extends StatelessWidget {
  final JournalEntry entry;
  final bool isLast;
  final VoidCallback? onTap;

  const TimelineEntry({
    super.key,
    required this.entry,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        final music = entry.music;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间线
              _buildTimeline(isCloud),
              
              const SizedBox(width: 16),
              
              // 内容卡片
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCloud
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xCC1E1E32),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCloud
                            ? CloudTheme.softBlue.withOpacity(0.2)
                            : SpaceTheme.primary.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCloud
                              ? CloudTheme.softBlue.withOpacity(0.15)
                              : SpaceTheme.primary.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 左侧信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题和输入类型
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      music.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isCloud
                                            ? CloudTheme.textPrimary
                                            : SpaceTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInputTypeBadge(isCloud, music.inputType),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // 情绪标签
                              if (music.emotionTags != null && music.emotionTags!.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: music.emotionTags!.take(3).map((tag) {
                                    return _buildEmotionTag(isCloud, tag);
                                  }).toList(),
                                ),
                              
                              const SizedBox(height: 10),
                              
                              // 时间和时长
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: isCloud
                                        ? CloudTheme.textSecondary
                                        : SpaceTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.timeString,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCloud
                                          ? CloudTheme.textSecondary
                                          : SpaceTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.music_note_rounded,
                                    size: 14,
                                    color: isCloud
                                        ? CloudTheme.textSecondary
                                        : SpaceTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    music.durationString,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCloud
                                          ? CloudTheme.textSecondary
                                          : SpaceTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // 播放按钮
                        _buildPlayButton(isCloud),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline(bool isCloud) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          // 时间点
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCloud ? CloudTheme.softBlue : SpaceTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.softBlue.withOpacity(0.5)
                      : SpaceTheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // 连接线
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isCloud ? CloudTheme.softBlue : SpaceTheme.primary,
                      isCloud
                          ? CloudTheme.softPink.withOpacity(0.5)
                          : SpaceTheme.secondary.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputTypeBadge(bool isCloud, inputType) {
    String icon;
    Color bgColor;
    
    switch (inputType.toString()) {
      case 'InputType.voice':
        icon = '🎤';
        bgColor = isCloud
            ? CloudTheme.softBlue.withOpacity(0.3)
            : SpaceTheme.cyan.withOpacity(0.2);
        break;
      case 'InputType.image':
        icon = '🖼️';
        bgColor = isCloud
            ? CloudTheme.softPink.withOpacity(0.3)
            : SpaceTheme.pink.withOpacity(0.2);
        break;
      default:
        icon = '✍️';
        bgColor = isCloud
            ? CloudTheme.accent.withOpacity(0.3)
            : SpaceTheme.accent.withOpacity(0.2);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        icon,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildEmotionTag(bool isCloud, String tag) {
    final emotionData = _getEmotionData(tag);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCloud
            ? CloudTheme.emotionColors[tag]?.withOpacity(0.3) ??
                CloudTheme.softBlue.withOpacity(0.3)
            : SpaceTheme.emotionColors[tag]?.withOpacity(0.2) ??
                SpaceTheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${emotionData['emoji']} ${emotionData['label']}',
        style: TextStyle(
          fontSize: 11,
          color: isCloud
              ? CloudTheme.textSecondary
              : SpaceTheme.textSecondary,
        ),
      ),
    );
  }

  Map<String, String> _getEmotionData(String key) {
    const emotions = {
      'happy': {'emoji': '😊', 'label': '开心'},
      'calm': {'emoji': '😌', 'label': '平静'},
      'sad': {'emoji': '😢', 'label': '忧伤'},
      'energetic': {'emoji': '⚡', 'label': '活力'},
      'nostalgic': {'emoji': '🌙', 'label': '思念'},
    };
    return emotions[key] ?? {'emoji': '✨', 'label': key};
  }

  Widget _buildPlayButton(bool isCloud) {
    return Container(
      width: 44,
      height: 44,
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
```

---

## 6. 收藏页面（黑胶唱片箱）

### 文件: `lib/screens/collection/collection_screen.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/music.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/vinyl/vinyl_sleeve.dart';
import '../player/player_screen.dart';

/// 收藏页面 - 黑胶唱片箱
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String _selectedTag = '全部';
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, MusicProvider>(
      builder: (context, themeProvider, musicProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SafeArea(
          child: Column(
            children: [
              // 头部
              _buildHeader(isCloud, themeProvider),
              
              // 标签筛选
              _buildTagFilter(isCloud),
              
              const SizedBox(height: 16),
              
              // 唱片箱
              Expanded(
                child: musicProvider.isLoadingFavorites
                    ? _buildLoading(isCloud)
                    : musicProvider.favorites.isEmpty
                        ? _buildEmpty(isCloud)
                        : _buildVinylCrate(isCloud, musicProvider.favorites),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我的收藏',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '珍藏每一份感动',
                style: TextStyle(
                  fontSize: 14,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
            ],
          ),
          // 主题切换按钮
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xCC1E1E32),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isCloud ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilter(bool isCloud) {
    final tags = ['全部', '#治愈', '#工作', '#助眠', '#放松'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag == _selectedTag;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tags.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTag = tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCloud
                          ? CloudTheme.softBlue.withOpacity(0.6)
                          : SpaceTheme.primary.withOpacity(0.4))
                      : (isCloud
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0x991E1E32)),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: isCloud 
                              ? CloudTheme.primary 
                              : SpaceTheme.accent,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isCloud 
                        ? CloudTheme.textPrimary 
                        : SpaceTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(bool isCloud) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isCloud ? CloudTheme.primary : SpaceTheme.accent,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isCloud) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.album_outlined,
            size: 80,
            color: isCloud 
                ? CloudTheme.textSecondary.withOpacity(0.3)
                : SpaceTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有收藏',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '播放音乐时点击收藏按钮添加',
            style: TextStyle(
              fontSize: 14,
              color: isCloud 
                  ? CloudTheme.textSecondary.withOpacity(0.7)
                  : SpaceTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylCrate(bool isCloud, List<Music> favorites) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? const Color(0xFFDEB887).withOpacity(0.3) // 木纹色
            : const Color(0xFF2A2A3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCloud
              ? const Color(0xFFD2B48C).withOpacity(0.5)
              : const Color(0xFF3A3A4A),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 唱片架标签
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCloud
                      ? const Color(0xFFDEB887)
                      : SpaceTheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${favorites.length} 张唱片',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCloud 
                        ? const Color(0xFF8B4513)
                        : SpaceTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 唱片列表
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final music = favorites[index];
                final isExpanded = _expandedIndex == index;
                
                return VinylSleeve(
                  music: music,
                  isExpanded: isExpanded,
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                  onPlay: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(music: music),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 7. 黑胶唱片套组件

### 文件: `lib/widgets/vinyl/vinyl_sleeve.dart`

```dart
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
    final gradient = _getEmotionGradient(isCloud, emotion);
    final emoji = _getEmotionEmoji(emotion);
    
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
```

---

## 📝 Part 5 完成

本部分包含了图片输入、生成动画、日记页面和收藏页面。接下来的 Part 6 将包含：

- 播放器页面（黑胶唱片播放器）
- 登录/注册页面
- 辅助背景组件
- 通用工具类

请继续查看 Part 6...
