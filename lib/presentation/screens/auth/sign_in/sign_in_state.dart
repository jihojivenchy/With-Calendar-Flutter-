import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/utils/extensions/validation_extension.dart';

mixin class SignInState {
  /// 로그인 정보
  static final informationProvider =
      StateProvider.autoDispose<SignInInformation>((ref) {
        return SignInInformation.initialData;
      });

  /// 비밀번호 보여주기
  static final isPasswordVisibleProvider = StateProvider.autoDispose<bool>((
    ref,
  ) {
    return false;
  });

  /// 유효성 검사
  static final isValidProvider = Provider.autoDispose<bool>((ref) {
    final information = ref.watch(informationProvider);
    return information.email.isValidEmail &&
        information.password.isValidPassword;
  });
}
