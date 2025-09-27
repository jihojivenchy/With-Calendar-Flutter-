import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';

/// 공유 달력 정보
class ShareCalendar {
  final String id;
  final String ownerID;
  final String title;
  final List<CalendarParticipant> participantList; // 참여자 리스트
  final List<CalendarParticipant> deletedParticipantList; // 삭제된 참여자 리스트
  final String createdAt;
  final bool isOwner;

  const ShareCalendar({
    required this.id,
    required this.ownerID,
    required this.title,
    required this.participantList,
    required this.deletedParticipantList,
    required this.createdAt,
    required this.isOwner,
  });

  factory ShareCalendar.fromJson(Map<String, dynamic> json) {
    return ShareCalendar(
      id: json['id'],
      ownerID: json['ownerID'],
      title: json['title'],
      participantList: (json['participantList'] as List? ?? [])
          .map((participant) => CalendarParticipant.fromJson(participant))
          .toList(),
      deletedParticipantList: [],
      createdAt: json['createdAt'],
      isOwner: false,
    );
  }

  ShareCalendar copyWith({
    String? title,
    List<CalendarParticipant>? participantList,
    List<CalendarParticipant>? deletedParticipantList,
    bool? isOwner,
  }) {
    return ShareCalendar(
      id: id,
      ownerID: ownerID,
      title: title ?? this.title,
      participantList: participantList ?? this.participantList,
      deletedParticipantList:
          deletedParticipantList ?? this.deletedParticipantList,
      createdAt: createdAt,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  ///
  /// 공유 달력 정보를 JSON으로 변환
  ///
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerID': ownerID,
      'title': title,
      'participantList': participantList
          .map((participant) => participant.toJson())
          .toList(),
      'createdAt': createdAt,
    };
  }
}
