import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_time_list_view.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onTapped,
    required this.onLongPressed,
    required this.onTodoListBtnTapped,
  });

  final Schedule schedule;
  final VoidCallback onTapped;
  final VoidCallback onLongPressed;
  final VoidCallback onTodoListBtnTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          color: context.isDarkMode
              ? context.surface
              : schedule.color.withValues(alpha: 0.1),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),

                // 일정 시간 표시
                ScheduleTimeListView(schedule: schedule),

                // 할 일 버튼
                _buildTodoButton(context),
              ],
            ),

            // 일정 메모 표시
            if (schedule.memo.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildMemoBlock(context),
            ],
          ],
        ),
      ),
    );
  }

  ///
  /// 일정 메모 표시
  ///
  Widget _buildMemoBlock(BuildContext context) {
    final textColor = context.dynamicColor(schedule.color);

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
        textColor: textColor,
      ),
    );
  }

  ///
  /// 할 일이 존재하면 아이콘 버튼 추가
  ///
  Widget _buildTodoButton(BuildContext context) {
    if (!schedule.isTodoExist) return const SizedBox.shrink();

    final iconColor = context.dynamicColor(schedule.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTodoListBtnTapped();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: schedule.color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(Icons.checklist, color: iconColor, size: 20),
      ),
    );
  }
}
