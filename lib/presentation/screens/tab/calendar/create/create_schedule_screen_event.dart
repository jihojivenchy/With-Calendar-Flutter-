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
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
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
    final request = _getRequest(ref);

    final date = DateTime(
      selectedDay.date.year,
      selectedDay.date.month,
      selectedDay.date.day,
    );

    _setRequest(ref, request.copyWith(startDate: date, endDate: date));
  }

  ///
  /// 일정 제목 수정
  ///
  void updateTitle(WidgetRef ref, String title) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(title: title));
  }

  ///
  /// 일정 시작 날짜 수정
  ///
  void updateStartDate(WidgetRef ref, DateTime startDate) {
    final request = _getRequest(ref);

    // 종료 날짜가 시작 날짜보다 이전인 경우 종료 날짜를 시작 날짜와 동일하게 설정
    if (request.endDate.isBefore(startDate)) {
      _setRequest(
        ref,
        request.copyWith(startDate: startDate, endDate: startDate),
      );
    } else {
      // 이전이 아닐경우 그대로 처리
      _setRequest(ref, request.copyWith(startDate: startDate));
    }
  }

  ///
  /// 일정 종료 날짜 수정
  ///
  void updateEndDate(WidgetRef ref, DateTime endDate) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(endDate: endDate));
  }

  ///
  /// 일정 유형 수정
  ///
  void updateType(WidgetRef ref, ScheduleType type) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(type: type, notificationTime: ''));
  }

  ///
  /// 일정 알림 유형 수정 (하루종일)
  ///
  void updateAllDayNotificationType(
    WidgetRef ref,
    AllDayNotificationType type,
  ) {
    final request = _getRequest(ref);
    _setRequest(
      ref,
      request.copyWith(
        notificationTime: type.calculateNotificationTime(request.startDate),
      ),
    );
  }

  ///
  /// 일정 알림 유형 수정 (시간)
  ///
  void updateTimeNotificationType(WidgetRef ref, TimeNotificationType type) {
    final request = _getRequest(ref);
    _setRequest(
      ref,
      request.copyWith(
        notificationTime: type.calculateNotificationTime(request.startDate),
      ),
    );
  }

  ///
  /// 일정 알림 시간 수정
  ///
  void updateNotificationTime(WidgetRef ref, String notificationTime) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(notificationTime: notificationTime));
  }

  ///
  /// 일정 메모 수정
  ///
  void updateMemo(WidgetRef ref, String memo) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(memo: memo));
  }

  ///
  /// 일정 색상 수정
  ///
  void updateColor(WidgetRef ref, Color color) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(color: color));
  }

  ///
  /// 일정 할 일 목록 수정
  ///
  void updateTodoList(WidgetRef ref, List<Todo> todoList) {
    final request = _getRequest(ref);
    _setRequest(ref, request.copyWith(todoList: todoList));
  }

  ///
  /// 일정 생성
  ///
  Future<void> create(WidgetRef ref) async {
    final request = _getRequest(ref);

    if (request.title.isEmpty) {
      _showDialog(ref, '제목을 입력해주세요');
      return;
    }

    try {
      // 일정 생성
      final scheduleID = await _scheduleService.create(request);

      // 알림 생성
      unawaited(
        NotificationService.instance.create(
          scheduleID: scheduleID,
          request: request,
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
  CreateScheduleRequest _getRequest(WidgetRef ref) =>
      ref.read(CreateScheduleState.requestProvider.notifier).state;

  void _setRequest(WidgetRef ref, CreateScheduleRequest request) =>
      ref.read(CreateScheduleState.requestProvider.notifier).state = request;
}
