import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

///
/// 일정 할 일 버튼
///
class ScheduleTodoListButton extends StatelessWidget {
  const ScheduleTodoListButton({
    super.key,
    required this.checkList,
    required this.selectedColor,
    required this.onTodoListBtnTapped,
  });

  final List<Todo> checkList;
  final Color selectedColor;
  final VoidCallback onTodoListBtnTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTodoListBtnTapped,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          border: Border(bottom: BorderSide(color: selectedColor, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(Icons.task_alt, color: selectedColor, size: 20),
            const SizedBox(width: 15),
            AppText(
              text: '할 일',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: selectedColor,
            ),
            const Spacer(),
            AppText(
              text: _getSummaryText(),
              textAlign: TextAlign.end,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: selectedColor,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 할 일 목록 요약 텍스트
  ///
  String _getSummaryText() {
    final totalCount = checkList.length;

    // 없으면 빈 문자열
    if (totalCount == 0) return '';
    
    // 완료된 할 일 개수
    final completedCount = checkList.where((todo) => todo.isDone).length;
    return '$completedCount / $totalCount 완료';
  }
}
