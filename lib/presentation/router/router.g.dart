// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$splashRoute, $signInRoute, $tabRoute];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  name: 'splash',

  factory: _$SplashRoute._fromState,
);

mixin _$SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  name: 'sign in',

  factory: _$SignInRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'sign-up',
      name: 'sign up',

      factory: _$SignUpRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'find-password',
      name: 'find password',

      factory: _$FindPasswordRoute._fromState,
    ),
  ],
);

mixin _$SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$SignUpRoute on GoRouteData {
  static SignUpRoute _fromState(GoRouterState state) => SignUpRoute();

  @override
  String get location => GoRouteData.$location('/sign-in/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$FindPasswordRoute on GoRouteData {
  static FindPasswordRoute _fromState(GoRouterState state) =>
      FindPasswordRoute();

  @override
  String get location => GoRouteData.$location('/sign-in/find-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $tabRoute => GoRouteData.$route(
  path: '/',
  name: 'tab',

  factory: _$TabRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'calendar/create-schedule',
      name: 'create schedule',

      factory: _$CreateScheduleRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'calendar/share-calendar-list',
      name: 'share calendar list',

      factory: _$ShareCalendarListRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'calendar/create-share-calendar',
          name: 'create share calendar',

          factory: _$CreateShareCalendarRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'calendar/update-share-calendar/:calendarID',
          name: 'update share calendar',

          factory: _$UpdateShareCalendarRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'calendar/search-user/:mode',
          name: 'search user',

          factory: _$SearchUserRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'memo/update',
      name: 'update memo',

      factory: _$UpdateMemoRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'memo/create',
      name: 'create memo',

      factory: _$CreateMemoRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'profile/update',
      name: 'update profile',

      factory: _$UpdateProfileRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'notification/list',
      name: 'notification list',

      factory: _$NotificationListRoute._fromState,
    ),
  ],
);

mixin _$TabRoute on GoRouteData {
  static TabRoute _fromState(GoRouterState state) => const TabRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CreateScheduleRoute on GoRouteData {
  static CreateScheduleRoute _fromState(GoRouterState state) =>
      CreateScheduleRoute();

  @override
  String get location => GoRouteData.$location('/calendar/create-schedule');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$ShareCalendarListRoute on GoRouteData {
  static ShareCalendarListRoute _fromState(GoRouterState state) =>
      ShareCalendarListRoute();

  @override
  String get location => GoRouteData.$location('/calendar/share-calendar-list');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CreateShareCalendarRoute on GoRouteData {
  static CreateShareCalendarRoute _fromState(GoRouterState state) =>
      CreateShareCalendarRoute();

  @override
  String get location => GoRouteData.$location(
    '/calendar/share-calendar-list/calendar/create-share-calendar',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UpdateShareCalendarRoute on GoRouteData {
  static UpdateShareCalendarRoute _fromState(GoRouterState state) =>
      UpdateShareCalendarRoute(calendarID: state.pathParameters['calendarID']!);

  UpdateShareCalendarRoute get _self => this as UpdateShareCalendarRoute;

  @override
  String get location => GoRouteData.$location(
    '/calendar/share-calendar-list/calendar/update-share-calendar/${Uri.encodeComponent(_self.calendarID)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$SearchUserRoute on GoRouteData {
  static SearchUserRoute _fromState(GoRouterState state) =>
      SearchUserRoute(mode: state.pathParameters['mode']!);

  SearchUserRoute get _self => this as SearchUserRoute;

  @override
  String get location => GoRouteData.$location(
    '/calendar/share-calendar-list/calendar/search-user/${Uri.encodeComponent(_self.mode)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UpdateMemoRoute on GoRouteData {
  static UpdateMemoRoute _fromState(GoRouterState state) => UpdateMemoRoute();

  @override
  String get location => GoRouteData.$location('/memo/update');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$CreateMemoRoute on GoRouteData {
  static CreateMemoRoute _fromState(GoRouterState state) => CreateMemoRoute();

  @override
  String get location => GoRouteData.$location('/memo/create');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UpdateProfileRoute on GoRouteData {
  static UpdateProfileRoute _fromState(GoRouterState state) =>
      UpdateProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile/update');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$NotificationListRoute on GoRouteData {
  static NotificationListRoute _fromState(GoRouterState state) =>
      NotificationListRoute();

  @override
  String get location => GoRouteData.$location('/notification/list');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
