import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class AuthService with BaseFirestoreMixin {
  ///
  /// 로그인
  ///
  Future<void> signIn(SignInInformation information) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: information.email,
        password: information.password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw FirebaseAuthError('유효하지 않은 이메일 형식입니다.');

        case 'invalid-credential':
          throw FirebaseAuthError('등록되지 않은 이메일입니다.');

        case 'wrong-password':
          throw FirebaseAuthError('비밀번호가 일치하지 않습니다.');

        case 'too-many-requests':
          throw FirebaseAuthError('이미 요청을 처리중입니다. 잠시 후 다시 시도해주세요.');

        default:
          throw FirebaseAuthError('로그인에 실패했습니다. ${e.toString()}');
      }
    }
  }

  ///
  /// 로그아웃
  ///
  Future<void> signOut() async {
    await auth.signOut();
  }

  ///
  /// 로그인 여부 확인
  ///
  bool isSignIn() {
    final user = auth.currentUser;
    return user != null;
  }

  ///
  /// 개인정보처리방침 링크 이동
  ///
  Future<void> goToPrivacyPolicyLink() async {
    const urlString = 'https://iosjiho.tistory.com/77';
    final Uri uri = Uri.parse(urlString);
    await launchUrl(uri);
  }

  ///
  /// 회원가입
  ///
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 회원가입 요청
      final UserCredential credential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 사용자 정보 가져오기
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthError('회원가입에 실패했습니다.');
      }

      final userUID = user.uid;
      final userCode = RandomGenerator.generateUserCode();
      final createdAt = DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss');

      // 유저 정보 저장
      await set(
        FirestoreConstants.usersCollection,
        documentID: userUID,
        data: {
          'id': userUID,
          'name': name,
          'email': email,
          'userCode': userCode,
          'createdAt': createdAt,
        },
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw FirebaseAuthError('유효하지 않은 이메일 형식입니다.');

        case 'email-already-in-use':
          throw FirebaseAuthError('이미 가입된 이메일입니다.');

        case 'weak-password':
          throw FirebaseAuthError('낮은 보안수준의 비밀번호입니다.');

        default:
          throw FirebaseAuthError('회원가입에 실패했습니다. ${e.toString()}');
      }
    }
  }

  ///
  /// 비밀번호 찾기
  ///
  Future<void> findPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}
