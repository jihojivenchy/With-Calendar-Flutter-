import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ShareCalendarService with BaseFirestoreMixin {
  ///
  /// 캘린더 리스트 조회
  ///
  Future<List<CalendarInformation>> fetchCalendarList() async {
    final data = await fetchDocumentData(
      FirestoreCollection.users,
      documentID: getUserUID,
    );

    // 캘린더 리스트 반환
    return Profile.fromJson(data).calendarList;
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
  Future<void> create(ShareCalendarCreation creation) async {
    // 공유 달력 상세 정보
    final calendarID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');
    final Map<String, dynamic> infoData = creation.toJson(
      calendarID,
      createdAt,
    );

    // 배치 생성
    final WriteBatch batch = firestore.batch();

    // 1. 공유 달력 정보 생성
    final DocumentReference infoRef = firestore
        .collection(FirestoreCollection.shareCalendarInfo)
        .doc(calendarID);

    batch.set(infoRef, infoData);

    // 2. 참여 유저들의 정보에 캘린더 정보 추가
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
          .doc(participant.userID);

      // 유저 정보 업데이트
      batch.update(userRef, {
        'calendarList': FieldValue.arrayUnion([calendarInfo]),
      });
    }

    // 배치 실행
    await batch.commit();
  }
}
