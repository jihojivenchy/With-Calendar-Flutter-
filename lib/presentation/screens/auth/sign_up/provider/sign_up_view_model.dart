import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/utils/services/snack_bar/snack_bar_service.dart';

/// 회원가입 뷰모델 provider
final signUpViewModelProvider =
    StateNotifierProvider.autoDispose<SignUpViewModel, SignUpScreenState>((
      ref,
    ) {
      return SignUpViewModel();
    });

/// 회원가입 화면 상태
class SignUpScreenState {
  final String name;
  final bool isPrivacyPolicyAgreed;
  final String email;
  final String password;
  final String passwordConfirm;
  final bool isPasswordVisible;
  final bool isPasswordConfirmVisible;
  final int pageIndex;

  SignUpScreenState({
    required this.name,
    required this.isPrivacyPolicyAgreed,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.isPasswordVisible,
    required this.isPasswordConfirmVisible,
    this.pageIndex = 0,
  });

  /// 이메일 유효성 검사
  bool get isEmailValid {
    return email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 비밀번호 유효성 검사
  bool get isPasswordValid {
    if (password.isEmpty) {
      return false;
    }

    if (password.length < 6) {
      return false;
    }

    if (password != passwordConfirm) {
      return false;
    }

    return true;
  }

  SignUpScreenState copyWith({
    String? name,
    bool? isPrivacyPolicyAgreed,
    String? email,
    String? password,
    String? passwordConfirm,
    bool? isPasswordVisible,
    bool? isPasswordConfirmVisible,
    int? pageIndex,
  }) {
    return SignUpScreenState(
      name: name ?? this.name,
      isPrivacyPolicyAgreed:
          isPrivacyPolicyAgreed ?? this.isPrivacyPolicyAgreed,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isPasswordConfirmVisible:
          isPasswordConfirmVisible ?? this.isPasswordConfirmVisible,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  /// 초기 상태
  static SignUpScreenState get initialState => SignUpScreenState(
    name: '',
    isPrivacyPolicyAgreed: false,
    email: '',
    password: '',
    passwordConfirm: '',
    isPasswordVisible: false,
    isPasswordConfirmVisible: false,
  );
}

/// 로그인 뷰모델
class SignUpViewModel extends StateNotifier<SignUpScreenState> {
  SignUpViewModel() : super(SignUpScreenState.initialState);

  final AuthService _authService = AuthService();

  ///
  /// 페이지 인덱스 업데이트
  ///
  void updatePageIndex(int pageIndex) {
    final updatedInformation = state.copyWith(pageIndex: pageIndex);
    state = updatedInformation;
  }

  ///
  /// 닉네임 업데이트
  ///
  void updateName(String name) {
    final updatedInformation = state.copyWith(name: name);
    state = updatedInformation;
  }

  ///
  /// 이메일 업데이트
  ///
  void updateEmail(String email) {
    final updatedInformation = state.copyWith(email: email);
    state = updatedInformation;
  }

  ///
  /// 비밀번호 업데이트
  ///
  void updatePassword(String password) {
    final updatedInformation = state.copyWith(password: password);
    state = updatedInformation;
  }

  ///
  /// 비밀번호 확인 업데이트
  ///
  void updatePasswordConfirm(String passwordConfirm) {
    final updatedInformation = state.copyWith(passwordConfirm: passwordConfirm);
    state = updatedInformation;
  }

  ///
  /// 비밀번호 보여주기 토글
  ///
  void togglePasswordVisibility() {
    final updatedInformation = state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    );
    state = updatedInformation;
  }

  ///
  /// 비밀번호 확인 보여주기 토글
  ///
  void togglePasswordConfirmVisibility() {
    final updatedInformation = state.copyWith(
      isPasswordConfirmVisible: !state.isPasswordConfirmVisible,
    );
    state = updatedInformation;
  }

  ///
  /// 개인정보처리방침 동의 업데이트
  ///
  void updatePrivacyPolicyAgreed(bool isPrivacyPolicyAgreed) {
    final updatedInformation = state.copyWith(
      isPrivacyPolicyAgreed: isPrivacyPolicyAgreed,
    );
    state = updatedInformation;
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
  Future<bool> signUp() async {
    try {
      await _authService.signUp(
        name: state.name,
        email: state.email,
        password: state.password,
      );
      SnackBarService.showSnackBar('회원가입이 완료되었습니다.');
      return true;
    } catch (e) {
      log('회원가입 실패: $e');
      SnackBarService.showSnackBar(e.toString());
      return false;
    }
  }
}