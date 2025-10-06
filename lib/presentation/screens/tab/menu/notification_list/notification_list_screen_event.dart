import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen_state.dart';

mixin class NotificationListEvent {
  ///
  /// 알림 리스트 조회
  ///
  Future<void> fetchNotificationList(WidgetRef ref) async {
    try {
      final notificationList = await NotificationService.instance
          .fetchNotificationList();
      _setNotificationList(ref, Fetched(notificationList));
    } catch (e) {
      log('알림 리스트 조회 실패: $e');
      if (ref.context.mounted) {
        SnackBarService.showSnackBar('알림 목록 조회 실패');
        ref.context.pop();
      }
    }
  }

  // -------------------------------- Helper -----------------------------------
  void _setNotificationList(
    WidgetRef ref,
    Ds<List<ScheduledNotification>> notificationList,
  ) {
    ref.read(NotificationListState.notificationListProvider.notifier).state =
        notificationList;
  }
}
