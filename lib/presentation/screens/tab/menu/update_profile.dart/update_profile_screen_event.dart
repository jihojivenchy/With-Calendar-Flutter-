import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/menu/menu_service.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/update_profile.dart/update_profile_state.dart';
import 'package:with_calendar/utils/services/random/random_generator.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

/// 프로필 수정 화면의 이벤트 (뷰 모델 역할을 수행합니다(비즈니스 로직))
mixin class UpdateProfileScreenEvent {
  final MenuService _menuService = MenuService();

  /// 프로필 조회
  Future<void> fetchProfile(WidgetRef ref) async {
    try {
      final profile = await _menuService.fetchProfile();

      // 프로필 데이터 업데이트
      _setProfile(ref, profile);

      // 화면 상태 업데이트
      _setScreenState(ref, ScreenState.success);
    } catch (e) {
      log(e.toString());
      SnackBarService.showSnackBar('프로필 조회 실패: ${e.toString()}');
      _setScreenState(ref, ScreenState.error); // 화면 상태 업데이트
    }
  }

  ///
  /// 유저 고유 코드 변경
  ///
  void updateUserCode(WidgetRef ref) {
    final newCode = RandomGenerator.generateUserCode();
    final updatedProfile = _getProfile(ref)?.copyWith(code: newCode);
    _setProfile(ref, updatedProfile);
  }

  ///
  /// 유저 이름 변경
  ///
  void updateName(WidgetRef ref, String name) {
    final updatedProfile = _getProfile(ref)?.copyWith(name: name);
    _setProfile(ref, updatedProfile);
  }

  ///
  /// 프로필 수정
  ///
  Future<void> updateProfile(WidgetRef ref) async {
    try {
      final profile = _getProfile(ref);
      await _menuService.updateProfile(profile!);

      if (ref.context.mounted) {
        SnackBarService.showSnackBar('프로필 수정 완료');
        ref.context.pop();
      }
    } catch (e) {
      log(e.toString());
      SnackBarService.showSnackBar('프로필 수정 실패: ${e.toString()}');
    }
  }

  //--------------------------------Helper 메서드--------------------------------
  Profile? _getProfile(WidgetRef ref) =>
      ref.read(UpdateProfileScreenState.profileProvider.notifier).state;

  void _setProfile(WidgetRef ref, Profile? profile) =>
      ref.read(UpdateProfileScreenState.profileProvider.notifier).state =
          profile;

  void _setScreenState(WidgetRef ref, ScreenState state) =>
      ref.read(UpdateProfileScreenState.screenStateProvider.notifier).state =
          state;
}
