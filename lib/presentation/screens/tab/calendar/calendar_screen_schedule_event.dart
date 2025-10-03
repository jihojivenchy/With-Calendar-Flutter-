part of 'calendar_screen_event.dart';

extension CalendarScheduleEvent on CalendarScreenEvent {
  ///
  /// 일정 리스트 구독
  ///
  Future<void> subscribeScheduleList(WidgetRef ref) async {
    // 현재 구독 상태 확인
    final currentSubscription = _getSubscription(ref);

    // 현재 구독 상태가 있으면 종료
    if (currentSubscription != null) return;

    // 일정 리스트 구독
    final subscription = _scheduleService
        .fetchScheduleList()
        .listen(
          (scheduleMap) {
            // 일정 리스트 업데이트
            ref.read(CalendarScreenState.scheduleListProvider.notifier).state =
                scheduleMap;
          },
          onError: (error, stackTrace) {
            SnackBarService.showSnackBar('일정 리스트 조회에 실패했습니다.');
            // 오류 상태 업데이트
            ref.read(CalendarScreenState.scheduleListProvider.notifier).state =
                {};
          },
        );

    // 구독 상태 업데이트
    _setSubscription(ref, subscription);
  }

  ///
  /// 일정 리스트 구독 해제
  ///
  Future<void> disposeSubscription(WidgetRef ref) async {
    final subscription = _getSubscription(ref);
    await subscription?.cancel();
    _setSubscription(ref, null);
  }

  ///
  /// 일정 리스트 구독 재시도
  ///
  Future<void> retry(WidgetRef ref) async {
    await disposeSubscription(ref);
    subscribeScheduleList(ref);
  }

  ///
  /// 일정 삭제
  ///
  Future<void> deleteSchedule(WidgetRef ref, String scheduleID) async {
    final calendar = ref.read(CalendarScreenState.currentCalendar);

    await _scheduleService.deleteSchedule(
      calendar: calendar,
      scheduleID: scheduleID,
    );
    retry(ref);
  }

  //--------------------------------Helper 메서드--------------------------------
  StreamSubscription<ScheduleMap>? _getSubscription(WidgetRef ref) =>
      ref.read(CalendarScreenState.subscriptionProvider.notifier).state;

  void _setSubscription(
    WidgetRef ref,
    StreamSubscription<ScheduleMap>? subscription,
  ) => ref.read(CalendarScreenState.subscriptionProvider.notifier).state =
      subscription;
}
