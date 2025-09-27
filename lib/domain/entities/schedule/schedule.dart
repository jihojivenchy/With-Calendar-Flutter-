import 'dart:ui';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';

class Schedule {
  final String id;
  final String title;
  final ScheduleType type;
  final DateTime startDate;
  final DateTime endDate;
  final String notificationTime;
  final String memo;
  final Color color;
  final ScheduleDuration duration;

  const Schedule({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.notificationTime,
    required this.memo,
    required this.color,
    required this.duration,
  });

  static Schedule fromJson(Map<String, dynamic> json) {
    final duration = (json['isLong'] as bool) == true
        ? ScheduleDuration.long
        : ScheduleDuration.short;

    return Schedule(
      id: json['id'],
      title: json['title'],
      type: ScheduleType.fromString(json['type']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      notificationTime: json['notificationTime'],
      memo: json['memo'],
      color: Color(json['color'] as int),
      duration: duration,
    );
  }
}

enum ScheduleDuration { long, short }


/// 타입 별칭
typedef ScheduleMap = Map<DateTime, List<Schedule>>;