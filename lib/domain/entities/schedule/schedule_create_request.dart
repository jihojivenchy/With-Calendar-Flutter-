import 'dart:ui';

import 'package:with_calendar/domain/entities/schedule/app_date_time.dart';

class ScheduleCreateRequest {
  final String id;
  final String title;
  final ScheduleType type;
  final DateTime startDate;
  final DateTime endDate;
  final String notificationTime;
  final String memo;
  final Color color;

  const ScheduleCreateRequest({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.notificationTime,
    required this.memo,
    required this.color,
  });

  ScheduleCreateRequest copyWith({
    String? title,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? notificationTime,
    String? memo,
    Color? color,
  }) {
    return ScheduleCreateRequest(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notificationTime: notificationTime ?? this.notificationTime,
      memo: memo ?? this.memo,
      color: color ?? this.color,
    );
  }

  static ScheduleCreateRequest initialState = ScheduleCreateRequest(
    id: '',
    title: '',
    type: ScheduleType.allDay,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    notificationTime: '',
    memo: '',
    color: const Color(0xFF409060),
  );

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

enum ScheduleType {
  allDay(displayText: '하루종일', queryValue: 'ALL_DAY'), // 하루종일
  time(displayText: '시간', queryValue: 'TIME'); // 시간

  final String displayText;
  final String queryValue;

  const ScheduleType({required this.displayText, required this.queryValue});

  static ScheduleType fromString(String value) {
    return ScheduleType.values.firstWhere(
      (type) => type.queryValue == value,
      orElse: () => ScheduleType.allDay,
    );
  }
}

// 제목
// 타입 (하루종일 or 시간)
// 시작 날짜
// 종료 날짜
// 알림 시간 타입 (시간, 분)
// 컬러
// 메모
