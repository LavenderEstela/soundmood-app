import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/journal_entry.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/journal/emotion_filter.dart';
import '../../widgets/journal/timeline_entry.dart';
import '../player/player_screen.dart';

/// 日记页面 - 时间轨迹
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedEmotion;
  bool _isListView = true; // true: 列表视图, false: 日历视图

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadJournal();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onEmotionSelected(String? emotion) {
    setState(() => _selectedEmotion = emotion);
    context.read<MusicProvider>().loadJournal(emotion: emotion);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, MusicProvider>(
      builder: (context, themeProvider, musicProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SafeArea(
          child: Column(
            children: [
              // 头部区域
              _buildHeader(isCloud, themeProvider),
              
              // 统计卡片
              _buildStatsCard(isCloud, musicProvider.stats),
              
              // 情绪筛选器
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: EmotionFilter(
                  selectedEmotion: _selectedEmotion,
                  onEmotionSelected: _onEmotionSelected,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 视图切换
              _buildViewToggle(isCloud),
              
              const SizedBox(height: 8),
              
              // 内容区域
              Expanded(
                child: musicProvider.isLoadingJournal
                    ? _buildLoading(isCloud)
                    : musicProvider.journalGroups.isEmpty
                        ? _buildEmpty(isCloud)
                        : _buildJournalList(isCloud, musicProvider.journalGroups),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCloud, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '时间轨迹',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCloud 
                      ? CloudTheme.textPrimary 
                      : SpaceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '记录每一刻的心情旋律',
                style: TextStyle(
                  fontSize: 14,
                  color: isCloud 
                      ? CloudTheme.textSecondary 
                      : SpaceTheme.textSecondary,
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
                color: isCloud
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xCC1E1E32),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isCloud
                        ? CloudTheme.softBlue.withOpacity(0.3)
                        : SpaceTheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isCloud ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isCloud 
                    ? CloudTheme.textPrimary 
                    : SpaceTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(bool isCloud, JournalStats? stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        boxShadow: [
          BoxShadow(
            color: isCloud
                ? CloudTheme.softBlue.withOpacity(0.2)
                : SpaceTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            isCloud: isCloud,
            value: '${stats?.totalCount ?? 0}',
            label: '总创作',
            icon: Icons.music_note_rounded,
          ),
          _buildStatDivider(isCloud),
          _buildStatItem(
            isCloud: isCloud,
            value: '${stats?.monthCount ?? 0}',
            label: '本月',
            icon: Icons.calendar_today_rounded,
          ),
          _buildStatDivider(isCloud),
          _buildStatItem(
            isCloud: isCloud,
            value: stats?.listenTimeString ?? '0分钟',
            label: '聆听',
            icon: Icons.headphones_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isCloud,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isCloud
                ? CloudTheme.buttonGradient
                : SpaceTheme.buttonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isCloud 
                ? CloudTheme.textPrimary 
                : SpaceTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildStatDivider(bool isCloud) {
    return Container(
      width: 1,
      height: 60,
      color: isCloud
          ? CloudTheme.softBlue.withOpacity(0.3)
          : SpaceTheme.primary.withOpacity(0.2),
    );
  }

  Widget _buildViewToggle(bool isCloud) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isCloud
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0x991E1E32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isListView = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isListView
                              ? (isCloud
                                  ? CloudTheme.softBlue.withOpacity(0.5)
                                  : SpaceTheme.primary.withOpacity(0.4))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_list_rounded,
                              size: 18,
                              color: isCloud
                                  ? CloudTheme.textPrimary
                                  : SpaceTheme.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '时间线',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _isListView 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: isCloud
                                    ? CloudTheme.textPrimary
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isListView = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isListView
                              ? (isCloud
                                  ? CloudTheme.softBlue.withOpacity(0.5)
                                  : SpaceTheme.primary.withOpacity(0.4))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_view_month_rounded,
                              size: 18,
                              color: isCloud
                                  ? CloudTheme.textPrimary
                                  : SpaceTheme.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '日历',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !_isListView 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: isCloud
                                    ? CloudTheme.textPrimary
                                    : SpaceTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isCloud) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isCloud ? CloudTheme.primary : SpaceTheme.accent,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isCloud) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 80,
            color: isCloud 
                ? CloudTheme.textSecondary.withOpacity(0.3)
                : SpaceTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有创作记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isCloud 
                  ? CloudTheme.textSecondary 
                  : SpaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去创作页面开始你的第一首音乐吧',
            style: TextStyle(
              fontSize: 14,
              color: isCloud 
                  ? CloudTheme.textSecondary.withOpacity(0.7)
                  : SpaceTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList(bool isCloud, List<JournalGroup> groups) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCloud 
                          ? CloudTheme.primary 
                          : SpaceTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    group.displayDate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCloud 
                          ? CloudTheme.textPrimary 
                          : SpaceTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCloud
                          ? CloudTheme.softBlue.withOpacity(0.3)
                          : SpaceTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${group.count}首',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCloud 
                            ? CloudTheme.textSecondary 
                            : SpaceTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 条目列表
            ...group.entries.asMap().entries.map((entry) {
              final index = entry.key;
              final journalEntry = entry.value;
              final isLast = index == group.entries.length - 1;
              
              return TimelineEntry(
                entry: journalEntry,
                isLast: isLast,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        music: journalEntry.music,
                      ),
                    ),
                  );
                },
              );
            }),
            
            if (groupIndex < groups.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}