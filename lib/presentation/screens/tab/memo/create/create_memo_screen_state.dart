import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';

mixin class CreateMemoScreenState {
  /// 메모
  static final memoProvider = StateProvider.autoDispose<MemoCreation>(
    (ref) {
      return MemoCreation.initialState;
    },
  );

  /// 메모 작성 유효성 검사
  static final isValidProvider = Provider.autoDispose<bool>((ref) {
    final memo = ref.watch(memoProvider);
    return memo.content.isNotEmpty;
  });
}
