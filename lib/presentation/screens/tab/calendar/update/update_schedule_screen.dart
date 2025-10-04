import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/schedule/notification/all_day_type.dart';
import 'package:with_calendar/domain/entities/schedule/notification/time_type.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_create_request.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/notification_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/set_notification_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button_group.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/component/view/app_date_time_picker_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/create_schedule_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_color_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_date_picker_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_memo_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_notification_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/create/widgets/schedule_title_text_field.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/update/update_schedule_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/update/update_schedule_screen_state.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class UpdateScheduleScreen extends ConsumerStatefulWidget {
  const UpdateScheduleScreen({super.key, required this.schedule});

  final ScheduleCreateRequest schedule;

  @override
  ConsumerState<UpdateScheduleScreen> createState() =>
      _UpdateScheduleScreenState();
}

class _UpdateScheduleScreenState extends ConsumerState<UpdateScheduleScreen>
    with UpdateScheduleEvent {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 일정 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize(ref, widget.schedule);
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
      height: AppSize.deviceHeight * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  _buildTitleTextField(ref),

                  // 하루 종일 모드인지 or 시간 모드인지 설정
                  const SizedBox(height: 20),
                  _buildScheduleTypeButton(ref),

                  // 시작일 선택
                  _buildStartDatePickerView(ref),

                  // 종료일 선택
                  _buildEndDatePickerView(ref),

                  // 알림 선택
                  _buildNotificationPickerView(ref),

                  // 컬러 선택
                  _buildColorPickerView(ref),

                  // 메모 입력
                  _buildMemoTextField(ref, scrollController),
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
  Widget _buildTitleTextField(WidgetRef ref) {
    // 선택된 색상
    final selectedColor = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.color),
    );

    return ScheduleTitleTextField(
      initialValue: widget.schedule.title,
      autoFocus: false,
      lineColor: selectedColor,
      onTitleChanged: (title) {
        updateTitle(ref, title);
      },
    );
  }

  ///
  /// 하루 종일 모드인지 or 시간 모드인지
  ///
  Widget _buildScheduleTypeButton(WidgetRef ref) {
    // 선택된 일정 유형
    final selectedType = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.type),
    );
    // 선택된 색상
    final selectedColor = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.color),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: selectedColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: AppButtonGroup(
        options: [
          AppButtonOption(text: '하루 종일', value: ScheduleType.allDay),
          AppButtonOption(text: '시간 설정', value: ScheduleType.time),
        ],
        selectedValue: selectedType,
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
  Widget _buildStartDatePickerView(WidgetRef ref) {
    // 일정 데이터
    final schedule = ref.watch(UpdateScheduleState.scheduleProvider);

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
  Widget _buildEndDatePickerView(WidgetRef ref) {
    // 일정 데이터
    final schedule = ref.watch(UpdateScheduleState.scheduleProvider);

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
  Widget _buildNotificationPickerView(WidgetRef ref) {
    // 일정 데이터
    final schedule = ref.watch(UpdateScheduleState.scheduleProvider);

    return ScheduleNotificationView(
      scheduleType: schedule.type,
      notificationTime: schedule.notificationTime,
      lineColor: schedule.color,
      onTapped: () =>
          _showNotificationPickerBottomSheet(ref, schedule: schedule),
    );
  }

  ///
  /// 컬러 선택 버튼
  ///
  Widget _buildColorPickerView(WidgetRef ref) {
    // 선택된 색상
    final selectedColor = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.color),
    );

    return ScheduleColorView(
      selectedColor: selectedColor,
      onColorSelected: () {
        _showColorPickerBottomSheet(ref, selectedColor);
      },
    );
  }

  ///
  /// 메모 입력
  ///
  Widget _buildMemoTextField(WidgetRef ref, ScrollController scrollController) {
    // 선택된 색상
    final selectedColor = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.color),
    );

    // 메모
    final memo = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.memo),
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
  /// 수정 버튼
  ///
  Widget _buildCompletionButton() {
    // 선택된 색상
    final selectedColor = ref.watch(
      UpdateScheduleState.scheduleProvider.select((value) => value.color),
    );

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: AppSize.responsiveBottomInset),
      child: AppButton(
        text: '수정하기',
        backgroundColor: selectedColor,
        onTapped: () {
          FocusScope.of(ref.context).unfocus();
          update(ref);
        },
      ),
    );
  }

  // ================================바텀 시트====================================
  ///
  /// 알림 피커 바텀시트
  ///
  void _showNotificationPickerBottomSheet(
    WidgetRef ref, {
    required ScheduleCreateRequest schedule,
  }) {
    FocusScope.of(ref.context).unfocus();

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return NotificationPickerBottomSheet(
          schedule: schedule,
          onAllDaySelected: (allDayType) {
            ref.context.pop();

            // 직접 설정인 경우
            if (allDayType == AllDayNotificationType.custom) {
              _showSetNotificationBottomSheet(ref);
              return;
            }

            updateAllDayNotificationType(ref, allDayType);
          },
          onTimeSelected: (timeType) {
            ref.context.pop();

            // 직접 설정인 경우
            if (timeType == TimeNotificationType.custom) {
              _showSetNotificationBottomSheet(ref);
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
  void _showSetNotificationBottomSheet(WidgetRef ref) {
    FocusScope.of(ref.context).unfocus();

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SetNotificationTimeBottomSheet(
          onChangeDate: (dateTime) {
            ref.context.pop();
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
  void _showColorPickerBottomSheet(WidgetRef ref, Color pinColor) {
    FocusScope.of(ref.context).unfocus();

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ColorPickerBottomSheet(
          selectedColor: pinColor,
          onColorSelected: (color) {
            ref.context.pop();
            updateColor(ref, color);
          },
        );
      },
    );
  }
}
