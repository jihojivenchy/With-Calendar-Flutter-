import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';

mixin class MemoListScreenState {
  /// 메모 리스트
  static final memoListProvider = StreamProvider<List<Memo>>((ref) {
    return MemoService().fetchMemoList();
  });
}
