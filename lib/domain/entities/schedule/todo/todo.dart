/// 할 일 정보
class Todo {
  final String id;
  final String title;
  final bool isDone;

  const Todo({required this.id, required this.title, required this.isDone});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], title: json['title'], isDone: json['isDone']);
  }

  Map<String, dynamic> toJson({required String scheduleID}) {
    return {
      'id': id,
      'scheduleID': scheduleID,
      'title': title,
      'isDone': isDone,
    };
  }
}


// id
// "0852a87b-f218-47b0-a10a-a8e9eebbf8f8"
// (문자열)


// isDone
// false
// (불리언)


// scheduleID
// "feb8d8c8-fa03-487b-a566-29e068c8925b"
// (문자열)


// title
// "5"