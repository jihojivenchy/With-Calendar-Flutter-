import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';

abstract class SearchUserScreenState {
  /// 검색 결과 리스트
  static final searchedUserListProvider =
      StateProvider.autoDispose<List<CalendarParticipant>>((ref) {
        return [];
      });

  /// 검색 중 여부
  static final isSearchingProvider = StateProvider.autoDispose<bool>((ref) {
    return false;
  });
}
