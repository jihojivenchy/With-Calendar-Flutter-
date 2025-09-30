import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({super.key, required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A8F8F8F),
            offset: Offset(0, 0),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: schedule.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(
                      text: schedule.title,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.gray600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 장기 일정인 경우
                    if (schedule.duration == ScheduleDuration.long) ...[
                      const SizedBox(width: 10),
                      AppText(
                        text: schedule.periodText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.gray500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (schedule.type == ScheduleType.time) ...[
                      // 시간 타입인 경우
                      const SizedBox(width: 10),
                      AppText(
                        text: schedule.startDate.toStringFormat('HH:mm'),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.gray500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                if (schedule.memo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    text: schedule.memo,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
