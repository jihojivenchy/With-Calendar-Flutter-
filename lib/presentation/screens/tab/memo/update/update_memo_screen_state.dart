import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';

mixin class UpdateMemoScreenState {
  /// 메모
  static final memoProvider = StateProvider.autoDispose<Memo>((ref) {
    return Memo.initialState;
  });

  /// 메모 수정을 하기 위해 포커스를 얻었는지 여부
  static final isStartedProvider = StateProvider.autoDispose<bool>((ref) {
    return false;
  });

  /// 메모 수정 유효성 검사
  static final isValidProvider = Provider.autoDispose<bool>((ref) {
    final memo = ref.watch(memoProvider);
    return memo.content.isNotEmpty;
  });
}
