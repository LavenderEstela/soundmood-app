import 'dart:io';
import 'dart:math'; 
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

  final String? preSelectedEmotion;  // ← 添加这个字段

  const ImageInputScreen({
    super.key,
    this.preSelectedEmotion,  // ← 添加这个参数
  });

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