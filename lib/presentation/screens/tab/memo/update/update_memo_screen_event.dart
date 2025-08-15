import 'dart:developer';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/common/type/screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/memo/update/update_memo_screen_state.dart';

mixin class UpdateMemoScreenEvent {
  final MemoService _memoService = MemoService();

  ///
  /// 메모 수정
  ///
  void updateMemo(WidgetRef ref, Memo memo) {
    _setMemo(ref, memo);
  }

  ///
  /// 메모 수정 시작
  ///
  void updateStarted(WidgetRef ref) {
    ref.read(UpdateMemoScreenState.isStartedProvider.notifier).state = true;
  }

  ///
  /// 메모 내용 업데이트
  ///
  void updateContent(WidgetRef ref, String content) {
    final memo = _getMemo(ref);
    _setMemo(ref, memo.copyWith(content: content));
  }

  ///
  /// 핀 상태 업데이트
  ///
  void updatePinState(WidgetRef ref, {bool? isPinned, Color? pinColor}) {
    final memo = _getMemo(ref);
    _setMemo(ref, memo.copyWith(isPinned: isPinned, pinColor: pinColor));
  }

  ///
  /// 메모 수정
  ///
  Future<void> update(WidgetRef ref) async {
    try {
      // 메모 수정
      await _memoService.updateMemo(_getMemo(ref));

      // 메모 수정 완료 후 화면 이동
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('수정이 완료되었습니다.');
        ref.context.pop();
      }
    } catch (e) {
      log('메모 수정 실패: ${e.toString()}');
      SnackBarService.showSnackBar('메모 수정에 실패했습니다. ${e.toString()}');
    }
  }

  //--------------------------------Helper 메서드--------------------------------
  Memo _getMemo(WidgetRef ref) =>
      ref.read(UpdateMemoScreenState.memoProvider.notifier).state;

  void _setMemo(WidgetRef ref, Memo memo) =>
      ref.read(UpdateMemoScreenState.memoProvider.notifier).state = memo;
}
