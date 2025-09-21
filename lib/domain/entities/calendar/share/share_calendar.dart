import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';

/// 공유 달력 정보
class ShareCalendar {
  final String id;
  final String title;
  final List<CalendarParticipant> participantList;
  final String createdAt;

  const ShareCalendar({
    required this.id,
    required this.title,
    required this.participantList,
    required this.createdAt,
  });

  factory ShareCalendar.fromJson(Map<String, dynamic> json) {
    return ShareCalendar(
      id: json['id'],
      title: json['title'],
      participantList: (json['participantList'] as List? ?? [])
          .map((participant) => CalendarParticipant.fromJson(participant))
          .toList(),
      createdAt: json['createdAt'],
    );
  }
}
