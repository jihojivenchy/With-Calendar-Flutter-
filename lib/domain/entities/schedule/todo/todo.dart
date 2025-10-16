/// 할 일 정보
class Todo {
  final String id;
  final String title;
  final bool isDone;

  const Todo({required this.id, required this.title, required this.isDone});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], title: json['title'], isDone: json['isDone']);
  }
}
