import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/todo/todo_service.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';

abstract class TodoState {
  /// 할 일 리스트 스트림
  static final todoListProvider =
      StreamProvider.autoDispose.family<List<Todo>, String>((ref, scheduleID) {
    final TodoService todoService = TodoService();
    return todoService.fetchTodoStreamList(scheduleID);
  });
}
