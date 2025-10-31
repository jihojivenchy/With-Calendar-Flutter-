import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/holiday_list_view.dart';
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
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: focusedDate.toKoreanMonthDay(),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textColor: _getDateTextColor(focusedDate, context),
              ),
              HolidayListView(holidayList: holidayList),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  text: lunarDate?.solarDate.toKoreanMonthDay() ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textColor: _getDateTextColor(
                    lunarDate?.solarDate ?? focusedDate,
                    context,
                  ),
                ),
                const SizedBox(width: 10),
                AppText(
                  text: '음력 ${lunarDate?.dateString ?? ''}',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.gray400,
                ),
                const SizedBox(width: 12),
                HolidayListView(holidayList: holidayList),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 날짜에 따른 텍스트 색상 결정
  ///
  Color _getDateTextColor(DateTime date, BuildContext context) {
    // 1. 공휴일이 가장 우선 (공휴일이 있으면 sundayRed)
    if (holidayList.isNotEmpty) {
      return AppColors.sundayRed;
    }

    // 2. 일요일인 경우 sundayRed
    if (date.weekday == DateTime.sunday) {
      return AppColors.sundayRed;
    }

    // 3. 토요일인 경우 saturdayBlue
    if (date.weekday == DateTime.saturday) {
      return AppColors.saturdayBlue;
    }

    // 4. 나머지는 모두 텍스트 컬러
    return context.textColor;
  }
}
