import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

/// 단기 일정 아이템
class ShortScheduleItem extends StatelessWidget {
  const ShortScheduleItem({super.key, required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
      child: Container(
        height: 18,
        decoration: BoxDecoration(
          color: schedule.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AppText(
          text: schedule.title,
          textAlign: TextAlign.center,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          textColor: context.dynamicColor(schedule.color),
          maxLines: 1,
        ),
      ),
    );
  }
}
