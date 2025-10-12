import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';

abstract final class AppTheme {
  /// 라이트 테마 구성
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    extensions: const [
      ThemeColors(
        backgroundColor: Color(0xFFF2F2F7),
        textColor: Color(0xFF282C35),
        tabIconColor: Color(0xFF727577),
        textFieldBorderColor: Color(0xFFD2D5D7),
        disableBackgroundColor: Color(0xFFDADCDF),
        whiteAndBlack: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        surface2: Color(0xFFF7F7F7),
        surface3: Color(0xFFFFFFFF),
        surface4: Color(0xFFF7F7F7),
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFF2F2F7),
      foregroundColor: Color(0xFF282C35),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // 기타 설정
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.transparent,
      selectionColor: AppColors.gray200,
    ),
    fontFamily: 'Pretendard',
  );

  /// 다크 테마 구성
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    extensions: const [
      ThemeColors(
        backgroundColor: Color(0xFF000000),
        textColor: Color(0xFFFFFFFF),
        tabIconColor: Color(0xFF9FA8B6),
        textFieldBorderColor: Color(0xFF48484A),
        disableBackgroundColor: Color(0xFF3C3C3E),
        whiteAndBlack: Color(0xFF000000),
        surface: Color(0xFF1E1E1E),
        surface2: Color(0xFF2C2C2E),
        surface3: Color(0xFF2C2C2E),
        surface4: Color(0xFF3C3C3E),
      ),
    ],

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF000000),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // 기타 설정
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.transparent,
      selectionColor: AppColors.gray200,
    ),
    fontFamily: 'Pretendard',
  );
}

///
/// 테마 컬러
///
class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color backgroundColor;
  final Color textColor;
  final Color tabIconColor;
  final Color textFieldBorderColor;
  final Color disableBackgroundColor;

  final Color whiteAndBlack;

  final Color surface; // 화이트 And 블랙 레이어 1
  final Color surface2; // 화이트 레이어 2 And 블랙 레이어 2
  final Color surface3; // 화이트 And 블랙 레이어 2
  final Color surface4; // 화이트 레이어 2 And 블랙 레이어 3

  const ThemeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.tabIconColor,
    required this.textFieldBorderColor,
    required this.disableBackgroundColor,
    required this.whiteAndBlack,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.surface4,
  });

  @override
  ThemeColors copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? tabIconColor,
    Color? textFieldBorderColor,
    Color? disableBackgroundColor,
    Color? whiteAndBlack,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? surface4,
  }) {
    return ThemeColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      tabIconColor: tabIconColor ?? this.tabIconColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      disableBackgroundColor:
          disableBackgroundColor ?? this.disableBackgroundColor,
      whiteAndBlack: whiteAndBlack ?? this.whiteAndBlack,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      surface4: surface4 ?? this.surface4,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) {
      return this;
    }
    return ThemeColors(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      tabIconColor: Color.lerp(tabIconColor, other.tabIconColor, t)!,
      textFieldBorderColor: Color.lerp(
        textFieldBorderColor,
        other.textFieldBorderColor,
        t,
      )!,
      disableBackgroundColor: Color.lerp(
        disableBackgroundColor,
        other.disableBackgroundColor,
        t,
      )!,
      whiteAndBlack: Color.lerp(whiteAndBlack, other.whiteAndBlack, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      surface4: Color.lerp(surface4, other.surface4, t)!,
    );
  }
}

///
/// 테마 컬러를 컨텍스트에서 쉽게 사용할 수 있도록
///
extension ThemeColorsExtension on BuildContext {
  ThemeColors get appColors => Theme.of(this).extension<ThemeColors>()!;

  Color get backgroundColor => appColors.backgroundColor;
  Color get textColor => appColors.textColor;
  Color get tabIconColor => appColors.tabIconColor;
  Color get textFieldBorderColor => appColors.textFieldBorderColor;
  Color get disableBackgroundColor => appColors.disableBackgroundColor;
  Color get whiteAndBlack => appColors.whiteAndBlack;
  Color get surface => appColors.surface;
  Color get surface2 => appColors.surface2;
  Color get surface3 => appColors.surface3;
  Color get surface4 => appColors.surface4;
}

// 화이트 컬러 베이스
// white: Color(0xFFFFFFFF),      // 베이스
// whiteLayer1: Color(0xFFF2F2F7),    // 레이어 1
// whiteLayer2: Color(0xFFF7F7F7),    // 레이어 2

// 블랙 컬러 베이스
// black: Color(0xFF000000),      // 베이스
// blackLayer1: Color(0xFF1E1E1E),    // 레이어 1
// blackLayer2: Color(0xFF2C2C2E),    // 레이어 2
// blackLayer3: Color(0xFF3C3C3E),    // 레이어 3

