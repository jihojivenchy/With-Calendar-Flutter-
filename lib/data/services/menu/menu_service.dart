import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class MenuService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///
  /// 프로필 조회
  ///
  Future<Profile> fetchProfile() async {
    final userUID = _auth.currentUser?.uid;
    if (userUID == null) {
      throw FirebaseAuthErrorType('로그인 상태가 아닙니다.');
    }

    final snapshot = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userUID)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw FirebaseAuthErrorType('사용자 정보를 찾을 수 없습니다.');
    }

    return Profile.fromJson(snapshot.data()!);
  }

  ///
  /// 프로필 수정
  ///
  Future<void> updateProfile(Profile profile) async {
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(profile.id)
        .update(profile.toJson());
  }
}
