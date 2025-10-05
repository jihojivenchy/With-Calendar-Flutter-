import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klc/klc.dart';
import 'package:with_calendar/data/services/calendar/calendar_service.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/data/services/holiday/holiday_service.dart';
import 'package:with_calendar/data/services/schedule/schedule_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

part 'calendar_screen_schedule_event.dart';

mixin class CalendarScreenEvent {
  final CalendarService _calendarService = CalendarService();
  final ShareCalendarService _shareCalendarService = ShareCalendarService();
  final ScheduleService _scheduleService = ScheduleService();
  final HolidayService _holidayService = HolidayService();

  // -------------------------------달력 날짜 계산 --------------------------------
  ///
  /// 달력 날짜 계산
  ///
  void calculateCalendarDay(WidgetRef ref) {
    // 달력 날짜 계산
    final calendarMap = _calendarService.calculateDayMap();
    ref.read(CalendarScreenState.calendarMap.notifier).state = calendarMap;

    // 주차 리스트 계산
    final weekList = _calendarService.calculateWeekList();
    ref.read(CalendarScreenState.weekList.notifier).state = weekList;
  }

  ///
  /// 달력 시작 날짜 반환
  ///
  DateTime getStartDate(WidgetRef ref) {
    return _calendarService.startDate;
  }

  ///
  /// 페이지 변경 처리
  ///
  void updatePage(WidgetRef ref, int index) {
    final targetDate = calculateDateFromIndex(index);
    updateFocusedDate(ref, targetDate);
  }

  ///
  /// 포커싱 날짜 변경
  ///
  void updateFocusedDate(WidgetRef ref, DateTime date) {
    final currentYear = ref.read(CalendarScreenState.focusedDate).year;
    final targetYear = date.year;

    // 포커싱 날짜의 년도가 변경되었으면 공휴일 리스트 조회
    if (currentYear != targetYear) {
      print('공휴일 리스트 조회: $targetYear');
      fetchHolidayList(ref, targetYear);
    }

    ref.read(CalendarScreenState.focusedDate.notifier).state = date;
  }

  ///
  /// 인덱스를 기반으로 날짜 계산
  ///
  DateTime calculateDateFromIndex(int index) {
    // DateTime 타입은 월 오버플로우를 자동으로 처리해줌
    return DateTime(
      _calendarService.startDate.year,
      _calendarService.startDate.month + index,
    );
  }

  ///
  /// 날짜를 기반으로 페이지 인덱스 계산
  ///
  int calculatePageIndexFromDate(DateTime targetDate) {
    final startYear = _calendarService.startDate.year;
    final startMonth = _calendarService.startDate.month;

    final yearDiff = targetDate.year - startYear;
    final monthDiff = targetDate.month - startMonth;

    return yearDiff * 12 + monthDiff;
  }

  ///
  /// 공휴일 리스트 조회
  ///
  Future<void> fetchHolidayList(WidgetRef ref, int year) async {
    final currentMap = ref.read(CalendarScreenState.holidayMap);
    final newMap = await _holidayService.fetchHolidayList(year);
    currentMap.addAll(newMap);
    ref.read(CalendarScreenState.holidayMap.notifier).state = currentMap;
  }

  // -------------------------------달력 화면 모드 변경 -----------------------------
  ///
  /// 달력 화면 모드 변경
  ///
  void updateCalendarMode(WidgetRef ref, CalendarScreenMode mode) {
    ref.read(CalendarScreenState.calendarMode.notifier).state = mode;
  }

  // -------------------------------음력 날짜 조회 --------------------------------
  ///
  /// 음력 날짜 조회
  ///
  void fetchLunarDate(WidgetRef ref, Day day) {
    final isConverted = setSolarDate(
      day.date.year,
      day.date.month,
      day.date.day,
    );

    if (!isConverted) {
      log('음력 변환 실패: 지원하지 않는 양력 날짜 (${day.date.toIso8601String()})');
      SnackBarService.showSnackBar('음력 변환에 실패했습니다. 지원하지 않는 날짜입니다.');
      return;
    }

    final isoString = getLunarIsoFormat();
    final lunarIsoDate = isoString.split(' ').first;
    final isLeapMonth = isoString.contains('Intercalation');

    try {
      final lunarDate = DateTime.parse(lunarIsoDate);
      final lunarText = lunarDate.toStringFormat('MM.dd');

      ref.read(CalendarScreenState.lunarDate.notifier).state = LunarDate(
        solarDate: day.date,
        date: lunarDate,
        dateString: isLeapMonth ? '윤 $lunarText' : lunarText,
      );
    } catch (e) {
      log('음력 날짜 파싱 실패: $isoString, error: $e');
      SnackBarService.showSnackBar('음력 변환에 실패했습니다. 다시 시도해주세요.');
    }
  }

  // -------------------------------캘린더 스위칭 ----------------------------------

  ///
  /// 현재 선택된 달력 정보 조회
  ///
  void fetchCurrentCalendar(WidgetRef ref) {
    try {
      final result = HiveService.instance.get(HiveBoxPath.currentCalendar);

      final currentCalendar = CalendarInformation.fromHiveJson(result);
      ref.read(CalendarScreenState.currentCalendar.notifier).state =
          currentCalendar;
    } catch (e) {
      log('현재 선택된 달력 정보 조회 실패: $e');
      SnackBarService.showSnackBar('달력 정보 조회에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 캘린더 리스트 조회
  ///
  Future<void> fetchCalendarList(WidgetRef ref) async {
    try {
      final calendarList = await _shareCalendarService.fetchCalendarList();
      ref.read(CalendarScreenState.calendarList.notifier).state = calendarList;
    } catch (e) {
      log('캘린더 리스트 조회 실패: $e');
      SnackBarService.showSnackBar('캘린더 목록 조회에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 선택 캘린더 변경
  ///
  Future<void> updateSelectedCalendar(
    WidgetRef ref, {
    required CalendarInformation calendar,
  }) async {
    // 현재 선택된 캘린더 정보 저장
    await HiveService.instance.create(
      HiveBoxPath.currentCalendar,
      value: calendar.toJson(),
    );

    // 현재 선택된 캘린더 ID 설정
    ref.read(CalendarScreenState.currentCalendar.notifier).state = calendar;
  }
}
