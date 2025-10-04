import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ScheduleTitleView extends StatelessWidget {
  const ScheduleTitleView({
    super.key,
    required this.focusedDate,
    required this.lunarDate,
  });

  final DateTime focusedDate;
  final LunarDate? lunarDate;

  @override
  Widget build(BuildContext context) {
    if (lunarDate == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppText(
            text: focusedDate.toKoreanMonthDay(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            textColor: AppColors.gray600,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Row(
          children: [
            AppText(
              text: lunarDate?.solarDate.toKoreanMonthDay() ?? '',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              textColor: AppColors.gray600,
            ),
            const SizedBox(width: 10),
            AppText(
              text: '음력 ${lunarDate?.dateString ?? ''}',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              textColor: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
