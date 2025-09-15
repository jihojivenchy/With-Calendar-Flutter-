import 'dart:developer';

import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';

class ShareCalendarService with BaseFirestoreMixin {
  ///
  /// 캘린더 리스트 조회
  ///
  Future<List<CalendarInformation>> fetchCalendarList() async {
    final data = await fetchDocumentData(
      FirestoreCollection.users,
      documentID: getUserUID,
    );

    // 캘린더 리스트 파싱
    final calendarList = Profile.fromJson(data).calendarList;

    // 캘린더 리스트 로컬에 저장
    for (var calendar in calendarList) {
      HiveService.instance.create(
        HiveBoxPath.calendarList,
        key: calendar.id,
        value: calendar.toJson(),
      );
    }

    // 캘린더 리스트 반환
    return calendarList;
  }
}
