import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/provider/auth/auth_state_provider.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen.dart';
import 'package:with_calendar/presentation/screens/tab/memo/memo_list_screen.dart';
import 'package:with_calendar/presentation/screens/tab/menu/menu_screen.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';
import 'package:with_calendar/utils/extensions/image_extension.dart';

enum TabType { calendar, memo, menu }

class TabScreen extends ConsumerStatefulWidget {
  const TabScreen({super.key});

  @override
  ConsumerState<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends ConsumerState<TabScreen> {
  final _pages = [
    CalendarScreen(key: ValueKey(TabType.calendar)),
    MemoListScreen(key: ValueKey(TabType.memo)),
    MenuScreen(key: ValueKey(TabType.menu)),
  ];

  late final PageController _pageController;
  int _currentIndex = 0; // 현재 선택된 탭 인덱스 추가

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 변경 감지
    ref.listen<bool>(isSignedInProvider, (previous, next) {
      if (previous == true && next == false) {
        const SignInRoute().go(context);
      }
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
        children: _pages.mapIndexed((index, page) {
          return page
              .animate(target: _currentIndex == index ? 1 : 0)
              .fade(duration: 200.ms);
        }).toList(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: context.backgroundColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        enableFeedback: false,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: context.tabIconColor,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagePaths.calendarOFF,
              width: 25,
              height: 25,
              cacheWidth: 25.cacheSize(context),
              cacheHeight: 25.cacheSize(context),
              color: context.tabIconColor,
            ),
            activeIcon: Image.asset(
              ImagePaths.calendarON,
              width: 25,
              height: 25,
              cacheWidth: 25.cacheSize(context),
              cacheHeight: 25.cacheSize(context),
              color: AppColors.primary,
            ),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagePaths.memo,
              width: 23,
              height: 23,
              cacheWidth: 23.cacheSize(context),
              cacheHeight: 23.cacheSize(context),
              color: context.tabIconColor,
            ),
            activeIcon: Image.asset(
              ImagePaths.memo,
              width: 23,
              height: 23,
              cacheWidth: 23.cacheSize(context),
              cacheHeight: 23.cacheSize(context),
              color: AppColors.primary,
            ),
            label: '메모',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              ImagePaths.menu,
              width: 22,
              height: 22,
              cacheWidth: 22.cacheSize(context),
              cacheHeight: 22.cacheSize(context),
              color: context.tabIconColor,
            ),
            activeIcon: Image.asset(
              ImagePaths.menu,
              width: 22,
              height: 22,
              cacheWidth: 22.cacheSize(context),
              cacheHeight: 22.cacheSize(context),
              color: AppColors.primary,
            ),
            label: '메뉴',
          ),
        ],
      ),
    );
  }
}
