class Holiday {
  final String title;
  final DateTime date;

  const Holiday({required this.title, required this.date});

  static Holiday fromJson(Map<String, dynamic> json) {
    String title = json['dateName'] ?? '';

    if (title == '1월1일') {
      title = '신정';
    }

    if (title == '기독탄신일') {
      title = '크리스마스';
    }

    if (title == '부처님오신날') {
      title = '석가탄신일';
    }

    final locdateStr = json['locdate'].toString();
    final year = int.parse(locdateStr.substring(0, 4));
    final month = int.parse(locdateStr.substring(4, 6));
    final day = int.parse(locdateStr.substring(6, 8));

    return Holiday(
      title: title,
      date: DateTime.utc(year, month, day),
    );
  }

  ///
  /// 해당 일정과 날짜 비교
  ///
  bool isSameDate(DateTime date) {
    return this.date.year == date.year &&
        this.date.month == date.month &&
        this.date.day == date.day;
  }
}


typedef HolidayMap = Map<DateTime, List<Holiday>>;
