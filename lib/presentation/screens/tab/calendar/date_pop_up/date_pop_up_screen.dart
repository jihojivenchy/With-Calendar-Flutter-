import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/domain/entities/schedule/request/update_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/date_pop_up/date_pop_up_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/date_pop_up/date_pop_up_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/date_pop_up/widgets/date_pop_up_page.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/todo_bottom_sheet.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/update/update_schedule_screen.dart';

class DatePopupScreen extends BaseScreen with DatePopupEvent {
  DatePopupScreen({super.key, required this.selectedDate});

  final DateTime selectedDate;

  bool _isListenerRegistered = false;

  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateLunarDateMap(ref, selectedDate);
      calculateScheduleMap(ref, selectedDate);
    });
  }

  ///
  /// 스케줄 변경사항 감지
  ///
  void _subscribeToScheduleStream(WidgetRef ref) {
    // 현재 선택된 달력 정보
    final currentCalendar = ref.read(CalendarScreenState.currentCalendar);

    // 스케줄 변경사항 감지
    ref.listen(
      CalendarScreenState.scheduleListStreamProvider(currentCalendar),
      (previous, next) {
        // 실제 데이터 변경이 있을 때만 처리
        final prevData = previous?.asData?.value;
        final nextData = next.asData?.value;

        if (prevData != null && nextData != null && prevData == nextData) {
          return; // 변경 없음
        }

        next.whenData((globalScheduleMap) {
          // 현재 로컬 맵
          final currentLocalMap = ref.read(DatePopupState.scheduleMap);

          // 아직 초기화되지 않았으면 스킵
          if (currentLocalMap.isEmpty) return;

          // 업데이트된 일정 맵
          final updatedEntries = <DateTime, List<Schedule>>{};

          // 해당 날짜의 일정 리스트 갱신
          for (final date in currentLocalMap.keys) {
            final scheduleList = globalScheduleMap[date] ?? [];
            updatedEntries[date] = filterSpacers(scheduleList);
          }

          // 변경사항이 있을 때만 업데이트
          if (updatedEntries.isNotEmpty) {
            ref.read(DatePopupState.scheduleMap.notifier).state =
                updatedEntries;
          }
        });
      },
    );
  }

  @override
  Color? backgroundColor(BuildContext context) {
    return Colors.transparent;
  }

  @override
  bool get resizeToAvoidBottomInset => false;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // 리스너 등록
    if (!_isListenerRegistered) {
      _subscribeToScheduleStream(ref);
      _isListenerRegistered = true;
    }

    // 페이지 컨트롤러 구성
    final pageController = usePageController(
      initialPage: calculatePageIndexFromDate(selectedDate),
      viewportFraction: 0.8,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              context.pop();
            },
            child: const SizedBox.shrink(),
          ),
        ),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: _buildCarouselView(ref, pageController: pageController),
          ),
        ),
      ],
    );
  }

  ///
  /// 캐러셀 뷰
  ///
  Widget _buildCarouselView(
    WidgetRef ref, {
    required PageController pageController,
  }) {
    final lunarDateMap = ref.watch(DatePopupState.lunarDateMap);
    final holidayMap = ref.watch(CalendarScreenState.holidayMap);
    final scheduleMap = ref.watch(DatePopupState.scheduleMap);

    return SizedBox(
      width: AppSize.deviceWidth,
      height: AppSize.deviceHeight * 0.65,
      child: PageView.builder(
        controller: pageController,
        itemCount: totalPageCount,
        onPageChanged: (index) {
          handlePageChanged(ref, index);
        },
        itemBuilder: (context, index) {
          // 음력 날짜 조회
          final lunarDate = getLunarDateFromMap(lunarDateMap, index);
          final holidayList = getHolidayFromMap(holidayMap, lunarDate);
          final scheduleList = getScheduleFromMap(scheduleMap, index);

          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              // 현재 페이지 위치 계산
              final position = _currentPosition(
                controller: pageController,
                fallBack: pageController.initialPage.toDouble(),
              );

              // 페이지 거리 계산 => 거리 값이 커질수록 페이지 크기가 작아지고, 투명도가 낮아짐
              final distance = (position - index).abs();
              final scale = (1 - distance * 0.18).clamp(0.8, 1.0);
              final opacity = (1 - distance * 0.45).clamp(0.5, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: DatePopupPage(
              lunarDate: lunarDate,
              scheduleList: scheduleList,
              holidayList: holidayList,

              onCreateScheduleTapped: () {
                _showCreateBottomSheet(ref, lunarDate);
              },
              onDeleteScheduleTapped: (schedule) {
                _showDeleteDialog(ref, schedule.id);
              },
              onTodoListBtnTapped: (schedule) {
                _showTodoListBottomSheet(ref, schedule);
              },
              onUpdateScheduleTapped: (schedule) {
                _showUpdateBottomSheet(ref, schedule);
              },
            ),
          );
        },
      ),
    );
  }

  ///
  /// 인덱스를 받아서 음력 날짜 리스트에서 조회
  ///
  LunarDate? getLunarDateFromMap(LunarDateMap lunarDateMap, int index) {
    final key = getCacheKey(dateOf(index));
    return lunarDateMap[key];
  }

  ///
  /// 인덱스를 받아서 휴일 맵에서 조회
  ///
  List<Holiday> getHolidayFromMap(HolidayMap holidayMap, LunarDate? lunarDate) {
    return holidayMap[lunarDate?.solarDate ?? DateTime.now()] ?? [];
  }

  ///
  /// 인덱스를 받아서 일정 리스트 맵에서 조회
  ///
  List<Schedule> getScheduleFromMap(ScheduleMap scheduleMap, int index) {
    final date = dateOf(index);
    return scheduleMap[date] ?? [];
  }

  /// 현재 페이지 위치 계산
  double _currentPosition({
    required PageController controller,
    required double fallBack,
  }) {
    if (!controller.hasClients) return fallBack;
    return controller.page ?? fallBack;
  }

  // ------------------------------- 바텀 시트 --------------------------------
  ///
  /// 일정 생성
  ///
  void _showCreateBottomSheet(WidgetRef ref, LunarDate? lunarDate) {
    final date = DateTime(
      lunarDate?.solarDate.year ?? DateTime.now().year,
      lunarDate?.solarDate.month ?? DateTime.now().month,
      lunarDate?.solarDate.day ?? DateTime.now().day,
    );

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CreateScheduleScreen(
          selectedDay: Day(
            date: date,
            isOutside: false,
            state: DayCellState.basic,
          ),
        );
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
}
