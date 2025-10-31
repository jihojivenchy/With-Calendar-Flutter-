import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

/// 일정의 시간 등을 표시해주는 리스트 뷰
class ScheduleTimeListView extends StatelessWidget {
  const ScheduleTimeListView({
    super.key,
    required this.schedule,
    this.listHeight = 30,
    this.fontSize = 12,
    this.paddingVertical = 6,
  });

  final Schedule schedule;

  final double listHeight;
  final double fontSize;
  final double paddingVertical;

  @override
  Widget build(BuildContext context) {
    final List<String> detailTexts = [];

    // 장기 일정
    if (schedule.duration == ScheduleDuration.long) {
      detailTexts.add(schedule.periodText);

      // 장기 일정 진행 표시
      final String progressText = _buildLongScheduleProgressText();
      if (progressText.isNotEmpty) {
        detailTexts.add(progressText);
      }

      // 시간 일정
    } else if (schedule.type == ScheduleType.time) {
      final String timeRange =
          '${schedule.startDate.toKoreanMeridiemTime()} ~ ${schedule.endDate.toKoreanMeridiemTime()}';
      detailTexts.add(timeRange);
      detailTexts.add(_buildShortScheduleProgressText());

      // 하루종일 일정
    } else {
      final String dateText = schedule.startDate.toKoreanSimpleDateFormat();
      detailTexts.add(dateText);
      detailTexts.add(_buildShortScheduleProgressText());
    }

    // 상세 텍스트가 없으면 빈 위젯
    if (detailTexts.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = context.dynamicColor(schedule.color);

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final text = detailTexts[index];
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: paddingVertical,
            ),
            decoration: BoxDecoration(
              color: schedule.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: AppText(
                text: text,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                textColor: textColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemCount: detailTexts.length,
      ),
    );
  }

  ///
  /// 장기 일정 진행 표시
  ///
  String _buildLongScheduleProgressText() {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    final DateTime startDateOnly = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
    );
    final DateTime endDateOnly = DateTime(
      schedule.endDate.year,
      schedule.endDate.month,
      schedule.endDate.day,
    );

    if (todayDateOnly.isBefore(startDateOnly)) {
      final int daysUntil = startDateOnly.difference(todayDateOnly).inDays;
      return 'D - $daysUntil';
    }

    if (todayDateOnly.isAfter(endDateOnly)) {
      final int totalDays = endDateOnly.difference(startDateOnly).inDays + 1;
      return '$totalDays일 일정';
    }

    final int progressDays = todayDateOnly.difference(startDateOnly).inDays + 1;
    return '$progressDays일차';
  }

  ///
  /// 단기 일정 진행 표시
  ///
  String _buildShortScheduleProgressText() {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    final DateTime startDateOnly = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
    );

    // D-Day
    if (todayDateOnly.isBefore(startDateOnly)) {
      final int daysUntil = startDateOnly.difference(todayDateOnly).inDays;
      return 'D - $daysUntil';
    }

    return schedule.type == ScheduleType.allDay ? '하루' : '시간';
  }
}
