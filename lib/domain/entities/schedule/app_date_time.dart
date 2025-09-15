class AppDateTime {
  final String year; // 2000-2100
  final String month; // 01-12
  final String day; // 01-31
  final AppDateTimePeriod period; // 오전, 오후
  final String hour; // 00-12
  final String minute; // 00-59

  const AppDateTime({
    required this.year,
    required this.month,
    required this.day,
    required this.period,
    required this.hour,
    required this.minute,
  });

  AppDateTime copyWith({
    String? year,
    String? month,
    String? day,
    AppDateTimePeriod? period,
    String? hour,
    String? minute,
  }) => AppDateTime(
    year: year ?? this.year,
    month: month ?? this.month,
    day: day ?? this.day,
    period: period ?? this.period,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );

  ///
  /// 초기 상태
  ///
  static AppDateTime initialState = AppDateTime(
    year: DateTime.now().year.toString(),
    month: DateTime.now().month.toString().padLeft(2, '0'),
    day: DateTime.now().day.toString().padLeft(2, '0'),
    period: AppDateTimePeriod.am,
    hour: '00',
    minute: '00',
  );

  ///
  /// 날짜와 시간을 DateTime 객체로 변환
  ///
  DateTime toDateTime() {
    // 24시간 형식으로 변환할 데이터
    int hour24 = int.parse(hour);

    switch (period) {
      // 오전인 경우
      case AppDateTimePeriod.am:
        // 12시 -> 00시로 변환
        if (hour24 == 12) {
          hour24 = 0;
        }
        break;

      // 오후인 경우
      case AppDateTimePeriod.pm:
        // 오후 12시를 제외하고 +12
        if (hour24 != 12) {
          hour24 += 12;
        }
        break;
    }

    return DateTime(
      int.parse(year),
      int.parse(month),
      int.parse(day),
      hour24,
      int.parse(minute),
    );
  }

  ///
  /// 날짜와 시간을 문자열로 변환
  ///
  String get fullDateText {
    // 시간과 분이 00인 경우 시간과 분을 제외하고 날짜만 반환
    if (hour == '00' || minute == '00') {
      return '$year년 $month월 $day일';
    }

    return '$year년 $month월 $day일 ${period.displayText} $hour시 $minute분';
  }

  @override
  String toString() {
    return 'fullDateText: $fullDateText, toDateTime: ${toDateTime()}';
  }
}

enum AppDateTimePeriod {
  am(displayText: '오전'),
  pm(displayText: '오후');

  final String displayText;

  const AppDateTimePeriod({required this.displayText});
}
