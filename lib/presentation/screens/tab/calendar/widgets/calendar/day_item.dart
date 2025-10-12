import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/day_long_schedule_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/day_short_schedule_item.dart';

class DayItem extends StatelessWidget {
  const DayItem({
    super.key,
    required this.day,
    required this.lunarDate,
    required this.scheduleList,
    required this.holidayList,
    required this.itemWidth,
    required this.itemMinHeight,
    required this.screenMode,
    required this.maxWidth,
    required this.onTapped,
    required this.onLongPressed,
  });

  final Day day;
  final LunarDate? lunarDate;
  final List<Schedule> scheduleList;
  final List<Holiday> holidayList;
  final Function(Day day, bool isDoubleTap) onTapped;
  final Function(Day) onLongPressed;

  final double maxWidth;
  final double itemWidth; // 아이템 너비

  /// 아이템 최소 높이
  final double itemMinHeight;

  /// 화면 모드
  final CalendarScreenMode screenMode;

  @override
  Widget build(BuildContext context) {
    final isSelected = (lunarDate != null && lunarDate!.solarDate == day.date);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped(day, isSelected);
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        onLongPressed(day);
      },
      child: Opacity(
        opacity: day.isOutside ? 0.4 : 1,
        child: Container(
          constraints: BoxConstraints(minHeight: itemMinHeight),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.color727577.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 날짜 텍스트
              SizedBox(height: 20, child: _buildDayText(context, isSelected)),
              const SizedBox(height: 4),
              _buildScheduleSection(context),
              _buildHolidayList(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 일정 섹션 생성
  ///
  Widget _buildScheduleSection(BuildContext context) {
    final hasSchedule = scheduleList.isNotEmpty;

    if (!hasSchedule) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildScheduleBody(context),
    );
  }

  ///
  /// 화면 모드에 따른 일정 리스트
  ///
  Widget _buildScheduleBody(BuildContext context) {
    switch (screenMode) {
      case CalendarScreenMode.full:
        return KeyedSubtree(
          key: const ValueKey<String>('fullMode'),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: scheduleList.length,
            itemBuilder: (context, index) {
              final schedule = scheduleList[index];

              switch (schedule.duration) {
                // 단기 일정
                case ScheduleDuration.short:
                  return ShortScheduleItem(schedule: schedule);

                // 장기 일정
                case ScheduleDuration.long:
                  return LongScheduleItem(
                    schedule: schedule,
                    maxWidth: maxWidth,
                    itemWidth: itemWidth,
                  );
              }
            },
          ),
        );
      case CalendarScreenMode.half:
        return KeyedSubtree(
          key: const ValueKey<String>('halfMode'),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: scheduleList
                .where(
                  (schedule) =>
                      schedule.weekSegmentState != WeekCellState.spacer,
                )
                .map((schedule) {
                  return _buildHalfModeScheduleItem(schedule);
                })
                .toList(),
          ),
        );
    }
  }

  ///
  /// 날짜 텍스트 생성
  ///
  Widget _buildDayText(BuildContext context, bool isSelected) {
    if (isSelected) {
      return Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _buildDayContainerColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AppText(
                text: '${day.date.day}',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                textColor: _getTextColor(context),
              ),
            ),
          ),
          const SizedBox(width: 3),
          AppText(
            text: lunarDate?.dateString ?? '',
            fontSize: 8,
            fontWeight: FontWeight.w400,
            textColor: AppColors.calendarBlue,
          ),
        ],
      );
    } else {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: _buildDayContainerColor(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AppText(
            text: '${day.date.day}',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            textColor: _getTextColor(context),
          ),
        ),
      );
    }
  }

  ///
  /// 날짜 텍스트 테두리 색상
  ///
  Color _buildDayContainerColor() {
    /// 오늘 날짜인 경우
    if (day.state == DayCellState.today) {
      return AppColors.primary.withValues(alpha: 0.8);
    } else {
      /// 오늘 날짜가 아닌 경우
      return Colors.transparent;
    }
  }

  ///
  /// 날짜 텍스트 색상
  ///
  Color _getTextColor(BuildContext context) {
    /// 공휴일인 경우
    if (holidayList.isNotEmpty) {
      return const Color(0xFFCC3636);
    }

    switch (day.state) {
      case DayCellState.basic:
        return context.textColor;
      case DayCellState.sunday:
        return const Color(0xFFCC3636);
      case DayCellState.saturday:
        return const Color(0xFF277BC0);
      case DayCellState.today:
        return Colors.white;
    }
  }

  ///
  /// 하프 모드 일정 아이템
  ///
  Widget _buildHalfModeScheduleItem(Schedule schedule) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: schedule.color, shape: BoxShape.circle),
    );
  }

  ///
  /// 공휴일 리스트
  ///
  Widget _buildHolidayList() {
    if (holidayList.isEmpty || screenMode == CalendarScreenMode.half) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: holidayList.length,
      itemBuilder: (context, index) {
        final holiday = holidayList[index];

        return AppText(
          text: holiday.title,
          textAlign: TextAlign.center,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          textColor: const Color(0xFFCC3636),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
