import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class MemoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///
  /// 메모 조회
  ///
  Stream<List<Memo>> fetchMemoList() {
    final userUID = _auth.currentUser?.uid;
    if (userUID == null) {
      throw FirebaseAuthErrorType('로그인 상태가 아닙니다.');
    }

    return _firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(userUID)
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
    final userUID = _auth.currentUser?.uid;
    if (userUID == null) {
      throw FirebaseAuthErrorType('로그인 상태가 아닙니다.');
    }

    final memoID = Uuid().v4();
    final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

    await _firestore
        .collection(FirestoreConstants.memoCollection)
        .doc(userUID)
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
}
