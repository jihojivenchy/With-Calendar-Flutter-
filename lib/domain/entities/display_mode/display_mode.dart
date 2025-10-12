import 'package:flutter/material.dart';

enum DisplayMode {
  light(displayText: '라이트 모드', themeMode: ThemeMode.light),
  dark(displayText: '다크 모드', themeMode: ThemeMode.dark),
  system(displayText: '시스템 설정 (자동)', themeMode: ThemeMode.system);

  final String displayText;
  final ThemeMode themeMode;
  const DisplayMode({required this.displayText, required this.themeMode});

  static DisplayMode fromString(String value) {
    return DisplayMode.values.firstWhere(
      (mode) => mode.displayText == value,
      orElse: () => DisplayMode.system,
    );
  }
}
