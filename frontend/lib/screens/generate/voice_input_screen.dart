import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recorder = AudioRecorder();
  
  int _duration = AppConfig.defaultDuration;
  bool _isRecording = false;
  bool _isGenerating = false;
  String? _recordedPath;

  @override
  void dispose() {
    _titleController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 停止录音
      final path = await _recorder.stop();
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
        
        setState(() => _isRecording = true);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音乐生成已开始，请稍候...'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('语音创作')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '音乐标题',
                  hintText: '给你的音乐起个名字',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入标题';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // 录音按钮
              Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isRecording
                          ? AppTheme.secondaryGradient
                          : AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor)
                              .withOpacity(0.4),
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
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording
                    ? '录音中...点击停止'
                    : (_recordedPath != null ? '录音完成 ✓' : '点击开始录音'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              Text(
                '音乐时长: $_duration 秒',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _duration.toDouble(),
                min: AppConfig.minDuration.toDouble(),
                max: AppConfig.maxDuration.toDouble(),
                divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
                label: '$_duration 秒',
                onChanged: (value) => setState(() => _duration = value.toInt()),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: (_isGenerating || _isRecording) ? null : _handleGenerate,
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始生成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}