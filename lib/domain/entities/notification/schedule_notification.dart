/// 예약된 알림 정보
class ScheduledNotification {
  final int id;
  final String title;
  final String body;

  final ScheduleNotificationPayload payload;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

class ScheduleNotificationPayload { 
  final String scheduleID; // 알림과 연결된 일정 ID
  final DateTime scheduledDate; // 예약된 알림 시간
  final DateTime notificationTime; // 예약된 알림 시간

  const ScheduleNotificationPayload({
    required this.scheduleID,
    required this.scheduledDate,
    required this.notificationTime,
  });

  factory ScheduleNotificationPayload.fromJson(Map<String, dynamic> json) {
    return ScheduleNotificationPayload(
      scheduleID: json['scheduleID'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      notificationTime: DateTime.parse(json['notificationTime']),
    );
  }
}
