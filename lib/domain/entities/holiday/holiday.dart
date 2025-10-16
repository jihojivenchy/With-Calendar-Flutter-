import 'package:intl/intl.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';

class Holiday {
  final String title;
  final DateTime date;

  const Holiday({required this.title, required this.date});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);

    return Holiday(
      title: json['title'] ?? '',
      date: DateTime.utc(date.year, date.month, date.day),
    );
  }

  ///
  /// Firestore에 저장할 수 있도록 Holiday 데이터를 Map으로 변환합니다.
  ///
  Map<String, dynamic> toFirestoreMap() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      FirestoreHolidayField.title: title,
      FirestoreHolidayField.date: dateFormat.format(date),
    };
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



// TODO: - 공휴일 리스트 조회 공공데이터 포털 API 연동 후 사용하세요.
//  static Holiday fromJson(Map<String, dynamic> json) {
//     String title = json['dateName'] ?? '';

//     if (title == '1월1일') {
//       title = '신정';
//     }

//     if (title == '기독탄신일') {
//       title = '크리스마스';
//     }

//     final locdateStr = json['locdate'].toString();
//     final year = int.parse(locdateStr.substring(0, 4));
//     final month = int.parse(locdateStr.substring(4, 6));
//     final day = int.parse(locdateStr.substring(6, 8));

//     return Holiday(title: title, date: DateTime.utc(year, month, day));
//   }