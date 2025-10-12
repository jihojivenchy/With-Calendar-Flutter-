import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/widgets/menu_item.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';

class MenuScreen extends BaseScreen with MenuScreenEvent {
  MenuScreen({super.key});

  ///
  /// 앱 바 구성
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '메뉴',
      fontSize: 28,
      fontWeight: FontWeight.w800,
      backgroundColor: context.backgroundColor,
      isShowBackButton: false,
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    return FocusDetector(
      onFocusGained: () {
        fetchNotificationPermissionStatus(ref);
      },
      child: _buildMenuList(ref),
    );
  }

  ///
  /// 메뉴 리스트 빌드
  ///
  Widget _buildMenuList(WidgetRef ref) {
    final menuList = ref.watch(MenuScreenState.menuListProvider);
    final isEnabled = ref.watch(MenuScreenState.notificationEnabledProvider);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 30,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final menu = menuList[index];
    
        return MenuItem(
          menu: menu,
          onTapped: () => _handleMenuTapped(ref, menu),
          notificationEnabled: isEnabled,
          onNotificationChanged: (value) {
            openSystemNotificationSettings(ref);
          },
        );
      },
    );
  }

  ///
  /// 메뉴 탭 처리
  ///
  void _handleMenuTapped(WidgetRef ref, Menu menu) {
    switch (menu.type) {
      case MenuType.profile:
        UpdateProfileRoute().push(ref.context);
        break;
      case MenuType.displayMode:
        DisplayModeRoute().push(ref.context);
        break;
      case MenuType.notification:
        break;
      case MenuType.notificationList:
        NotificationListRoute().push(ref.context);
        break;
      case MenuType.feedback:
        FeedbackRoute().push(ref.context);
        break;
      case MenuType.privacyPolicy:
        goToPrivacyPolicyLink();
        break;
      case MenuType.signOut:
        _showSignOutDialog(ref);
        break;
      case MenuType.signIn:
        const SignInRoute().push(ref.context);
        break;
    }
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 로그아웃 다이얼로그
  ///
  void _showSignOutDialog(WidgetRef ref) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '로그아웃',
        subTitle: '정말 로그아웃 하시겠습니까?',
        leftBtnContent: '취소',
        rightBtnContent: '로그아웃',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          signOut();
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }
}
