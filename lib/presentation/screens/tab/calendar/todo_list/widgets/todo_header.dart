import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_time_list_view.dart';

class TodoHeader extends StatelessWidget {
  const TodoHeader({super.key, required this.schedule, required this.todoList});

  final Schedule schedule;
  final List<Todo> todoList;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: schedule.color.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: schedule.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: schedule.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: schedule.title,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ScheduleTimeListView(schedule: schedule),
          // const SizedBox(height: 18),
          _buildProgressRatio(context),
        ],
      ),
    );
  }

  ///
  /// 진행 비율 표시
  ///
  Widget _buildProgressRatio(BuildContext context) {
    // 전체 갯수가 0이면 빈 위젯 반환
    final totalCount = todoList.length;
    if (totalCount == 0) return const SizedBox.shrink();

    // 완료된 갯수
    final completedCount = todoList.where((todo) => todo.isDone).length;

    // 진행률 계산
    final progress = completedCount / totalCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: '$completedCount / $totalCount 완료',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            AppText(
              text: '${(progress * 100).round()}%',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, animatedValue, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: animatedValue,
                backgroundColor: schedule.color.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(schedule.color),
              ),
            );
          },
        ),
      ],
    );
  }
}
