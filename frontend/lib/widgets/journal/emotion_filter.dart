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