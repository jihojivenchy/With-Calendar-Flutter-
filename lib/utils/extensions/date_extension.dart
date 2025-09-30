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

  /// '08월 14일 (목)' 형식으로 변환
  String toKoreanMonthDay({bool isShort = false}) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일']; // 1=Mon ... 7=Sun
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    final w = weekdays[weekday - 1];

    if (isShort) {
      return '$mm.$dd ($w)';
    } else {
      return '$mm월 $dd일 ($w)';
    }
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
