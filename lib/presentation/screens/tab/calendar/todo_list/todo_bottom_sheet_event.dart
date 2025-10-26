import 'dart:developer';

import 'package:with_calendar/data/services/todo/todo_service.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';

mixin class TodoEvent {
  final TodoService _todoService = TodoService();

  ///
  /// 할 일 수정
  ///
  Future<void> updateTodo({
    required String scheduleID,
    required String todoID,
    required bool isDone,
  }) async {
    try {
      await _todoService.updateTodo(
        scheduleID: scheduleID,
        todoID: todoID,
        isDone: isDone,
      );
    } catch (e) {
      log('할 일 수정 실패: ${e.toString()}');
      SnackBarService.showSnackBar('수정 중 오류가 발생했습니다.');
    }
  }

  ///
  /// 할 일 삭제
  ///
  Future<void> deleteTodo({
    required String scheduleID,
    required String todoID,
  }) async {
    try {
      await _todoService.deleteTodo(scheduleID: scheduleID, todoID: todoID);
    } catch (e) {
      log('할 일 삭제 실패: ${e.toString()}');
      SnackBarService.showSnackBar('삭제 중 오류가 발생했습니다.');
    }
  }
}
