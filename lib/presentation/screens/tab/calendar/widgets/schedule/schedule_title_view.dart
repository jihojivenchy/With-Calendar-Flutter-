import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

class ScheduleTitleView extends StatelessWidget {
  const ScheduleTitleView({
    super.key,
    required this.focusedDate,
    required this.lunarDate,
    required this.holidayList,
  });

  final DateTime focusedDate;
  final LunarDate? lunarDate;
  final List<Holiday> holidayList;

  @override
  Widget build(BuildContext context) {
    if (lunarDate == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHolidayListView(),
              AppText(
                text: focusedDate.toKoreanMonthDay(),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textColor: AppColors.gray600,
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHolidayListView(),
            Row(
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
          ],
        ),
      ),
    );
  }

  ///
  /// 공휴일 리스트 뷰
  ///
  Widget _buildHolidayListView() {
    if (holidayList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 30,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 10),
        itemCount: holidayList.length,
        itemBuilder: (context, index) {
          final holiday = holidayList[index];

          return AppText(
            text: holiday.title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            textColor: const Color(0xFFCC3636),
          );
        },
        separatorBuilder: (context, index) {
          return AppText(
            text: ',  ',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            textColor: const Color(0xFFCC3636),
          );
        },
      ),
    );
  }
}
