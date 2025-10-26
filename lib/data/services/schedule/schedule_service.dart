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
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
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
        .orderBy('timestamp', descending: false)
        .orderBy('durationPriority', descending: true)
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
      // 시작 날짜
      final startKey = _createDateKey(schedule.startDate);

      // 단기 일정은 spacer가 있다면 우선 채워 넣는다
      if (schedule.duration == ScheduleDuration.short) {
        _insertShortSchedule(
          scheduleMap: scheduleMap,
          key: startKey,
          schedule: schedule,
        );
        continue;
      }

      // 종료 날짜
      final endKey = _createDateKey(schedule.endDate);

      // 장기 일정은 주 단위로 나누어 처리
      var segmentStart = startKey;

      // 종료 날짜까지 반복
      while (!segmentStart.isAfter(endKey)) {
        // 주 시작 날짜
        final weekStart = _startOfWeek(segmentStart);

        // 주 종료 날짜
        final weekEnd = weekStart.add(const Duration(days: 6));

        // 주 종료 날짜(일요일)와 일정의 종료 날짜를 비교하여 더 이른 날짜를 종료 날짜로 설정
        final segmentEnd = weekEnd.isBefore(endKey) ? weekEnd : endKey;

        // 해당 날짜의 슬롯 인덱스
        final slotIndex = _getSlotIndex(
          scheduleMap,
          segmentStart: segmentStart,
        );

        // 시작 날짜 데이터 주입
        _addScheduleAtSlot(
          scheduleMap: scheduleMap,
          key: segmentStart,
          slotIndex: slotIndex,
          schedule: schedule.copyWith(
            weekSegmentState: WeekCellState.start,
            weekStartVisibleDayCount:
                segmentEnd.difference(segmentStart).inDays + 1,
          ),
        );

        // 시작 날짜를 제외한 나머지 날짜들은 content로 채우기
        var contentDay = segmentStart.add(const Duration(days: 1));

        // 종료 날짜까지 반복
        while (!contentDay.isAfter(segmentEnd)) {
          _addScheduleAtSlot(
            scheduleMap: scheduleMap,
            key: contentDay,
            slotIndex: slotIndex,
            schedule: schedule.copyWith(
              weekSegmentState: WeekCellState.content,
              weekStartVisibleDayCount: 0,
            ),
          );
          contentDay = contentDay.add(const Duration(days: 1));
        }

        // 다음 주로 이동
        segmentStart = segmentEnd.add(const Duration(days: 1));
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
  /// 해당 날짜의 주 시작 날짜 계산
  ///
  DateTime _startOfWeek(DateTime day) {
    final difference = day.weekday % 7;
    return day.subtract(Duration(days: difference));
  }

  ///
  /// 해당 날짜 리스트에서 현재 일정이 위치해야 할 인덱스 계산
  ///
  int _getSlotIndex(
    Map<DateTime, List<Schedule>> scheduleMap, {
    required DateTime segmentStart,
  }) {
    final key = _createDateKey(segmentStart);
    return scheduleMap[key]?.length ?? 0;
  }

  ///
  /// 지정된 슬롯에 일정을 삽입하면서 부족한 칸은 자동으로 spacer로 채움
  ///
  void _addScheduleAtSlot({
    required Map<DateTime, List<Schedule>> scheduleMap,
    required DateTime key,
    required int slotIndex,
    required Schedule schedule,
  }) {
    final list = scheduleMap.putIfAbsent(key, () => <Schedule>[]);

    // 부족한 칸은 spacer로 채우기
    while (list.length < slotIndex) {
      list.add(
        schedule.copyWith(
          weekSegmentState: WeekCellState.spacer,
          weekStartVisibleDayCount: 0,
        ),
      );
    }

    // 일정이 위치해야할 인덱스에 일정 주입
    if (list.length == slotIndex) {
      list.add(schedule);
    } else {
      list[slotIndex] = schedule;
    }
  }

  ///
  /// 단기 일정 처리
  /// 기존 spacer 데이터가 있으면 갈아끼우기
  /// 없으면 추가
  ///
  void _insertShortSchedule({
    required DateTime key,
    required Map<DateTime, List<Schedule>> scheduleMap,
    required Schedule schedule,
  }) {
    final list = scheduleMap.putIfAbsent(key, () => <Schedule>[]);

    // spacer 데이터가 있는 인덱스 찾기
    final spacerIndex = list.indexWhere(
      (item) => item.weekSegmentState == WeekCellState.spacer,
    );

    // spacer 데이터가 없으면 추가
    if (spacerIndex == -1) {
      list.add(schedule);
      return;
    }

    // spacer 데이터가 있으면 갈아끼우기
    list[spacerIndex] = schedule;
  }

  ///
  /// 일정 생성
  ///
  Future<String> create(CreateScheduleRequest schedule) async {
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
      'isTodoExist': schedule.todoList.isNotEmpty, // 할 일 목록 존재 여부
    };

    final collectionName = calendar.type == CalendarType.private
        ? FirestoreCollection.calendar
        : FirestoreCollection.shareCalendar;

    // 배치 생성으로 일정 생성과 할 일 목록 생성을 한 번에 처리
    final batch = firestore.batch();

    // 1. 일정 문서 생성
    final scheduleRef = firestore
        .collection(collectionName)
        .doc(calendar.id)
        .collection(collectionName)
        .doc(scheduleID);
    batch.set(scheduleRef, scheduleData);

    // 2. 할 일 목록 문서 생성 (할 일이 있는 경우)
    if (schedule.todoList.isNotEmpty) {
      final todoCollectionRef = scheduleRef.collection(
        FirestoreCollection.todo,
      );

      // 할 일 목록 문서 생성
      for (final todo in schedule.todoList) {
        final todoRef = todoCollectionRef.doc(todo.id);
        batch.set(todoRef, todo.toJson(scheduleID: scheduleID));
      }
    }

    // 배치 실행
    await batch.commit();

    return scheduleID;
  }

  ///
  /// 일정 삭제
  ///
  Future<void> deleteSchedule({
    required CalendarInformation calendar,
    required String scheduleID,
  }) async {
    // 캘린더 컬렉션 이름
    final collectionName = calendar.type == CalendarType.private
        ? FirestoreCollection.calendar
        : FirestoreCollection.shareCalendar;

    // 일정 삭제
    await firestore
        .collection(collectionName)
        .doc(calendar.id)
        .collection(collectionName)
        .doc(scheduleID)
        .delete();
  }

  ///
  /// 일정 수정
  ///
  Future<void> updateSchedule(CreateScheduleRequest schedule) async {
    // 현재 선택된 캘린더 정보 가져오기
    final result = HiveService.instance.get(HiveBoxPath.currentCalendar);
    final calendar = CalendarInformation.fromHiveJson(result);

    final Map<String, dynamic> updateData = {
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
        .doc(schedule.id)
        .update(updateData);
  }

  
}
