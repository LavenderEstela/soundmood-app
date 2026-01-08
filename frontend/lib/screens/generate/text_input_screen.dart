import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

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
      appBar: AppBar(title: const Text('文字创作')),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _textController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '情感描述',
                  hintText: '描述你的情感、心情或想要的场景...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return '请输入描述';
                  if (value.length < 10) return '描述至少 10 个字符';
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
                onPressed: _isGenerating ? null : _handleGenerate,
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