enum InputType { voice, text, image }

enum MusicStatus { generating, completed, failed }

class Music {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final InputType inputType;
  final String? inputContent;     // 文字内容或语音转文字
  final String? inputImageUrl;    // 图片URL（如果是图片输入）
  final List<String>? emotionTags;
  final String? coverUrl;         // 封面图片URL
  final String? aiAnalysis;
  final String musicUrl;
  final String musicFormat;
  final int duration;
  final int fileSize;
  final int bpm;
  final String? genre;
  final List<String>? instruments;
  final MusicStatus status;
  final bool isPublic;
  final bool isFavorite;          // 是否收藏
  final int playCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Music({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.inputType,
    this.inputContent,
    this.inputImageUrl,
    this.emotionTags,
    this.coverUrl,
    this.aiAnalysis,
    required this.musicUrl,
    required this.musicFormat,
    required this.duration,
    required this.fileSize,
    required this.bpm,
    this.genre,
    this.instruments,
    required this.status,
    required this.isPublic,
    this.isFavorite = false,
    required this.playCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      inputType: _parseInputType(json['input_type']),
      inputContent: json['input_content'],
      inputImageUrl: json['input_image_url'],
      emotionTags: json['emotion_tags'] != null
          ? List<String>.from(json['emotion_tags'])
          : null,
      coverUrl: json['cover_url'],
      aiAnalysis: json['ai_analysis'],
      musicUrl: json['music_url'] ?? '',
      musicFormat: json['music_format'] ?? 'mp3',
      duration: json['duration'] ?? 0,
      fileSize: json['file_size'] ?? 0,
      bpm: json['bpm'] ?? 120,
      genre: json['genre'],
      instruments: json['instruments'] != null
          ? List<String>.from(json['instruments'])
          : null,
      status: _parseStatus(json['status']),
      isPublic: json['is_public'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      playCount: json['play_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static InputType _parseInputType(String? type) {
    switch (type) {
      case 'voice':
        return InputType.voice;
      case 'text':
        return InputType.text;
      case 'image':
        return InputType.image;
      default:
        return InputType.text;
    }
  }

  static MusicStatus _parseStatus(String? status) {
    switch (status) {
      case 'generating':
        return MusicStatus.generating;
      case 'completed':
        return MusicStatus.completed;
      case 'failed':
        return MusicStatus.failed;
      default:
        return MusicStatus.generating;
    }
  }

  String get inputTypeString {
    switch (inputType) {
      case InputType.voice:
        return 'voice';
      case InputType.text:
        return 'text';
      case InputType.image:
        return 'image';
    }
  }

  String get inputTypeIcon {
    switch (inputType) {
      case InputType.voice:
        return '🎤';
      case InputType.text:
        return '✍️';
      case InputType.image:
        return '🖼️';
    }
  }

  String get inputTypeLabel {
    switch (inputType) {
      case InputType.voice:
        return '语音';
      case InputType.text:
        return '文字';
      case InputType.image:
        return '图片';
    }
  }

  String get durationString {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 从 emotionTags 获取主要情绪
  String get primaryEmotion {
    if (emotionTags != null && emotionTags!.isNotEmpty) {
      return emotionTags!.first;
    }
    return 'calm';
  }

  Music copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    InputType? inputType,
    String? inputContent,
    String? inputImageUrl,
    List<String>? emotionTags,
    String? coverUrl,
    String? aiAnalysis,
    String? musicUrl,
    String? musicFormat,
    int? duration,
    int? fileSize,
    int? bpm,
    String? genre,
    List<String>? instruments,
    MusicStatus? status,
    bool? isPublic,
    bool? isFavorite,
    int? playCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Music(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      inputType: inputType ?? this.inputType,
      inputContent: inputContent ?? this.inputContent,
      inputImageUrl: inputImageUrl ?? this.inputImageUrl,
      emotionTags: emotionTags ?? this.emotionTags,
      coverUrl: coverUrl ?? this.coverUrl,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      musicUrl: musicUrl ?? this.musicUrl,
      musicFormat: musicFormat ?? this.musicFormat,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      bpm: bpm ?? this.bpm,
      genre: genre ?? this.genre,
      instruments: instruments ?? this.instruments,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
