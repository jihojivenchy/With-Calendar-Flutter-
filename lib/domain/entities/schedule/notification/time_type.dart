import 'package:intl/intl.dart';

/// 시간 일정에 대한 알림 유형
enum TimeNotificationType {
  start(displayText: '시작 시간'),
  tenMinutesBefore(displayText: '10분 전'),
  thirtyMinutesBefore(displayText: '30분 전'),
  oneHourBefore(displayText: '1시간 전'),
  custom(displayText: '직접 설정'),
  none(displayText: '알림 없음');

  final String displayText;

  const TimeNotificationType({required this.displayText});

  String calculateNotificationTime(DateTime startDate) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    switch (this) {
      // 시작 시간
      case TimeNotificationType.start:
        return formatter.format(startDate);

      // 10분 전
      case TimeNotificationType.tenMinutesBefore:
        return formatter.format(
          startDate.subtract(const Duration(minutes: 10)),
        );

      // 30분 전
      case TimeNotificationType.thirtyMinutesBefore:
        return formatter.format(
          startDate.subtract(const Duration(minutes: 30)),
        );

      // 1시간 전
      case TimeNotificationType.oneHourBefore:
        return formatter.format(startDate.subtract(const Duration(hours: 1)));

      case TimeNotificationType.custom:
        return '';
      case TimeNotificationType.none:
        return '';
    }
  }
}
