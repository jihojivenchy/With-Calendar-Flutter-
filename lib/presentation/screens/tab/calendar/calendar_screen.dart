import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/update_schedule_request.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/month_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/router/router.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/share/calendar_menu_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/todo_bottom_sheet.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/update/update_schedule_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/calendar_animation_builder.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/calendar_header.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/month_page.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/create_schedule_button.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_title_view.dart';

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
      fetchCurrentCalendar(ref); // 현재 선택된 달력 정보 조회
      fetchHolidayList(ref, DateTime.now().year); // 공휴일 리스트 조회
    });
  }

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
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(8),
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
          _buildScheduleCreateButton(ref, focusedDate: focusedDate),
        ],
      ],
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

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 10),
      child: CalendarHeader(
        calendar: calendar,
        focusedMonth: focusedDate,
        screenMode: screenMode,
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
          _showCalendarMenu(context: ref.context);
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
    final holidayMap = ref.watch(CalendarScreenState.holidayMap);
    final calendar = ref.watch(CalendarScreenState.currentCalendar);

    final scheduleMapAsync = ref.watch(
      CalendarScreenState.scheduleListStreamProvider(calendar),
    );

    return scheduleMapAsync.when(
      data: (scheduleMap) {
        return CalendarAnimationBuilder(
          screenMode: screenMode,
          onScreenModeChanged: (mode) {
            updateCalendarMode(ref, mode);
          },
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
                holidayMap: holidayMap,
                onTapped: (day) {
                  // 화면 모드가 전체 모드인 경우 일정 리스트 화면으로 이동
                  if (screenMode == CalendarScreenMode.full) {
                    ScheduleListRoute(selectedDate: day.date).push(context);
                  } 

                  fetchLunarDate(ref, day);
                },
              );
            },
            onPageChanged: (index) {
              updatePage(ref, index);
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: AppSize.calendarHeight,
        child: const LoadingView(title: '달력을 불러오는 중입니다.'),
      ),
      error: (error, _) {
        log('달력 조회 실패: ${error.toString()}');
        return SizedBox(
          height: AppSize.calendarHeight,
          child: ErrorView(title: '달력 표시에 실패했습니다.', onRetryBtnTapped: () {}),
        );
      },
    );
  }

  ///
  /// 선택된 날짜 타이틀 뷰 (half 모드)
  ///
  Widget _buildDateTitleView(WidgetRef ref, {required DateTime focusedDate}) {
    final lunarDate = ref.watch(CalendarScreenState.lunarDate);
    final holidayMap = ref.watch(CalendarScreenState.holidayMap);

    return ScheduleTitleView(
      focusedDate: focusedDate,
      lunarDate: lunarDate,
      holidayList: holidayMap[lunarDate?.solarDate ?? focusedDate] ?? [],
    );
  }

  ///
  /// 선택된 날짜 일정 리스트
  ///
  Widget _buildScheduleListView(WidgetRef ref) {
    final scheduleListAsync = ref.watch(
      CalendarScreenState.focusedScheduleList,
    );

    return scheduleListAsync.when(
      data: (scheduleList) {
        if (scheduleList.isEmpty) {
          return const SliverToBoxAdapter();
        }

        return SliverPadding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          sliver: SliverList.separated(
            itemCount: scheduleList.length,
            itemBuilder: (context, index) {
              final schedule = scheduleList[index];
              return ScheduleItem(
                schedule: schedule,
                onTapped: () {
                  _showUpdateBottomSheet(ref, schedule);
                },
                onLongPressed: () {
                  _showDeleteDialog(ref, schedule.id);
                },
                onTodoListBtnTapped: () {
                  _showTodoListBottomSheet(ref, schedule);
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(),
      error: (error, _) => const SliverToBoxAdapter(),
    );
  }

  ///
  /// 일정 생성 버튼
  ///
  Widget _buildScheduleCreateButton(
    WidgetRef ref, {
    required DateTime focusedDate,
  }) {
    final lunarDate = ref.watch(CalendarScreenState.lunarDate);
    final selectedDate = lunarDate?.solarDate ?? focusedDate;

    return CreateScheduleButton(
      selectedDate: selectedDate,
      onTapped: () {
        FocusScope.of(ref.context).unfocus();

        final baseDate = selectedDate;
        final targetDay = Day(
          date: DateTime(baseDate.year, baseDate.month, baseDate.day),
          isOutside: false,
          state: DayCellState.basic,
        );

        _showCreateBottomSheet(ref, targetDay);
      },
    );
  }

  // --------------------------------- 바텀 시트 ---------------------------------
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

  ///
  /// 일정 생성
  ///
  void _showCreateBottomSheet(WidgetRef ref, Day selectedDay) {
    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CreateScheduleScreen(selectedDay: selectedDay);
      },
    );
  }

  ///
  /// 일정 수정
  ///
  void _showUpdateBottomSheet(WidgetRef ref, Schedule schedule) {
    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return UpdateScheduleScreen(
          request: UpdateScheduleRequest(
            id: schedule.id,
            title: schedule.title,
            type: schedule.type,
            startDate: schedule.startDate,
            endDate: schedule.endDate,
            notificationTime: schedule.notificationTime,
            memo: schedule.memo,
            color: schedule.color,
            isTodoExist: schedule.isTodoExist,
            existTodoList: [],
            newTodoList: [],
          ),
        );
      },
    );
  }

  ///
  /// 할 일 목록 바텀시트
  ///
  void _showTodoListBottomSheet(WidgetRef ref, Schedule schedule) {
    final calendar = ref.watch(CalendarScreenState.currentCalendar);

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return TodoBottomSheet(calendar: calendar, schedule: schedule);
      },
    );
  }

  // ------------------------------- Dialog ------------------------------------
  ///
  /// 일정 삭제 다이얼로그
  ///
  void _showDeleteDialog(WidgetRef ref, String scheduleID) {
    DialogService.show(
      dialog: AppDialog.doubleBtn(
        title: '해당 일정을 삭제할까요?',
        leftBtnContent: '취소',
        rightBtnContent: '삭제',
        rightBtnColor: const Color(0xFFEF4444),
        onRightBtnClicked: () {
          ref.context.pop();
          deleteSchedule(ref, scheduleID);
        },
        onLeftBtnClicked: () => ref.context.pop(),
      ),
    );
  }

  ///
  /// 사이드 메뉴 표시
  ///
  Future<void> _showCalendarMenu({required BuildContext context}) async {
    // 전체 화면을 덮는 다이얼로그 표시
    final result = await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 비활성화 (애니메이션으로만 닫기)
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return CalendarMenuView();
      },
    );

    return result;
  }
}
