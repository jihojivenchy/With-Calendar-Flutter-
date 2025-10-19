import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/find_password/find_pw_screen.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:with_calendar/presentation/screens/auth/sign_up/sign_up_screen.dart';
import 'package:with_calendar/presentation/screens/splash/splash_screen.dart';
import 'package:with_calendar/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:with_calendar/presentation/screens/splash/splash_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/create/create_share_calendar_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/search/search_user_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/update/update_share_calendar_screen.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/create_memo_screen.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/search_memo_screen.dart';
import 'package:with_calendar/presentation/screens/tab/memo/update/update_memo_screen.dart';
import 'package:with_calendar/presentation/screens/tab/menu/display_mode/display_mode_screen.dart';
import 'package:with_calendar/presentation/screens/tab/menu/feedback/feedback_screen.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen.dart';
import 'package:with_calendar/presentation/screens/tab/menu/update_profile/update_profile_screen.dart';
import 'package:with_calendar/presentation/screens/tab/tab_screen.dart';

part 'router.g.dart';

///
/// 부모 라우트가 [$extra]로 argument를 전달하고 있고
/// 자식 라우트도 동일하게 [$extra]로 argument을 전달하는 상황일 때
/// 부모 [$extra]값이 자식[$extra]를 덮어쓰는 고질적인 이슈가 존재.
///
/// 해당 이슈: https://github.com/flutter/flutter/issues/106121
///
/// 1년 반이 더 지난 이슈지만 Flutter tream에서 해결의지 크게 없어보임.
/// 이를 우회회할 수 있는 방법은 라우트를 부모와 자식으로 구분하지 않는 것인데,
/// 이렇게 되면 route path경로를 유동적으로 설정하지 못한다는 문제점이 발생.
/// 이러한 이유로 [$extra]를 통해 인자를 전달 받지 않고
/// Route 모듈의 전역변수 값을 외부에서 업데이트하여 필요한 섹션에 인자를 전달하는 중
///
///

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter appRouter() => GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: rootNavigatorKey,
  initialLocation: SplashRoute.path, // 스플래시부터 시작
  routes: $appRoutes, // 모든 최상위 라우트들을 수집
);

///
/// @TypedGoRoute
/// Gorouter의 타입 세이프 라우팅 기능을 위한 어노테이션
/// 컴파일 타임에 타입 안정성을 보장하는 라우팅 기능을 제공함
///
///
///
///

///
/// splash
///
@TypedGoRoute<SplashRoute>(path: SplashRoute.path, name: SplashRoute.name)
class SplashRoute extends GoRouteData with _$SplashRoute {
  const SplashRoute();

  static const String path = '/splash';
  static const String name = 'splash';

  @override
  Page<Function> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
          child: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}

///
/// Sign In Route
///
@TypedGoRoute<SignInRoute>(
  path: SignInRoute.path,
  name: SignInRoute.name,
  routes: [
    TypedGoRoute<SignUpRoute>(path: SignUpRoute.path, name: SignUpRoute.name),
    TypedGoRoute<FindPasswordRoute>(
      path: FindPasswordRoute.path,
      name: FindPasswordRoute.name,
    ),
  ],
)
class SignInRoute extends GoRouteData with _$SignInRoute {
  const SignInRoute();

  static const String path = '/sign-in';
  static const String name = 'sign in';

  @override
  Page<Function> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      },
      child: SignInScreen(),
    );
  }
}

///
/// 회원가입 라우트
///
class SignUpRoute extends GoRouteData with _$SignUpRoute {
  static const String path = 'sign-up';
  static const String name = 'sign up';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SignUpScreen();
  }
}

///
/// 비밀번호 찾기 라우트
///
class FindPasswordRoute extends GoRouteData with _$FindPasswordRoute {
  static const String path = 'find-password';
  static const String name = 'find password';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FindPasswordScreen();
  }
}

///
/// Tab Route
///
@TypedGoRoute<TabRoute>(
  path: TabRoute.path,
  name: TabRoute.name,
  routes: [
    // ------------------------------ 달력 라우트 ------------------------------
    TypedGoRoute<CreateScheduleRoute>(
      path: CreateScheduleRoute.path,
      name: CreateScheduleRoute.name,
    ),
    TypedGoRoute<CreateShareCalendarRoute>(
      path: CreateShareCalendarRoute.path,
      name: CreateShareCalendarRoute.name,
    ),
    TypedGoRoute<UpdateShareCalendarRoute>(
      path: UpdateShareCalendarRoute.path,
      name: UpdateShareCalendarRoute.name,
    ),
    TypedGoRoute<SearchUserRoute>(
      path: SearchUserRoute.path,
      name: SearchUserRoute.name,
    ),

    // ------------------------------ 메모 라우트 ------------------------------
    TypedGoRoute<UpdateMemoRoute>(
      path: UpdateMemoRoute.path,
      name: UpdateMemoRoute.name,
    ),
    TypedGoRoute<CreateMemoRoute>(
      path: CreateMemoRoute.path,
      name: CreateMemoRoute.name,
    ),
    TypedGoRoute<SearchMemoRoute>(
      path: SearchMemoRoute.path,
      name: SearchMemoRoute.name,
    ),

    // ------------------------------ 메뉴 라우트 ------------------------------
    TypedGoRoute<UpdateProfileRoute>(
      path: UpdateProfileRoute.path,
      name: UpdateProfileRoute.name,
    ),
    TypedGoRoute<NotificationListRoute>(
      path: NotificationListRoute.path,
      name: NotificationListRoute.name,
    ),
    TypedGoRoute<FeedbackRoute>(
      path: FeedbackRoute.path,
      name: FeedbackRoute.name,
    ),
    TypedGoRoute<DisplayModeRoute>(
      path: DisplayModeRoute.path,
      name: DisplayModeRoute.name,
    ),
  ],
)
class TabRoute extends GoRouteData with _$TabRoute {
  const TabRoute();

  static const String path = '/';
  static const String name = 'tab';

  @override
  Page<Function> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey, // 라우팅 시 페이지 식별자
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      },
      child: const TabScreen(),
    );
  }
}

///
/// 메모 작성 라우트
///
class CreateMemoRoute extends GoRouteData with _$CreateMemoRoute {
  static const String path = 'memo/create';
  static const String name = 'create memo';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateMemoScreen();
  }
}

///
/// 메모 수정 라우트
///
class UpdateMemoRoute extends GoRouteData with _$UpdateMemoRoute {
  static const String path = 'memo/update';
  static const String name = 'update memo';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final Memo memo = state.extra as Memo;
    return UpdateMemoScreen(memo: memo);
  }
}

///
/// 메모 검색 라우트
///
class SearchMemoRoute extends GoRouteData with _$SearchMemoRoute {
  static const String path = 'memo/search';
  static const String name = 'search memo';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchMemoScreen();
  }
}

//------------------------달력 라우트----------------------------------------------
///
/// 달력 생성 라우트
///
class CreateScheduleRoute extends GoRouteData with _$CreateScheduleRoute {
  static const String path = 'calendar/create-schedule';
  static const String name = 'create schedule';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final Day selectedDay = state.extra as Day;
    return CreateScheduleScreen(selectedDay: selectedDay);
  }
}

///
/// 공유 캘린더 생성 라우트
///
class CreateShareCalendarRoute extends GoRouteData
    with _$CreateShareCalendarRoute {
  static const String path = 'calendar/create-share-calendar';
  static const String name = 'create share calendar';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreateShareCalendarScreen();
  }
}

///
/// 공유 캘린더 유저 검색 라우트
///
class SearchUserRoute extends GoRouteData with _$SearchUserRoute {
  static const String path = 'calendar/search-user/:mode';
  static const String name = 'search user';

  final String mode;
  SearchUserRoute({required this.mode});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchUserScreen(mode: SearchMode.fromValue(mode));
  }
}

///
/// 공유 캘린더 수정 라우트
///
class UpdateShareCalendarRoute extends GoRouteData
    with _$UpdateShareCalendarRoute {
  static const String path = 'calendar/update-share-calendar/:calendarID';
  static const String name = 'update share calendar';

  final String calendarID;
  UpdateShareCalendarRoute({required this.calendarID});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UpdateShareCalendarScreen(calendarID: calendarID);
  }
}

//------------------------메뉴 라우트--------------------------------
///
/// 프로필 수정 라우트
///
class UpdateProfileRoute extends GoRouteData with _$UpdateProfileRoute {
  static const String path = 'profile/update';
  static const String name = 'update profile';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UpdateProfileScreen();
  }
}

///
/// 알림 리스트 라우트
///
class NotificationListRoute extends GoRouteData with _$NotificationListRoute {
  static const String path = 'notification/list';
  static const String name = 'notification list';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NotificationListScreen();
  }
}

///
/// 피드백 라우트
///
class FeedbackRoute extends GoRouteData with _$FeedbackRoute {
  static const String path = 'feedback';
  static const String name = 'feedback';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeedbackScreen();
  }
}

///
/// 화면 모드 라우트
///
class DisplayModeRoute extends GoRouteData with _$DisplayModeRoute {
  static const String path = 'display-mode';
  static const String name = 'display mode';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DisplayModeScreen();
  }
}
