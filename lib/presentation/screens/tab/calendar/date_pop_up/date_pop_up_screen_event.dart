import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klc/klc.dart';
import 'package:with_calendar/data/services/schedule/schedule_service.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/date_pop_up/date_pop_up_screen_state.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

///
/// 날짜 팝업 화면 이벤트
///
mixin class DatePopupEvent {
  /// 일정 서비스
  final ScheduleService _scheduleService = ScheduleService();

  /// 달력 시작, 종료 날짜
  final DateTime _startDate = DateTime.utc(2000, 1, 1);
  final DateTime _endDate = DateTime.utc(2050, 12, 31);

  /// 전체 날짜 수 반환
  int get totalPageCount => _endDate.difference(_startDate).inDays + 1;

  /// 날짜가 범위 안인지 확인
  bool isInRange(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return !utcDate.isBefore(_startDate) && !utcDate.isAfter(_endDate);
  }

  ///
  /// DateTime을 UTC 자정으로 정규화
  ///
  /// 시간, 밀리초, 마이크로초 정보를 제거하여
  /// 날짜 부분만 남긴 UTC DateTime을 반환합니다.
  ///
  /// 예시:
  /// - 2024-01-15 09:30:45.123 → 2024-01-15 00:00:00.000Z
  /// - 2024-01-15T14:00:00+09:00 → 2024-01-15 00:00:00.000Z
  ///
  DateTime _normalizeDateToUtc(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  ///
  /// 아래 세 가지 날짜의 일정 리스트를 계산하여 Map에 저장하는 메서드
  /// - 전달받은 날짜의 이전 날짜
  /// - 전달받은 날짜
  /// - 전달받은 날짜의 이후 날짜
  ///
  void calculateScheduleMap(WidgetRef ref, DateTime targetDate) {
    // 날짜를 정규화하여 생성
    final dates = [
      _normalizeDateToUtc(targetDate.subtract(const Duration(days: 1))),
      _normalizeDateToUtc(targetDate),
      _normalizeDateToUtc(targetDate.add(const Duration(days: 1))),
    ];

    // 현재 선택된 달력 정보
    final currentCalendar = ref.read(CalendarScreenState.currentCalendar);

    // 전역 스케줄 스트림에서 현재 데이터 읽기
    final scheduleMapAsync = ref.read(
      CalendarScreenState.scheduleListStreamProvider(currentCalendar),
    );

    // 데이터가 로드되지 않았으면 스킵
    final globalScheduleMap = scheduleMapAsync.asData?.value;
    if (globalScheduleMap == null) return;

    // 현재 로컬 맵
    final currentLocalMap = ref.read(DatePopupState.scheduleMap);
    final newEntries = <DateTime, List<Schedule>>{};

    for (final date in dates) {
      // 이미 로컬 캐시에 있으면 스킵
      if (currentLocalMap.containsKey(date)) continue;

      // 해당 날짜의 스케줄 가져오기
      final scheduleList = globalScheduleMap[date] ?? [];

      // spacer 제외한 일정 리스트 반환
      newEntries[date] = filterSpacers(scheduleList);
    }

    // 맵 업데이트
    if (newEntries.isNotEmpty) {
      ref.read(DatePopupState.scheduleMap.notifier).state = {
        ...currentLocalMap,
        ...newEntries,
      };
    }
  }

  ///
  /// spacer 제외한 일정 리스트 반환
  ///
  List<Schedule> filterSpacers(List<Schedule> schedules) {
    return schedules
        .where((e) => e.weekSegmentState != WeekCellState.spacer)
        .toList();
  }

  ///
  /// 날짜를 기반으로 페이지 인덱스 계산
  ///
  int calculatePageIndexFromDate(DateTime date) {
    // 날짜를 UTC 형식으로 변환
    final utcDate = DateTime.utc(date.year, date.month, date.day);

    // 최소 날짜 이전이면 첫 번째 인덱스
    if (utcDate.isBefore(_startDate)) return 0;

    // 최대 날짜 이후이면 마지막 인덱스
    if (utcDate.isAfter(_endDate)) return totalPageCount - 1;

    // 최소 날짜부터 전달된 날짜까지의 일수 계산
    return utcDate.difference(_startDate).inDays;
  }

  /// 전달된 인덱스를 날짜로 변환
  DateTime dateOf(int index) {
    // 첫 번째 인덱스이면 최소 날짜 반환
    if (index <= 0) return _startDate;

    // 마지막 인덱스이면 최대 날짜 반환
    if (index >= totalPageCount - 1) return _endDate;

    // 최소 날짜부터 전달된 인덱스까지의 날짜 반환
    return _startDate.add(Duration(days: index));
  }

  ///
  /// 페이지 이동 처리
  /// - 페이지 인덱스를 상태로 저장
  /// - 인덱스에 해당하는 날짜를 계산하여 선택 날짜 업데이트
  ///
  void handlePageChanged(WidgetRef ref, int pageIndex) {
    final resolvedIndex = _resolveIndex(pageIndex);

    // 음력 날짜 계산
    calculateLunarDateMap(ref, dateOf(resolvedIndex));
  }

  ///
  /// 범위를 벗어난 인덱스가 들어왔을 때 안전하게 보정
  ///
  int _resolveIndex(int index) {
    if (index < 0) return 0;
    if (index >= totalPageCount) return totalPageCount - 1;
    return index;
  }

  // -------------------------------음력 날짜 조회 --------------------------------

  ///
  /// 아래 세 가지 날짜의 음력 날짜를 계산하여 Map에 저장하는 메서드
  /// - 전달받은 날짜의 이전 날짜
  /// - 전달받은 날짜
  /// - 전달받은 날짜의 이후 날짜
  ///
  void calculateLunarDateMap(WidgetRef ref, DateTime targetDate) {
    // 이전, 현재, 이후 날짜 계산
    final dates = [
      targetDate.subtract(const Duration(days: 1)),
      targetDate,
      targetDate.add(const Duration(days: 1)),
    ];

    // 현재 음력 날짜 맵
    final currentLunarMap = ref.read(DatePopupState.lunarDateMap);

    // 새로운 음력 날짜 맵
    final newLunarMap = <String, LunarDate>{};

    for (final date in dates) {
      final cacheKey = getCacheKey(date);

      // 이미 캐시에 있으면 스킵
      if (currentLunarMap.containsKey(cacheKey)) continue;

      // 음력 계산
      final lunarDate = calculateLunarDate(date);
      if (lunarDate != null) {
        newLunarMap[cacheKey] = lunarDate;
      }
    }

    // 새로운 항목이 있을 때만 한 번에 업데이트
    if (newLunarMap.isNotEmpty) {
      ref.read(DatePopupState.lunarDateMap.notifier).state = {
        ...currentLunarMap,
        ...newLunarMap,
      };
    }
  }

  ///
  /// Date를 기반으로 캐시 키 생성
  ///
  String getCacheKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  ///
  /// 음력 날짜 조회
  ///
  LunarDate? calculateLunarDate(DateTime date) {
    try {
      // 양력 날짜 변환
      final isConverted = setSolarDate(date.year, date.month, date.day);

      // 변환 실패 시 null 반환
      if (!isConverted) {
        throw Exception('음력 변환 실패: 지원하지 않는 양력 날짜');
      }

      final isoString = getLunarIsoFormat();
      final lunarIsoDate = isoString.split(' ').first;
      final isLeapMonth = isoString.contains('Intercalation');

      final lunarDate = DateTime.parse(lunarIsoDate);
      final lunarText = lunarDate.toStringFormat('yyyy년 MM월 dd일');

      /// 음력 날짜 설정
      return LunarDate(
        solarDate: date,
        date: lunarDate,
        dateString: isLeapMonth ? '윤 $lunarText' : lunarText,
      );
    } catch (e) {
      log('음력 날짜 파싱 실패: error: $e');
      return null;
    }
  }

  // -------------------------------일정 관련 ----------------------------------
  ///
  /// 일정 삭제
  ///
  Future<void> deleteSchedule(WidgetRef ref, String scheduleID) async {
    final calendar = ref.read(CalendarScreenState.currentCalendar);

    await _scheduleService.deleteSchedule(
      calendar: calendar,
      scheduleID: scheduleID,
    );
  }
}
