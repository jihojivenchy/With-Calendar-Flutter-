
/// 예약된 알림 정보
class ScheduledNotification {
  final int id;
  final String title;
  final String body;

  final String scheduleID;  // 알림과 연결된 일정 ID
  final DateTime scheduledDate;  // 예약된 알림 시간
  
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.scheduleID,
  });
}
