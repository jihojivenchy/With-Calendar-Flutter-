import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/share/calendar_participant.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

class ParticipantItem extends StatelessWidget {
  const ParticipantItem({
    super.key,
    required this.participant,
    required this.onRemoveBtnTapped,
  });

  final CalendarParticipant participant;
  final VoidCallback onRemoveBtnTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.transparent, width: 1),
      ),
      child: Row(
        children: [
          if (participant.isOwner) ...[
            const Icon(
              Icons.workspace_premium_rounded,
              size: 25,
              color: AppColors.primary,
            ),
          ] else ...[
            const Icon(
              Icons.account_circle_rounded,
              size: 25,
              color: AppColors.colord2d5d7,
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              text: participant.userName,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: Colors.black87,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // 오너가 아닌 경우 추방 버튼
          if (!participant.isOwner) ...[
            IconButton(
              icon: const Icon(
                Icons.cancel_outlined,
                size: 20,
                color: AppColors.color727577,
              ),
              onPressed: onRemoveBtnTapped,
            ),
          ],
        ],
      ),
    );
  }
}
