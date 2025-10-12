import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/domain/entities/memo/memo_creation.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/app_bar/app_bar.dart';
import 'package:with_calendar/presentation/design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/text/app_text.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/design_system/foundation/app_theme.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/create_memo_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/create_memo_screen_state.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/widgets/color_picker_button.dart';

class CreateMemoScreen extends BaseScreen with CreateMemoScreenEvent {
  CreateMemoScreen({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 15),
          _buildMemoTextField(ref),
          _buildCompletionButton(ref),
        ],
      ),
    );
  }

  ///
  /// 앱바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return DefaultAppBar(
      title: '메모 작성',
      backgroundColor: context.backgroundColor,
      actions: [_buildColorPickerButton(ref), const SizedBox(width: 16)],
    );
  }

  ///
  /// 핀 색상 선택 버튼
  ///
  Widget _buildColorPickerButton(WidgetRef ref) {
     // 고정 여부
    final isPinned = ref.watch(
      CreateMemoScreenState.memoProvider.select((value) => value.isPinned),
    );

    // 핀 색상
    final pinColor = ref.watch(
      CreateMemoScreenState.memoProvider.select((value) => value.pinColor),
    );

    return ColorPickerButton(
      isPinned: isPinned,
      onTapped: () {
        // 고정 상태 변경
        final newPinState = !isPinned;
        updatePinState(ref, isPinned: newPinState);

        // 핀 Color Picker 표시
        if (newPinState) {
          _showColorPickerBottomSheet(ref, pinColor);
        }
      },
      pinColor: pinColor,
    );
  }

  ///
  /// 메모 작성 텍스트 필드
  ///
  Widget _buildMemoTextField(WidgetRef ref) {
    return Expanded(
      child: AppTextField(
        autoFocus: true,
        placeholderText: '내용을 입력하세요',
        keyboardType: TextInputType.multiline,
        maxLines: null,
        backgroundColor: ref.context.surface,
        borderColor: Colors.transparent,
        onTextChanged: (content) {
          updateContent(ref, content);
        },
      ),
    );
  }

  ///
  /// 메모 작성 완료 버튼
  ///
  Widget _buildCompletionButton(WidgetRef ref) {
    final isValidate = ref.watch(CreateMemoScreenState.isValidProvider);

    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: AppSize.responsiveBottomInset),
      child: AppButton(
        isEnabled: isValidate,
        text: '완료',
        onTapped: () => create(ref),
      ),
    );
  }

  // ================================바텀 시트====================================
  ///
  /// 컬러 피커 바텀시트
  ///
  void _showColorPickerBottomSheet(WidgetRef ref, Color pinColor) {
    FocusScope.of(ref.context).unfocus();

    showModalBottomSheet(
      context: ref.context,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ColorPickerBottomSheet(
          selectedColor: pinColor,
          onColorSelected: (color) {
            ref.context.pop();
            updatePinState(ref, pinColor: color);
          },
        );
      },
    );
  }
}
