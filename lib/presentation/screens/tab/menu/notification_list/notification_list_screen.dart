import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
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
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '알림 목록',
      backgroundColor: context.backgroundColor,
    );
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
        return NotificationItem(
          notification: notification,
          onTapped: () {
            _showDeleteDialog(ref, notification.id);
          },
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 알림 삭제 다이얼로그
  ///
  void _showDeleteDialog(WidgetRef ref, int notificationID) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '해당 알림을 삭제할까요?',
        leftBtnContent: '취소',
        rightBtnContent: '삭제',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          deleteNotification(ref, notificationID);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }
}
