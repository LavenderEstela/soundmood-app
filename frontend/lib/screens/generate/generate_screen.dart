import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'text_input_screen.dart';
import 'voice_input_screen.dart';
import 'image_input_screen.dart';

class GenerateScreen extends StatelessWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 音乐创作'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '选择创作方式',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '从文字、语音或图片生成独特的音乐',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 文字输入
            _GenerateMethodCard(
              title: '文字描述',
              subtitle: '用文字描述你的情感或场景',
              icon: Icons.text_fields_rounded,
              gradient: AppTheme.primaryGradient,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TextInputScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 语音输入
            _GenerateMethodCard(
              title: '语音录制',
              subtitle: '说出你的感受，让AI理解你的情绪',
              icon: Icons.mic_rounded,
              gradient: AppTheme.secondaryGradient,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 图片输入
            _GenerateMethodCard(
              title: '图片灵感',
              subtitle: '上传图片，AI 将捕捉其中的情感',
              icon: Icons.image_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImageInputScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GenerateMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}