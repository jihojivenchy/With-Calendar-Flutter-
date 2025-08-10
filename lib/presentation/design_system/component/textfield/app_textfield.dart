import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class AppTextField extends StatelessWidget {
  final String? initialValue;
  final String placeholderText;
  final Color backgroundColor;
  final EdgeInsets padding;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final int? maxLines;
  final int? maxLength;
  final bool isEnabled;
  final TextEditingController? controller;
  final bool autoFocus; // 시작할 때, 포커싱을 할 지 여부
  final Function(String)? onTextChanged;
  final FocusNode? focusNode;
  final TextAlignVertical? textAlignVertical;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final AutovalidateMode? autovalidateMode;
  final Function(bool)? onFocusChanged;

  const AppTextField({
    super.key,
    this.initialValue,
    this.onTextChanged,
    this.padding = const EdgeInsets.only(
      top: 8,
      bottom: 8,
      left: 14,
      right: 14,
    ),
    this.backgroundColor = Colors.white,
    this.placeholderText = '입력해주세요',
    this.borderWidth = 1,
    this.borderRadius = 6,
    this.borderColor = AppColors.colord2d5d7,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.controller,
    this.isEnabled = true,
    this.autoFocus = false,
    this.focusNode,
    this.textAlignVertical = TextAlignVertical.top,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.autovalidateMode,
    this.onFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChanged,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: isEnabled,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        expands: maxLines == null, // 텍스트 필드가 여러 줄일 경우 확장된 높이로 설정
        textAlignVertical: textAlignVertical,
        autofocus: autoFocus,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          counterText: '',
          filled: true,
          fillColor: backgroundColor,
          contentPadding: padding,
          hintText: placeholderText,
          hintStyle: const TextStyle(
            color: AppColors.colora1a4a6,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.34,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: AppColors.primary, width: borderWidth),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: AppColors.sundayRed, width: borderWidth),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: AppColors.sundayRed, width: borderWidth),
          ),
        ),
        cursorColor: AppColors.primary,
        cursorHeight: 15,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.34,
        ),
        onChanged: (value) => onTextChanged?.call(value),
        onFieldSubmitted: (value) => onSubmitted?.call(value),
        autovalidateMode: autovalidateMode,
      ),
    );
  }
}
