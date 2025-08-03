import 'package:flutter/material.dart';
import 'package:with_calendar/data/services/calendar/calendar_service.dart';
import 'package:with_calendar/domain/entities/calendar/day.dart';
import 'package:with_calendar/main.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final CalendarService _calendarService = CalendarService(
    startDate: DateTime(2000, 1, 1),
    endDate: DateTime(2050, 12, 31),
    startingDayOfWeek: StartingDayOfWeek.sunday,
  );

  Map<DateTime, List<Day>> _calendarMap = {};
  List<String> _weekList = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      _calendarMap = _calendarService.calculateDayMap();
      _weekList = _calendarService.calculateWeekList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: DefaultAppBar(
        title: '',
        isShowBackButton: false,
        height: 0,
        backgroundColor: Color(0xFFF2F2F7),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CalendarView(
              calendarMap: _calendarMap,
              weekList: _weekList,
              startDate: _calendarService.startDate,
            ),
          ),
        ),
      ),
    );
  }
}
