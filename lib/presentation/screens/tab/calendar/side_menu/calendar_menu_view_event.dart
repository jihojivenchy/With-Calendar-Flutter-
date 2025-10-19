import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/data/services/menu/menu_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/side_menu/calendar_menu_view_state.dart';

mixin class CalendarMenuEvent {
  final MenuService _menuService = MenuService();
  final ShareCalendarService _service = ShareCalendarService();

  /// 프로필 조회
  Future<void> fetchProfile(WidgetRef ref) async {
    try {
      final profile = await _menuService.fetchProfile();
      ref.read(CalendarMenuState.profileProvider.notifier).state = profile;
    } catch (e) {
      log(e.toString());
    }
  }

  ///
  /// 캘린더 리스트 조회
  ///
  Future<void> fetchCalendarList(WidgetRef ref) async {
    try {
      final calendarList = await _service.fetchCalendarList();
      _setCalendarList(ref, calendarList);
    } catch (e) {
      log('캘린더 리스트 조회 실패: $e');
      _setCalendarList(ref, []);
    }
  }

  ///
  /// 현재 선택된 캘린더 정보 가져오기
  ///
  void fetchCurrentCalendar(WidgetRef ref) {
    try {
      // 현재 선택된 캘린더 정보 가져오기
      final result = HiveService.instance.get(HiveBoxPath.currentCalendar);
      final currentCalendar = CalendarInformation.fromHiveJson(result);

      // 현재 선택된 캘린더 ID 설정
      _setCurrentCalendarID(ref, currentCalendar.id);
    } catch (e) {
      log('현재 선택된 달력 조회 실패: $e');
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
    _setCurrentCalendarID(ref, calendar.id);

    // 일정 구독 재시작
    final calendarEvent = CalendarScreenEvent();
    calendarEvent.updateSelectedCalendar(ref, calendar: calendar);
  }

  // -------------------------------- Helper -----------------------------------
  void _setCalendarList(WidgetRef ref, List<CalendarInformation> calendarList) {
    ref.read(CalendarMenuState.calendarListProvider.notifier).state =
        calendarList;
  }

  void _setCurrentCalendarID(WidgetRef ref, String currentCalendarID) {
    ref.read(CalendarMenuState.currentCalendarIDProvider.notifier).state =
        currentCalendarID;
  }
}
