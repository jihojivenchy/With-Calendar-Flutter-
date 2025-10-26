import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/todo_bottom_sheet_event.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/todo_bottom_sheet_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/widgets/todo_header.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/todo_list/widgets/todo_item.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class TodoBottomSheet extends ConsumerStatefulWidget {
  final Schedule schedule;

  const TodoBottomSheet({super.key, required this.schedule});

  @override
  ConsumerState<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends ConsumerState<TodoBottomSheet>
    with TodoEvent {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
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
          _buildContentView(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  ///
  /// 컨텐츠 뷰
  ///
  Widget _buildContentView() {
    final AsyncValue<List<Todo>> todoListAsync = ref.watch(
      TodoState.todoListProvider(widget.schedule.id),
    );

    return todoListAsync.when(
      data: (todoList) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TodoHeader(schedule: widget.schedule, todoList: todoList),
            const SizedBox(height: 30),
            if (todoList.isNotEmpty) ...[
              _buildTodoListView(todoList),
            ] else ...[
              _buildEmptyView(context),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ErrorView(title: '조회 중 오류가 발생했습니다.'),
        );
      },
    );
  }

  ///
  /// 할 일 목록 뷰
  ///
  Widget _buildTodoListView(List<Todo> todoList) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          final todo = todoList[index];

          return TodoItem(
            todo: todo,
            selectedColor: widget.schedule.color,
            onDoneTapped: () {
              updateTodo(
                scheduleID: widget.schedule.id,
                todoID: todo.id,
                isDone: !todo.isDone,
              );
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }

  ///
  /// 빈 뷰
  ///
  Widget _buildEmptyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rtl, size: 30, color: context.textColor),
          const SizedBox(height: 12),
          AppText(
            text: '아직 등록된 할 일이 없어요',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          AppText(
            text: '이 일정에 필요한 할 일을 추가해 보세요.',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textColor: context.textColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}