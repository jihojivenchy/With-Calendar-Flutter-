import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';

mixin class CalendarScreenState {
  /// 날짜 맵
  static final calendarMap = StateProvider<Map<DateTime, List<Day>>>((ref) {
    return {};
  });

  /// 주차 리스트
  static final weekList = StateProvider<List<String>>((ref) {
    return [];
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
