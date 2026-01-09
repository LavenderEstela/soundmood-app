import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';

/// 漂浮的心情气泡
class MoodBubble extends StatefulWidget {
  final String emotion;
  final String label;
  final Offset offset;
  final VoidCallback? onTap;
  
  const MoodBubble({
    super.key,
    required this.emotion,
    required this.label,
    required this.offset,
    this.onTap,
  });

  @override
  State<MoodBubble> createState() => _MoodBubbleState();
}

class _MoodBubbleState extends State<MoodBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _floatOffset;

  @override
  void initState() {
    super.initState();
    _floatOffset = Random().nextDouble() * 2 * pi;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000 + Random().nextInt(2000)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final float = sin(_controller.value * pi * 2 + _floatOffset) * 10;
            
            return Transform.translate(
              offset: widget.offset + Offset(0, float),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCloud
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xE6141428),
                    borderRadius: BorderRadius.circular(25),
                    border: isCloud
                        ? null
                        : Border.all(
                            color: SpaceTheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                    boxShadow: isCloud
                        ? [
                            BoxShadow(
                              color: CloudTheme.softBlue.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: SpaceTheme.primary.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isCloud
                          ? CloudTheme.textPrimary
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 心情气泡组
class MoodBubblesGroup extends StatelessWidget {
  final Function(String emotion)? onEmotionSelected;
  
  const MoodBubblesGroup({super.key, this.onEmotionSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MoodBubble(
            emotion: 'happy',
            label: '😊 开心',
            offset: const Offset(-80, -80),
            onTap: () => onEmotionSelected?.call('happy'),
          ),
          MoodBubble(
            emotion: 'calm',
            label: '😌 平静',
            offset: const Offset(85, -40),
            onTap: () => onEmotionSelected?.call('calm'),
          ),
          MoodBubble(
            emotion: 'sad',
            label: '😢 忧伤',
            offset: const Offset(-70, 80),
            onTap: () => onEmotionSelected?.call('sad'),
          ),
          MoodBubble(
            emotion: 'energetic',
            label: '⚡ 活力',
            offset: const Offset(75, 60),
            onTap: () => onEmotionSelected?.call('energetic'),
          ),
          MoodBubble(
            emotion: 'nostalgic',
            label: '🌙 思念',
            offset: const Offset(0, 110),
            onTap: () => onEmotionSelected?.call('nostalgic'),
          ),
        ],
      ),
    );
  }
}