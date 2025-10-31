import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_time_list_view.dart';

class DatePopupScheduleItem extends StatelessWidget {
  const DatePopupScheduleItem({
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
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 색상 바
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: schedule.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),

              // 메인 컨텐츠
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    AppText(
                      text: schedule.title,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    /// 일정 시간 표시 & 할 일 버튼
                    Row(
                      children: [
                        Flexible(
                          child: ScheduleTimeListView(
                            schedule: schedule,
                            listHeight: 24,
                            fontSize: 11,
                            paddingVertical: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTodoButton(context),
                      ],
                    ),

                    // 일정 메모 표시
                    if (schedule.memo.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildMemoBlock(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: schedule.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: schedule.memo,
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: schedule.color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.checklist, color: iconColor, size: 16),
      ),
    );
  }
}
