import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:with_calendar/data/network/error/error_type.dart';
import 'package:with_calendar/data/services/firestore/base_firestore_mixin.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/utils/constants/firestore_constants.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';

class AuthService with BaseFirestoreMixin {
  ///
  /// 로그인
  ///
  Future<void> signIn(SignInInformation information) async {
    try {
      // 로그인 요청
      final credential = await auth.signInWithEmailAndPassword(
        email: information.email,
        password: information.password,
      );

      // 사용자 정보 가져오기
      if (credential.user == null) {
        throw FirebaseAuthError('해당 이메일에 등록된 계정이 없습니다.');
      }

      // 기본 캘린더 정보 가져오기
      final defaultCalendar = CalendarInformation(
        id: credential.user!.uid,
        name: 'With Calendar',
        type: CalendarType.private,
        createdAt: '',
      );

      // 현재 선택된 캘린더로 설정
      HiveService.instance.create(
        HiveBoxPath.currentCalendar,
        value: defaultCalendar.toJson(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw FirebaseAuthError('유효하지 않은 이메일 형식입니다.');

        case 'invalid-credential':
          throw FirebaseAuthError('등록되지 않은 이메일 혹은 비밀번호가 일치하지 않습니다.');

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

      // 배치 생성
      final batch = firestore.batch();

      // 유저 정보
      final profile = Profile(
        id: user.uid,
        name: name,
        email: email,
        code: RandomGenerator.generateUserCode(),
        createdAt: DateTime.now().toStringFormat('yyyy-MM-dd HH:mm:ss'),
      );

      // 1. 유저 정보 저장
      final userRef = firestore
          .collection(FirestoreCollection.users)
          .doc(profile.id);
      batch.set(userRef, profile.toJson());

      // 캘린더 정보
      final defaultCalendar = CalendarInformation(
        id: profile.id,
        name: 'With Calendar',
        type: CalendarType.private,
        createdAt: profile.createdAt,
      );

      // 2. 캘린더 리스트 정보 저장
      final calendarListRef = firestore
          .collection(FirestoreCollection.users)
          .doc(profile.id)
          .collection(FirestoreCollection.calendarList)
          .doc(profile.id);
      batch.set(calendarListRef, defaultCalendar.toJson());

      // 3. 캘린더 생성
      final calendarRef = firestore
          .collection(FirestoreCollection.calendar)
          .doc(profile.id);
      batch.set(calendarRef, defaultCalendar.toJson());

      // 4. 현재 선택된 캘린더로 설정
      HiveService.instance.create(
        HiveBoxPath.currentCalendar,
        value: defaultCalendar.toJson(),
      );

      // 배치 실행
      await batch.commit();
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

  ///
  /// 회원 탈퇴
  ///
  Future<void> withdraw() async {
    // 유저아이디를 미리 가지고 있어야 함.
    final userUID = getUserUID;

    // 회원탈퇴 후 삭제 진행 => 회원 탈퇴가 안되는 경우가 있음
    await auth.currentUser!.delete();

    Future.wait([
      // 유저 정보 삭제
      firestore.collection(FirestoreCollection.users).doc(userUID).delete(),
      // 캘린더 삭제
      firestore.collection(FirestoreCollection.calendar).doc(userUID).delete(),

      // 현재 선택된 캘린더 제거
      HiveService.instance.delete(HiveBoxPath.currentCalendar),
    ]);
  }
}
