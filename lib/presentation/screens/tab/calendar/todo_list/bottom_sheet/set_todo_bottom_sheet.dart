import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/backspace_aware_text_field.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/bottom_sheet/set_todo_item.dart';
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
  final GlobalKey<AnimatedListState> _todoListKey =
      GlobalKey<AnimatedListState>();
  final List<TodoInput> _todoInputList = [];

  @override
  void initState() {
    super.initState();
    _todoInputList.addAll(
      widget.todoList.map((todo) => TodoInput.fromTodo(todo)),
    );

    // 바텀시트가 다 올라오는 시간을 감안한 후에 키보드 올라오도록 딜레이 처리
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_todoInputList.isEmpty) {
        _add(0);
      }
    });
  }

  @override
  void dispose() {
    for (final todoInput in _todoInputList) {
      todoInput.dispose();
    }
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
          // 타이틀
          _buildTitle(),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 할 일 목록
                  _buildTodoList(),

                  // 새 할 일 추가 버튼
                  _buildAddTodoButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
    return AnimatedList(
      key: _todoListKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _todoInputList.length,
      itemBuilder: (context, index, animation) {
        final todoInput = _todoInputList[index];

        return _buildAnimatedTodoItem(
          todoInput: todoInput,
          index: index,
          animation: animation,
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
      final insertIndex = _todoInputList.length;

      setState(() {
        _todoInputList.add(newTodo);
      });

      if (_todoListKey.currentState == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _insertAnimationItem(insertIndex);
        });
      } else {
        _insertAnimationItem(insertIndex);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        newTodo.focusNode.requestFocus();
      });
    } else {
      // 다음 할 일 포커스 이동
      _todoInputList[index + 1].focusNode.requestFocus();
    }
  }

  ///
  /// 애니메이션 아이템 삽입
  ///
  void _insertAnimationItem(int insertIndex) {
    _todoListKey.currentState?.insertItem(
      insertIndex,
      duration: const Duration(milliseconds: 300),
    );
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
    if (index >= _todoInputList.length) {
      return;
    }

    final removedTodo = _todoInputList[index];

    setState(() {
      _todoInputList.removeAt(index);
    });

    // 리스트에서 애니메이션 아이템 제거
    _todoListKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedTodoItem(
        todoInput: removedTodo,
        index: index,
        animation: animation,
        isRemovedItem: true,
      ),
      duration: const Duration(milliseconds: 180),
    );

    // 할 일 입력 컨트롤러 해제
    Future.delayed(const Duration(milliseconds: 200), removedTodo.dispose);

    // 할 일 삭제될 경우 이전 할 일 포커스 이동
    if (index - 1 >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (index - 1 < _todoInputList.length) {
          _todoInputList[index - 1].focusNode.requestFocus();
        }
      });
    }
  }

  ///
  /// 애니메이션 아이템
  ///
  Widget _buildAnimatedTodoItem({
    required TodoInput todoInput,
    required int index,
    required Animation<double> animation,
    bool isRemovedItem = false,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);

    return SizeTransition(
      sizeFactor: curvedAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: IgnorePointer(
            ignoring: isRemovedItem,
            child: SetTodoItem(
              key: ValueKey(todoInput.id),
              todoInput: todoInput,
              selectedColor: widget.selectedColor,
              onSubmitted: (text) {
                // 삭제된 할 일인 경우 추가하지 않음
                if (isRemovedItem) return;

                // 다음 할 일 추가
                _add(index, isFirst: false);
              },
              onDoneTapped: () {
                // 삭제된 할 일인 경우 작업하지 않음
                if (isRemovedItem) return;

                // 할 일 완료 토글
                _toggleTodo(index, todoInput);
              },
              onRemoveTapped: () {
                // 삭제된 할 일인 경우 삭제하지 않음
                if (isRemovedItem) return;

                // 할 일 삭제
                _removeTodoAt(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// 완료 버튼 클릭
  ///
  void _onCompleteTapped() {
    final List<Todo> result = _todoInputList
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final todoInput = entry.value;

          // sentinel을 제거한 실제 텍스트
          final title = BackspaceAwareHelper.sanitizeBackspaceAwareText(
            todoInput.controller.text,
          ).trim();

          return Todo(
            id: todoInput.id,
            title: title,
            isDone: todoInput.isDone,
            position: index.toDouble(),
          );
        })
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
    id: Uuid().v4(),
    controller: TextEditingController(),
    focusNode: FocusNode(),
    isDone: false,
  );
}
