import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/calendar/lunar_date.dart';
import 'package:with_calendar/domain/entities/holiday/holiday.dart';
import 'package:with_calendar/domain/entities/schedule/schedule.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/date_pop_up/widgets/date_pop_up_schedule_item.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/create_schedule_button.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/holiday_list_view.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/schedule/schedule_item.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';

/// 날짜 팝업 페이지
class DatePopupPage extends StatelessWidget {
  const DatePopupPage({
    super.key,
    required this.lunarDate,
    required this.holidayList,
    required this.scheduleList,

    required this.onCreateScheduleTapped,
    required this.onDeleteScheduleTapped,
    required this.onTodoListBtnTapped,
    required this.onUpdateScheduleTapped,
  });

  final LunarDate? lunarDate;
  final List<Holiday> holidayList;
  final List<Schedule> scheduleList;

  final VoidCallback onCreateScheduleTapped;
  final Function(Schedule schedule) onDeleteScheduleTapped;
  final Function(Schedule schedule) onTodoListBtnTapped;
  final Function(Schedule schedule) onUpdateScheduleTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: AppText(
                  text: lunarDate?.solarDate.toKoreanSimpleDateFormat() ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textColor: _getDateTextColor(lunarDate?.solarDate, context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              HolidayListView(holidayList: holidayList),
            ],
          ),
          const SizedBox(height: 4),
          AppText(
            text: '음력 ${lunarDate?.dateString ?? ''}',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textColor: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildScheduleList(context)),
          const SizedBox(height: 16),
          _buildCreateScheduleButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  ///
  /// 일정 리스트 생성
  ///
  Widget _buildScheduleList(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: scheduleList.length,
      itemBuilder: (context, index) {
        final schedule = scheduleList[index];
        return DatePopupScheduleItem(
          schedule: schedule,
          onTapped: () {
            onUpdateScheduleTapped(schedule);
          },
          onLongPressed: () {
            onDeleteScheduleTapped(schedule);
          },
          onTodoListBtnTapped: () {
            onTodoListBtnTapped(schedule);
          },
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }

  ///
  /// 일정 생성 버튼
  ///
  Widget _buildCreateScheduleButton(BuildContext context) {
    return BounceTapper(
      highlightColor: Colors.transparent,
      onTap: onCreateScheduleTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.surface4,
          borderRadius: BorderRadius.circular(8),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: context.textColor, size: 20),
            const SizedBox(width: 5),
            AppText(
              text: '새로운 일정',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 날짜에 따른 텍스트 색상 결정
  ///
  Color _getDateTextColor(DateTime? date, BuildContext context) {
    // 1. 공휴일이 가장 우선 (공휴일이 있으면 sundayRed)
    if (holidayList.isNotEmpty) {
      return AppColors.sundayRed;
    }

    if (date == null) {
      return context.textColor;
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
