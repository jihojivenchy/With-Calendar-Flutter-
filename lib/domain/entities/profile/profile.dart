import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';

class Profile {
  final String id;
  final String name;
  final String email;
  final String code;
  final String createdAt;
  final List<CalendarInformation> calendarList;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.code,
    required this.calendarList,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['createdAt'],
      code: json['userCode'],
      calendarList: (json['calendarList'] as List? ?? [])
          .map(
            (dynamic e) => CalendarInformation.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'userCode': code};
  }

  Profile copyWith({String? name, String? code}) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email,
      createdAt: createdAt,
      code: code ?? this.code,
      calendarList: calendarList,
    );
  }
}
