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
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class ScheduleService with BaseFirestoreMixin {
  ///
  /// 일정 조회
  ///
  Stream<ScheduleMap> fetchScheduleList() {
    // 현재 선택된 캘린더 정보 가져오기
    final result = HiveService.instance.get(HiveBoxPath.currentCalendar);
    final calendar = CalendarInformation.fromHiveJson(result);

    // 캘린더 컬렉션 이름
    final collectionName = calendar.type == CalendarType.private
        ? FirestoreCollection.calendar
        : FirestoreCollection.shareCalendar;

    return firestore
        .collection(collectionName)
        .doc(calendar.id)
        .collection(collectionName)
        .orderBy('isLong', descending: true)
        .orderBy('durationPriority', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final scheduleList = snapshot.docs
              .map((doc) => Schedule.fromJson(doc.data()))
              .toList();
          return _calculateScheduleMap(scheduleList);
        });
  }

  ///
  /// 일정 리스트 => {date: [scheduleList]}
  ///
  Map<DateTime, List<Schedule>> _calculateScheduleMap(
    List<Schedule> scheduleList,
  ) {
    final scheduleMap = <DateTime, List<Schedule>>{};

    for (final schedule in scheduleList) {
      // 시작 날짜 키 생성
      final startKey = _createDateKey(schedule.startDate);

      // 단기 일정은 시작 날짜만 매핑하고 종료
      if (schedule.duration == ScheduleDuration.short) {
        scheduleMap.putIfAbsent(startKey, () => <Schedule>[]).add(schedule);
        continue;
      }

      // 종료 날짜 키 생성
      final endKey = _createDateKey(schedule.endDate);

      // 장기 일정은 시작 ~ 종료까지 모든 날짜에 매핑
      var currentKey = startKey;

      while (!currentKey.isAfter(endKey)) {
        scheduleMap.putIfAbsent(currentKey, () => <Schedule>[]).add(schedule);
        currentKey = currentKey.add(const Duration(days: 1));
      }
    }

    return scheduleMap;
  }

  ///
  /// 날짜를 기반으로 키 생성
  ///
  DateTime _createDateKey(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  ///
  /// 일정 생성
  ///
  Future<void> create(ScheduleCreation schedule) async {
    // 현재 선택된 캘린더 정보 가져오기
    final result = HiveService.instance.get(HiveBoxPath.currentCalendar);
    final calendar = CalendarInformation.fromHiveJson(result);

    // 일정 고유 아이디
    final scheduleID = Uuid().v4();

    final Map<String, dynamic> scheduleData = {
      'id': scheduleID,
      'title': schedule.title,
      'isLong': schedule.isLongSchedule,
      'durationPriority': schedule.durationPriority,
      'type': schedule.type.queryValue,
      'startDate': schedule.startDate.toStringFormat('yyyy-MM-dd HH:mm:ss'),
      'endDate': schedule.endDate.toStringFormat('yyyy-MM-dd HH:mm:ss'),
      'timestamp': Timestamp.fromDate(schedule.startDate),
      'notificationTime': schedule.notificationTime,
      'memo': schedule.memo,
      'color': schedule.color.toARGB32(), // 32비트 색상 값으로 변환
    };

    final collectionName = calendar.type == CalendarType.private
        ? FirestoreCollection.calendar
        : FirestoreCollection.shareCalendar;

    await firestore
        .collection(collectionName)
        .doc(calendar.id)
        .collection(collectionName)
        .doc(scheduleID)
        .set(scheduleData);
  }
}
