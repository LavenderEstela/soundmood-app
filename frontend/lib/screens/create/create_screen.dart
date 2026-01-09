import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/orb/inspiration_orb.dart';
import '../../widgets/common/mood_bubble.dart';
import 'input_method_sheet.dart';

/// 创作页面 - 灵感球首页
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SafeArea(
          child: Column(
            children: [
              // 顶部区域
              _buildHeader(context, isCloud, themeProvider, authProvider),
              
              // 灵感球区域 - 使用 Expanded + LayoutBuilder 实现响应式布局
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 根据可用高度动态调整布局
                    final availableHeight = constraints.maxHeight;
                    final isCompact = availableHeight < 500;
                    
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 心情气泡 - 在小屏幕上缩小
                            _ResponsiveMoodBubbles(
                              isCompact: isCompact,
                              onEmotionSelected: (emotion) {
                                _showInputMethod(context, preSelectedEmotion: emotion);
                              },
                            ),
                            
                            SizedBox(height: isCompact ? 10 : 20),
                            
                            // 灵感球
                            InspirationOrb(
                              onTap: () => _showInputMethod(context),
                              onLongPress: () => _showInputMethod(context, startVoice: true),
                              mainText: '开始创作',
                              subText: '点击输入灵感',
                            ),
                            
                            SizedBox(height: isCompact ? 20 : 40),
                            
                            // 输入提示
                            _buildInputHint(context, isCloud),
                            
                            // 底部安全间距
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isCloud,
    ThemeProvider themeProvider,
    AuthProvider authProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '今天想创作什么？',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                  shadows: isCloud ? null : [
                    Shadow(
                      color: SpaceTheme.primary.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 主题切换按钮
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xE61E1E32),
                boxShadow: isCloud
                    ? [
                        BoxShadow(
                          color: CloudTheme.softBlue.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: SpaceTheme.primary.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  isCloud ? '☀️' : '🌙',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputHint(BuildContext context, bool isCloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _HintItem(
          icon: Icons.mic_rounded,
          label: '长按语音',
          isCloud: isCloud,
        ),
        const SizedBox(width: 24),
        _HintItem(
          icon: Icons.edit_rounded,
          label: '点击文字',
          isCloud: isCloud,
        ),
        const SizedBox(width: 24),
        _HintItem(
          icon: Icons.image_rounded,
          label: '上传图片',
          isCloud: isCloud,
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    if (hour < 22) return '晚上好';
    return '夜深了';
  }

  void _showInputMethod(
    BuildContext context, {
    bool startVoice = false,
    String? preSelectedEmotion,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InputMethodSheet(
        startVoice: startVoice,
        preSelectedEmotion: preSelectedEmotion,
      ),
    );
  }
}

/// 响应式心情气泡组件
class _ResponsiveMoodBubbles extends StatelessWidget {
  final bool isCompact;
  final Function(String emotion)? onEmotionSelected;

  const _ResponsiveMoodBubbles({
    required this.isCompact,
    this.onEmotionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 根据屏幕大小调整尺寸
    final scale = isCompact ? 0.7 : 1.0;
    final width = 320 * scale;
    final height = 200 * scale; // 原来是 300，减小高度

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 将气泡重新排列，使其更紧凑
          _buildBubble('happy', '😊 开心', Offset(-70 * scale, -60 * scale)),
          _buildBubble('calm', '😌 平静', Offset(75 * scale, -30 * scale)),
          _buildBubble('sad', '😢 忧伤', Offset(-65 * scale, 50 * scale)),
          _buildBubble('energetic', '⚡ 活力', Offset(70 * scale, 45 * scale)),
          _buildBubble('nostalgic', '🌙 思念', Offset(0, 70 * scale)),
        ],
      ),
    );
  }

  Widget _buildBubble(String emotion, String label, Offset offset) {
    return MoodBubble(
      emotion: emotion,
      label: label,
      offset: offset,
      onTap: () => onEmotionSelected?.call(emotion),
    );
  }
}

class _HintItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCloud;

  const _HintItem({
    required this.icon,
    required this.label,
    required this.isCloud,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isCloud 
              ? CloudTheme.textSecondary 
              : SpaceTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCloud 
                ? CloudTheme.textSecondary 
                : SpaceTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}