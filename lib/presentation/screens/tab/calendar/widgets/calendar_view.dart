// import 'package:flutter/material.dart';
// import 'package:with_calendar/domain/entities/calendar/calendar_information.dart';
// import 'package:with_calendar/presentation/design_system/component/bottom_sheet/month_picker_bottom_sheet.dart';
// import 'package:with_calendar/presentation/screens/tab/calendar/widgets/calendar_header.dart';
// import 'package:with_calendar/presentation/screens/tab/calendar/widgets/month_page.dart';
// import 'package:with_calendar/domain/entities/calendar/day.dart';
// import 'package:with_calendar/utils/extensions/date_extension.dart';

// class CalendarView extends StatefulWidget {
//   const CalendarView({
//     super.key,
//     required this.calendar,
//     required this.calendarMap,
//     required this.weekList,
//     required this.startDate,
//     required this.onLongPressed,
//     required this.onMenuButtonTapped,
//     required this.calendarList,
//     required this.onCalendarTapped,
//   });

//   /// 캘린더 정보
//   final CalendarInformation calendar;

//   /// 달력 날짜
//   final Map<DateTime, List<Day>> calendarMap;

//   /// 주차 리스트
//   final List<String> weekList;

//   /// 날짜 롱 프레스 콜백 => 일정 생성 화면
//   final Function(Day) onLongPressed;

//   /// 캘린더 시작 날짜
//   final DateTime startDate;

//   /// 캘린더 메뉴 버튼 클릭
//   final VoidCallback onMenuButtonTapped;

//   /// 캘린더 리스트
//   final List<CalendarInformation> calendarList;

//   /// 캘린더 선택
//   final Function(CalendarInformation calendar) onCalendarTapped;

//   @override
//   State<CalendarView> createState() => _CalendarViewState();
// }

// class _CalendarViewState extends State<CalendarView> {
//   late final PageController _pageController;
//   late final ValueNotifier<DateTime> _focusedDay;

//   @override
//   void initState() {
//     super.initState();
//     // 초기 포커스 날짜 설정
//     final now = DateTime.now();
//     _focusedDay = ValueNotifier(DateTime(now.year, now.month));

//     // 초기 페이지 인덱스 계산
//     final initialPageIndex = _calculatePageIndexFromDate(_focusedDay.value);
//     _pageController = PageController(initialPage: initialPageIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _focusedDay.dispose();
//     super.dispose();
//   }

//   ///
//   /// 날짜를 기반으로 페이지 인덱스 계산
//   ///
//   int _calculatePageIndexFromDate(DateTime targetDate) {
//     final startYear = widget.startDate.year;
//     final startMonth = widget.startDate.month;

//     final yearDiff = targetDate.year - startYear;
//     final monthDiff = targetDate.month - startMonth;

//     return yearDiff * 12 + monthDiff;
//   }

//   /// 인덱스를 기반으로 날짜 계산
//   DateTime _calculateDateFromIndex(int index) {
//     // DateTime 타입은 월 오버플로우를 자동으로 처리해줌
//     return DateTime(widget.startDate.year, widget.startDate.month + index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 10),
//         ValueListenableBuilder<DateTime>(
//           valueListenable: _focusedDay,
//           builder: (context, value, child) {
//             return Padding(
//               padding: const EdgeInsets.only(left: 16, right: 10),
//               child: CalendarHeader(
//                 calendar: widget.calendar,
//                 focusedMonth: value,
//                 onHeaderTap: _showDatePickerBottomSheet,
//                 onTodayButtonTapped: () => _onChangeDate(DateTime.now()),
//                 onMenuButtonTapped: widget.onMenuButtonTapped,
//                 calendarList: widget.calendarList,
//                 onCalendarTapped: widget.onCalendarTapped,
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 15),
//         Expanded(
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: widget.calendarMap.length,
//             itemBuilder: (context, index) {
//               // 포커스 날짜 업데이트
//               final targetDate = _calculateDateFromIndex(index);
//               final dayList = widget.calendarMap[targetDate] ?? [];

//               return MonthPageView(
//                 dayList: dayList,
//                 weekList: widget.weekList,
//                 onLongPressed: widget.onLongPressed,
//               );
//             },
//             onPageChanged: (index) {
//               // 포커스 날짜 업데이트
//               final targetDate = _calculateDateFromIndex(index);
//               _focusedDay.value = targetDate;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   ///
//   /// 캘린더 헤더
//   /// 



//   ///
//   /// 날짜 이동 bottom sheet
//   ///
//   void _showDatePickerBottomSheet() {
//     FocusScope.of(context).unfocus();

//     showModalBottomSheet(
//       context: context,
//       useSafeArea: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         return MonthPickerBottomSheet(
//           focusedDate: _focusedDay.value,
//           onChangeDate: (focusedDate) {
//             Navigator.pop(context);
//             _onChangeDate(focusedDate);
//           },
//         );
//       },
//     );
//   }

//   ///
//   /// 선택한 날짜로 이동
//   ///
//   void _onChangeDate(DateTime focusedDate) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final targetIndex = _calculatePageIndexFromDate(focusedDate);
//       _pageController.jumpToPage(targetIndex);
//     });
//   }
// }
