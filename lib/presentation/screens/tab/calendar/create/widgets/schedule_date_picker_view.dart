import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:with_calendar/domain/entities/schedule/app_date_time.dart';
import 'package:with_calendar/domain/entities/schedule/request/create_schedule_request.dart';
import 'package:with_calendar/domain/entities/schedule/request/schedule_type.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/view/app_date_time_picker_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

///
/// 일정 날짜 선택 뷰
///
class ScheduleDatePickerView extends StatelessWidget {
  const ScheduleDatePickerView({
    super.key,
    required this.title,
    required this.selectedDate,
    required this.scheduleType,
    this.startDate,
    this.lineColor = AppColors.primary,
    required this.onChangeDate,
  });

  final String title;
  final ScheduleType scheduleType;
  final DateTime selectedDate;
  final DateTime? startDate; // 시작일을 기반으로 더 이전으로 못가게 하기 위해 종료일 전달
  final Color lineColor;
  final void Function(DateTime dateTime) onChangeDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(bottom: BorderSide(color: lineColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        backgroundColor: context.surface,
        title: Row(
          children: [
            Icon(Icons.date_range, color: lineColor, size: 20),
            const SizedBox(width: 15),
            AppText(
              text: title,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: lineColor,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: AppText(
                text: scheduleType == ScheduleType.allDay
                    ? selectedDate.toKoreanSimpleDateFormat()
                    : selectedDate.toKoreanFullDateTimeFormat(),
                textAlign: TextAlign.end,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: lineColor,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        trailing: const SizedBox.shrink(),
        showTrailingIcon: false,
        children: [_buildDatePicker()],
      ),
    );
  }

  ///
  /// 날짜 선택 버튼
  ///
  Widget _buildDatePicker() {
    final pickerMode = scheduleType == ScheduleType.allDay
        ? CupertinoDatePickerMode.date
        : CupertinoDatePickerMode.dateAndTime;

    return SizedBox(
      height: 160,
      child: CupertinoDatePicker(
        key: ValueKey(pickerMode),
        mode: pickerMode,
        initialDateTime: selectedDate,
        minimumDate: startDate,
        maximumDate: DateTime(2050, 12, 31),
        onDateTimeChanged: (dateTime) {
          onChangeDate(dateTime);
        },
      ),
    );
  }
}
