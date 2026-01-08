enum InputType { voice, text, image }

enum MusicStatus { generating, completed, failed }

class Music {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final InputType inputType;
  final String? inputContent;
  final List<String>? emotionTags;
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
    this.emotionTags,
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
      emotionTags: json['emotion_tags'] != null
          ? List<String>.from(json['emotion_tags'])
          : null,
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
}