# SoundMood Flutter 完整实现 - Part 4

## 主页面与创作功能

> 🎵 **本部分包含**：
> - 主页面容器与底部导航
> - 创作页面（灵感球首页）
> - 输入方式选择弹窗
> - 文字/语音/图片输入页面
> - 生成动画页面

---

## 1. 主页面容器

### 文件: `lib/screens/main/main_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import '../create/create_screen.dart';
import '../journal/journal_screen.dart';
import '../collection/collection_screen.dart';

/// 主页面 - 包含底部导航
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CreateScreen(),     // 创作
    JournalScreen(),    // 日记
    CollectionScreen(), // 收藏
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: _buildBottomNav(isCloud),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud 
            ? Colors.white.withOpacity(0.95)
            : const Color(0xE6141428),
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.2)
                : SpaceTheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: '创作',
                isSelected: _currentIndex == 0,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.schedule_rounded,
                label: '日记',
                isSelected: _currentIndex == 1,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.album_rounded,
                label: '收藏',
                isSelected: _currentIndex == 2,
                isCloud: isCloud,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCloud;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCloud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isCloud 
        ? CloudTheme.textPrimary 
        : SpaceTheme.accent;
    final unselectedColor = isCloud 
        ? CloudTheme.textSecondary 
        : SpaceTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCloud 
                  ? CloudTheme.softBlue.withOpacity(0.3)
                  : SpaceTheme.primary.withOpacity(0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 2. 创作页面

### 文件: `lib/screens/create/create_screen.dart`

```dart
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
              
              // 灵感球区域
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 心情气泡
                      MoodBubblesGroup(
                        onEmotionSelected: (emotion) {
                          _showInputMethod(context, preSelectedEmotion: emotion);
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 灵感球
                      InspirationOrb(
                        onTap: () => _showInputMethod(context),
                        onLongPress: () => _showInputMethod(context, startVoice: true),
                        mainText: '开始创作',
                        subText: '点击输入灵感',
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 输入提示
                      _buildInputHint(context, isCloud),
                    ],
                  ),
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
```

---

## 3. 输入方式选择弹窗

### 文件: `lib/screens/create/input_method_sheet.dart`

```dart
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
```

---

## 4. 文字输入页面

### 文件: `lib/screens/create/text_input_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'generating_screen.dart';

/// 文字输入页面
class TextInputScreen extends StatefulWidget {
  final String? preSelectedEmotion;
  
  const TextInputScreen({super.key, this.preSelectedEmotion});

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
      // 跳转到生成动画页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GeneratingScreen(music: music),
        ),
      );
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isCloud),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 标题输入
                            _buildTextField(
                              controller: _titleController,
                              label: '音乐标题',
                              hint: '给你的音乐起个名字',
                              icon: Icons.music_note_rounded,
                              isCloud: isCloud,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入标题';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 情感描述输入
                            _buildTextField(
                              controller: _textController,
                              label: '情感描述',
                              hint: '描述你的情感、心情或想要的场景...\n\n例如：\n• 阳光透过窗户洒在身上的温暖\n• 雨天窗边看书的宁静\n• 夜晚独自散步的思绪',
                              icon: Icons.edit_note_rounded,
                              isCloud: isCloud,
                              maxLines: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入描述';
                                }
                                if (value.length < 10) {
                                  return '描述至少 10 个字符';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // 时长选择
                            _buildDurationSelector(isCloud),
                            
                            const SizedBox(height: 40),
                            
                            // 生成按钮
                            _buildGenerateButton(isCloud),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
          Text(
            '文字创作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isCloud,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.15)
                : Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: isCloud
                ? CloudTheme.textSecondary.withOpacity(0.5)
                : SpaceTheme.textSecondary.withOpacity(0.5),
          ),
          prefixIcon: maxLines == 1
              ? Icon(icon, color: isCloud ? CloudTheme.primary : SpaceTheme.primary)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDurationSelector(bool isCloud) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '音乐时长',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isCloud
                      ? CloudTheme.buttonGradient
                      : SpaceTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_duration 秒',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.primary,
              inactiveTrackColor: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.3)
                  : SpaceTheme.primary.withOpacity(0.2),
              thumbColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.accent,
              overlayColor: isCloud
                  ? CloudTheme.primary.withOpacity(0.2)
                  : SpaceTheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _duration.toDouble(),
              min: AppConfig.minDuration.toDouble(),
              max: AppConfig.maxDuration.toDouble(),
              divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
              onChanged: (value) => setState(() => _duration = value.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppConfig.minDuration}秒',
                style: TextStyle(
                  fontSize: 12,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
                ),
              ),
              Text(
                '${AppConfig.maxDuration}秒',
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
    );
  }

  Widget _buildGenerateButton(bool isCloud) {
    return GestureDetector(
      onTap: _isGenerating ? null : _handleGenerate,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isCloud
              ? CloudTheme.buttonGradient
              : SpaceTheme.buttonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isCloud
                  ? CloudTheme.primary.withOpacity(0.4)
                  : SpaceTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isGenerating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '开始生成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
```

---

## 5. 语音输入页面

### 文件: `lib/screens/create/voice_input_screen.dart`

```dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../config/app_config.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/backgrounds/themed_background.dart';
import 'generating_screen.dart';

/// 语音输入页面
class VoiceInputScreen extends StatefulWidget {
  final String? preSelectedEmotion;
  
  const VoiceInputScreen({super.key, this.preSelectedEmotion});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recorder = AudioRecorder();
  
  late AnimationController _waveController;
  
  int _duration = AppConfig.defaultDuration;
  bool _isRecording = false;
  bool _isGenerating = false;
  String? _recordedPath;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recorder.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 停止录音
      final path = await _recorder.stop();
      _waveController.stop();
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
        
        _waveController.repeat();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        
        // 开始计时
        _startTimer();
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

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() => _recordingSeconds++);
        _startTimer();
      }
    });
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GeneratingScreen(music: music),
        ),
      );
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return Scaffold(
          body: ThemedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isCloud),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // 标题输入
                            _buildTitleField(isCloud),
                            
                            const SizedBox(height: 40),
                            
                            // 录音按钮
                            _buildRecordButton(isCloud),
                            
                            const SizedBox(height: 16),
                            
                            // 录音状态文字
                            Text(
                              _isRecording
                                  ? '录音中... ${_formatSeconds(_recordingSeconds)}'
                                  : (_recordedPath != null 
                                      ? '录音完成 ✓ ${_formatSeconds(_recordingSeconds)}'
                                      : '点击开始录音'),
                              style: TextStyle(
                                fontSize: 16,
                                color: isCloud 
                                    ? CloudTheme.textPrimary 
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // 时长选择
                            _buildDurationSelector(isCloud),
                            
                            const SizedBox(height: 40),
                            
                            // 生成按钮
                            _buildGenerateButton(isCloud),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
          Text(
            '语音创作',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isCloud 
                  ? CloudTheme.textPrimary 
                  : SpaceTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(bool isCloud) {
    return Container(
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: _titleController,
        style: TextStyle(
          color: isCloud 
              ? CloudTheme.textPrimary 
              : SpaceTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: '音乐标题',
          hintText: '给你的音乐起个名字',
          prefixIcon: Icon(
            Icons.music_note_rounded,
            color: isCloud ? CloudTheme.primary : SpaceTheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '请输入标题';
          return null;
        },
      ),
    );
  }

  Widget _buildRecordButton(bool isCloud) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return GestureDetector(
          onTap: _toggleRecording,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 波纹效果
                if (_isRecording) ...[
                  for (int i = 0; i < 3; i++)
                    _buildWaveRing(isCloud, i),
                ],
                
                // 主按钮
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isRecording
                        ? LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          )
                        : (isCloud
                            ? CloudTheme.buttonGradient
                            : SpaceTheme.buttonGradient),
                    boxShadow: [
                      BoxShadow(
                        color: _isRecording
                            ? Colors.red.withOpacity(0.4)
                            : (isCloud
                                ? CloudTheme.primary.withOpacity(0.4)
                                : SpaceTheme.primary.withOpacity(0.4)),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveRing(bool isCloud, int index) {
    final progress = (_waveController.value + index * 0.3) % 1.0;
    final scale = 1.0 + progress * 0.8;
    final opacity = (1.0 - progress) * 0.5;
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.red.withOpacity(opacity),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector(bool isCloud) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? Colors.white.withOpacity(0.9)
            : const Color(0xCC1E1E32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCloud
              ? CloudTheme.softBlue.withOpacity(0.3)
              : SpaceTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '音乐时长',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: isCloud
                      ? CloudTheme.buttonGradient
                      : SpaceTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_duration 秒',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.primary,
              inactiveTrackColor: isCloud
                  ? CloudTheme.softBlue.withOpacity(0.3)
                  : SpaceTheme.primary.withOpacity(0.2),
              thumbColor: isCloud 
                  ? CloudTheme.primary 
                  : SpaceTheme.accent,
            ),
            child: Slider(
              value: _duration.toDouble(),
              min: AppConfig.minDuration.toDouble(),
              max: AppConfig.maxDuration.toDouble(),
              divisions: (AppConfig.maxDuration - AppConfig.minDuration) ~/ 5,
              onChanged: (value) => setState(() => _duration = value.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isCloud) {
    return GestureDetector(
      onTap: (_isGenerating || _isRecording) ? null : _handleGenerate,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isCloud
              ? CloudTheme.buttonGradient
              : SpaceTheme.buttonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isCloud
                  ? CloudTheme.primary.withOpacity(0.4)
                  : SpaceTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isGenerating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '开始生成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
```

---

## 📝 Part 4 完成

本部分包含了主页面容器、创作页面和输入页面。接下来的 Part 5 将包含：

- 图片输入页面
- 生成动画页面（灵感球→胶片变形）
- 日记页面（时间轨迹）
- 收藏页面（黑胶唱片箱）

请继续查看 Part 5...
