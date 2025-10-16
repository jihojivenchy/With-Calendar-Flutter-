import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';

typedef HolidaySeedPayload = Map<String, Map<String, List<Holiday>>>;

class HolidayService with BaseFirestoreMixin {
  ///
  /// 공휴일 리스트 조회
  ///
  Future<HolidayMap> fetchHolidayList(int year) async {
    final snapshot = await firestore
        .collection(FirestoreCollection.holiday)
        .doc('$year')
        .get();

    // 데이터가 없을 경우, 빈 맵 반환
    if (!snapshot.exists || snapshot.data() == null) {
      return {};
    }

    // 저장된 공휴일 데이터
    final rawDates = snapshot.data()!['dates'];

    // 변환할 공휴일 맵
    final holidayMap = <DateTime, List<Holiday>>{};

    // 공휴일 데이터 파싱
    for (final entry in rawDates.entries) {
      final date = _parseDateKey(entry.key);
      final holidays = _parseHolidayList(entry.value);

      // 각 데이터가 없으면 다음으로 넘어감
      if (date == null || holidays.isEmpty) {
        continue;
      }

      holidayMap[date] = holidays;
    }

    return holidayMap;
  }

  ///
  /// 날짜 파싱
  ///
  DateTime? _parseDateKey(String key) {
    final date = DateTime.parse(key);
    return DateTime.utc(date.year, date.month, date.day);
  }

  ///
  /// 공휴일 리스트 파싱
  ///
  List<Holiday> _parseHolidayList(List<dynamic> rawList) {
    final holidays = <Holiday>[];

    for (final element in rawList) {
      final holiday = Holiday.fromJson(element);
      holidays.add(holiday);
    }

    return holidays;
  }
}


// TODO: - 공휴일 리스트 조회 공공데이터 포털 API 연동 후 사용하세요.
// Future<HolidayMap> fetchHolidayList(int year) async {
//     final response = await _dioService.get(
//       path: 'B090041/openapi/service/SpcdeInfoService/getRestDeInfo',
//       parameters: {
//         'solYear': year.toString(),
//         'ServiceKey':
//             'IIL7UWdyZVoWG7cxSTS8dR7GOOF39dZfa5Yb2ycPnkfuzythdYSJAHrD3ymecrT0Ll0p1B9F%2Bc3diiWELt3nUw%3D%3D',
//         '_type': 'json',
//         'numOfRows': '30',
//       },
//     );
//     final items = response['response']['body']['items'];
//     final rawItems = items?['item'];
//     if (rawItems == null || rawItems is! List) {
//       return {};
//     }

//     // 공휴일 리스트
//     final HolidayMap holidayMap = {};

//     // 파싱 후 맵에 추가
//     for (final item in rawItems) {
//       final holiday = Holiday.fromJson(item);
//       holidayMap.putIfAbsent(holiday.date, () => []).add(holiday);
//     }
//     return holidayMap;
//   }