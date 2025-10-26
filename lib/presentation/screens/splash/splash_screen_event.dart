import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/presentation/router/router.dart';

mixin class SplashScreenEvent {
  final AuthService _authService = AuthService();

  ///
  /// 로그인 상태 확인
  ///
  void checkLoginStatus(WidgetRef ref) {
    if (_authService.isSignIn()) {
      const TabRoute().go(ref.context);
    } else {
      const SignInRoute().go(ref.context);
    }
  }
}
