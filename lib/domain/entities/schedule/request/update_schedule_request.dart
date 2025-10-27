import 'dart:ui';

import 'package:with_calendar/domain/entities/schedule/request/schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';

class UpdateScheduleRequest extends ScheduleRequest {
  final bool isTodoExist;
  final List<Todo> existTodoList;
  final List<Todo> newTodoList;

  const UpdateScheduleRequest({
    required super.id,
    required super.title,
    required super.type,
    required super.startDate,
    required super.endDate,
    required super.notificationTime,
    required super.memo,
    required super.color,
    required this.isTodoExist,
    required this.existTodoList,
    required this.newTodoList,
  });

  UpdateScheduleRequest copyWith({
    String? title,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? notificationTime,
    String? memo,
    Color? color,
    bool? isTodoExist,
    List<Todo>? existTodoList,
    List<Todo>? newTodoList,
  }) =>
      UpdateScheduleRequest(
        id: id,
        title: title ?? this.title,
        type: type ?? this.type,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        notificationTime: notificationTime ?? this.notificationTime,
        memo: memo ?? this.memo,
        color: color ?? this.color,
        isTodoExist: isTodoExist ?? this.isTodoExist,
        existTodoList: existTodoList ?? this.existTodoList,
        newTodoList: newTodoList ?? this.newTodoList,
      );

  static UpdateScheduleRequest initialState = UpdateScheduleRequest(
    id: '',
    title: '',
    type: ScheduleType.allDay,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    notificationTime: '',
    memo: '',
    color: const Color(0xFF409060),
    isTodoExist: false,
    existTodoList: [],
    newTodoList: [],
  );
}
