import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/data/services/notification/notification_service.dart';
import 'package:with_calendar/domain/entities/display_mode/display_mode.dart';
import 'package:with_calendar/domain/entities/notification/schedule_notification.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/dialog/dialog_service.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/dialog/app_dialog.dart';
import 'package:with_calendar/presentation/design_system/component/view/empty_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/error_view.dart';
import 'package:with_calendar/presentation/design_system/component/view/loading_view.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_color.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/provider/display_mode/display_mode_provider.dart';
import 'package:with_calendar/presentation/screens/tab/menu/display_mode/display_mode_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/display_mode/widgets/display_mode_item.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/notification_list_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/menu/notification_list/widgets/notification_item.dart';

class DisplayModeScreen extends BaseScreen with DisplayModeEvent {
  const DisplayModeScreen({super.key});

  ///
  /// Init
  ///
  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  ///
  /// 앱 바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '화면 모드',
      backgroundColor: context.backgroundColor,
    );
  }

  ///
  /// 본문
  ///
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(DisplayModeState.displayModeProvider);

    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 30),
      itemCount: DisplayMode.values.length,
      itemBuilder: (context, index) {
        final displayMode = DisplayMode.values[index];
        final isSelected = displayMode == currentMode;
        return DisplayModeItem(
          mode: displayMode,
          isSelected: isSelected,
          onTapped: () {
            updateDisplayMode(ref, displayMode);
          },
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }
}
