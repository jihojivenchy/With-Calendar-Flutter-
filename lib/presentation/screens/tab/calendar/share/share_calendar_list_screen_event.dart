import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/calendar/share_calendar_service.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/share_calendar_list_screen_state.dart';

mixin class ShareCalendarListEvent {
  final ShareCalendarService _service = ShareCalendarService();

  ///
  /// 캘린더 리스트 조회
  ///
  Future<void> fetchCalendarList(WidgetRef ref) async {
    try {
      final calendarList = await _service.fetchCalendarList();
      _setCalendarList(ref, Fetched(calendarList));
    } catch (e) {
      log('캘린더 리스트 조회 실패: $e');
      _setCalendarList(ref, Failed(e));
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
  }

  // -------------------------------- Helper -----------------------------------
  void _setCalendarList(
    WidgetRef ref,
    Ds<List<CalendarInformation>> calendarList,
  ) {
    ref.read(ShareCalendarListState.calendarListProvider.notifier).state =
        calendarList;
  }

  void _setCurrentCalendarID(WidgetRef ref, String currentCalendarID) {
    ref.read(ShareCalendarListState.currentCalendarIDProvider.notifier).state =
        currentCalendarID;
  }
}
