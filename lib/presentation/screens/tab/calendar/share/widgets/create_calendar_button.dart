import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';

class CreateCalendarButton extends StatelessWidget {
  const CreateCalendarButton({super.key, required this.onTapped});

  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      sliver: SliverToBoxAdapter(
        child: BounceTapper(
          highlightColor: Colors.transparent,
          onTap: onTapped,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.surface3,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: context.whiteAndBlack.withValues(alpha: 0.05),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: context.textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    text: '달력 생성',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFB0B3BC),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
