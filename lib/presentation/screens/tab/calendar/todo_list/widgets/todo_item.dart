import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.selectedColor,
    required this.onDoneTapped,
  });

  final Todo todo;
  final Color selectedColor;
  final VoidCallback onDoneTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onDoneTapped();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCheckbox(context),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              text: todo.title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textColor: todo.isDone ? AppColors.gray400 : context.textColor,
              textDecoration: todo.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: todo.isDone ? selectedColor : Colors.transparent,
        border: Border.all(
          color: todo.isDone ? selectedColor : AppColors.gray200,
          width: 0.7,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: todo.isDone
            ? const Icon(
                Icons.check,
                key: ValueKey('checked'),
                color: Colors.white,
                size: 19,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
