import 'package:with_calendar/data/network/dio/dio_service.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';

class HolidayService {
  final DioService _dioService = DioService();

  Future<HolidayMap> fetchHolidayList(int year) async {
    final response = await _dioService.get(
      path: 'B090041/openapi/service/SpcdeInfoService/getRestDeInfo',
      parameters: {
        'solYear': year.toString(),
        'ServiceKey':
            'IIL7UWdyZVoWG7cxSTS8dR7GOOF39dZfa5Yb2ycPnkfuzythdYSJAHrD3ymecrT0Ll0p1B9F%2Bc3diiWELt3nUw%3D%3D',
        '_type': 'json',
        'numOfRows': '30',
      },
    );
    final items = response['response']['body']['items'];
    final rawItems = items?['item'];
    if (rawItems == null || rawItems is! List) {
      return {};
    }

    // 공휴일 리스트
    final HolidayMap holidayMap = {};

    // 파싱 후 맵에 추가
    for (final item in rawItems) {
      final holiday = Holiday.fromJson(item);
      holidayMap.putIfAbsent(holiday.date, () => []).add(holiday);
    }
    return holidayMap;
  }
}
