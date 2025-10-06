import 'dart:ui';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

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

  /// 주별 상태
  final WeekCellState weekSegmentState;

  /// 주별 상태가 앵커인 경우 보여지는 날짜 수
  final int weekStartVisibleDayCount;

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
    this.weekSegmentState = WeekCellState.start,
    this.weekStartVisibleDayCount = 1,
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
      weekSegmentState: WeekCellState.start,
      weekStartVisibleDayCount: 1,
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? notificationTime,
    String? memo,
    Color? color,
    ScheduleDuration? duration,
    WeekCellState? weekSegmentState,
    int? weekStartVisibleDayCount,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notificationTime: notificationTime ?? this.notificationTime,
      memo: memo ?? this.memo,
      color: color ?? this.color,
      duration: duration ?? this.duration,
      weekSegmentState: weekSegmentState ?? this.weekSegmentState,
      weekStartVisibleDayCount:
          weekStartVisibleDayCount ?? this.weekStartVisibleDayCount,
    );
  }

  String get periodText {
    final startText = startDate.toKoreanMonthDay(isShort: true);
    final endText = endDate.toKoreanMonthDay(isShort: true);
    return '$startText ~ $endText';
  }
}

///
/// 일정 시간 유형
///
enum ScheduleDuration { long, short }

///
/// 일정 주별 상태
///
enum WeekCellState {
  start, // 주의 시작
  content, // 주의 시작을 제외한 나머지
  spacer, // 빈 공간 처리를 위함
}

/// 타입 별칭
typedef ScheduleMap = Map<DateTime, List<Schedule>>;
