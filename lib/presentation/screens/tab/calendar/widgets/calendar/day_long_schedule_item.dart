import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

/// 장기 일정 아이템
class LongScheduleItem extends StatelessWidget {
  const LongScheduleItem({
    super.key,
    required this.schedule,
    required this.maxWidth,
    required this.itemWidth,
  });

  final Schedule schedule;
  final double maxWidth;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: _buildItem(context),
    );
  }

  ///
  /// 주 상태에 따른 아이템 생성
  ///
  Widget _buildItem(BuildContext context) {
    switch (schedule.weekSegmentState) {
      case WeekCellState.start:
        return IntrinsicHeight(
          child: OverflowBox(
            maxWidth: maxWidth,
            alignment: Alignment.centerLeft,
            child: Container(
              width: itemWidth * schedule.weekStartVisibleDayCount,
              height: 18,
              decoration: BoxDecoration(
                color: schedule.color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: AppText(
                text: schedule.title,
                textAlign: TextAlign.center,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                textColor: context.dynamicColor(schedule.color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      case WeekCellState.content:
        return SizedBox(width: itemWidth, height: 18);
      case WeekCellState.spacer:
        return SizedBox(width: itemWidth, height: 18);
    }
  }
}
