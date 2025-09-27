import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';

/// 캘린더 날짜 이동을 위한 바텀시트
class MonthPickerBottomSheet extends StatefulWidget {
  const MonthPickerBottomSheet({
    super.key,
    required this.focusedDate,
    required this.onChangeDate,
  });

  final DateTime focusedDate;
  final void Function(DateTime selectedDate) onChangeDate;

  @override
  State<MonthPickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<MonthPickerBottomSheet> {
  List<String> _yearList = [];
  List<String> _monthList = [];

  late String _selectedYear; // 년
  late String _selectedMonth; // 월

  FixedExtentScrollController? _yearPickerController;
  FixedExtentScrollController? _monthPickerController;

  @override
  void initState() {
    super.initState();
    // 년도 리스트 생성 (2000년부터 2050년까지)
    _yearList = List.generate(51, (index) => (2000 + index).toString());

    // 월 리스트 생성 (01-12)
    _monthList =
        List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));

    // 선택된 값을 설정
    _selectedYear = widget.focusedDate.year.toString();
    _selectedMonth = widget.focusedDate.month.toString();

    // 초기 스크롤 컨트롤러 설정
    _initScrollControllers();
  }

  @override
  void dispose() {
    _yearPickerController?.dispose();
    _monthPickerController?.dispose();
    super.dispose();
  }

  ///
  /// 컨트롤러 초기화
  ///
  void _initScrollControllers() {
    // 선택된 값의 인덱스 찾기
    final yearIndex = _yearList.indexOf(_selectedYear);
    final monthIndex = int.parse(_selectedMonth) - 1; // 월은 1부터 시작하므로 -1

    // 각 피커의 초기 위치를 설정하는 ScrollController
    _yearPickerController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : 0,
    );
    _monthPickerController = FixedExtentScrollController(
      initialItem: monthIndex >= 0 ? monthIndex : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 34,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF767676),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 250,
            height: 165,
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
                          _selectedYear = _yearList[index];
                        });
                      },
                      children: _yearList
                          .map(
                            (year) => Center(
                              child: AppText(
                                text: year,
                                fontSize: 20,
                                textColor: Colors.black,
                              ),
                            ),
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
                          _selectedMonth = _monthList[index];
                        });
                      },
                      children: _monthList.map((month) {
                        return Center(
                          child: AppText(
                            text: month,
                            fontSize: 20,
                            textColor: Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          AppButton(
            text: '확인',
            onTapped: () {
              context.pop();
              widget.onChangeDate(
                DateTime(
                  int.parse(_selectedYear),
                  int.parse(_selectedMonth),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}