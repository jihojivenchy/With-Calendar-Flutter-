import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
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
  final List<_TodoInput> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _todoItems
        .addAll(widget.todoList.map((todo) => _TodoInput.fromTodo(todo)));

    if (_todoItems.isEmpty) {
      _addNewTodo(requestFocus: false);
    }
  }

  @override
  void dispose() {
    for (final item in _todoItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.65;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface3,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SizedBox(
          height: maxHeight,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: '할 일 목록',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _todoItems.isEmpty
                            ? _EmptyTodoView(
                                onAddPressed: () => _addNewTodo(),
                                accentColor: widget.selectedColor,
                              )
                            : ListView.separated(
                                itemBuilder: (context, index) =>
                                    _buildTodoTile(index),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemCount: _todoItems.length,
                              ),
                      ),
                      const SizedBox(height: 16),
                      _AddTodoButton(
                        onAddPressed: () => _addNewTodo(),
                        accentColor: widget.selectedColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppButton(
                  text: '완료',
                  onTapped: _onCompleteTapped,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoTile(int index) {
    final todoItem = _todoItems[index];
    final bool isCompleted = todoItem.isDone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _toggleTodo(index),
          constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
          padding: EdgeInsets.zero,
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? widget.selectedColor : context.tabIconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextField(
            controller: todoItem.controller,
            focusNode: todoItem.focusNode,
            placeholderText: '할 일을 입력해주세요',
            backgroundColor: context.surface,
            focusedBorderColor: widget.selectedColor,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _handleSubmit(index),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _removeTodoAt(index),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.surface2,
              shape: BoxShape.circle,
              border: Border.all(color: context.textFieldBorderColor),
            ),
            child: Icon(
              Icons.close,
              color: context.tabIconColor,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _addNewTodo({bool requestFocus = true}) {
    HapticFeedback.selectionClick();
    final newItem = _TodoInput(
      id: _generateTodoId(),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      isDone: false,
    );

    setState(() {
      _todoItems.add(newItem);
    });

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(newItem.focusNode);
        }
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todoItems[index].isDone = !_todoItems[index].isDone;
    });
    HapticFeedback.selectionClick();
  }

  void _handleSubmit(int index) {
    _addNewTodo(requestFocus: true);
  }

  void _removeTodoAt(int index) {
    if (index < 0 || index >= _todoItems.length) {
      return;
    }

    final removedItem = _todoItems.removeAt(index);

    setState(() {});

    removedItem.dispose();
    HapticFeedback.lightImpact();

    if (_todoItems.isNotEmpty) {
      final nextIndex = index >= _todoItems.length ? _todoItems.length - 1 : index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && nextIndex >= 0 && nextIndex < _todoItems.length) {
          FocusScope.of(context).requestFocus(_todoItems[nextIndex].focusNode);
        }
      });
    }
  }

  void _onCompleteTapped() {
    final List<Todo> result = _todoItems
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

  String _generateTodoId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}

class _TodoInput {
  _TodoInput({
    required this.id,
    required this.controller,
    required this.focusNode,
    required this.isDone,
  });

  factory _TodoInput.fromTodo(Todo todo) => _TodoInput(
        id: todo.id,
        controller: TextEditingController(text: todo.title),
        focusNode: FocusNode(),
        isDone: todo.isDone,
      );

  final String id;
  final TextEditingController controller;
  final FocusNode focusNode;
  bool isDone;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _AddTodoButton extends StatelessWidget {
  const _AddTodoButton({
    required this.onAddPressed,
    required this.accentColor,
  });

  final VoidCallback onAddPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onAddPressed,
        icon: Icon(Icons.add_circle_outline, color: accentColor, size: 20),
        label: AppText(
          text: '새 할 일 추가',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          textColor: accentColor,
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _EmptyTodoView extends StatelessWidget {
  const _EmptyTodoView({
    required this.onAddPressed,
    required this.accentColor,
  });

  final VoidCallback onAddPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: '등록된 할 일이 없습니다.',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: context.tabIconColor,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onAddPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: AppText(
              text: '새 할 일을 추가해보세요',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              textColor: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
