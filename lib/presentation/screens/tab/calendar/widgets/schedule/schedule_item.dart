import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onTapped,
    required this.onLongPressed,
  });

  final Schedule schedule;
  final VoidCallback onTapped;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    return BounceTapper(
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped();
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        onLongPressed();
      },
      child: Container(
        decoration: BoxDecoration(
          color: schedule.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 25,
                  decoration: BoxDecoration(
                    color: schedule.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    text: schedule.title,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.gray800,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 일정 상세 표시
                _buildDetailWidgets(),
              ],
            ),

            // 일정 메모 표시
            if (schedule.memo.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildMemoBlock(),
            ],
          ],
        ),
      ),
    );
  }

  ///
  /// 일정 상세 표시
  ///
  Widget _buildDetailWidgets() {
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

      // 하루종일 일정
    } else {
      final String dateText = schedule.startDate.toKoreanSimpleDateFormat();
      detailTexts.add(dateText);
    }

    // 상세 텍스트가 없으면 빈 위젯
    if (detailTexts.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = Color.lerp(schedule.color, Colors.black, 0.35);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: detailTexts
            .map(
              (text) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: schedule.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: AppText(
                  text: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: textColor ?? AppColors.gray600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  ///
  /// 일정 메모 표시
  ///
  Widget _buildMemoBlock() {
    final textColor = Color.lerp(schedule.color, Colors.black, 0.35);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: schedule.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: schedule.memo,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        textColor: textColor ?? AppColors.gray600,
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
}
