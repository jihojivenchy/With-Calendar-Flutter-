
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.calendarName,
    required this.focusedMonth,
    required this.onHeaderTap,
    required this.onTodayButtonTapped,
  });

  final String calendarName;
  final DateTime focusedMonth;
  final VoidCallback onHeaderTap; 
  final VoidCallback onTodayButtonTapped;

  @override
  Widget build(BuildContext context) {
    final text = focusedMonth.toStringFormat();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onHeaderTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(text: text, fontSize: 18, fontWeight: FontWeight.w700),
              AppText(
                text: calendarName,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (!focusedMonth.isToday) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTodayButtonTapped();
                },
                child: AppText(text: 'Today', fontSize: 11, fontWeight: FontWeight.w700, textColor: const Color(0xFF000000)),
              ),
              const SizedBox(width: 30),
            ],
            GestureDetector(
              onTap: () {
                // 캘린더 전환 로직
              },
              child: const Icon(
                Icons.swap_horiz,
                color: Color(0xFF000000),
                size: 20,
              ),
            ),
            const SizedBox(width: 30),
            GestureDetector(
              onTap: () {
                // 캘린더 전환 로직
              },
              child: const Icon(
                Icons.menu,
                color: Color(0xFF000000),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
