import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';

typedef LunarDateMap = Map<String, LunarDate>;

///
/// 날짜 팝업 화면 상태
///
mixin class DatePopupState {
  /// 음력 날짜
  static final lunarDateMap = StateProvider.autoDispose<LunarDateMap>((ref) {
    return {};
  });

  /// 일정 맵 (날짜별 일정 리스트)
  static final scheduleMap = StateProvider.autoDispose<ScheduleMap>((ref) {
    return {};
  });
}
