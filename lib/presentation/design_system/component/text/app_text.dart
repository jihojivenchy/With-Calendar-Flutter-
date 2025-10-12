import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class AppText extends StatelessWidget {
  final TextDecoration? textDecoration;
  final String text;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String fontFamily;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final int? maxLength;
  final double? height;
  final double? width;
  final double? letterSpacing;

  const AppText({
    super.key,
    required this.text,
    this.textColor,
    this.fontFamily = 'Pretendard',
    this.height,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.width,
    this.maxLength,
    this.letterSpacing,
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
        height: height,
        decoration: textDecoration ?? TextDecoration.none,
        decorationColor: textColor,
        fontFamily: fontFamily,
        fontSize: fontSize ?? 14,
        letterSpacing: letterSpacing ?? -0.32,
        fontStyle: fontStyle ?? FontStyle.normal,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: textColor ?? context.textColor,
      ),
    );
  }
}