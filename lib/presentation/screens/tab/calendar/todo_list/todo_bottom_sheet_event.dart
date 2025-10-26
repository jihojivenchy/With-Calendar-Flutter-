import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/todo/todo_service.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/common/services/snack_bar/snack_bar_service.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';

mixin class TodoEvent {
  final TodoService _todoService = TodoService();

  ///
  /// 할 일 수정
  ///
  Future<void> updateTodo({
    required CalendarInformation calendar,
    required String scheduleID,
    required String todoID,
    required bool isDone,
  }) async {
    try {
      await _todoService.updateTodo(
        calendar: calendar,
        scheduleID: scheduleID,
        todoID: todoID,
        isDone: isDone,
      );
    } catch (e) {
      log('할 일 수정 실패: ${e.toString()}');
      SnackBarService.showSnackBar('수정 중 오류가 발생했습니다.');
    }
  }
}
