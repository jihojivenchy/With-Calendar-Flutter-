import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
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
    final memoID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

    await firestore
        .collection(FirestoreCollection.memo)
        .doc(getUserUID)
        .collection(FirestoreCollection.memo)
        .doc(memoID)
        .set({
          'id': memoID,
          'content': schedule.memo,
          'pinColor': schedule.color.toARGB32(), // 32비트 색상 값으로 변환
          'createdAt': createdAt,
        });
  }
}
