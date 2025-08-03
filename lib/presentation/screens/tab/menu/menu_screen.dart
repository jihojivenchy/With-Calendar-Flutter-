import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/menu/menu_item.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/provider/menu_view_model.dart';
import 'package:with_calendar/presentation/screens/tab/menu/widgets/menu_item.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/utils/services/dialog/dialog_service.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen>
    with AutomaticKeepAliveClientMixin, MenuEvent {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              AppText(text: '메뉴', fontSize: 28, fontWeight: FontWeight.w800),
              _buildMenuList(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 메뉴 리스트 빌드
  ///
  Widget _buildMenuList() {
    return Consumer(
      builder: (context, ref, child) {
        final menuList = ref.watch(MenuState.menuListProvider);

        return Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 30),
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              final menu = menuList[index];

              return MenuItem(
                menu: menu,
                onTapped: () => _handleMenuTapped(menu),
              );
            },
          ),
        );
      },
    );
  }

  ///
  /// 메뉴 탭 처리
  ///
  void _handleMenuTapped(Menu menu) {
    switch (menu.type) {
      case MenuType.profile:
        UpdateProfileRoute().push(context);
        break;
      case MenuType.notification:
        print('notification');
        break;
      case MenuType.notificationList:
        print('notificationList');
        break;
      case MenuType.feedback:
        print('feedback');
        break;
      case MenuType.privacyPolicy:
        goToPrivacyPolicyLink();
        break;
      case MenuType.signOut:
        _showSignOutDialog();
        break;
      case MenuType.signIn:
        const SignInRoute().push(context);
        break;
    }
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 로그아웃 다이얼로그
  ///
  void _showSignOutDialog() {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '로그아웃',
        subTitle: '정말 로그아웃 하시겠습니까?',
        leftBtnContent: '취소',
        rightBtnContent: '로그아웃',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          context.pop();
          signOut();
        },
        onLeftBtnClicked: () => context.pop(),
      ),
    );
  }
}
