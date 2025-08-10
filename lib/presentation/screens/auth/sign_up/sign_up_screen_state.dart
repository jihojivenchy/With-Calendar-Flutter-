import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/auth/sign_up_information.dart';

/// 회원가입 화면의 상태
abstract class SignUpScreenState {
  // ==================== 회원가입 정보 ==========================================
  /// 회원가입 정보
  static final informationProvider =
      StateProvider.autoDispose<SignUpInformation>((ref) {
        return SignUpInformation.initialState;
      });

  // ==================== 화면 상태 ==============================================

  /// 페이지 인덱스
  static final pageIndexProvider = StateProvider.autoDispose<int>((ref) {
    return 0;
  });

  /// 비밀번호 보여주기
  static final isPasswordVisibleProvider = StateProvider.autoDispose<bool>((
    ref,
  ) {
    return false;
  });

  /// 비밀번호 확인 보여주기
  static final isPasswordConfirmVisibleProvider =
      StateProvider.autoDispose<bool>((ref) {
        return false;
      });

  // ==================== Validation 상태 =======================================

  /// 첫 페이지 유효성 검사
  static final isFirstPageValidProvider = Provider.autoDispose<bool>((ref) {
    final information = ref.watch(informationProvider);
    return information.name.isNotEmpty && information.isPrivacyPolicyAgreed;
  });

  /// 두번페이지 유효성 검사
  static final isSecondPageValidProvider = Provider.autoDispose<bool>((ref) {
    final information = ref.watch(informationProvider);
    final email = information.email;
    return email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  });

  /// 세번째 페이지 유효성 검사
  static final isThirdPageValidProvider = Provider.autoDispose<bool>((ref) {
    final information = ref.watch(informationProvider);
    final password = information.password;
    final passwordConfirm = information.passwordConfirm;
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
  });
}
