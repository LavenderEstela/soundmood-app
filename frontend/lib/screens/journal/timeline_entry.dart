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