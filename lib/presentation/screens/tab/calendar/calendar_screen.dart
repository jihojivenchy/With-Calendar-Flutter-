import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/calendar/calendar_service.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/main.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/month_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_animation_builder.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_header.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/month_page.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule_title_view.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class CalendarScreen extends BaseScreen with CalendarScreenEvent {
  CalendarScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateCalendarDay(ref); // 달력 날짜 계산
      subscribeScheduleList(ref); // 일정 리스트 구독
    });
  }

  ///
  /// Dispose
  ///
  @override
  void onDispose(WidgetRef ref) {
    super.onDispose(ref);
    disposeSubscription(ref); // 일정 리스트 구독 해제
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

    // 달력 데이터 및 주차 리스트가 계산되기 전까지 대기
    final calendarMap = ref.watch(CalendarScreenState.calendarMap);
    final weekList = ref.watch(CalendarScreenState.weekList);

    if (calendarMap.isEmpty || weekList.isEmpty) {
      return const LoadingView(title: '달력 데이터를 불러오는 중입니다');
    }

    // 포커스 날짜
    final focusedDate = ref.watch(CalendarScreenState.focusedDate);

    // PageController 초기화
    final pageController = useMemoized(() {
      final initialPageIndex = calculatePageIndexFromDate(focusedDate);
      return PageController(initialPage: initialPageIndex);
    }, []);

    useEffect(() {
      // 페이지 컨트롤러가 초기화되지 않았으면 반환
      if (!pageController.hasClients) return null;

      // 이동할 페이지 및 현재 페이지 계산
      final targetIndex = calculatePageIndexFromDate(focusedDate);
      final currentIndex = pageController.page != null
          ? pageController.page!.round()
          : pageController.initialPage;

      // 현재 페이지와 이동 페이지가 같으면 아무 작업도 하지 않음
      if (currentIndex == targetIndex) return null;

      // 이동 거리에 따른 애니메이션 시간 계산
      final distance = (targetIndex - currentIndex).abs();
      final durationMs = 250 + distance * 70;
      final resolvedDurationMs = durationMs > 700 ? 700 : durationMs;

      // 이동
      pageController.animateToPage(
        targetIndex,
        duration: Duration(milliseconds: resolvedDurationMs),
        curve: Curves.easeOutCubic,
      );

      return null;
    }, [focusedDate]);

    final screenMode = ref.watch(CalendarScreenState.calendarMode);

    // 달력 뷰 구성
    return FocusDetector(
      onFocusGained: () {
        // 캘린더 리스트 조회 및 현재 선택된 달력 정보 조회
        fetchCalendarList(ref);
        fetchCurrentCalendar(ref);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 캘린더 헤더
                        _buildCalendarHeader(
                          ref,
                          focusedDate: focusedDate,
                          screenMode: screenMode,
                        ),
                        const SizedBox(height: 15),

                        // 캘린더 뷰
                        _buildCalendarView(
                          ref,
                          pageController: pageController,
                          calendarMap: calendarMap,
                          weekList: weekList,
                          screenMode: screenMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (screenMode == CalendarScreenMode.half) ...[
            _buildDateTitleView(ref, focusedDate: focusedDate),
            _buildScheduleListView(ref),
          ],
        ],
      ),
    );
  }

  ///
  /// 캘린더 헤더
  ///
  Widget _buildCalendarHeader(
    WidgetRef ref, {
    required DateTime focusedDate,
    required CalendarScreenMode screenMode,
  }) {
    final calendar = ref.watch(CalendarScreenState.currentCalendar);
    final calendarList = ref.watch(CalendarScreenState.calendarList);

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 10),
      child: CalendarHeader(
        calendar: calendar,
        focusedMonth: focusedDate,
        screenMode: screenMode,
        calendarList: calendarList, // 캘린더 리스트
        // 날짜 이동 bottom sheet 표시
        onHeaderTap: () {
          _showDatePickerBottomSheet(ref, focusedDate);
        },
        // 오늘 날짜로 이동
        onTodayButtonTapped: () {
          final now = DateTime.now();
          updateFocusedDate(ref, DateTime(now.year, now.month));
        },
        // 캘린더 메뉴 버튼 클릭 (공유 캘린더 이동)
        onMenuButtonTapped: () {
          ShareCalendarListRoute().push(ref.context);
        },
        // 캘린더 스위칭
        onCalendarTapped: (calendar) {
          updateSelectedCalendar(ref, calendar: calendar);
        },
        // 달력 화면 모드 변경
        onScreenModeButtonTapped: (mode) {
          updateCalendarMode(ref, mode);
        },
      ),
    );
  }

  ///
  /// 캘린더 뷰
  ///
  Widget _buildCalendarView(
    WidgetRef ref, {
    required PageController pageController,
    required Map<DateTime, List<Day>> calendarMap,
    required List<String> weekList,
    required CalendarScreenMode screenMode,
  }) {
    final lunarDate = ref.watch(CalendarScreenState.lunarDate);
    final scheduleMap = ref.watch(CalendarScreenState.scheduleListProvider);

    return CalendarAnimationBuilder(
      screenMode: screenMode,
      child: PageView.builder(
        controller: pageController,
        itemCount: calendarMap.length,
        itemBuilder: (context, index) {
          final targetDate = calculateDateFromIndex(index);
          final dayList = calendarMap[targetDate] ?? [];

          return MonthPageView(
            dayList: dayList,
            weekList: weekList,
            lunarDate: lunarDate,
            scheduleMap: scheduleMap,
            screenMode: screenMode,
            onTapped: (day) {
              fetchLunarDate(ref, day);
            },
            onLongPressed: (day) {
              log('날짜 클릭 => 일정 생성 화면 이동: $day');
              ref.context.push(CreateScheduleRoute().location, extra: day);
            },
          );
        },
        onPageChanged: (index) {
          updatePage(ref, index);
        },
      ),
    );
  }

  ///
  /// 선택된 날짜 타이틀 뷰 (half 모드)
  ///
  Widget _buildDateTitleView(WidgetRef ref, {required DateTime focusedDate}) {
    final lunarDate = ref.watch(CalendarScreenState.lunarDate);
    return ScheduleTitleView(focusedDate: focusedDate, lunarDate: lunarDate);
  }

  ///
  /// 선택된 날짜 일정 리스트
  ///
  Widget _buildScheduleListView(WidgetRef ref) {
    final scheduleList = ref.watch(CalendarScreenState.focusedScheduleList);

    // 일정이 없는 경우
    if (scheduleList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Center(
            child: AppText(
              text: '일정이 없습니다.',
              textAlign: TextAlign.center,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              textColor: AppColors.gray400,
            ),
          ),
        ),
      );
    }

    // 일정이 있는 경우
    return SliverPadding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),
      sliver: SliverList.separated(
        itemCount: scheduleList.length,
        itemBuilder: (context, index) {
          final schedule = scheduleList[index];
          return ScheduleItem(schedule: schedule);
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
      ),
    );
  }

  ///
  /// 날짜 이동 bottom sheet
  ///
  void _showDatePickerBottomSheet(WidgetRef ref, DateTime focusedDate) {
    FocusScope.of(ref.context).unfocus();

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return MonthPickerBottomSheet(
          focusedDate: focusedDate,
          onChangeDate: (date) {
            updateFocusedDate(ref, date);
          },
        );
      },
    );
  }
}
