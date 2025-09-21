import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';

abstract class ShareCalendarListState {
  /// 전체 캘린더 리스트
  static final calendarListProvider =
      StateProvider.autoDispose<Ds<List<CalendarInformation>>>((ref) {
        return Loading();
      });

  /// 현재 선택된 캘린더 ID
  static final currentCalendarIDProvider = StateProvider.autoDispose<String>((
    ref,
  ) {
    return '';
  });
}
