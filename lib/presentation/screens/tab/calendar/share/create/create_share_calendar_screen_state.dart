import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/domain/entities/calendar/share/share_calendar_creation.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/profile/profile.dart';

abstract class CreateShareCalendarState {
  /// 달력 생성 정보
  static final creationProvider =
      StateProvider.autoDispose<Ds<ShareCalendarCreation>>((ref) {
        return Loading();
      });
}
