import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/calendar/calendar_service.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';

mixin class CalendarScreenEvent {
  final CalendarService _calendarService = CalendarService();
  final ShareCalendarService _shareCalendarService = ShareCalendarService();

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
