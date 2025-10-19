import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.information,
    required this.isSelected,
    required this.onTapped,
    required this.onLongPressed,
  });

  final CalendarInformation information;
  final bool isSelected;
  final VoidCallback onTapped;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      onLongPress: onLongPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: information.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: information.createdAt,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.color727577,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
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
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
