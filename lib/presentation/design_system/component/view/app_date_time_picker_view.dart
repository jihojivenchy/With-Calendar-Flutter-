import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:with_calendar/domain/entities/schedule/app_date_time.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

enum AppDateTimePickerType {
  date,
  dateTime,
}

///
/// 년도, 월, 일, 시간, 분을 선택할 수 있는 피커
///
class AppDateTimePickerView extends StatefulWidget {
  const AppDateTimePickerView({
    super.key,
    this.type = AppDateTimePickerType.date,
    required this.initialDateTime,
    required this.onChangeDate,
    this.height = 160,
  });

  /// 초기 선택된 날짜
  final AppDateTime initialDateTime;

  /// 선택된 날짜와 시간을 반환
  final void Function(AppDateTime dateTime) onChangeDate;

  /// 피커 높이
  final double height;

  /// 피커 타입
  final AppDateTimePickerType type;

  @override
  State<AppDateTimePickerView> createState() => _AppDateTimePickerViewState();
}

class _AppDateTimePickerViewState extends State<AppDateTimePickerView> {
  /// 날짜 리스트
  late final List<String> _yearList;
  late final List<String> _monthList;
  final List<String> _dayList = [];

  /// 시간 리스트
  late final List<AppDateTimePeriod> _periodList;
  late final List<String> _hourList;
  late final List<String> _minuteList;

  late AppDateTime _selectedDateTime;

  FixedExtentScrollController? _yearPickerController;
  FixedExtentScrollController? _monthPickerController;
  FixedExtentScrollController? _dayPickerController;
  FixedExtentScrollController? _periodPickerController;
  FixedExtentScrollController? _hourPickerController;
  FixedExtentScrollController? _minutePickerController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;

    // 리스트 초기화
    _initializeData();

    // 초기 스크롤 컨트롤러 설정
    _initScrollControllers();
  }

  @override
  void dispose() {
    _yearPickerController?.dispose();
    _monthPickerController?.dispose();
    _dayPickerController?.dispose();
    super.dispose();
  }

  ///
  /// 리스트 초기화
  ///
  void _initializeData() {
    // 2000년부터 2100년까지의 년도 리스트
    _yearList = List.generate(100, (index) => (2000 + index).toString());

    // 월 리스트 생성 (01-12)
    _monthList = List.generate(
      12,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );

    // 해당 월에 맞는 일 리스트 생성
    _updateDaysForSelectedMonthAndYear();

    // 기간 리스트 생성
    _periodList = AppDateTimePeriod.values;

    // 시간 리스트 생성
    _hourList = List.generate(
      12,
      (index) => (index).toString().padLeft(2, '0'),
    );

    // 분 리스트 생성
    _minuteList = List.generate(
      60,
      (index) => (index).toString().padLeft(2, '0'),
    );
  }

  ///
  /// 선택한 연도와 월을 가지고 일수 계산
  ///
  void _updateDaysForSelectedMonthAndYear() {
    // 연도와 월 가져오기
    final year = int.parse(_selectedDateTime.year);
    final month = int.parse(_selectedDateTime.month);

    // 해당 월의 일수 계산
    final daysInMonth = _getDaysInMonth(year, month);

    // 1부터 해당 월의 마지막 날까지의 일 리스트 생성
    _dayList.clear();
    _dayList.addAll(
      List.generate(
        daysInMonth,
        (index) => (index + 1).toString().padLeft(2, '0'),
      ),
    );

    // 선택된 일이 현재 월의 최대 일수를 초과하는 경우 조정
    if (int.parse(_selectedDateTime.day) > daysInMonth) {
      // 일을 최대 일수로 설정
      _selectedDateTime = _selectedDateTime.copyWith(
        day: daysInMonth.toString().padLeft(2, '0'),
      );

      // 컨트롤러가 이미 초기화된 경우에만 점프
      if (_dayPickerController != null) {
        _dayPickerController!.jumpToItem(daysInMonth - 1);
      }
    }
  }

  ///
  /// 해당 월의 일수 계산
  ///
  int _getDaysInMonth(int year, int month) {
    // 각 월의 일수
    const daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // 2월이고 윤년인 경우 29일, 아니면 해당 월의 기본 일수
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }

    return daysInMonth[month];
  }

  ///
  /// 윤년 계산
  ///
  bool _isLeapYear(int year) {
    // 4로 나누어 떨어지고, 100으로 나누어 떨어지지 않거나 400으로 나누어 떨어지는 해
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  ///
  /// 컨트롤러 초기화
  ///
  void _initScrollControllers() {
    // 선택된 값의 인덱스 찾기
    final yearIndex = _yearList.indexOf(_selectedDateTime.year);
    final monthIndex =
        int.parse(_selectedDateTime.month) - 1; // 월은 1부터 시작하므로 -1
    final dayIndex = int.parse(_selectedDateTime.day) - 1; // 일은 1부터 시작하므로 -1

    // 각 피커의 초기 위치를 설정하는 ScrollController
    _yearPickerController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : 0,
    );
    _monthPickerController = FixedExtentScrollController(
      initialItem: monthIndex >= 0 ? monthIndex : 0,
    );
    _dayPickerController = FixedExtentScrollController(
      initialItem: dayIndex >= 0 ? dayIndex : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSize.deviceWidth,
      height: widget.height,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.8),
              Colors.white,
              Colors.white.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: _yearPickerController,
                backgroundColor: Colors.transparent,
                itemExtent: 40,
                diameterRatio: 20,
                squeeze: 1.2,
                selectionOverlay: null,
                onSelectedItemChanged: (index) {
                  setState(() {
                    // 연도 변경
                    _selectedDateTime = _selectedDateTime.copyWith(
                      year: _yearList[index],
                    );

                    // 일 리스트 업데이트
                    _updateDaysForSelectedMonthAndYear();
                  });

                  // 선택된 날짜와 시간 반환
                  widget.onChangeDate(_selectedDateTime);
                },
                children: _yearList
                    .map(
                      (year) =>
                          Center(child: AppText(text: year, fontSize: 20)),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: _monthPickerController,
                backgroundColor: Colors.transparent,
                itemExtent: 40,
                diameterRatio: 20,
                squeeze: 1.2,
                selectionOverlay: null,
                onSelectedItemChanged: (index) {
                  setState(() {
                    // 월 변경
                    _selectedDateTime = _selectedDateTime.copyWith(
                      month: _monthList[index],
                    );

                    // 일 리스트 업데이트
                    _updateDaysForSelectedMonthAndYear();
                  });

                  // 선택된 날짜와 시간 반환
                  widget.onChangeDate(_selectedDateTime);
                },
                children: _monthList.map((month) {
                  return Center(child: AppText(text: month, fontSize: 20));
                }).toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: _dayPickerController,
                backgroundColor: Colors.transparent,
                itemExtent: 40,
                diameterRatio: 20,
                squeeze: 1.2,
                selectionOverlay: null,
                onSelectedItemChanged: (index) {
                  // 일 변경
                  _selectedDateTime = _selectedDateTime.copyWith(
                    day: _dayList[index],
                  );

                  // 선택된 날짜와 시간 반환
                  widget.onChangeDate(_selectedDateTime);
                },
                children: _dayList.map((day) {
                  return Center(child: AppText(text: day, fontSize: 20));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
