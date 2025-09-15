/// 캘린더 정보
class CalendarInformation {
  final String id;
  final String name;
  final CalendarType type;
  final String createdAt;

  const CalendarInformation({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  factory CalendarInformation.fromJson(Map<String, dynamic> json) {
    return CalendarInformation(
      id: json['id'],
      name: json['name'],
      type: CalendarType.fromString(json['type']),
      createdAt: json['createdAt'],
    );
  }

  ///
  /// Hive 데이터 조회
  ///
  factory CalendarInformation.fromHiveJson(Map<dynamic, dynamic> json) {
    return CalendarInformation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CalendarType.fromString(json['type'] as String),
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.queryValue,
      'createdAt': createdAt,
    };
  }
}

enum CalendarType {
  private(queryValue: 'PRIVATE'), // 개인 캘린더
  shared(queryValue: 'SHARED'); // 공유 캘린더

  final String queryValue;
  const CalendarType({required this.queryValue});

  static CalendarType fromString(String value) {
    return CalendarType.values.firstWhere(
      (type) => type.queryValue == value,
      orElse: () => CalendarType.private,
    );
  }
}
