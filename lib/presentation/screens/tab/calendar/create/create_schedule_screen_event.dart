import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/data/services/schedule/schedule_service.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/app_date_time.dart';
import 'package:with_calendar/domain/entities/schedule/notification/all_day_type.dart';
import 'package:with_calendar/domain/entities/schedule/notification/time_type.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen_state.dart';

///
/// 일정 생성 화면 이벤트
///
mixin class CreateScheduleEvent {
  final ScheduleService _scheduleService = ScheduleService();

  ///
  /// 일정 초기화 (선택된 날짜로)
  ///
  void initialize(WidgetRef ref, Day selectedDay) {
    final schedule = _getSchedule(ref);

    final date = DateTime(
      selectedDay.date.year,
      selectedDay.date.month,
      selectedDay.date.day,
    );

    _setSchedule(ref, schedule.copyWith(startDate: date, endDate: date));
  }

  ///
  /// 일정 제목 수정
  ///
  void updateTitle(WidgetRef ref, String title) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(title: title));
  }

  ///
  /// 일정 시작 날짜 수정
  ///
  void updateStartDate(WidgetRef ref, DateTime startDate) {
    final schedule = _getSchedule(ref);

    // 종료 날짜가 시작 날짜보다 이전인 경우 종료 날짜를 시작 날짜와 동일하게 설정
    if (schedule.endDate.isBefore(startDate)) {
      _setSchedule(
        ref,
        schedule.copyWith(startDate: startDate, endDate: startDate),
      );
    } else {
      // 이전이 아닐경우 그대로 처리
      _setSchedule(ref, schedule.copyWith(startDate: startDate));
    }
  }

  ///
  /// 일정 종료 날짜 수정
  ///
  void updateEndDate(WidgetRef ref, DateTime endDate) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(endDate: endDate));
  }

  ///
  /// 일정 유형 수정
  ///
  void updateType(WidgetRef ref, ScheduleType type) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(type: type, notificationTime: ''));
  }

  ///
  /// 일정 알림 유형 수정 (하루종일)
  ///
  void updateAllDayNotificationType(
    WidgetRef ref,
    AllDayNotificationType type,
  ) {
    final schedule = _getSchedule(ref);
    _setSchedule(
      ref,
      schedule.copyWith(
        notificationTime: type.calculateNotificationTime(schedule.startDate),
      ),
    );
  }

  ///
  /// 일정 알림 유형 수정 (시간)
  ///
  void updateTimeNotificationType(WidgetRef ref, TimeNotificationType type) {
    final schedule = _getSchedule(ref);
    _setSchedule(
      ref,
      schedule.copyWith(
        notificationTime: type.calculateNotificationTime(schedule.startDate),
      ),
    );
  }

  ///
  /// 일정 알림 시간 수정
  ///
  void updateNotificationTime(WidgetRef ref, String notificationTime) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(notificationTime: notificationTime));
  }

  ///
  /// 일정 메모 수정
  ///
  void updateMemo(WidgetRef ref, String memo) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(memo: memo));
  }

  ///
  /// 일정 색상 수정
  ///
  void updateColor(WidgetRef ref, Color color) {
    final schedule = _getSchedule(ref);
    _setSchedule(ref, schedule.copyWith(color: color));
  }

  ///
  /// 일정 생성
  ///
  Future<void> create(WidgetRef ref) async {
    final schedule = _getSchedule(ref);

    if (schedule.title.isEmpty) {
      _showDialog(ref, '제목을 입력해주세요');
      return;
    }

    try {
      // 일정 생성
      final scheduleID = await _scheduleService.create(schedule);

      // 알림 생성
      unawaited(
        NotificationService.instance.create(
          scheduleID: scheduleID,
          schedule: schedule,
        ),
      );

      // 일정 생성 완료 후 화면 이동
      if (ref.context.mounted) {
        ref.context.pop();
      }
    } catch (e) {
      log('일정 생성 실패: ${e.toString()}');
      _showDialog(ref, '일정 생성에 실패했습니다. ${e.toString()}');
    }
  }

  ///
  /// 다이얼로그
  ///
  void _showDialog(WidgetRef ref, String title) {
    DialogService.show(
      dialog: AppDialog.singleBtn(
        title: title,
        btnContent: '확인',
        onBtnClicked: () => ref.context.pop(),
      ),
    );
  }

  //--------------------------------Helper 메서드--------------------------------
  CreateScheduleRequest _getSchedule(WidgetRef ref) =>
      ref.read(CreateScheduleState.scheduleProvider.notifier).state;

  void _setSchedule(WidgetRef ref, CreateScheduleRequest schedule) =>
      ref.read(CreateScheduleState.scheduleProvider.notifier).state = schedule;
}
