import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color disableTextColor;
  final Color backgroundColor;
  final Color disableBackgroundColor;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final VoidCallback onTapped;
  final int? maxLines;
  final double borderRadius;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final bool isEnabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onTapped,
    this.textColor = Colors.white,
    this.disableTextColor = const Color(0xFF8B8D95),
    this.backgroundColor = AppColors.primary,
    this.disableBackgroundColor = const Color(0xFFDADCDF),
    this.fontFamily = 'Pretendard',
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.borderRadius = 8,
    this.width = double.infinity,
    this.height = 50,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 16,
    this.border,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isEnabled) {
          HapticFeedback.lightImpact();
          onTapped();
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isEnabled ? backgroundColor : disableBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Center(
          child: AppText(
            text: text,
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
            textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }
}
