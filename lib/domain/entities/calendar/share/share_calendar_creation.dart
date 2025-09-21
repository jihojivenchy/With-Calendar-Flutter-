import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';

class ShareCalendarCreation {
  final String title;
  final List<CalendarParticipant> participantList;

  const ShareCalendarCreation({
    required this.title,
    required this.participantList,
  });

  ShareCalendarCreation copyWith({
    String? title,
    List<CalendarParticipant>? participantList,
  }) {
    return ShareCalendarCreation(
      title: title ?? this.title,
      participantList: participantList ?? this.participantList,
    );
  }

  Map<String, dynamic> toJson(String id, String createdAt) {
    return {
      'id': id,
      'title': title,
      'participantList': participantList.map((participant) => participant.toJson()).toList(),
    };
  }

  // 'id': calendarID,
  //     'title': creation.title,
  //     'participantList': creation.participantList
  //         .map((participant) => participant.toJson())
  //         .toList(),
  //     'createdAt': createdAt,
}
