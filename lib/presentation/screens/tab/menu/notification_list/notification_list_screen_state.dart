import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/data_state/data_state.dart';
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';

abstract class NotificationListState {
  static final notificationListProvider =
      StateProvider.autoDispose<Ds<List<ScheduledNotification>>>((ref) {
        return Loading();
      });
}
