import 'package:with_calendar/data/services/holiday/holiday_service.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';

/// Firestore에 주입할 공휴일 시드 데이터
class HolidaySeedData {
  /// 2022년 공휴일 정보 (yyyy-MM-dd -> Holiday 리스트)
  static final Map<String, List<Holiday>> holidays2022 = {
    '2022-01-01': [Holiday(title: '신정', date: DateTime.utc(2022, 1, 1))],
    '2022-01-31': [Holiday(title: '설날', date: DateTime.utc(2022, 1, 31))],
    '2022-02-01': [Holiday(title: '설날 연휴', date: DateTime.utc(2022, 2, 1))],
    '2022-02-02': [Holiday(title: '설날', date: DateTime.utc(2022, 2, 2))],
    '2022-03-01': [Holiday(title: '삼일절', date: DateTime.utc(2022, 3, 1))],
    '2022-03-09': [Holiday(title: '대통령선거', date: DateTime.utc(2022, 3, 9))],
    '2022-05-05': [Holiday(title: '어린이날', date: DateTime.utc(2022, 5, 5))],
    '2022-05-08': [Holiday(title: '부처님오신날', date: DateTime.utc(2022, 5, 8))],
    '2022-06-01': [Holiday(title: '전국동시지방선거', date: DateTime.utc(2022, 6, 1))],
    '2022-06-06': [Holiday(title: '현충일', date: DateTime.utc(2022, 6, 6))],
    '2022-08-15': [Holiday(title: '광복절', date: DateTime.utc(2022, 8, 15))],
    '2022-09-09': [Holiday(title: '추석', date: DateTime.utc(2022, 9, 9))],
    '2022-09-10': [Holiday(title: '추석 연휴', date: DateTime.utc(2022, 9, 10))],
    '2022-09-11': [Holiday(title: '추석', date: DateTime.utc(2022, 9, 11))],
    '2022-09-12': [
      Holiday(title: '대체공휴일(추석)', date: DateTime.utc(2022, 9, 12)),
    ],
    '2022-10-03': [Holiday(title: '개천절', date: DateTime.utc(2022, 10, 3))],
    '2022-10-09': [Holiday(title: '한글날', date: DateTime.utc(2022, 10, 9))],
    '2022-10-10': [
      Holiday(title: '대체공휴일(한글날)', date: DateTime.utc(2022, 10, 10)),
    ],
    '2022-12-25': [Holiday(title: '크리스마스', date: DateTime.utc(2022, 12, 25))],
  };

  /// 2021년 공휴일 정보 (yyyy-MM-dd -> Holiday 리스트)
  static final Map<String, List<Holiday>> holidays2021 = {
    '2021-01-01': [Holiday(title: '신정', date: DateTime.utc(2021, 1, 1))],
    '2021-02-11': [Holiday(title: '설날', date: DateTime.utc(2021, 2, 11))],
    '2021-02-12': [Holiday(title: '설날 연휴', date: DateTime.utc(2021, 2, 12))],
    '2021-02-13': [Holiday(title: '설날', date: DateTime.utc(2021, 2, 13))],
    '2021-03-01': [Holiday(title: '삼일절', date: DateTime.utc(2021, 3, 1))],
    '2021-05-05': [Holiday(title: '어린이날', date: DateTime.utc(2021, 5, 5))],
    '2021-05-19': [Holiday(title: '부처님오신날', date: DateTime.utc(2021, 5, 19))],
    '2021-06-06': [Holiday(title: '현충일', date: DateTime.utc(2021, 6, 6))],
    '2021-08-15': [Holiday(title: '광복절', date: DateTime.utc(2021, 8, 15))],
    '2021-08-16': [
      Holiday(title: '대체공휴일(광복절)', date: DateTime.utc(2021, 8, 16)),
    ],
    '2021-09-20': [Holiday(title: '추석', date: DateTime.utc(2021, 9, 20))],
    '2021-09-21': [Holiday(title: '추석 연휴', date: DateTime.utc(2021, 9, 21))],
    '2021-09-22': [Holiday(title: '추석', date: DateTime.utc(2021, 9, 22))],
    '2021-10-03': [Holiday(title: '개천절', date: DateTime.utc(2021, 10, 3))],
    '2021-10-04': [
      Holiday(title: '대체공휴일(개천절)', date: DateTime.utc(2021, 10, 4)),
    ],
    '2021-10-09': [Holiday(title: '한글날', date: DateTime.utc(2021, 10, 9))],
    '2021-10-11': [
      Holiday(title: '대체공휴일(한글날)', date: DateTime.utc(2021, 10, 11)),
    ],
    '2021-12-25': [Holiday(title: '크리스마스', date: DateTime.utc(2021, 12, 25))],
  };

  /// Firestore 주입용 Payload
  static final HolidaySeedPayload payload2021 = {'2021': holidays2021};

  static Future<void> seed2021() async {
    final service = HolidayService();
    await service.seedHolidayDocuments(payload2021);
  }

  /// Firestore 주입용 Payload
  static final HolidaySeedPayload payload2022 = {'2022': holidays2022};

  /// 2022년 공휴일 데이터를 Firestore에 주입합니다.
  static Future<void> seed2022() async {
    final service = HolidayService();
    await service.seedHolidayDocuments(payload2022);
  }
}
