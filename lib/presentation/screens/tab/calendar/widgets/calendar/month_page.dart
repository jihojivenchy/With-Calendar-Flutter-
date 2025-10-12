import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/grid/dynamic_height_grid_view.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/day_item.dart';

/// 월 별 페이지 뷰
class MonthPageView extends StatelessWidget {
  const MonthPageView({
    super.key,
    required this.dayList,
    required this.weekList,
    required this.scheduleMap,
    required this.screenMode,
    required this.holidayMap,
    this.lunarDate,
    required this.onTapped,
    required this.onLongPressed,
  });

  final List<Day> dayList;
  final List<String> weekList;
  final LunarDate? lunarDate;
  final ScheduleMap scheduleMap;
  final CalendarScreenMode screenMode;
  final HolidayMap holidayMap;

  final Function(Day day, bool isDoubleTap) onTapped;
  final Function(Day) onLongPressed;

  @override
  Widget build(BuildContext context) {
    // 총 주차 갯수 (row)
    final rowCount = dayList.length ~/ 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / weekList.length;
        // 요일 헤더를 제외한 나머지 영역을 rowCount로 나눈 값이 기본 높이
        final itemMinHeight = (constraints.maxHeight - 35) / rowCount;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              /// 요일 목록
              SizedBox(
                width: constraints.maxWidth,
                height: 35,
                child: Row(
                  children: [
                    ...List.generate(weekList.length, (index) {
                      final Color textColor = switch (index) {
                        0 => const Color(0xFFCC3636),
                        6 => const Color(0xFF277BC0),
                        _ => context.textColor,
                      };

                      return SizedBox(
                        width: itemWidth,
                        height: 35,
                        child: AppText(
                          text: weekList[index],
                          textAlign: TextAlign.center,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          textColor: textColor,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              /// Day 목록
              DynamicHeightGridView(
                itemCount: dayList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                builder: (context, index) {
                  final day = dayList[index];

                  return DayItem(
                    day: day,
                    lunarDate: lunarDate,
                    scheduleList: _getScheduleList(day.date),
                    holidayList: _getHolidayList(day.date),
                    itemWidth: itemWidth,
                    itemMinHeight: itemMinHeight,
                    screenMode: screenMode,
                    maxWidth: constraints.maxWidth,
                    onTapped: onTapped,
                    onLongPressed: onLongPressed,
                  );
                },
                crossAxisCount: weekList.length,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
            ],
          ),
        );
      },
    );
  }

  ///
  /// 해당 날짜의 일정 리스트 반환
  ///
  List<Schedule> _getScheduleList(DateTime date) {
    return scheduleMap[date] ?? [];
  }

  ///
  /// 해당 날짜의 공휴일 반환
  ///
  List<Holiday> _getHolidayList(DateTime date) {
    return holidayMap[date] ?? [];
  }
}
