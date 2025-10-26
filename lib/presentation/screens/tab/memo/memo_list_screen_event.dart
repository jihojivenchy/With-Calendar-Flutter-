import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_screen_state.dart';

mixin class MemoListScreenEvent {
  final MemoService _memoService = MemoService();
  
  ///
  /// 메모 삭제
  ///
  Future<void> deleteMemo(WidgetRef ref, String memoID) async {
    await _memoService.deleteMemo(memoID);
  }
}
