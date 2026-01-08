import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/music.dart';

class MusicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Music> _musics = [];
  bool _isLoading = false;
  String? _error;
  
  List<Music> get musics => _musics;
  bool get isLoading => _isLoading;
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
      notifyListeners();
      return true;
    } catch (e) {
      _error = '删除失败';
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
}