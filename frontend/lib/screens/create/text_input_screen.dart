import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'generating_screen.dart';

/// 文字输入页面
class TextInputScreen extends StatefulWidget {
  final String? preSelectedEmotion;
  
  const TextInputScreen({super.key, this.preSelectedEmotion});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  int _duration = AppConfig.defaultDuration;
  bool _isGenerating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromText(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (music != null) {
      // 跳转到生成动画页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GeneratingScreen(music: music),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(musicProvider.error ?? '生成失败'),
          backgroundColor: Colors.red,
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
              child: Column(
                children: [
                  _buildAppBar(context, isCloud),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 标题输入
                            _buildTextField(
                              controller: _titleController,
                              label: '音乐标题',
                              hint: '给你的音乐起个名字',
                              icon: Icons.music_note_rounded,
                              isCloud: isCloud,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入标题';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 情感描述输入
                            _buildTextField(
                              controller: _textController,
                              label: '情感描述',
                              hint: '描述你的情感、心情或想要的场景...\n\n例如：\n• 阳光透过窗户洒在身上的温暖\n• 雨天窗边看书的宁静\n• 夜晚独自散步的思绪',
                              icon: Icons.edit_note_rounded,
                              isCloud: isCloud,
                              maxLines: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入描述';
                                }
                                if (value.length < 10) {
                                  return '描述至少 10 个字符';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // 时长选择
                            _buildDurationSelector(isCloud),
                            
                            const SizedBox(height: 40),
                            
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

  Widget _buildAppBar(BuildContext context, bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
          Text(
            '文字创作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isCloud,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
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
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.15)
                : Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: isCloud
                ? CloudTheme.textSecondary.withOpacity(0.5)
                : SpaceTheme.textSecondary.withOpacity(0.5),
          ),
          prefixIcon: maxLines == 1
              ? Icon(icon, color: isCloud ? CloudTheme.primary : SpaceTheme.primary)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
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
              overlayColor: isCloud
                  ? CloudTheme.primary.withOpacity(0.2)
                  : SpaceTheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _duration.toDouble(),
              min: AppConfig.minDuration.toDouble(),
              max: AppConfig.maxDuration.toDouble(),
              divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
              onChanged: (value) => setState(() => _duration = value.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppConfig.minDuration}秒',
                style: TextStyle(
                  fontSize: 12,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
              Text(
                '${AppConfig.maxDuration}秒',
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