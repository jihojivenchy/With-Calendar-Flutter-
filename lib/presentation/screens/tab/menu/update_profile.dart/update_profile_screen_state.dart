import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';

/// 프로필 수정 화면의 상태
abstract class UpdateProfileScreenState {
  /// 프로필 데이터
  static final profileProvider = StateProvider.autoDispose<Ds<Profile>>((ref) {
    return Loading();
  });

  /// 프로필 유효성 검사
  /// 단순히 값을 read하는 것이기 때문에 Provider로 선언
  static final profileValidationProvider = Provider.autoDispose<bool>((ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    
    // 프로필 데이터가 없으면 유효하지 않음
    if (profile == null) {
      return false;
    }

    // 프로필 이름이 비어있으면 유효하지 않음
    return profile.name.isNotEmpty;
  });
}
