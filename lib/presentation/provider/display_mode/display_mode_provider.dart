import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/data/services/hive/hive_service.dart';
import 'package:with_calendar/domain/entities/display_mode/display_mode.dart';

/// DisplayMode Notifier
class DisplayModeNotifier extends Notifier<DisplayMode> {
  @override
  DisplayMode build() {
    // 초기값 설정
    final displayModeString = HiveService.instance.get<String>(
      HiveBoxPath.displayMode,
    );

    // 비어있을 경우 => 시스템 설정
    if (displayModeString == null) {
      return DisplayMode.system;
    }

    return DisplayMode.fromString(displayModeString);
  }

  /// 디스플레이 모드 변경
  void updateDisplayMode(DisplayMode mode) {
    state = mode;
    HiveService.instance.create(
      HiveBoxPath.displayMode,
      value: mode.displayText,
    );
  }

  ///
  /// 현재 선택된 모드 반환
  ///
  DisplayMode getDisplayMode() {
    return state;
  }
}

/// Provider 정의
abstract class DisplayModeState {
  static final displayModeProvider =
      NotifierProvider<DisplayModeNotifier, DisplayMode>(
        DisplayModeNotifier.new,
      );
}
