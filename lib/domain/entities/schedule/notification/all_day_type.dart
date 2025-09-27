import 'package:intl/intl.dart';

/// 하루종일 일정에 대한 알림 유형
enum AllDayNotificationType {
  today(displayText: '당일'),
  oneDayBefore(displayText: '1일 전'),
  threeDayBefore(displayText: '3일 전'),
  oneWeekBefore(displayText: '1주일 전'),
  custom(displayText: '직접 설정'),
  none(displayText: '알림 없음');

  final String displayText;

  const AllDayNotificationType({
    required this.displayText,
  });

  ///
  /// 알림 시간 계산
  ///
  String calculateNotificationTime(DateTime startDate) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    switch (this) {
      case AllDayNotificationType.today:
        // 당일 00:00:00
        final todayNotification = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          0,
          0,
          0,
        );
        return formatter.format(todayNotification);

      case AllDayNotificationType.oneDayBefore:
        // 1일 전 00:00:00
        final oneDayBefore = startDate.subtract(const Duration(days: 1));
        final notification = DateTime(
          oneDayBefore.year,
          oneDayBefore.month,
          oneDayBefore.day,
          0,
          0,
          0,
        );
        return formatter.format(notification);
      case AllDayNotificationType.threeDayBefore:
        // 3일 전 00:00:00
        final threeDaysBefore = startDate.subtract(const Duration(days: 3));
        final notification = DateTime(
          threeDaysBefore.year,
          threeDaysBefore.month,
          threeDaysBefore.day,
          0,
          0,
          0,
        );
        return formatter.format(notification);

      case AllDayNotificationType.oneWeekBefore:
        // 1주일 전 00:00:00
        final oneWeekBefore = startDate.subtract(const Duration(days: 7));
        final notification = DateTime(
          oneWeekBefore.year,
          oneWeekBefore.month,
          oneWeekBefore.day,
          0,
          0,
          0,
        );
        return formatter.format(notification);

      case AllDayNotificationType.custom:
        return '';
      case AllDayNotificationType.none:
        return '';
    }
  }
}
