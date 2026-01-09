import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'generating_screen.dart';

/// 语音输入页面
class VoiceInputScreen extends StatefulWidget {
  final String? preSelectedEmotion;
  
  const VoiceInputScreen({super.key, this.preSelectedEmotion});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recorder = AudioRecorder();
  
  late AnimationController _waveController;
  
  int _duration = AppConfig.defaultDuration;
  bool _isRecording = false;
  bool _isGenerating = false;
  String? _recordedPath;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recorder.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 停止录音
      final path = await _recorder.stop();
      _waveController.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } else {
      // 开始录音
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        _waveController.repeat();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        
        // 开始计时
        _startTimer();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要麦克风权限'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() => _recordingSeconds++);
        _startTimer();
      }
    });
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_recordedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先录制语音'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final musicProvider = context.read<MusicProvider>();
    final music = await musicProvider.generateFromVoice(
      title: _titleController.text.trim(),
      audioFile: File(_recordedPath!),
      duration: _duration,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (music != null) {
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
                          children: [
                            // 标题输入
                            _buildTitleField(isCloud),
                            
                            const SizedBox(height: 40),
                            
                            // 录音按钮
                            _buildRecordButton(isCloud),
                            
                            const SizedBox(height: 16),
                            
                            // 录音状态文字
                            Text(
                              _isRecording
                                  ? '录音中... ${_formatSeconds(_recordingSeconds)}'
                                  : (_recordedPath != null 
                                      ? '录音完成 ✓ ${_formatSeconds(_recordingSeconds)}'
                                      : '点击开始录音'),
                              style: TextStyle(
                                fontSize: 16,
                                color: isCloud 
                                    ? CloudTheme.textPrimary 
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
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
            '语音创作',
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

  Widget _buildRecordButton(bool isCloud) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return GestureDetector(
          onTap: _toggleRecording,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 波纹效果
                if (_isRecording) ...[
                  for (int i = 0; i < 3; i++)
                    _buildWaveRing(isCloud, i),
                ],
                
                // 主按钮
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isRecording
                        ? LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          )
                        : (isCloud
                            ? CloudTheme.buttonGradient
                            : SpaceTheme.buttonGradient),
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording
                            ? Colors.red.withOpacity(0.4)
                            : (isCloud
                                ? CloudTheme.primary.withOpacity(0.4)
                                : SpaceTheme.primary.withOpacity(0.4)),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveRing(bool isCloud, int index) {
    final progress = (_waveController.value + index * 0.3) % 1.0;
    final scale = 1.0 + progress * 0.8;
    final opacity = (1.0 - progress) * 0.5;
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.red.withOpacity(opacity),
            width: 2,
          ),
        ),
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
      onTap: (_isGenerating || _isRecording) ? null : _handleGenerate,
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

  String _formatSeconds(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}