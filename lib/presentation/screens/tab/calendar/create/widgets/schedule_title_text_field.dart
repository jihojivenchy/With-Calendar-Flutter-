import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class ScheduleTitleTextField extends StatelessWidget {
  const ScheduleTitleTextField({
    super.key,
    this.initialValue,
    required this.onTitleChanged,
    this.lineColor = AppColors.primary,
  });

  final String? initialValue;
  final Function(String) onTitleChanged;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      autofocus: true,
      keyboardType: TextInputType.text,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      onChanged: onTitleChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: EdgeInsets.zero,
        hintText: '제목',
        hintStyle: const TextStyle(
          color: AppColors.colora1a4a6,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.34,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: lineColor, width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lineColor, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lineColor, width: 2),
        ),
      ),
      cursorColor: lineColor,
      cursorHeight: 24,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.34,
      ),
    );
  }
}
