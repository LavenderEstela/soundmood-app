import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../config/themes/app_theme.dart';
import '../config/themes/cloud_theme.dart';
import '../config/themes/space_theme.dart';
import '../models/music.dart';

/// 音乐卡片组件
class MusicCard extends StatelessWidget {
  final Music music;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final bool showPlayButton;
  final bool compact;

  const MusicCard({
    super.key,
    required this.music,
    this.onTap,
    this.onPlay,
    this.onFavorite,
    this.showPlayButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;

        // 修复: 使用条件判断获取颜色
        final accentColor = isCloud ? CloudTheme.accent : SpaceTheme.accent;
        final primaryColor = isCloud ? CloudTheme.primary : SpaceTheme.primary;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(compact ? 12 : 16),
            decoration: BoxDecoration(
              color: isCloud
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xCC1E1E32),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCloud
                    ? CloudTheme.softBlue.withValues(alpha: 0.3)
                    : SpaceTheme.primary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: isCloud
                      ? CloudTheme.softBlue.withValues(alpha: 0.2)
                      : SpaceTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // 封面/情绪图标
                _buildCover(isCloud, primaryColor),

                SizedBox(width: compact ? 12 : 16),

                // 音乐信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        music.title,
                        style: TextStyle(
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: isCloud
                              ? CloudTheme.textPrimary
                              : SpaceTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            music.inputTypeIcon,
                            style: TextStyle(fontSize: compact ? 10 : 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            music.inputTypeLabel,
                            style: TextStyle(
                              fontSize: compact ? 11 : 12,
                              color: isCloud
                                  ? CloudTheme.textSecondary
                                  : SpaceTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            music.durationString,
                            style: TextStyle(
                              fontSize: compact ? 11 : 12,
                              color: isCloud
                                  ? CloudTheme.textSecondary
                                  : SpaceTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (music.emotionTags != null &&
                          music.emotionTags!.isNotEmpty &&
                          !compact) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: music.emotionTags!.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // 操作按钮
                if (showPlayButton) ...[
                  const SizedBox(width: 8),
                  _buildActionButtons(isCloud, accentColor, primaryColor),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(bool isCloud, Color primaryColor) {
    final emotion = music.primaryEmotion;
    final emoji = _getEmotionEmoji(emotion);

    return Container(
      width: compact ? 48 : 60,
      height: compact ? 48 : 60,
      decoration: BoxDecoration(
        gradient: _getEmotionGradient(isCloud, emotion),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: compact ? 20 : 24),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isCloud, Color accentColor, Color primaryColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 收藏按钮
        if (onFavorite != null)
          GestureDetector(
            onTap: onFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: music.isFavorite
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                music.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: music.isFavorite
                    ? Colors.red
                    : (isCloud
                        ? CloudTheme.textSecondary
                        : SpaceTheme.textSecondary),
              ),
            ),
          ),

        const SizedBox(width: 4),

        // 播放按钮
        if (onPlay != null)
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isCloud
                    ? CloudTheme.buttonGradient
                    : SpaceTheme.buttonGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // 修复: 移除 const，因为颜色是动态的
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
      ],
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