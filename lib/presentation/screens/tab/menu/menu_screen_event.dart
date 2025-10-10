import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/auth/auth_service.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_screen_state.dart';
import 'package:with_calendar/presentation/router/router.dart';

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

  ///
  /// 알림 권한 상태조회
  ///
  Future<void> fetchNotificationPermissionStatus(WidgetRef ref) async {
    try {
      final isEnabled = await NotificationService.instance
          .fetchPermissionStatus();
      ref.read(MenuScreenState.notificationEnabledProvider.notifier).state =
          isEnabled;
    } catch (e) {
      log('알림 권한 상태조회에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 알림 설정으로 이동
  ///
  Future<void> openSystemNotificationSettings(WidgetRef ref) async {
    try {
      await NotificationService.instance.openSystemNotificationSettings();
    } catch (e) {
      log('알림 설정으로 이동에 실패했습니다. ${e.toString()}');
    }
  }
}
