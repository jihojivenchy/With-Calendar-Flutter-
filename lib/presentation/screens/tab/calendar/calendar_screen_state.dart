import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';

/// 달력 화면 모드
enum CalendarScreenMode { full, half }

abstract class CalendarScreenState {
  // ---------------------------- 달력 UI 관련 ------------------------------------
  /// 날짜 맵
  static final calendarMap =
      StateProvider.autoDispose<Map<DateTime, List<Day>>>((ref) {
        return {};
      });

  /// 주차 리스트
  static final weekList = StateProvider.autoDispose<List<String>>((ref) {
    return [];
  });

  /// 포커스 날짜
  static final focusedDate = StateProvider.autoDispose<DateTime>((ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  });

  /// 음력 날짜
  static final lunarDate = StateProvider.autoDispose<LunarDate?>((ref) {
    return null;
  });

  /// 달력 화면 모드
  static final calendarMode = StateProvider.autoDispose<CalendarScreenMode>((
    ref,
  ) {
    return CalendarScreenMode.full;
  });

  // ---------------------------- 캘린더 리스트 관련 -------------------------------

  /// 현재 선택된 달력 정보
  static final currentCalendar = StateProvider.autoDispose<CalendarInformation>(
    (ref) {
      return CalendarInformation(
        id: '',
        name: '',
        type: CalendarType.private,
        createdAt: '',
      );
    },
  );

  /// 캘린더 리스트
  static final calendarList =
      StateProvider.autoDispose<List<CalendarInformation>>((ref) {
        return [];
      });

  // ---------------------------------- 일정 관련 ----------------------------------

  /// 일정 리스트
  static final scheduleListProvider = StateProvider.autoDispose<ScheduleMap>((
    ref,
  ) {
    return {};
  });

  /// 일정 리스트 구독 상태
  static final subscriptionProvider =
      StateProvider.autoDispose<StreamSubscription<ScheduleMap>?>((ref) {
        return null;
      });

  /// 포커스 날짜 일정 리스트
  static final focusedScheduleList = Provider.autoDispose<List<Schedule>>((
    ref,
  ) {
    final scheduleMap = ref.watch(scheduleListProvider);
    final lunarDate = ref.watch(CalendarScreenState.lunarDate);

    // 선택된 날짜의 일정 리스트
    final scheduleList = scheduleMap[lunarDate?.solarDate] ?? [];
    return scheduleList.where((schedule) {
      return schedule.weekSegmentState != WeekCellState.spacer;
    }).toList();
  });
}
