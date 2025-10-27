import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/update_schedule_request.dart';

///
/// 일정 수정 화면 상태
///
mixin class UpdateScheduleState {
  /// 수정할 일정 프로바이더
  static final requestProvider =
      StateProvider.autoDispose<UpdateScheduleRequest>((ref) {
        return UpdateScheduleRequest.initialState;
      });
}
