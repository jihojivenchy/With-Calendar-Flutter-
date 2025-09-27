import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class ScheduleService with BaseFirestoreMixin {
  ///
  /// 일정 생성
  ///
  Future<void> create(ScheduleCreation schedule) async {
    // 현재 선택된 캘린더 정보 가져오기
    final result = HiveService.instance.get(HiveBoxPath.currentCalendar);
    final calendar = CalendarInformation.fromHiveJson(result);

    // 일정 정보
    final scheduleID = Uuid().v4();

    // 장기 일정인지 단기 일정인지

    final Map<String, dynamic> scheduleData = {
      'id': scheduleID,
      'title': schedule.title,
      'isLong': schedule.isLongSchedule,
      'type': schedule.type.queryValue,
      'startDate': schedule.startDate.toStringFormat('yyyy-MM-dd HH:mm:ss'),
      'endDate': schedule.endDate.toStringFormat('yyyy-MM-dd HH:mm:ss'),
      'notificationTime': schedule.notificationTime,
      'memo': schedule.memo,
      'color': schedule.color.toARGB32(), // 32비트 색상 값으로 변환
    };

    switch (calendar.type) {
      case CalendarType.private:
        await firestore
            .collection(FirestoreCollection.calendar)
            .doc(calendar.id)
            .collection(FirestoreCollection.calendar)
            .doc(scheduleID)
            .set(scheduleData);

        break;
      case CalendarType.shared:
        await firestore
            .collection(FirestoreCollection.shareCalendar)
            .doc(calendar.id)
            .collection(FirestoreCollection.shareCalendar)
            .doc(scheduleID)
            .set(scheduleData);
        break;
    }
  }
}
