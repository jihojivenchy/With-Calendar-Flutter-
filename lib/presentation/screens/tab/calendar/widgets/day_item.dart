import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class DayItem extends StatelessWidget {
  const DayItem({
    super.key,
    required this.day,
    required this.lunarDate,
    required this.scheduleList,
    required this.baseRowHeight,
    required this.onTapped,
    required this.onLongPressed,
  });

  final Day day;
  final LunarDate? lunarDate;
  final List<Schedule> scheduleList;

  final Function(Day) onTapped;
  final Function(Day) onLongPressed;
  final double baseRowHeight;

  @override
  Widget build(BuildContext context) {
    final isSelected = (lunarDate != null && lunarDate!.solarDate == day.date);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped(day);
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        onLongPressed(day);
      },
      child: Opacity(
        opacity: day.isOutside ? 0.4 : 1,
        child: Container(
          constraints: BoxConstraints(minHeight: baseRowHeight),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.color727577.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 날짜 텍스트
              SizedBox(height: 20, child: _buildDayText(isSelected)),
              const SizedBox(height: 4),

              // 일정 리스트
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scheduleList.length,
                itemBuilder: (context, index) {
                  return _buildScheduleItem(scheduleList[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 날짜 텍스트 생성
  ///
  Widget _buildDayText(bool isSelected) {
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
                textColor: _getTextColor(),
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
            textColor: _getTextColor(),
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
      return AppColors.primary;
    } else {
      /// 오늘 날짜가 아닌 경우
      return Colors.transparent;
    }
  }

  ///
  /// 날짜 텍스트 색상
  ///
  Color _getTextColor() {
    switch (day.state) {
      case DayCellState.basic:
        return const Color(0xFF000000);
      case DayCellState.sunday:
        return const Color(0xFFCC3636);
      case DayCellState.saturday:
        return const Color(0xFF277BC0);
      case DayCellState.holiday:
        return const Color(0xFFCC3636);
      case DayCellState.today:
        return Colors.white;
    }
  }

  ///
  /// 일정 아이템
  ///
  Widget _buildScheduleItem(Schedule schedule) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
      child: Container(
        decoration: BoxDecoration(
          color: schedule.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: AppText(
          text: schedule.title,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          textColor: schedule.color,
          maxLines: 1,
        ),
      ),
    );
  }
}
