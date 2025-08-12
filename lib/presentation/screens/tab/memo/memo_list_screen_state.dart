import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';

mixin class MemoListScreenState {
  /// 메모 리스트
  static final memoListProvider = StateProvider<AsyncValue<List<Memo>>>((ref) {
    return const AsyncValue.loading();
  });

  /// 메모 리스트 구독 상태
  static final subscriptionProvider =
      StateProvider<StreamSubscription<List<Memo>>?>((ref) {
        return null;
      });
}
