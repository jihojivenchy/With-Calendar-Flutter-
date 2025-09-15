import 'dart:ui';

import 'package:with_calendar/domain/entities/schedule/app_date_time.dart';

class ScheduleCreation {
  final String title;
  final ScheduleType type;
  final DateTime startDate;
  final DateTime endDate;
  final AllDayNotificationType allDayNotificationType;
  final TimeNotificationType timeNotificationType;
  final String memo;
  final Color color;

  const ScheduleCreation({
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.allDayNotificationType,
    required this.timeNotificationType,
    required this.memo,
    required this.color,
  });

  ScheduleCreation copyWith({
    String? title,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? endDate,
    AllDayNotificationType? allDayNotificationType,
    TimeNotificationType? timeNotificationType,
    String? memo,
    Color? color,
  }) {
    return ScheduleCreation(
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allDayNotificationType: allDayNotificationType ?? this.allDayNotificationType,
      timeNotificationType: timeNotificationType ?? this.timeNotificationType,
      memo: memo ?? this.memo,
      color: color ?? this.color,
    );
  }

  static ScheduleCreation initialState = ScheduleCreation(
    title: '',
    type: ScheduleType.allDay,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    allDayNotificationType: AllDayNotificationType.none,
    timeNotificationType: TimeNotificationType.none,
    memo: '',
    color: const Color(0xFF409060),
  );
}

enum ScheduleType {
  allDay(displayText: '하루종일'), // 하루종일
  time(displayText: '시간'); // 시간

  final String displayText;

  const ScheduleType({required this.displayText});
}

/// 하루종일 일정에 대한 알림 유형
enum AllDayNotificationType {
  today(displayText: '당일'), 
  oneDayBefore(displayText: '1일 전'), 
  threeDayBefore(displayText: '3일 전'),
  oneWeekBefore(displayText: '1주일 전'),
  custom(displayText: '직접 설정'), 
  none(displayText: '알림 없음');

  final String displayText;

  const AllDayNotificationType({required this.displayText});
}

/// 시간 일정에 대한 알림 유형
enum TimeNotificationType {
  start(displayText: '시작 시간'), 
  tenMinutesBefore(displayText: '10분 전'), 
  thirtyMinutesBefore(displayText: '30분 전'), 
  oneHourBefore(displayText: '1시간 전'), 
  custom(displayText: '직접 설정'), 
  none(displayText: '알림 없음');

  final String displayText;
  const TimeNotificationType({required this.displayText});
}

// 제목
// 타입 (하루종일 or 시간)
// 시작 날짜
// 종료 날짜
// 알림 시간 타입 (시간, 분)
// 컬러
// 메모
