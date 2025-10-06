import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/data/services/menu/menu_service.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/update_profile/update_profile_screen_state.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

/// 메뉴 화면의 이벤트 (뷰 모델 역할을 수행합니다(비즈니스 로직))
mixin class MenuScreenEvent {
  final AuthService _authService = AuthService();

  ///
  /// 개인정보처리방침 링크 이동
  ///
  Future<void> goToPrivacyPolicyLink() async {
    try {
      await _authService.goToPrivacyPolicyLink();
    } catch (e) {
      log(e.toString());
      SnackBarService.showSnackBar('개인정보처리방침 이동에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 로그아웃
  ///
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      log(e.toString());
      SnackBarService.showSnackBar('로그아웃에 실패했습니다. ${e.toString()}');
    }
  }
}
