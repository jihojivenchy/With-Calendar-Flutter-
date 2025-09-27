import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ShareCalendarService with BaseFirestoreMixin {
  ///
  /// 캘린더 리스트 조회
  ///
  Future<List<CalendarInformation>> fetchCalendarList() async {
    final data = await firestore
        .collection(FirestoreCollection.users)
        .doc(getUserUID)
        .collection(FirestoreCollection.calendarList)
        .get();

    // 캘린더 리스트 반환
    return (data.docs as List? ?? [])
        .map((doc) => CalendarInformation.fromJson(doc.data()))
        .toList();
  }

  ///
  /// 내 정보 조회해서 달력 참여자 리스트에 방장으로 추가
  ///
  Future<CalendarParticipant> fetchProfile() async {
    final data = await fetchDocumentData(
      FirestoreCollection.users,
      documentID: getUserUID,
    );
    final participant = CalendarParticipant.fromJson(data);
    return participant.copyWith(isOwner: true);
  }

  ///
  /// 유저 검색
  ///
  Future<List<CalendarParticipant>> searchUser(String userCode) async {
    final data = await firestore
        .collection(FirestoreCollection.users)
        .where('userCode', isEqualTo: userCode)
        .get();

    return (data.docs as List? ?? [])
        .map((doc) => CalendarParticipant.fromJson(doc.data()))
        .toList();
  }

  ///
  /// 공유달력 생성
  ///
  Future<void> createCalendar(ShareCalendarCreation creation) async {
    // 공유 달력 상세 정보
    final calendarID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');
    final Map<String, dynamic> infoData = creation.toJson(
      ownerID: getUserUID,
      calendarID: calendarID,
      createdAt: createdAt,
    );

    // 배치 생성
    final WriteBatch batch = firestore.batch();

    // 1. 공유 달력 정보 생성
    final DocumentReference infoRef = firestore
        .collection(FirestoreCollection.shareCalendarInfo)
        .doc(calendarID);

    batch.set(infoRef, infoData);

    // 2. 참여 유저들의 캘린더 리스트에 추가
    for (var participant in creation.participantList) {
      // 캘린더 정보
      final Map<String, dynamic> calendarInfo = CalendarInformation(
        id: calendarID,
        name: creation.title,
        type: CalendarType.shared,
        createdAt: createdAt,
      ).toJson();

      // 유저 Reference
      final userRef = firestore
          .collection(FirestoreCollection.users)
          .doc(participant.userID)
          .collection(FirestoreCollection.calendarList)
          .doc(calendarID);

      // 유저 캘린더 리스트에 추가
      batch.set(userRef, calendarInfo);
    }

    // 배치 실행
    await batch.commit();
  }

  ///
  /// 공유 달력 조회
  ///
  Future<ShareCalendar> fetchShareCalendar(String calendarID) async {
    final data = await fetchDocumentData(
      FirestoreCollection.shareCalendarInfo,
      documentID: calendarID,
    );

    // 공유 달력 정보 반환 (현재 유저가 오너인지 판별 후)
    final calendar = ShareCalendar.fromJson(data);
    return calendar.copyWith(isOwner: getUserUID == calendar.ownerID);
  }

  ///
  /// 공유달력 수정
  ///
  Future<void> updateCalendar(ShareCalendar calendar) async {
    // 배치 생성
    final WriteBatch batch = firestore.batch();

    // 1. 공유 달력 정보 수정
    final DocumentReference infoRef = firestore
        .collection(FirestoreCollection.shareCalendarInfo)
        .doc(calendar.id);

    batch.set(infoRef, calendar.toJson());

    // 2. 삭제된 유저들의 정보에 캘린더 정보 제거
    for (var participant in calendar.deletedParticipantList) {
      final userRef = firestore
          .collection(FirestoreCollection.users)
          .doc(participant.userID)
          .collection(FirestoreCollection.calendarList)
          .doc(calendar.id);

      // 유저 캘린더 리스트에서 제거
      batch.delete(userRef);
    }

    // 3. 참여 유저들의 캘린더 리스트에 추가
    for (var participant in calendar.participantList) {
      // 캘린더 정보
      final Map<String, dynamic> calendarInfo = CalendarInformation(
        id: calendar.id,
        name: calendar.title,
        type: CalendarType.shared,
        createdAt: calendar.createdAt,
      ).toJson();

      final userRef = firestore
          .collection(FirestoreCollection.users)
          .doc(participant.userID)
          .collection(FirestoreCollection.calendarList)
          .doc(calendar.id);

      // 유저 캘린더 리스트에 추가
      batch.set(userRef, calendarInfo);
    }

    // 배치 실행
    await batch.commit();
  }

  ///
  /// 공유달력 나가기
  ///
  Future<void> exitCalendar(ShareCalendar calendar) async {
    // 캘린더 리스트에서 자신을 제외
    final updatedCalendar = calendar.copyWith(
      participantList: calendar.participantList
          .where((participant) => participant.userID != getUserUID)
          .toList(),
    );

    // 배치 생성
    final WriteBatch batch = firestore.batch();

    // 1. 공유 달력 정보 수정
    final DocumentReference infoRef = firestore
        .collection(FirestoreCollection.shareCalendarInfo)
        .doc(calendar.id);
    batch.set(infoRef, updatedCalendar.toJson());

    // 2. 내 캘린더 리스트에서 제거
    final userRef = firestore
        .collection(FirestoreCollection.users)
        .doc(getUserUID)
        .collection(FirestoreCollection.calendarList)
        .doc(calendar.id);

    // 유저 캘린더 리스트에서 제거
    batch.delete(userRef);

    // 배치 실행
    await batch.commit();

    // 기본 캘린더로 선택 전환
    setDefaultCalendar();
  }

  ///
  /// 공유달력 삭제
  ///
  Future<void> deleteCalendar(ShareCalendar calendar) async {
    // 배치 생성
    final WriteBatch batch = firestore.batch();

    // 1. 공유 달력 정보 제거
    final DocumentReference infoRef = firestore
        .collection(FirestoreCollection.shareCalendarInfo)
        .doc(calendar.id);
    batch.delete(infoRef);

    // 2. 공유 달력 제거
    final calendarRef = firestore
        .collection(FirestoreCollection.shareCalendar)
        .doc(calendar.id);
    batch.delete(calendarRef);

    // 3. 각 참가자들의 캘린더 리스트에서 제거
    for (var participant in calendar.participantList) {
      final userRef = firestore
          .collection(FirestoreCollection.users)
          .doc(participant.userID)
          .collection(FirestoreCollection.calendarList)
          .doc(calendar.id);
      batch.delete(userRef);
    }

    // 배치 실행
    await batch.commit();

    // 기본 캘린더로 선택 전환
    setDefaultCalendar();
  }

  //
  /// 기본 캘린더로 선택 전환
  ///
  void setDefaultCalendar() {
    // 기본 캘린더 정보
    final defaultCalendar = CalendarInformation(
      id: getUserUID,
      name: 'With Calendar',
      type: CalendarType.private,
      createdAt: '',
    );
    HiveService.instance.create(
      HiveBoxPath.currentCalendar,
      value: defaultCalendar.toJson(),
    );
  }
}
