import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/todo/set_todo_item.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class SetTodoBottomSheet extends StatefulWidget {
  final Color selectedColor;
  final List<Todo> todoList;
  final Function(List<Todo>) onCompletedBtnTapped;

  const SetTodoBottomSheet({
    super.key,
    required this.selectedColor,
    required this.todoList,
    required this.onCompletedBtnTapped,
  });

  @override
  State<SetTodoBottomSheet> createState() => _SetTodoBottomSheetState();
}

class _SetTodoBottomSheetState extends State<SetTodoBottomSheet> {
  final List<TodoInput> _todoInputList = [];

  @override
  void initState() {
    super.initState();
    _todoInputList.addAll(
      widget.todoList.map((todo) => TodoInput.fromTodo(todo)),
    );

    if (_todoInputList.isEmpty) {
      _add(0);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface3,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF767676),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  _buildTitle(),
                  const SizedBox(height: 16),

                  // 할 일 목록
                  _buildTodoList(),

                  // 새 할 일 추가 버튼
                  _buildAddTodoButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          AppButton(
            text: '완료',
            backgroundColor: widget.selectedColor,
            onTapped: _onCompleteTapped,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  ///
  /// 타이틀
  ///
  Widget _buildTitle() {
    final todoCount = _todoInputList.length;
    final doneCount = _todoInputList
        .where((todoInput) => todoInput.isDone)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          text: '$doneCount / $todoCount 완료',
          textAlign: TextAlign.center,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  ///
  /// 할 일 목록
  ///
  Widget _buildTodoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todoInputList.length,
      itemBuilder: (context, index) {
        final todoInput = _todoInputList[index];
        return SetTodoItem(
          key: ValueKey(todoInput.id),
          todoInput: todoInput,
          selectedColor: widget.selectedColor,
          onSubmitted: (text) => _add(index, isFirst: false),
          onDoneTapped: () {
            _toggleTodo(index, todoInput);
          },
          onRemoveTapped: () => _removeTodoAt(index),
        );
      },
    );
  }

  ///
  /// 새 할 일 추가 버튼
  ///
  Widget _buildAddTodoButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _add(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.gray400, size: 20),
            const SizedBox(width: 10),
            AppText(
              text: '추가',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 새 할 일 추가
  ///
  void _add(int index, {bool isFirst = true}) {
    // 새로운 할 일 추가
    if (isFirst || index == _todoInputList.length - 1) {
      final newTodo = TodoInput.empty;
      setState(() {
        _todoInputList.add(newTodo);
      });

      // 새로운 할 일 포커스 이동
      newTodo.focusNode.requestFocus();
    } else {
      // 다음 할 일 포커스 이동
      _todoInputList[index + 1].focusNode.requestFocus();
    }
  }

  ///
  /// 할 일 완료 토글
  ///
  void _toggleTodo(int index, TodoInput todoInput) {
    HapticFeedback.selectionClick();
    setState(() {
      _todoInputList[index] = todoInput.copyWith(isDone: !todoInput.isDone);
    });
  }

  ///
  /// 할 일 삭제
  ///
  void _removeTodoAt(int index) {
    if (index < 1 || index >= _todoInputList.length) {
      return;
    }

    setState(() {
      _todoInputList.removeAt(index);
    });

    // 할 일 삭제될 경우 이전 할 일 포커스 이동
    if (index - 1 >= 0) {
      _todoInputList[index - 1].focusNode.requestFocus();
    }
  }

  ///
  /// 완료 버튼 클릭
  ///
  void _onCompleteTapped() {
    final List<Todo> result = _todoInputList
        .map(
          (item) => Todo(
            id: item.id,
            title: item.controller.text.trim(),
            isDone: item.isDone,
          ),
        )
        .where((todo) => todo.title.isNotEmpty)
        .toList();

    widget.onCompletedBtnTapped(result);
  }
}

///
/// 할 일 입력 모델
///
class TodoInput {
  TodoInput({
    required this.id,
    required this.controller,
    required this.focusNode,
    required this.isDone,
  });

  factory TodoInput.fromTodo(Todo todo) => TodoInput(
    id: todo.id,
    controller: TextEditingController(text: todo.title),
    focusNode: FocusNode(),
    isDone: todo.isDone,
  );

  final String id;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDone;

  TodoInput copyWith({bool? isDone}) {
    return TodoInput(
      id: id,
      controller: controller,
      focusNode: focusNode,
      isDone: isDone ?? this.isDone,
    );
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  static TodoInput get empty => TodoInput(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    controller: TextEditingController(),
    focusNode: FocusNode(),
    isDone: false,
  );
}
