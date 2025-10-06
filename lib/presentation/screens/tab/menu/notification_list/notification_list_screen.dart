import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/widgets/notification_item.dart';

class NotificationListScreen extends BaseScreen with NotificationListEvent {
  NotificationListScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchNotificationList(ref);
    });
  }

  ///
  /// 배경색
  ///
  @override
  Color? get backgroundColor => AppColors.background;

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(title: '알림 목록', backgroundColor: Color(0xFFF2F2F7));
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // 알림 리스트
    final notificationListState = ref.watch(
      NotificationListState.notificationListProvider,
    );

    final child = notificationListState.onState(
      fetched: (notificationList) {
        if (notificationList.isEmpty) {
          return EmptyView(title: '예약된 알림이 없습니다.');
        }
        return _buildNotificationList(ref, notificationList);
      },
      failed: (error) {
        return const ErrorView(title: '알림 목록 조회 중 오류가 발생했습니다.');
      },
      loading: () {
        return const LoadingView(title: '알림 목록을 불러오는 중입니다.');
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  ///
  /// 알림 리스트
  ///
  Widget _buildNotificationList(
    WidgetRef ref,
    List<ScheduledNotification> notificationList,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        final notification = notificationList[index];
        return NotificationItem(notification: notification);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }
}
