import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_screen_state.dart';

mixin class MemoListScreenEvent {
  final MemoService _memoService = MemoService();

  ///
  /// 메모 리스트 구독
  ///
  void subscribeMemoList(WidgetRef ref) {
    // 현재 구독 상태 확인
    final currentSubscription = _getSubscription(ref);

    // 현재 구독 상태가 있으면 종료
    if (currentSubscription != null) return;

    // 메모 리스트 구독
    final subscription = _memoService.fetchMemoList().listen(
      (memoList) {
        // 메모 리스트 업데이트
        ref.read(MemoListScreenState.memoListProvider.notifier).state =
            AsyncValue.data(memoList);
      },
      onError: (error, stackTrace) {
        // 오류 상태 업데이트
        ref.read(MemoListScreenState.memoListProvider.notifier).state =
            AsyncValue.error(error, stackTrace);
      },
    );

    // 구독 상태 업데이트
    _setSubscription(ref, subscription);
  }

  ///
  /// 메모 리스트 구독 해제
  ///
  Future<void> disposeSubscription(WidgetRef ref) async {
    final subscription = _getSubscription(ref);
    await subscription?.cancel();
    _setSubscription(ref, null);
  }

  ///
  /// 메모 리스트 구독 재시도
  ///
  Future<void> retry(WidgetRef ref) async {
    await disposeSubscription(ref);
    subscribeMemoList(ref);
  }

  //--------------------------------Helper 메서드--------------------------------
  StreamSubscription<List<Memo>>? _getSubscription(WidgetRef ref) =>
      ref.read(MemoListScreenState.subscriptionProvider.notifier).state;

  void _setSubscription(
    WidgetRef ref,
    StreamSubscription<List<Memo>>? subscription,
  ) => ref.read(MemoListScreenState.subscriptionProvider.notifier).state =
      subscription;
}
