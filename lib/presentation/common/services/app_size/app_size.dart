import 'package:flutter/material.dart';

class AppSize {
  AppSize._();

  static bool _isInitialized = false; // 초기화 상태 확인 변수
  static double deviceWidth = 0.0; // 디바이스 넓이
  static double deviceHeight = 0.0; // 디바이스 높이
  static double statusBarHeight = 0.0; // Safe Area 상단 Inset
  static double bottomInset = 0.0; // Safe Area 하단 Inset
  static double calendarHeight = 0.0; // Calendar 높이

  // 반응형 하단 Safe Area 하단 Inset
  static double get responsiveBottomInset =>
      bottomInset == 0.0 ? 16.0 : bottomInset;

  // Initialize
  static void init(BuildContext context) {
    if (_isInitialized) return;
    statusBarHeight = MediaQuery.paddingOf(context).top;
    bottomInset = MediaQuery.paddingOf(context).bottom;
    deviceWidth = MediaQuery.sizeOf(context).width;
    deviceHeight = MediaQuery.sizeOf(context).height;

    // 달력 높이 계산
    final tabBarHeight = 56;
    final containerPadding = 10 * 2;
    final headerArea = 55;
    final gap = 15;

    AppSize.calendarHeight =
        AppSize.deviceHeight -
        statusBarHeight -
        bottomInset -
        tabBarHeight -
        containerPadding -
        headerArea -
        gap;

    _isInitialized = true;
  }
}
