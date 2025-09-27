import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_list_dropdown.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.calendar,
    required this.calendarList,
    required this.focusedMonth,
    required this.onCalendarTapped,
    required this.onHeaderTap,
    required this.onTodayButtonTapped,
    required this.onMenuButtonTapped,
  });

  /// 현재 캘린더 정보
  final CalendarInformation calendar;

  /// 캘린더 리스트
  final List<CalendarInformation> calendarList;

  /// 포커스 날짜
  final DateTime focusedMonth;

  /// 캘린더 선택
  final Function(CalendarInformation calendar) onCalendarTapped;

  /// 날짜 변경 (헤더 클릭)
  final VoidCallback onHeaderTap;

  /// 오늘 날짜 버튼 클릭
  final VoidCallback onTodayButtonTapped;

  /// 메뉴 버튼 클릭
  final VoidCallback onMenuButtonTapped;

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
                text: calendar.name,
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
                child: AppText(
                  text: 'Today',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  textColor: const Color(0xFF000000),
                ),
              ),
              const SizedBox(width: 40),
            ],
            CalendarListDropdown(
              currentCalendarID: calendar.id,
              calendarList: calendarList,
              onCalendarTapped: onCalendarTapped,
            ),
            const SizedBox(width: 30),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                onMenuButtonTapped();
              },
              child: const SizedBox(
                width: 30,
                height: 40,
                child: Center(
                  child: Icon(Icons.menu, color: Color(0xFF000000), size: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
