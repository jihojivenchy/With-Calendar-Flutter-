import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';

/// 프로필 수정 화면의 상태
abstract class UpdateProfileScreenState {
  /// 화면 상태
  static final screenStateProvider = StateProvider.autoDispose<ScreenState>((
    ref,
  ) {
    return ScreenState.loading;
  });

  /// 프로필 데이터
  static final profileProvider = StateProvider<Profile?>((ref) {
    return null;
  });

  /// 프로필 유효성 검사
  /// 단순히 값을 read하는 것이기 때문에 Provider로 선언
  static final profileValidationProvider = Provider.autoDispose<bool>((ref) {
    final profile = ref.watch(profileProvider);
    return profile?.name != null && profile!.name.isNotEmpty;
  });
}
