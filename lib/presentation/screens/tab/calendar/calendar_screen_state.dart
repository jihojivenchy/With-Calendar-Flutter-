import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/schedule/schedule_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
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
  static final currentCalendar = StateProvider<CalendarInformation>((ref) {
    return CalendarInformation(
      id: '',
      name: '',
      type: CalendarType.private,
      createdAt: '',
    );
  });

  // ---------------------------------- 일정 관련 --------------------------------
  static final scheduleListStreamProvider = StreamProvider.autoDispose
      .family<ScheduleMap, CalendarInformation>((ref, calendar) {
        final ScheduleService scheduleService = ScheduleService();
        return scheduleService.fetchScheduleList(calendar: calendar);
      });

  // 선택된 날짜의 일정 리스트
  static final focusedScheduleList =
      Provider.autoDispose<AsyncValue<List<Schedule>>>((ref) {
        // 현재 선택된 달력 정보
        final currentCalendar = ref.watch(CalendarScreenState.currentCalendar);

        // 일정 리스트 스트림
        final scheduleMapAsync = ref.watch(
          scheduleListStreamProvider(currentCalendar),
        );

        // 선택된 날짜
        final focusedSolarDate = ref.watch(
          CalendarScreenState.lunarDate.select((lunar) => lunar?.solarDate),
        );

        // 일정 리스트 반환
        return scheduleMapAsync.whenData((map) {
          final list = map[focusedSolarDate] ?? [];
          return list
              .where((e) => e.weekSegmentState != WeekCellState.spacer)
              .toList();
        });
      });

  // ---------------------------------- 공휴일 관련 -------------------------------
  /// 공휴일 맵 (날짜별 공휴일 리스트)
  static final holidayMap = StateProvider.autoDispose<HolidayMap>((ref) {
    return {};
  });

  /// 공휴일을 이미 조회한 연도 집합
  static final loadedHolidayYears = StateProvider<Set<int>>((ref) {
    return <int>{};
  });
}
