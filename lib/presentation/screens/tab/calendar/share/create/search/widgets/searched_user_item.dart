import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class SearchedUserItem extends StatelessWidget {
  const SearchedUserItem({
    super.key,
    required this.user,
    required this.onTapped,
  });

  final CalendarParticipant user;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapped,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.transparent, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_circle_rounded,
              size: 25,
              color: AppColors.colord2d5d7,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: user.userName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textColor: Colors.black87,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
