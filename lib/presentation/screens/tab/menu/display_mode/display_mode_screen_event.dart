import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_calendar/domain/entities/display_mode/display_mode.dart';
import 'package:with_calendar/presentation/provider/display_mode/display_mode_provider.dart';

mixin class DisplayModeEvent {
  void updateDisplayMode(WidgetRef ref, DisplayMode displayMode) {
    ref
        .read(DisplayModeState.displayModeProvider.notifier)
        .updateDisplayMode(displayMode);
  }
}
