import 'music.dart';

/// 日记条目模型 - 用于时间轨迹页面
class JournalEntry {
  final int id;
  final Music music;
  final DateTime date;
  
  JournalEntry({
    required this.id,
    required this.music,
    required this.date,
  });
  
  factory JournalEntry.fromMusic(Music music) {
    return JournalEntry(
      id: music.id,
      music: music,
      date: music.createdAt,
    );
  }
  
  /// 获取日期字符串 (用于分组)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 获取友好的日期显示
  String get friendlyDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference 天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
  
  /// 获取时间字符串
  String get timeString {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// 按日期分组的日记
class JournalGroup {
  final String dateKey;
  final String displayDate;
  final List<JournalEntry> entries;
  
  JournalGroup({
    required this.dateKey,
    required this.displayDate,
    required this.entries,
  });
  
  int get count => entries.length;
}

/// 日记统计数据
class JournalStats {
  final int totalCount;
  final int monthCount;
  final int totalListenTime; // 秒
  
  JournalStats({
    required this.totalCount,
    required this.monthCount,
    required this.totalListenTime,
  });
  
  String get listenTimeString {
    final hours = totalListenTime ~/ 3600;
    final minutes = (totalListenTime % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours 小时';
    }
    return '$minutes 分钟';
  }
}