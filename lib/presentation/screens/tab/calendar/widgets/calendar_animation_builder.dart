import 'package:flutter/material.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/calendar_screen_state.dart';

class CalendarAnimationBuilder extends StatelessWidget {
  const CalendarAnimationBuilder({
    super.key,
    required this.screenMode,
    required this.child,
  });

  final CalendarScreenMode screenMode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(
        begin: screenMode == CalendarScreenMode.full
            ? AppSize.calendarHeight
            : AppSize.calendarHeight / 2,
        end: screenMode == CalendarScreenMode.full
            ? AppSize.calendarHeight
            : AppSize.calendarHeight / 2,
      ),
      builder: (context, height, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: 1.0,
            curve: Curves.easeInOutBack,
            child: SizedBox(height: height, child: child),
          ),
        );
      },
    );
  }
}
