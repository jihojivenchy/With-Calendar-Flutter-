import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

///
/// 일정 색상 선택 버튼
///
class ScheduleColorButton extends StatelessWidget {
  const ScheduleColorButton({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final VoidCallback onColorSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onColorSelected,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          border: Border(bottom: BorderSide(color: selectedColor, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(Icons.color_lens, color: selectedColor, size: 20),
            const SizedBox(width: 15),
            AppText(
              text: '색상',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: selectedColor,
            ),
          ],
        ),
      ),
    );
  }
}
