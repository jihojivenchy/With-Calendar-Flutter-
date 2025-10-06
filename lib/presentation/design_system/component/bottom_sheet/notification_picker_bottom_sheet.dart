import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/notification/all_day_type.dart';
import 'package:with_calendar/domain/entities/schedule/notification/time_type.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

/// 일정 알림 선택 바텀 시트
class NotificationPickerBottomSheet extends StatefulWidget {
  const NotificationPickerBottomSheet({
    super.key,
    required this.schedule,
    required this.onAllDaySelected,
    required this.onTimeSelected,
  });

  /// 일정
  final CreateScheduleRequest schedule;

  /// 하루 종일 알림 선택 콜백
  final Function(AllDayNotificationType allDayType) onAllDaySelected;

  /// 시간 알림 선택 콜백
  final Function(TimeNotificationType timeType) onTimeSelected;

  @override
  State<NotificationPickerBottomSheet> createState() =>
      _NotificationPickerBottomSheetState();
}

class _NotificationPickerBottomSheetState
    extends State<NotificationPickerBottomSheet> {
  AllDayNotificationType _selectedAllDayType = AllDayNotificationType.none;
  TimeNotificationType _selectedTimeType = TimeNotificationType.none;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 34,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // 각 일정 모드에 따른 알림 리스트
          widget.schedule.type == ScheduleType.allDay
              ? _buildAllDayMenuList()
              : _buildTimeMenuList(),
          const SizedBox(height: 32),

          // 완료 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              text: '완료',
              backgroundColor: widget.schedule.color,
              onTapped: () {
                switch (widget.schedule.type) {
                  case ScheduleType.allDay:
                    widget.onAllDaySelected(_selectedAllDayType);
                    break;
                  case ScheduleType.time:
                    widget.onTimeSelected(_selectedTimeType);
                    break;
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 하루종일 모드 알림 리스트
  Widget _buildAllDayMenuList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: AllDayNotificationType.values.length,
      itemBuilder: (context, index) {
        final menuType = AllDayNotificationType.values[index];
        final isSelected = _selectedAllDayType == menuType;

        return _buildMenuItem(
          title: menuType.displayText,
          isSelected: isSelected,
          onTapped: () {
            setState(() {
              _selectedAllDayType = menuType;
            });
          },
        );
      },
    );
  }

  /// 시간 알림 리스트
  Widget _buildTimeMenuList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: TimeNotificationType.values.length,
      itemBuilder: (context, index) {
        final menuType = TimeNotificationType.values[index];
        final isSelected = _selectedTimeType == menuType;

        return _buildMenuItem(
          title: menuType.displayText,
          isSelected: isSelected,
          onTapped: () {
            setState(() {
              _selectedTimeType = menuType;
            });
          },
        );
      },
    );
  }

  ///
  /// 알림 메뉴 아이템
  ///
  Widget _buildMenuItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTapped,
  }) {
    final color = widget.schedule.color;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped();
      },
      child: Container(
        color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              textColor: AppColors.gray700,
            ),
          ],
        ),
      ),
    );
  }
}
