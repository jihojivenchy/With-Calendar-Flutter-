import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/display_mode/display_mode.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/menu/display_mode/display_mode_screen.dart';

class DisplayModeItem extends StatelessWidget {
  const DisplayModeItem({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTapped,
  });

  final DisplayMode mode;
  final bool isSelected;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTapped();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCheckIndicator(context, isSelected),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                text: mode.displayText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 체크 버튼
  ///
  Widget _buildCheckIndicator(BuildContext context, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.colord2d5d7,
          width: 1,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        child: isSelected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
