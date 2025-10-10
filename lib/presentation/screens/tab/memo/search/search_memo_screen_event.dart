import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/memo/memo_service.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/search_memo_screen_state.dart';

mixin class SearchMemoScreenEvent {
  final MemoService _memoService = MemoService();

  ///
  /// 메모 검색
  ///
  Future<void> search(WidgetRef ref, String keyword) async {
    final memoList = await _memoService.searchMemo(keyword);
    ref.read(SearchMemoState.memoListProvider.notifier).state = memoList;
  }

  ///
  /// 메모 삭제
  ///
  Future<void> deleteMemo(WidgetRef ref, String memoID) async {
    await _memoService.deleteMemo(memoID);
  }
}
