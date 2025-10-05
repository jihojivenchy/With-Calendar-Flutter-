part of 'calendar_screen_event.dart';

extension CalendarHolidayEvent on CalendarScreenEvent {
  ///
  /// 공휴일 리스트 조회
  ///
  Future<void> fetchHolidayList(WidgetRef ref, int year) async {
    try {
      // 이미 조회한 연도면 조회하지 않음
      Set<int> loadedYears = ref.read(CalendarScreenState.loadedHolidayYears);
      if (loadedYears.contains(year)) return;

      // 공휴일 리스트 조회
      final currentMap = ref.read(CalendarScreenState.holidayMap);
      final newMap = await _holidayService.fetchHolidayList(year);

      // 공휴일 리스트가 비어있지 않으면 추가
      if (newMap.isNotEmpty) {
        final updatedMap = HolidayMap.from(currentMap);
        updatedMap.addAll(newMap);
        ref.read(CalendarScreenState.holidayMap.notifier).state = updatedMap;
      }

      // 조회한 연도 추가
      ref.read(CalendarScreenState.loadedHolidayYears.notifier).state =
          loadedYears..add(year);
    } catch (e) {
      log('공휴일 리스트 조회 실패: ${e.toString()}');
      SnackBarService.showSnackBar('공휴일 조회에 실패했습니다.');
    }
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
}
