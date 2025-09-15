import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_up_information.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/sign_up_screen_state.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

/// 회원가입 화면의 이벤트 (뷰 모델 역할을 수행합니다(비즈니스 로직))
mixin class SignUpScreenEvent {
  final AuthService _authService = AuthService();

  ///
  /// 페이지 인덱스 업데이트
  ///
  void updatePageIndex(WidgetRef ref, int pageIndex) {
    ref.read(SignUpScreenState.pageIndexProvider.notifier).state = pageIndex;
  }

  ///
  /// 닉네임 업데이트
  ///
  void updateName(WidgetRef ref, String name) {
    final updatedInformation = _getInformation(ref).copyWith(name: name);
    _setInformation(ref, updatedInformation);
  }

  ///
  /// 개인정보처리방침 동의 업데이트
  ///
  void updatePrivacyPolicyAgreed(WidgetRef ref, bool isPrivacyPolicyAgreed) {
    final updatedInformation = _getInformation(
      ref,
    ).copyWith(isPrivacyPolicyAgreed: isPrivacyPolicyAgreed);
    _setInformation(ref, updatedInformation);
  }

  ///
  /// 이메일 업데이트
  ///
  void updateEmail(WidgetRef ref, String email) {
    final updatedInformation = _getInformation(ref).copyWith(email: email);
    _setInformation(ref, updatedInformation);
  }

  ///
  /// 비밀번호 업데이트
  ///
  void updatePassword(WidgetRef ref, String password) {
    final updatedInformation = _getInformation(
      ref,
    ).copyWith(password: password);
    _setInformation(ref, updatedInformation);
  }

  ///
  /// 비밀번호 확인 업데이트
  ///
  void updatePasswordConfirm(WidgetRef ref, String passwordConfirm) {
    final updatedInformation = _getInformation(
      ref,
    ).copyWith(passwordConfirm: passwordConfirm);
    _setInformation(ref, updatedInformation);
  }

  ///
  /// 비밀번호 보여주기 토글
  ///
  void updatePasswordVisibility(WidgetRef ref, bool isPasswordVisible) {
    ref.read(SignUpScreenState.isPasswordVisibleProvider.notifier).state =
        isPasswordVisible;
  }

  ///
  /// 비밀번호 확인 보여주기 토글
  ///
  void updatePasswordConfirmVisibility(
    WidgetRef ref,
    bool isPasswordConfirmVisible,
  ) {
    ref
            .read(SignUpScreenState.isPasswordConfirmVisibleProvider.notifier)
            .state =
        isPasswordConfirmVisible;
  }

  ///
  /// 개인정보처리방침 링크 이동
  ///
  Future<void> goToPrivacyPolicyLink() async {
    try {
      await _authService.goToPrivacyPolicyLink();
    } catch (e) {
      log('개인정보처리방침 링크 이동 실패: $e');
      SnackBarService.showSnackBar('링크 이동에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 회원가입
  ///
  Future<void> signUp(WidgetRef ref) async {
    EasyLoading.show();

    try {
      final information = _getInformation(ref);

      await _authService.signUp(
        name: information.name,
        email: information.email,
        password: information.password,
      );
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('회원가입이 완료되었습니다.');
        const TabRoute().go(ref.context);
      }
    } catch (e) {
      log('회원가입 실패: $e');
      SnackBarService.showSnackBar(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  //--------------------------------Helper 메서드--------------------------------
  SignUpInformation _getInformation(WidgetRef ref) =>
      ref.read(SignUpScreenState.informationProvider.notifier).state;

  void _setInformation(WidgetRef ref, SignUpInformation information) =>
      ref.read(SignUpScreenState.informationProvider.notifier).state =
          information;
}
