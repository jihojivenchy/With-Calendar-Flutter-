import 'dart:ui';

import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';

/// 일정 요청 정보 인터페이스
abstract class ScheduleRequest {
  final String id;
  final String title;
  final ScheduleType type;
  final DateTime startDate;
  final DateTime endDate;
  final String notificationTime;
  final String memo;
  final Color color;

  const ScheduleRequest({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.notificationTime,
    required this.memo,
    required this.color,
  });

  ///
  /// 장기 일정인지 단기 일정인지
  ///
  bool get isLongSchedule {
    final DateTime startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime endDateOnly = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return endDateOnly.difference(startDateOnly).inDays.abs() > 0;
  }

  ///
  /// startDate와 endDate의 차이
  ///
  int get durationPriority {
    // 단기 일정일 경우 0
    if (!isLongSchedule) return 0;

    // 장기 일정일 경우 startDate와 endDate의 차이
    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return endDateOnly.difference(startDateOnly).inDays.abs();
  }
}
