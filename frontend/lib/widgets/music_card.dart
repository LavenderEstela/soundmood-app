import 'package:flutter/material.dart';
import '../models/music.dart';
import '../config/theme.dart';

class MusicCard extends StatelessWidget {
  final Music music;

  const MusicCard({super.key, required this.music});

  String _getStatusText() {
    switch (music.status) {
      case MusicStatus.generating:
        return '生成中...';
      case MusicStatus.completed:
        return '已完成';
      case MusicStatus.failed:
        return '生成失败';
    }
  }

  Color _getStatusColor() {
    switch (music.status) {
      case MusicStatus.generating:
        return AppTheme.accentColor;
      case MusicStatus.completed:
        return Colors.green;
      case MusicStatus.failed:
        return Colors.red;
    }
  }

  IconData _getInputTypeIcon() {
    switch (music.inputType) {
      case InputType.voice:
        return Icons.mic_rounded;
      case InputType.text:
        return Icons.text_fields_rounded;
      case InputType.image:
        return Icons.image_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: music.status == MusicStatus.completed
            ? () {
                // TODO: 播放音乐
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getInputTypeIcon(),
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${music.duration}s',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (music.status == MusicStatus.completed)
                    const Icon(Icons.play_circle_filled, 
                      color: AppTheme.primaryColor, 
                      size: 40,
                    ),
                ],
              ),
              if (music.emotionTags != null && music.emotionTags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: music.emotionTags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}