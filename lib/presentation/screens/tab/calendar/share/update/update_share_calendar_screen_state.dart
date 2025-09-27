import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';

abstract class UpdateShareCalendarState {
  /// 달력 정보
  static final shareCalendarProvider =
      StateProvider.autoDispose<Ds<ShareCalendar>>((ref) {
        return Loading();
      });
}
