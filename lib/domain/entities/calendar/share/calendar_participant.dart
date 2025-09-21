/// 공유 달력 참여자
class CalendarParticipant {
  final String userID;
  final String userName;
  final bool isOwner;

  const CalendarParticipant({
    required this.userID,
    required this.userName,
    required this.isOwner,
  });

  factory CalendarParticipant.fromJson(Map<String, dynamic> json) {
    return CalendarParticipant(
      userID: json['id'] as String,
      userName: json['name'] as String,
      isOwner: json['isOwner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': userID, 'name': userName, 'isOwner': isOwner};
  }

  CalendarParticipant copyWith({bool? isOwner}) {
    return CalendarParticipant(
      userID: userID,
      userName: userName,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}
