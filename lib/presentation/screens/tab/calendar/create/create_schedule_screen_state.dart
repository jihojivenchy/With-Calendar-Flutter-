import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';

///
/// 일정 생성 화면 상태
///
mixin class CreateScheduleState {
  /// 생성할 일정 프로바이더
  static final scheduleProvider = StateProvider<ScheduleCreation>((ref) {
    return ScheduleCreation.initialState;
  });
}


