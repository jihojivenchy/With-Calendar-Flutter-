import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';

mixin class MemoListScreenState {
  /// 메모 리스트 스트림
  static final memoListStreamProvider = StreamProvider.autoDispose<List<Memo>>((
    ref,
  ) {
    final MemoService memoService = MemoService();
    return memoService.fetchMemoList();
  });
}
