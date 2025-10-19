import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';

class CalendarRangeService {
  CalendarRangeService._();
  static final CalendarRangeService _instance = CalendarRangeService._();
  factory CalendarRangeService() => _instance;
  static CalendarRangeService get instance => _instance;

  /// 캘린더 데이터를 저장하는 맵
  final Map<DateTime, List<Day>> _calendarMap = {};

  /// 캘린더 최소 월
  final DateTime _minMonth = DateTime(2000, 1);

  /// 캘린더 최대 월
  final DateTime _maxMonth = DateTime(2050, 12);

  /// 캘린더 시작 요일
  final StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.sunday;

  /// 캘린더 데이터를 반환하는 맵
  Map<DateTime, List<Day>> get calendarMap => Map.unmodifiable(_calendarMap);

  /// 캘린더 초기 데이터 로드
  void initialize() {
    final now = DateTime.now();
    _populateRange(DateTime(now.year, now.month));
  }

  /// 캘린더 데이터 확인
  void updateRange(DateTime targetMonth) {
    _populateRange(DateTime(targetMonth.year, targetMonth.month));
  }

  /// 캘린더 데이터 채우기
  void _populateRange(DateTime centerMonth) {
    // 캘린더 데이터 최소 월 계산
    final startMonth = _clampMonth(DateTime(centerMonth.year, centerMonth.month - 3));

    // 캘린더 데이터 최대 월 계산
    final endMonth = _clampMonth(DateTime(centerMonth.year, centerMonth.month + 3));

    // 캘린더 데이터 커서 초기화
    var cursor = startMonth;

    // 캘린더 데이터 최대 월 까지 반복
    while (!_isAfter(cursor, endMonth)) {
      _ensureMonth(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
  }

  ///
  /// 이미 캘린더 데이터가 있는지 확인하고,
  /// 없으면 캘린더 데이터 채우기
  /// 
  void _ensureMonth(DateTime month) {
    final monthKey = DateTime(month.year, month.month);
    if (_calendarMap.containsKey(monthKey)) {
      return;
    }
    _calendarMap[monthKey] = _buildMonth(monthKey);
  }

  ///
  /// 캘린더 데이터 채우기
  /// 
  List<Day> _buildMonth(DateTime month) {
    final range = _daysInMonth(month);
    return _calculateDays(range.start, range.end, month);
  }

  DateTimeRange _daysInMonth(DateTime month) {
    final first = _firstDayOfMonth(month);
    final daysBefore = _getBeforeDays(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    final last = _lastDayOfMonth(month);
    final daysAfter = _getAfterDays(last);
    final lastToDisplay = last.add(Duration(days: daysAfter));
    return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
  }

  List<Day> _calculateDays(DateTime first, DateTime last, DateTime focusedDay) {
    final dayCount = last.difference(first).inDays + 1;
    final now = DateTime.now();
    return List.generate(dayCount, (index) {
      final day = DateTime.utc(first.year, first.month, first.day + index);
      final isOutside = day.month != focusedDay.month;
      var state = DayCellState.basic;
      if (_isSunday(day)) {
        state = DayCellState.sunday;
      } else if (_isSaturday(day)) {
        state = DayCellState.saturday;
      }
      final isToday = now.year == day.year && now.month == day.month && now.day == day.day;
      if (isToday) {
        state = DayCellState.today;
      }
      return Day(date: day, isOutside: isOutside, state: state);
    });
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12 ? DateTime.utc(month.year, month.month + 1) : DateTime.utc(month.year + 1);
    return date.subtract(const Duration(days: 1));
  }

  int _getBeforeDays(DateTime firstDay) {
    return (firstDay.weekday + 7 - _getWeekdayNumber(_startingDayOfWeek)) % 7;
  }

  int _getAfterDays(DateTime lastDay) {
    final invertedStartingWeekday = 8 - _getWeekdayNumber(_startingDayOfWeek);
    final daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      return 0;
    }
    return daysAfter;
  }

  int _getWeekdayNumber(StartingDayOfWeek weekday) {
    return StartingDayOfWeek.values.indexOf(weekday) + 1;
  }

  bool _isSunday(DateTime day) {
    return day.weekday == DateTime.sunday;
  }

  bool _isSaturday(DateTime day) {
    return day.weekday == DateTime.saturday;
  }

  DateTime _clampMonth(DateTime month) {
    if (_isBefore(month, _minMonth)) {
      return DateTime(_minMonth.year, _minMonth.month);
    }
    if (_isAfter(month, _maxMonth)) {
      return DateTime(_maxMonth.year, _maxMonth.month);
    }
    return DateTime(month.year, month.month);
  }

  bool _isBefore(DateTime a, DateTime b) {
    return a.year < b.year || (a.year == b.year && a.month < b.month);
  }

  bool _isAfter(DateTime a, DateTime b) {
    return a.year > b.year || (a.year == b.year && a.month > b.month);
  }
}
