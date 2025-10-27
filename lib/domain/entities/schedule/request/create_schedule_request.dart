import 'dart:ui';

import 'package:with_calendar/domain/entities/schedule/request/schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/domain/entities/schedule/todo/todo.dart';

class CreateScheduleRequest extends ScheduleRequest {
  final List<Todo> todoList;

  const CreateScheduleRequest({
    required super.id,
    required super.title,
    required super.type,
    required super.startDate,
    required super.endDate,
    required super.notificationTime,
    required super.memo,
    required super.color,
    required this.todoList,
  });

  CreateScheduleRequest copyWith({
    String? title,
    ScheduleType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? notificationTime,
    String? memo,
    Color? color,
    List<Todo>? todoList,
  }) => CreateScheduleRequest(
    id: id,
    title: title ?? this.title,
    type: type ?? this.type,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    notificationTime: notificationTime ?? this.notificationTime,
    memo: memo ?? this.memo,
    color: color ?? this.color,
    todoList: todoList ?? this.todoList,
  );

  static CreateScheduleRequest initialState = CreateScheduleRequest(
    id: '',
    title: '',
    type: ScheduleType.allDay,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    notificationTime: '',
    memo: '',
    color: const Color(0xFF409060),
    todoList: [],
  );
}

// 제목
// 타입 (하루종일 or 시간)
// 시작 날짜
// 종료 날짜
// 알림 시간 타입 (시간, 분)
// 컬러
// 메모
