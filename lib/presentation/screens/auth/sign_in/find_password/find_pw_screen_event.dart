import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/domain/entities/auth/sign_in_information.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_screen_state.dart';

mixin class FindPasswordScreenEvent {
  final AuthService _authService = AuthService();

  ///
  /// 비밀번호 찾기 요청
  ///
  Future<void> findPassword(WidgetRef ref, String email) async {
    try {
      // 비밀번호 찾기 요청
      await _authService.findPassword(email);
      SnackBarService.showSnackBar('비밀번호 재설정 이메일을 발송했습니다.');
    } catch (e) {
      log('비밀번호 찾기 실패: $e');
      SnackBarService.showSnackBar(e.toString());
    }
  }
}
