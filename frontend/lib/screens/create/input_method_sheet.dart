import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import 'text_input_screen.dart';
import 'voice_input_screen.dart';
import 'image_input_screen.dart';

/// 输入方式选择弹窗
class InputMethodSheet extends StatelessWidget {
  final bool startVoice;
  final String? preSelectedEmotion;

  const InputMethodSheet({
    super.key,
    this.startVoice = false,
    this.preSelectedEmotion,
  });

  @override
  Widget build(BuildContext context) {
    // 如果是长按触发，直接进入语音输入
    if (startVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VoiceInputScreen(
              preSelectedEmotion: preSelectedEmotion,
            ),
          ),
        );
      });
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Container(
          decoration: BoxDecoration(
            color: isCloud ? Colors.white : const Color(0xFF141428),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: isCloud
                    ? CloudTheme.softBlue.withOpacity(0.3)
                    : SpaceTheme.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖动指示器
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCloud
                        ? CloudTheme.textSecondary.withOpacity(0.3)
                        : SpaceTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 标题
                Text(
                  '选择输入方式',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isCloud 
                        ? CloudTheme.textPrimary 
                        : SpaceTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '用你喜欢的方式表达情感',
                  style: TextStyle(
                    fontSize: 14,
                    color: isCloud 
                        ? CloudTheme.textSecondary 
                        : SpaceTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 三个输入选项
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InputMethodCard(
                          icon: Icons.mic_rounded,
                          title: '语音',
                          subtitle: '说出你的心情',
                          gradient: isCloud
                              ? CloudTheme.voiceIconGradient
                              : SpaceTheme.voiceIconGradient,
                          isCloud: isCloud,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VoiceInputScreen(
                                  preSelectedEmotion: preSelectedEmotion,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputMethodCard(
                          icon: Icons.edit_rounded,
                          title: '文字',
                          subtitle: '写下你的感受',
                          gradient: isCloud
                              ? CloudTheme.textIconGradient
                              : SpaceTheme.textIconGradient,
                          isCloud: isCloud,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TextInputScreen(
                                  preSelectedEmotion: preSelectedEmotion,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputMethodCard(
                          icon: Icons.image_rounded,
                          title: '图片',
                          subtitle: '分享一张照片',
                          gradient: isCloud
                              ? CloudTheme.imageIconGradient
                              : SpaceTheme.imageIconGradient,
                          isCloud: isCloud,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageInputScreen(
                                  preSelectedEmotion: preSelectedEmotion,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InputMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final bool isCloud;
  final VoidCallback onTap;

  const _InputMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isCloud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isCloud
              ? Colors.white
              : const Color(0xFF1E1E32),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.3)
                : SpaceTheme.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.2)
                  : SpaceTheme.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isCloud ? CloudTheme.textPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isCloud 
                    ? CloudTheme.textSecondary 
                    : SpaceTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}