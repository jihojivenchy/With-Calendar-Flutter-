import 'dart:developer';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_screen_state.dart';

mixin class SignInScreenEvent {
  final AuthService _authService = AuthService();

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
  /// 비밀번호 보여주기 토글
  ///
  void togglePasswordVisibility(WidgetRef ref) {
    final isPasswordVisibleProvider = ref.read(
      SignInScreenState.isPasswordVisibleProvider.notifier,
    );
    isPasswordVisibleProvider.state = !isPasswordVisibleProvider.state;
  }

  ///
  /// 로그인
  ///
  Future<void> signIn(WidgetRef ref) async {
    EasyLoading.show();

    try {
      // 로그인 요청
      await _authService.signIn(_getInformation(ref));

      // 로그인 성공 시 탭 페이지로 이동
      if (ref.context.mounted) {
        const TabRoute().go(ref.context);
      }
    } catch (e) {
      log('로그인 실패: $e');
      SnackBarService.showSnackBar(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  //--------------------------------Helper 메서드--------------------------------
  SignInInformation _getInformation(WidgetRef ref) =>
      ref.read(SignInScreenState.informationProvider.notifier).state;

  void _setInformation(WidgetRef ref, SignInInformation information) =>
      ref.read(SignInScreenState.informationProvider.notifier).state =
          information;
}
