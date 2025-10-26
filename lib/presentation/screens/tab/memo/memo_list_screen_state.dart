import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';

mixin class MemoListScreenState {
  /// 메모 리스트
  static final memoListProvider =
      StateProvider.autoDispose<AsyncValue<List<Memo>>>((ref) {
        return const AsyncValue.loading();
      });

  /// 메모 리스트 구독 상태
  static final subscriptionProvider =
      StateProvider.autoDispose<StreamSubscription<List<Memo>>?>((ref) {
        // 구독 해제 트리거 시 구독 취소
        ref.onDispose(() {
          final subscription = ref.controller.state;

          if (subscription != null) {
            log('메모 구독 해제: ${subscription.hashCode}');
            subscription.cancel();
          }
        });
        return null;
      });
}
