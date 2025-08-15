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
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class MemoService with BaseFirestoreMixin {
  ///
  /// 메모 조회
  ///
  Stream<List<Memo>> fetchMemoList() {
    return firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(getUserUID)
        .collection(FirestoreConstants.memoCollection)
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Memo.fromJson(doc.data())).toList();
        });
  }

  ///
  /// 메모 생성
  ///
  Future<void> create(MemoCreation memo) async {
    final memoID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

    await firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(getUserUID)
        .collection(FirestoreConstants.memoCollection)
        .doc(memoID)
        .set({
          'id': memoID,
          'content': memo.content,
          'isPinned': memo.isPinned,
          'pinColor': memo.pinColor.toARGB32(), // 32비트 색상 값으로 변환
          'createdAt': createdAt,
        });
  }

  ///
  /// 메모 수정
  ///
  Future<void> updateMemo(Memo memo) async {
    final updatedAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

    await firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(getUserUID)
        .collection(FirestoreConstants.memoCollection)
        .doc(memo.id)
        .update({
          'content': memo.content,
          'isPinned': memo.isPinned,
          'pinColor': memo.pinColor.toARGB32(), // 32비트 색상 값으로 변환
          'createdAt': updatedAt,
        });
  }

  ///
  /// 메모 삭제
  ///
  Future<void> deleteMemo(String memoID) async {
    await firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(getUserUID)
        .collection(FirestoreConstants.memoCollection)
        .doc(memoID)
        .delete();
  }
}
