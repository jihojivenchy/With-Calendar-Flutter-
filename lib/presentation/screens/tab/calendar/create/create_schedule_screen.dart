import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/schedule/notification/all_day_type.dart';
import 'package:with_calendar/domain/entities/schedule/notification/time_type.dart';
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/notification_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/set_notification_bottom_sheet.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/bottom_sheet/set_todo_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button_group.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/component/view/app_date_time_picker_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_color_button.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_date_picker_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_memo_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_notification_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_title_text_field.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_todo_list_button.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class CreateScheduleScreen extends ConsumerStatefulWidget {
  const CreateScheduleScreen({super.key, required this.selectedDay});

  final Day selectedDay;

  @override
  ConsumerState<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends ConsumerState<CreateScheduleScreen>
    with CreateScheduleEvent {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 일정 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize(ref, widget.selectedDay);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  ///
  /// 본문
  ///
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.deviceHeight * 0.9,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF767676),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 제목 입력
                  _buildTitleTextField(),

                  // 하루 종일 모드인지 or 시간 모드인지 설정
                  const SizedBox(height: 20),
                  _buildScheduleTypeButton(),

                  // 시작일 선택
                  _buildStartDatePickerView(),

                  // 종료일 선택
                  _buildEndDatePickerView(),

                  // 알림 선택
                  _buildNotificationPickerView(),

                  // 컬러 선택
                  _buildColorPickerButton(),

                  // 할 일 목록 버튼
                  _buildTodoListButton(),

                  // 메모 입력
                  _buildMemoTextField(scrollController),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildCompletionButton(),
        ],
      ),
    );
  }

  ///
  /// 제목 텍스트 필드
  ///
  Widget _buildTitleTextField() {
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    return ScheduleTitleTextField(
      lineColor: selectedColor,
      onTitleChanged: (title) {
        updateTitle(ref, title);
      },
    );
  }

  ///
  /// 하루 종일 모드인지 or 시간 모드인지
  ///
  Widget _buildScheduleTypeButton() {
    // 선택된 일정 유형
    final selectedType = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.type),
    );
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    return Container(
      decoration: BoxDecoration(
        color: ref.context.surface,
        border: Border(bottom: BorderSide(color: selectedColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: AppButtonGroup(
        options: [
          AppButtonOption(text: '하루 종일', value: ScheduleType.allDay),
          AppButtonOption(text: '시간 설정', value: ScheduleType.time),
        ],
        selectedValue: selectedType,
        backgroundColor: ref.context.surface2,
        selectedBackgroundColor: ref.context.surface,
        selectedBorderColor: selectedColor,
        selectedTextColor: selectedColor,
        onChanged: (type) {
          updateType(ref, type);
        },
      ),
    );
  }

  ///
  /// 시작일 선택
  ///
  Widget _buildStartDatePickerView() {
    // 일정 데이터
    final schedule = ref.watch(CreateScheduleState.requestProvider);

    return ScheduleDatePickerView(
      title: '시작',
      selectedDate: schedule.startDate,
      scheduleType: schedule.type,
      lineColor: schedule.color,
      onChangeDate: (dateTime) {
        updateStartDate(ref, dateTime);
      },
    );
  }

  ///
  /// 종료일 선택
  ///
  Widget _buildEndDatePickerView() {
    // 일정 데이터
    final schedule = ref.watch(CreateScheduleState.requestProvider);

    return ScheduleDatePickerView(
      title: '종료',
      selectedDate: schedule.endDate,
      scheduleType: schedule.type,
      startDate: schedule.startDate,
      lineColor: schedule.color,
      onChangeDate: (dateTime) {
        updateEndDate(ref, dateTime);
      },
    );
  }

  ///
  /// 알림 선택
  ///
  Widget _buildNotificationPickerView() {
    // 일정 데이터
    final request = ref.watch(CreateScheduleState.requestProvider);

    return ScheduleNotificationView(
      scheduleType: request.type,
      notificationTime: request.notificationTime,
      lineColor: request.color,
      onTapped: () => _showNotificationPickerBottomSheet(request: request),
    );
  }

  ///
  /// 컬러 선택 버튼
  ///
  Widget _buildColorPickerButton() {
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    return ScheduleColorButton(
      selectedColor: selectedColor,
      onColorSelected: () {
        _showColorPickerBottomSheet(selectedColor);
      },
    );
  }

  ///
  /// 메모 입력
  ///
  Widget _buildMemoTextField(ScrollController scrollController) {
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    // 선택된 색상
    final memo = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.memo),
    );

    return ScheduleMemoView(
      lineColor: selectedColor,
      memo: memo,
      onMemoChanged: (memo) {
        updateMemo(ref, memo);
      },
      onExpansionChanged: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent - 50,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
    );
  }

  ///
  /// 할 일 목록 버튼
  ///
  Widget _buildTodoListButton() {
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    // 할 일 목록
    final todoList = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.todoList),
    );

    return ScheduleTodoListButton(
      checkList: todoList,
      selectedColor: selectedColor,
      onTodoListBtnTapped: () {
        _showTodoListBottomSheet(
          todoList: todoList,
          selectedColor: selectedColor,
        );
      },
    );
  }

  ///
  /// 생성 버튼
  ///
  Widget _buildCompletionButton() {
    // 선택된 색상
    final selectedColor = ref.watch(
      CreateScheduleState.requestProvider.select((value) => value.color),
    );

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: AppSize.responsiveBottomInset),
      child: AppButton(
        text: '완료',
        backgroundColor: selectedColor,
        onTapped: () {
          FocusScope.of(ref.context).unfocus();
          create(ref);
        },
      ),
    );
  }

  // ================================바텀 시트====================================
  ///
  /// 알림 피커 바텀시트
  ///
  void _showNotificationPickerBottomSheet({required ScheduleRequest request}) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return NotificationPickerBottomSheet(
          request: request,
          onAllDaySelected: (allDayType) {
            context.pop();

            // 직접 설정인 경우
            if (allDayType == AllDayNotificationType.custom) {
              _showSetNotificationBottomSheet();
              return;
            }

            updateAllDayNotificationType(ref, allDayType);
          },
          onTimeSelected: (timeType) {
            context.pop();

            // 직접 설정인 경우
            if (timeType == TimeNotificationType.custom) {
              _showSetNotificationBottomSheet();
              return;
            }

            updateTimeNotificationType(ref, timeType);
          },
        );
      },
    );
  }

  ///
  /// 알림 설정 바텀시트
  ///
  void _showSetNotificationBottomSheet() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SetNotificationTimeBottomSheet(
          onChangeDate: (dateTime) {
            context.pop();
            updateNotificationTime(
              ref,
              dateTime.toStringFormat('yyyy-MM-dd HH:mm:ss'),
            );
          },
        );
      },
    );
  }

  ///
  /// 컬러 피커 바텀시트
  ///
  void _showColorPickerBottomSheet(Color pinColor) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ColorPickerBottomSheet(
          selectedColor: pinColor,
          onColorSelected: (color) {
            context.pop();
            updateColor(ref, color);
          },
        );
      },
    );
  }

  ///
  /// 할 일 목록 바텀시트
  ///
  void _showTodoListBottomSheet({
    required List<Todo> todoList,
    required Color selectedColor,
  }) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SetTodoBottomSheet(
          selectedColor: selectedColor,
          todoList: todoList,
          onCompletedBtnTapped: (todoList) {
            context.pop();
            updateTodoList(ref, todoList);
          },
        );
      },
    );
  }
}
