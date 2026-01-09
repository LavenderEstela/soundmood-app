import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/music_provider.dart';
import '../../models/music.dart';
import '../../config/themes/app_theme.dart';
import '../../config/themes/cloud_theme.dart';
import '../../config/themes/space_theme.dart';
import '../../widgets/vinyl/vinyl_sleeve.dart';
import '../player/player_screen.dart';

/// 收藏页面 - 黑胶唱片箱
class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String _selectedTag = '全部';
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, MusicProvider>(
      builder: (context, themeProvider, musicProvider, _) {
        final isCloud = themeProvider.currentTheme == AppThemeType.cloud;
        
        return SafeArea(
          child: Column(
            children: [
              // 头部
              _buildHeader(isCloud, themeProvider),
              
              // 标签筛选
              _buildTagFilter(isCloud),
              
              const SizedBox(height: 16),
              
              // 唱片箱
              Expanded(
                child: musicProvider.isLoadingFavorites
                    ? _buildLoading(isCloud)
                    : musicProvider.favorites.isEmpty
                        ? _buildEmpty(isCloud)
                        : _buildVinylCrate(isCloud, musicProvider.favorites),
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
                '我的收藏',
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
                '珍藏每一份感动',
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

  Widget _buildTagFilter(bool isCloud) {
    final tags = ['全部', '#治愈', '#工作', '#助眠', '#放松'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag == _selectedTag;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tags.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTag = tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCloud
                          ? CloudTheme.softBlue.withOpacity(0.6)
                          : SpaceTheme.primary.withOpacity(0.4))
                      : (isCloud
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0x991E1E32)),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: isCloud 
                              ? CloudTheme.primary 
                              : SpaceTheme.accent,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isCloud 
                        ? CloudTheme.textPrimary 
                        : SpaceTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
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
            Icons.album_outlined,
            size: 80,
            color: isCloud 
                ? CloudTheme.textSecondary.withOpacity(0.3)
                : SpaceTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有收藏',
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
            '播放音乐时点击收藏按钮添加',
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

  Widget _buildVinylCrate(bool isCloud, List<Music> favorites) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCloud
            ? const Color(0xFFDEB887).withOpacity(0.3) // 木纹色
            : const Color(0xFF2A2A3A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCloud
              ? const Color(0xFFD2B48C).withOpacity(0.5)
              : const Color(0xFF3A3A4A),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 唱片架标签
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCloud
                      ? const Color(0xFFDEB887)
                      : SpaceTheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${favorites.length} 张唱片',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCloud 
                        ? const Color(0xFF8B4513)
                        : SpaceTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 唱片列表
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final music = favorites[index];
                final isExpanded = _expandedIndex == index;
                
                return VinylSleeve(
                  music: music,
                  isExpanded: isExpanded,
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                  onPlay: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(music: music),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}