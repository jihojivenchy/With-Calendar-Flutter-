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
    GoRouteData.$route(
      path: 'calendar/schedule-list',
      name: 'schedule list',

      factory: _$ScheduleListRoute._fromState,
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
      path: 'memo/search',
      name: 'search memo',

      factory: _$SearchMemoRoute._fromState,
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
    GoRouteData.$route(
      path: 'feedback',
      name: 'feedback',

      factory: _$FeedbackRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'display-mode',
      name: 'display mode',

      factory: _$DisplayModeRoute._fromState,
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

mixin _$CreateShareCalendarRoute on GoRouteData {
  static CreateShareCalendarRoute _fromState(GoRouterState state) =>
      CreateShareCalendarRoute();

  @override
  String get location =>
      GoRouteData.$location('/calendar/create-share-calendar');

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
    '/calendar/update-share-calendar/${Uri.encodeComponent(_self.calendarID)}',
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
    '/calendar/search-user/${Uri.encodeComponent(_self.mode)}',
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

mixin _$ScheduleListRoute on GoRouteData {
  static ScheduleListRoute _fromState(GoRouterState state) => ScheduleListRoute(
    selectedDate: DateTime.parse(state.uri.queryParameters['selected-date']!)!,
  );

  ScheduleListRoute get _self => this as ScheduleListRoute;

  @override
  String get location => GoRouteData.$location(
    '/calendar/schedule-list',
    queryParams: {'selected-date': _self.selectedDate.toString()},
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

mixin _$SearchMemoRoute on GoRouteData {
  static SearchMemoRoute _fromState(GoRouterState state) => SearchMemoRoute();

  @override
  String get location => GoRouteData.$location('/memo/search');

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

mixin _$FeedbackRoute on GoRouteData {
  static FeedbackRoute _fromState(GoRouterState state) => FeedbackRoute();

  @override
  String get location => GoRouteData.$location('/feedback');

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

mixin _$DisplayModeRoute on GoRouteData {
  static DisplayModeRoute _fromState(GoRouterState state) => DisplayModeRoute();

  @override
  String get location => GoRouteData.$location('/display-mode');

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
