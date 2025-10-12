import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

/// 핀 색상 선택 버튼
class ColorPickerButton extends StatelessWidget {
  const ColorPickerButton({
    super.key,
    required this.isPinned,
    required this.onTapped,
    required this.pinColor,
  });

  final bool isPinned;
  final VoidCallback onTapped; 
  final Color pinColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPinned
              ? pinColor.withValues(alpha: 0.1)
              : context.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPinned ? pinColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: isPinned ? pinColor : context.textColor,
          size: 20,
        ),
      ),
    );
  }
}
