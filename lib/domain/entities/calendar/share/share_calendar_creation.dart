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

  Map<String, dynamic> toJson({
    required String ownerID,
    required String calendarID,
    required String createdAt,
  }) {
    return {
      'id': calendarID,
      'ownerID': ownerID,
      'title': title,
      'participantList': participantList
          .map((participant) => participant.toJson())
          .toList(),
      'createdAt': createdAt,
    };
  }
}
