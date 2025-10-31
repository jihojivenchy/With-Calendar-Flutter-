import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class HolidayListView extends StatelessWidget {
  const HolidayListView({super.key, required this.holidayList});

  final List<Holiday> holidayList;

  @override
  Widget build(BuildContext context) {
    if (holidayList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 19,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: holidayList.length,
          itemBuilder: (context, index) {
            final holiday = holidayList[index];

            return AppText(
              text: holiday.title,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xFFCC3636),
            );
          },
          separatorBuilder: (context, index) {
            return AppText(
              text: ',  ',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xFFCC3636),
            );
          },
        ),
      ),
    );
  }
}
