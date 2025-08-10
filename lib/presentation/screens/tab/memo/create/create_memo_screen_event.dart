import 'dart:developer';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/create_memo_screen_state.dart';

mixin class CreateMemoScreenEvent {
  final MemoService _memoService = MemoService();

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
  void updatePinState(
    WidgetRef ref, {
    bool? isPinned,
    Color? pinColor,
  }) {
    final memo = _getMemo(ref);
    _setMemo(ref, memo.copyWith(isPinned: isPinned, pinColor: pinColor));
  }

  ///
  /// 메모 생성
  /// 
  Future<void> create(WidgetRef ref) async {
    
    try {
      // 메모 생성
      await _memoService.create(_getMemo(ref));

      // 메모 생성 완료 후 화면 이동
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('메모가 완료되었습니다.');
        ref.context.pop();
      }
    } catch (e) {
      log('메모 생성 실패: ${e.toString()}');
      SnackBarService.showSnackBar('메모 생성에 실패했습니다. ${e.toString()}');
    }
  }

  //--------------------------------Helper 메서드--------------------------------
  MemoCreation _getMemo(WidgetRef ref) =>
      ref.read(CreateMemoScreenState.memoProvider.notifier).state;

  void _setMemo(WidgetRef ref, MemoCreation memo) =>
      ref.read(CreateMemoScreenState.memoProvider.notifier).state = memo;
}
