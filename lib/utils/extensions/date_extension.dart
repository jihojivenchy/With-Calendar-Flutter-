import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// DateTime을 원하는 포맷의 문자열로 변환합니다.
  ///
  /// [format] - 날짜 포맷 (기본값: 'yyyy.MM')
  ///
  String toStringFormat([String format = 'yyyy.MM']) {
    return DateFormat(format).format(this);
  }

  ///
  /// 오늘 날짜와 동일한 년도와 달인지 확인합니다.
  ///
  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month;
  }

  ///
  /// yyyy년 MM월 dd일 (요일) 오전/오후 HH시 mm분 형식
  ///
  String toKoreanFullDateTimeFormat() {
    final DateFormat formatter = DateFormat(
      'yyyy년 MM월 dd일 (E) a hh시 mm분',
      'ko_KR',
    );
    return formatter.format(this);
  }

  ///
  /// yyyy년 MM월 dd일 (요일) 오전/오후 HH시 mm분 형식
  ///
  String toKoreanSimpleDateFormat() {
    final DateFormat formatter = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');
    return formatter.format(this);
  }
}

extension StringDateExtension on String {
  ///
  /// 문자열을 DateTime으로 변환합니다.
  ///
  String toAnotherDateFormat([String format = 'yyyy년 MM월 dd일']) {
    try {
      final date = DateTime.parse(this);
      return date.toStringFormat(format);
    } catch (e) {
      return this;
    }
  }
}
