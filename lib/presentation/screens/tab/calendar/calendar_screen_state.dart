import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';

mixin class CalendarScreenState {
  /// 날짜 맵
  static final calendarMap = StateProvider<Map<DateTime, List<Day>>>((ref) {
    return {};
  });

  /// 주차 리스트
  static final weekList = StateProvider<List<String>>((ref) {
    return [];
  });

  /// 포커스 날짜
  static final focusedDate = StateProvider<DateTime>((ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  });

  /// 음력 날짜
  static final lunarDate = StateProvider<LunarDate?>((ref) {
    return null;
  });

  /// 현재 선택된 달력 정보
  static final currentCalendar = StateProvider<CalendarInformation>((ref) {
    return CalendarInformation(
      id: '',
      name: '',
      type: CalendarType.private,
      createdAt: '',
    );
  });

  /// 캘린더 리스트
  static final calendarList = StateProvider<List<CalendarInformation>>((ref) {
    return [];
  });
}
