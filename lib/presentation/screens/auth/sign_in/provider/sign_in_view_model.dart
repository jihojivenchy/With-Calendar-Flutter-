import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/utils/services/snack_bar/snack_bar_service.dart';

/// 로그인 뷰모델 provider
final signInViewModelProvider =
    StateNotifierProvider.autoDispose<SignInViewModel, SignInScreenState>((
      ref,
    ) {
      return SignInViewModel();
    });

/// 로그인 화면 상태
class SignInScreenState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isValid;

  SignInScreenState({
    required this.email,
    required this.password,
    required this.isPasswordVisible,
    required this.isValid,
  });

  SignInScreenState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isValid,
  }) {
    return SignInScreenState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isValid: isValid ?? this.isValid,
    );
  }

  /// 초기 상태
  static SignInScreenState get initialState => SignInScreenState(
    email: '',
    password: '',
    isPasswordVisible: false,
    isValid: false,
  );
}

/// 로그인 뷰모델
class SignInViewModel extends StateNotifier<SignInScreenState> {
  SignInViewModel() : super(SignInScreenState.initialState);

  final AuthService _authService = AuthService();

  ///
  /// 이메일 업데이트
  ///
  void updateEmail(String email) {
    final updatedInformation = state.copyWith(email: email);
    state = updatedInformation;
    _validateInformation();
  }

  ///
  /// 비밀번호 업데이트
  ///
  void updatePassword(String password) {
    final updatedInformation = state.copyWith(password: password);
    state = updatedInformation;
    _validateInformation();
  }

  ///
  /// 유효성 검사
  ///
  void _validateInformation() {
    final email = state.email;
    final password = state.password;

    // 이메일 유효성 검사
    final isEmailValid =
        email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    // 비밀번호 유효성 검사
    final isPasswordValid = password.isNotEmpty && password.length >= 6;

    // 유효성 검사 결과 업데이트
    state = state.copyWith(isValid: isEmailValid && isPasswordValid);
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
  /// 로그인
  ///
  Future<bool> signIn() async {
    try {
      await _authService.signIn(email: state.email, password: state.password);
      return true;
    } catch (e) {
      log('로그인 실패: $e');
      SnackBarService.showSnackBar(e.toString());
      return false;
    }
  }
}
