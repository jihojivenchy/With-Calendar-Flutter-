import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/day_item.dart';

/// 월 별 페이지 뷰
class MonthPageView extends StatelessWidget {
  final List<Day> dayList;
  final List<String> weekList;
  final Function(Day) onLongPressed;

  const MonthPageView({
    super.key,
    required this.dayList,
    required this.weekList,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 총 주차 갯수 (row)
    final rowCount = dayList.length ~/ 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 요일 헤더를 제외한 나머지 영역을 rowCount로 나눈 값이 기본 높이
        final baseRowHeight = (constraints.maxHeight - 35) / rowCount;

        return Table(
          children: [
            /// 요일 목록
            TableRow(
              children: List.generate(weekList.length, (index) {
                final Color textColor = switch (index) {
                  0 => const Color(0xFFCC3636),
                  6 => const Color(0xFF277BC0),
                  _ => const Color(0xFF000000),
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AppText(
                    text: weekList[index],
                    textAlign: TextAlign.center,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    textColor: textColor,
                  ),
                );
              }),
            ),

            /// Day 목록
            ..._buildCalendarDays(
              rowCount: rowCount,
              baseRowHeight: baseRowHeight,
            ),
          ],
        );
      },
    );
  }

  ///
  /// Day 목록
  ///
  List<TableRow> _buildCalendarDays({
    required int rowCount,
    required double baseRowHeight,
  }) {
    return List.generate(
      rowCount,
      (index) => TableRow(
        children: List.generate(7, (id) {
          final dayIndex = index * 7 + id;

          // 인덱스 범위를 넘어설 경우 -> 빈 칸 반환
          if (dayIndex >= dayList.length) {
            return const SizedBox();
          }

          final day = dayList[dayIndex];
          return DayItem(
            day: day,
            baseRowHeight: baseRowHeight,
            onLongPressed: (day) => onLongPressed(day),
          );
        }),
      ),
    );
  }
}
