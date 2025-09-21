import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/calendar/calendar_service.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/main.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_view.dart';

class CalendarScreen extends BaseScreen with CalendarScreenEvent {
  CalendarScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);

    // 달력 날짜 계산
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateCalendarDay(ref);
    });
  }

  ///
  /// Dispose
  ///
  @override
  void onDispose(WidgetRef ref) {
    super.onDispose(ref);
  }

  ///
  /// 배경색
  ///
  @override
  Color? get backgroundColor => const Color(0xFFF2F2F7);

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // keep alive
    useAutomaticKeepAlive();

    // 달력 뷰 구성
    return FocusDetector(
      onFocusGained: () {
        // 현재 선택된 달력 정보 조회
        fetchCurrentCalendar(ref);
      },
      child: _buildCalendarView(ref),
    );
  }

  ///
  /// 달력 뷰 구성
  ///
  Widget _buildCalendarView(WidgetRef ref) {
    // 달력 데이터
    final calendarMap = ref.watch(CalendarScreenState.calendarMap);

    // 주차 리스트
    final weekList = ref.watch(CalendarScreenState.weekList);

    // 현재 선택된 달력 정보
    final currentCalendar = ref.watch(CalendarScreenState.currentCalendar);

    // 캘린더 리스트 (스위칭)
    final calendarList = ref.watch(CalendarScreenState.calendarList);

    /// 달력 날짜가 없으면 로딩 뷰 반환
    if (calendarMap.isEmpty) {
      return const LoadingView(title: '달력을 불러오는 중입니다.');
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: CalendarView(
          calendar: currentCalendar,
          calendarList: calendarList,
          calendarMap: calendarMap,
          weekList: weekList,
          startDate: getStartDate(ref),

          // 날짜 클릭 => 일정 생성 화면 이동
          onLongPressed: (day) {
            ref.context.push(CreateScheduleRoute().location, extra: day);
          },

          // 캘린더 메뉴 버튼 클릭 (공유 캘린더 이동)
          onMenuButtonTapped: () {
            ShareCalendarListRoute().push(ref.context);
          },

          // 캘린더 리스트 조회 (드롭다운 메뉴 표시 전)
          onWillShow: () async {
            await fetchCalendarList(ref);
          },

          // 선택 캘린더 변경
          onCalendarTapped: (calendar) =>
              updateSelectedCalendar(ref, calendar: calendar),
        ),
      ),
    );
  }
}
