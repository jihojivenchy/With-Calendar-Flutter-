import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/domain/entities/memo/memo.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/screens/tab/memo/search/widgets/search_highlight_text.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class SearchedMemoItem extends StatelessWidget {
  const SearchedMemoItem({
    super.key,
    required this.memo,
    required this.keyword,
    required this.onTapped,
    required this.onLongPressed,
  });

  final String keyword;
  final Memo memo;
  final VoidCallback onTapped;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    return BounceTapper(
      onTap: onTapped,
      onLongPress: () {
        HapticFeedback.lightImpact();
        onLongPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: memo.isPinned
              ? Border.all(
                  color: memo.pinColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchHighlightText(
                    text: memo.content,
                    highlightText: keyword,
                    highlightColor: memo.isPinned
                        ? memo.pinColor
                        : AppColors.primary,
                  ),
                ),
                if (memo.isPinned) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: memo.pinColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.push_pin, size: 16, color: memo.pinColor),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              text: memo.createdAt.toAnotherDateFormat('yyyy년 MM월 dd일 HH:mm'),
              textColor: AppColors.color727577,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
