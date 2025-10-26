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
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class TodoService with BaseFirestoreMixin {
  ///
  /// 일정 조회
  ///
  Stream<List<Todo>> fetchTodoList(String scheduleID) {
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
        .doc(scheduleID)
        .collection(FirestoreCollection.todo)
        .snapshots()
        .map((snapshot) {
          final todoList = snapshot.docs
              .map((doc) => Todo.fromJson(doc.data()))
              .toList();
          return todoList;
        });
  }

  ///
  /// 할 일 수정
  ///
  Future<void> updateTodo({
    required CalendarInformation calendar,
    required String scheduleID,
    required String todoID,
    required bool isDone,
  }) async {
    // 캘린더 컬렉션 이름
    final collectionName = calendar.type == CalendarType.private
        ? FirestoreCollection.calendar
        : FirestoreCollection.shareCalendar;

    await firestore
        .collection(collectionName)
        .doc(calendar.id)
        .collection(collectionName)
        .doc(scheduleID)
        .collection(FirestoreCollection.todo)
        .doc(todoID)
        .update({'isDone': isDone});
  }
}
