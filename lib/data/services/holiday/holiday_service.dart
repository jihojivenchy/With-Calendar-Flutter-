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
    if (items == null || items['item'] == null) {
      return {};
    }

    // 공휴일 리스트
    final holidayList = (items['item'] as List)
        .map((e) => Holiday.fromJson(e))
        .toList();

    // 공휴일 맵으로 변경
    final HolidayMap holidayMap = {};

    for (final holiday in holidayList) {
      holidayMap.putIfAbsent(holiday.date, () => []).add(holiday);
    }
    return holidayMap;
  }
}
