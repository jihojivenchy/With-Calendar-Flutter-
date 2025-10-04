import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';

///
/// 일정 수정 화면 상태
///
mixin class UpdateScheduleState {
  /// 수정할 일정 프로바이더
  static final scheduleProvider = StateProvider.autoDispose<ScheduleCreation>((
    ref,
  ) {
    return ScheduleCreation.initialState;
  });
}
