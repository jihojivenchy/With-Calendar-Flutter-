import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class DayItem extends StatelessWidget {
  const DayItem({
    super.key,
    required this.day,
    required this.baseRowHeight,
  });

  final Day day;
  final double baseRowHeight;

  @override
  Widget build(BuildContext context) {
    final dayText = '${day.date.day}';

    return Opacity(
      opacity: day.isOutside ? 0.4 : 1,
      child: Container(
        constraints: BoxConstraints(
          minHeight: baseRowHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _buildDayContainerColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AppText(
                  text: dayText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textColor: _getTextColor(),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Color _buildDayContainerColor() {
    /// 오늘 날짜인 경우
    if (day.state == DayCellState.today) {
      return AppColors.primary;
    } else {
      /// 오늘 날짜가 아닌 경우
      return Colors.transparent;
    }
  }

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
}