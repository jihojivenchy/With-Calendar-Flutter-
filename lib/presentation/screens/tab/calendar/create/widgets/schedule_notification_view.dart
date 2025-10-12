import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/create_schedule_request.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

///
/// 일정 알림 선택 뷰
///
class ScheduleNotificationView extends StatelessWidget {
  const ScheduleNotificationView({
    super.key,
    required this.scheduleType,
    required this.notificationTime,
    required this.onTapped,
    required this.lineColor,
  });

  final ScheduleType scheduleType;
  final String notificationTime;
  final VoidCallback onTapped;

  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapped,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          border: Border(bottom: BorderSide(color: lineColor, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(Icons.alarm_add, color: lineColor, size: 20),
            const SizedBox(width: 15),
            AppText(
              text: '알림',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: lineColor,
            ),
            const Spacer(),
            AppText(
              text: notificationTime,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: lineColor,
            ),
          ],
        ),
      ),
    );
  }
}
