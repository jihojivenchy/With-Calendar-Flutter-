import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/schedule/notification/all_day_type.dart';
import 'package:with_calendar/domain/entities/schedule/notification/time_type.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/domain/entities/schedule/schedule_creation.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/constants/image_paths.dart';

/// 알림 설정 바텀 시트
class SetNotificationTimeBottomSheet extends StatefulWidget {
  const SetNotificationTimeBottomSheet({
    super.key,
    required this.onChangeDate,
  });

  final Function(DateTime dateTime) onChangeDate;

  @override
  State<SetNotificationTimeBottomSheet> createState() =>
      _SetNotificationTimeBottomSheetState();
}

class _SetNotificationTimeBottomSheetState
    extends State<SetNotificationTimeBottomSheet> {

  /// 선택된 날짜
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 34,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 250,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _selectedDate,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _selectedDate = dateTime;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          // 완료 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
              text: '완료',
              onTapped: () {
                widget.onChangeDate(_selectedDate);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
