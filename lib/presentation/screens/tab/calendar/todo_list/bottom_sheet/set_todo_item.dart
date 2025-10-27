import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/backspace_aware_text_field.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/bottom_sheet/set_todo_bottom_sheet.dart';

class SetTodoItem extends StatelessWidget {
  const SetTodoItem({
    super.key,
    required this.todoInput,
    required this.selectedColor,
    required this.onDoneTapped,
    required this.onRemoveTapped,
    required this.onSubmitted,
  });

  final TodoInput todoInput;
  final Color selectedColor;

  final Function(String) onSubmitted;
  final VoidCallback onDoneTapped;
  final VoidCallback onRemoveTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BounceTapper(
            onTap: onDoneTapped,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: todoInput.isDone ? selectedColor : Colors.transparent,
                border: Border.all(
                  color: todoInput.isDone
                      ? selectedColor
                      : AppColors.colord2d5d7,
                  width: 0.7,
                ),
              ),
              child: todoInput.isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: BackspaceAwareTextField(
              controller: todoInput.controller,
              focusNode: todoInput.focusNode,
              onSubmitted: (text) {
                FocusScope.of(context).requestFocus(todoInput.focusNode);
                onSubmitted(text.trim());
              },
              onBackspaceWhenEmpty: onRemoveTapped,
            ),
          ),

          // Expanded(
          //   child: KeyboardListener(
          //     focusNode: FocusNode(skipTraversal: true),
          //     onKeyEvent: (KeyEvent event) {
          //       if (event is KeyDownEvent &&
          //           event.logicalKey == LogicalKeyboardKey.backspace &&
          //           todoInput.controller.text.isEmpty) {
          //         onRemoveTapped();
          //       }
          //     },
          //     child: AppTextField(
          //       controller: todoInput.controller,
          //       focusNode: todoInput.focusNode,
          //       placeholderText: '할 일을 입력해주세요',
          //       cursorColor: context.textColor,
          //       backgroundColor: Colors.transparent,
          //       borderColor: Colors.transparent,
          //       focusedBorderColor: Colors.transparent,
          //       textInputAction: TextInputAction.next,
          //       onSubmitted: (text) {
          //         FocusScope.of(context).requestFocus(todoInput.focusNode);
          //         onSubmitted(text.trim());
          //       },
          //     ),
          //   ),
          // ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onRemoveTapped,
            child: Container(
              decoration: BoxDecoration(
                color: context.gray200And600,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, color: AppColors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
