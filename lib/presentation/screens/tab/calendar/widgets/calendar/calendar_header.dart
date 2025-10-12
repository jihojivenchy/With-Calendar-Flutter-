import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar/calendar_list_dropdown.dart';
import 'package:with_calendar/utils/extensions/date_extension.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.calendar,
    required this.calendarList,
    required this.focusedMonth,
    required this.screenMode,
    required this.onCalendarTapped,
    required this.onHeaderTap,
    required this.onTodayButtonTapped,
    required this.onMenuButtonTapped,
    required this.onScreenModeButtonTapped,
  });

  /// 현재 캘린더 정보
  final CalendarInformation calendar;

  /// 캘린더 리스트
  final List<CalendarInformation> calendarList;

  /// 포커스 날짜
  final DateTime focusedMonth;

  /// 달력 화면 모드
  final CalendarScreenMode screenMode;

  /// 캘린더 선택
  final Function(CalendarInformation calendar) onCalendarTapped;

  /// 날짜 변경 (헤더 클릭)
  final VoidCallback onHeaderTap;

  /// 오늘 날짜 버튼 클릭
  final VoidCallback onTodayButtonTapped;

  /// 메뉴 버튼 클릭
  final VoidCallback onMenuButtonTapped;

  /// 달력 화면 모드 버튼 클릭
  final Function(CalendarScreenMode mode) onScreenModeButtonTapped;

  @override
  Widget build(BuildContext context) {
    final headerKey = ValueKey<String>(calendar.id);

    return SizedBox(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitleView(headerKey: headerKey),
          Row(
            children: [
              if (!focusedMonth.isToday) ...[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTodayButtonTapped();
                  },
                  child: AppText(
                    text: 'Today',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    textColor: context.textColor,
                  ),
                ),
                const SizedBox(width: 15),
              ],
              IconButton(
                icon: Icon(
                  screenMode == CalendarScreenMode.full
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: context.textColor,
                  size: 25,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onScreenModeButtonTapped(
                    screenMode == CalendarScreenMode.full
                        ? CalendarScreenMode.half
                        : CalendarScreenMode.full,
                  );
                },
              ),
              const SizedBox(width: 12),
              CalendarListDropdown(
                currentCalendarID: calendar.id,
                calendarList: calendarList,
                onCalendarTapped: onCalendarTapped,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(Icons.menu, color: context.textColor, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onMenuButtonTapped();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// 타이틀 뷰
  ///
  Widget _buildTitleView({required ValueKey<String> headerKey}) {
    return GestureDetector(
      onTap: onHeaderTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        // 이전 위젯이 사라지는 동시에 새로운 위젯이 나타나는 애니메이션
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              ...previousChildren, // 이전 위젯
              if (currentChild != null) currentChild, // 새로운 위젯
            ],
          );
        },
        //
        transitionBuilder: (child, animation) {
          final isCurrentCalendar = child.key == headerKey;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // 바운싱 효과
            reverseCurve: Curves.easeInCubic,
          );
          final slideTween = Tween<Offset>(
            begin: isCurrentCalendar
                ? const Offset(0.0, 0.3) // 새로운 위젯 => 아래에서 위로
                : const Offset(0.0, -0.3), // 이전 위젯 => 위로 사라짐
            end: Offset.zero,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: curvedAnimation.drive(slideTween),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: headerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: focusedMonth.toStringFormat(),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              AppText(
                text: calendar.name,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
