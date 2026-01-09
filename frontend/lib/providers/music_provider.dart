import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/music.dart';
import '../models/journal_entry.dart';

class MusicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 音乐列表
  List<Music> _musics = [];
  List<Music> _favorites = [];

  // 日记数据
  List<JournalGroup> _journalGroups = [];
  JournalStats? _stats;

  // 当前筛选
  String? _currentEmotionFilter;

  // 状态
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingJournal = false;
  String? _error;

  // Getters
  List<Music> get musics => _musics;
  List<Music> get favorites => _favorites;
  List<JournalGroup> get journalGroups => _journalGroups;
  JournalStats? get stats => _stats;
  String? get currentEmotionFilter => _currentEmotionFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingJournal => _isLoadingJournal;
  String? get error => _error;

  /// 加载音乐列表
  Future<void> loadMusics({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _musics = await _apiService.getMusics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载收藏列表
  Future<void> loadFavorites({bool refresh = false}) async {
    if (_isLoadingFavorites) return;

    _isLoadingFavorites = true;
    notifyListeners();

    try {
      _favorites = await _apiService.getFavoriteMusics();
      _isLoadingFavorites = false;
      notifyListeners();
    } catch (e) {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// 加载日记数据
  Future<void> loadJournal({String? emotion}) async {
    if (_isLoadingJournal) return;

    _isLoadingJournal = true;
    _currentEmotionFilter = emotion;
    notifyListeners();

    try {
      // 加载统计数据
      _stats = await _apiService.getJournalStats();

      // 加载分组数据
      _journalGroups = await _apiService.getJournalEntries(emotion: emotion);

      // 如果没有从服务器获取统计，本地计算
      if (_stats?.totalCount == 0 && _journalGroups.isNotEmpty) {
        int total = 0;
        int monthTotal = 0;
        int listenTime = 0;
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 1);

        for (final group in _journalGroups) {
          for (final entry in group.entries) {
            total++;
            listenTime += entry.music.duration;
            if (entry.date.isAfter(thisMonth)) {
              monthTotal++;
            }
          }
        }

        _stats = JournalStats(
          totalCount: total,
          monthCount: monthTotal,
          totalListenTime: listenTime,
        );
      }

      _isLoadingJournal = false;
      notifyListeners();
    } catch (e) {
      _isLoadingJournal = false;
      notifyListeners();
    }
  }

  /// 从文本生成
  Future<Music?> generateFromText({
    required String title,
    required String text,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromText(
        title: title,
        text: text,
        duration: duration,
      );

      // 添加到列表开头
      _musics.insert(0, music);
      notifyListeners();

      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 从语音生成
  Future<Music?> generateFromVoice({
    required String title,
    required File audioFile,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromVoice(
        title: title,
        audioFile: audioFile,
        duration: duration,
      );

      _musics.insert(0, music);
      notifyListeners();

      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 从图片生成
  Future<Music?> generateFromImage({
    required String title,
    required File imageFile,
    required int duration,
  }) async {
    _error = null;

    try {
      final music = await _apiService.generateFromImage(
        title: title,
        imageFile: imageFile,
        duration: duration,
      );

      _musics.insert(0, music);
      notifyListeners();

      return music;
    } catch (e) {
      _error = '生成失败，请重试';
      notifyListeners();
      return null;
    }
  }

  /// 删除音乐
  Future<bool> deleteMusic(int id) async {
    try {
      await _apiService.deleteMusic(id);
      _musics.removeWhere((m) => m.id == id);
      _favorites.removeWhere((m) => m.id == id);

      // 更新日记分组
      for (final group in _journalGroups) {
        group.entries.removeWhere((e) => e.id == id);
      }
      _journalGroups.removeWhere((g) => g.entries.isEmpty);

      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除失败';
      notifyListeners();
      return false;
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(int id) async {
    try {
      final updatedMusic = await _apiService.toggleFavorite(id);

      // 更新音乐列表
      final index = _musics.indexWhere((m) => m.id == id);
      if (index != -1) {
        _musics[index] = updatedMusic;
      }

      // 更新收藏列表
      if (updatedMusic.isFavorite) {
        if (!_favorites.any((m) => m.id == id)) {
          _favorites.insert(0, updatedMusic);
        }
      } else {
        _favorites.removeWhere((m) => m.id == id);
      }

      // 更新日记中的条目
      for (final group in _journalGroups) {
        for (int i = 0; i < group.entries.length; i++) {
          if (group.entries[i].id == id) {
            group.entries[i] = JournalEntry.fromMusic(updatedMusic);
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = '操作失败';
      notifyListeners();
      return false;
    }
  }

  /// 刷新单个音乐状态
  Future<void> refreshMusicStatus(int id) async {
    try {
      final music = await _apiService.getGenerationStatus(id);
      final index = _musics.indexWhere((m) => m.id == id);
      if (index != -1) {
        _musics[index] = music;
        notifyListeners();
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
