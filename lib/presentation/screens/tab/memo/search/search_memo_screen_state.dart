import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';


///
/// 메모 검색 화면 상태
///
abstract class SearchMemoState {
  static final memoListProvider = StateProvider.autoDispose<List<Memo>>((ref) {
    return [];
  });
}
