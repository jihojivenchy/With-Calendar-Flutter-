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

  ///
  /// Firestore에 공휴일 데이터를 주입합니다.
  ///
  /// [holidaySeedPayload] 는 연도(문서 ID) -> 'yyyy-MM-dd' 문자열 -> Holiday 리스트 구조입니다.
  /// Firestore에는 날짜별 Holiday 리스트를 Map<String, dynamic> 형태로 직렬화하여 저장합니다.
  ///
  Future<void> seedHolidayDocuments(
    HolidaySeedPayload holidaySeedPayload,
  ) async {
    if (holidaySeedPayload.isEmpty) {
      return;
    }

    final writeJobs = <Future<void>>[];

    holidaySeedPayload.forEach((yearKey, holidaysByDate) {
      if (holidaysByDate.isEmpty) {
        return;
      }

      final sortedEntries = holidaysByDate.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      final serializedDates = <String, List<Map<String, dynamic>>>{};

      for (final entry in sortedEntries) {
        final holidays = entry.value;
        if (holidays.isEmpty) {
          continue;
        }

        serializedDates[entry.key] = holidays
            .map((holiday) => holiday.toFirestoreMap())
            .toList();
      }

      if (serializedDates.isEmpty) {
        return;
      }

      final data = <String, dynamic>{
        FirestoreHolidayField.year: int.tryParse(yearKey) ?? yearKey,
        FirestoreHolidayField.dates: serializedDates,
      };

      writeJobs.add(
        set(FirestoreCollection.holiday, documentID: yearKey, data: data),
      );
    });

    if (writeJobs.isEmpty) {
      return;
    }

    await Future.wait(writeJobs);
  }
}
