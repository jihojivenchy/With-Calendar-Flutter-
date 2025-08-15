import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:with_calendar/data/network/error/error_type.dart';

/// Firestore 서비스 API를 위한 기본 객체입니다.
mixin class BaseFirestoreMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;

  ///
  /// 현재 로그인 중인 사용자의 UID를 반환합니다.
  /// 없을 경우 오류를 throw합니다.
  ///
  String get getUserUID {
    final userUID = auth.currentUser?.uid;

    if (userUID == null) {
      throw FirebaseAuthError('로그인 상태가 아닙니다.');
    }

    return userUID;
  }

  ///
  /// Collection에 있는 모든 Document를 조회합니다.
  ///
  Future<List<DocumentSnapshot>> fetchDocumentList(
    String collectionName,
  ) async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs;
  }

  ///
  /// Collection에 있는 특정 Document를 조회합니다.
  ///
  Future<Map<String, dynamic>> fetchDocumentData(
    String collectionName, {
    required String documentID,
    String? errorMessage, 
  }) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .doc(documentID)
        .get();

    // 해당 도큐먼트가 존재하지 않을 경우 오류를 throw합니다.
    if (!snapshot.exists) {
      throw FirestoreError(errorMessage ?? '데이터를 찾을 수 없습니다.');
    }

    final data = snapshot.data();

    // 데이터가 비어있을 경우 오류를 throw합니다.
    if (data == null || data.isEmpty) {
      throw FirestoreError(errorMessage ?? '데이터를 찾을 수 없습니다.');
    }

    return data;
  }

  ///
  /// 특정 Document를 생성합니다.
  ///
  Future<void> set(
    String collectionName, {
    required String documentID,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore
        .collection(collectionName)
        .doc(documentID)
        .set(data, SetOptions(merge: merge));
  }

  ///
  /// 특정 Document를 수정합니다.
  ///
  Future<void> update(
    String collectionName, {
    required String documentID,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).doc(documentID).update(data);
  }

  ///
  /// 특정 Document를 삭제합니다.
  ///
  Future<void> delete(
    String collectionName, {
    required String documentID,
  }) async {
    await _firestore.collection(collectionName).doc(documentID).delete();
  }

  ///
  /// 특정 컬렉션에 새로운 도큐먼트를 추가합니다.
  ///
  Future<DocumentReference> add(
    String collectionName, {
    required Map<String, dynamic> data,
  }) async {
    return await _firestore.collection(collectionName).add(data);
  }
}
