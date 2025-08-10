import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/presentation/common/base/base_screen.dart';
import 'package:with_calendar/presentation/common/services/app_size/app_size.dart';
import 'package:with_calendar/presentation/design_system/component/button/app_button.dart';
import 'package:with_calendar/presentation/design_system/component/textfield/app_textfield.dart';
import 'package:with_calendar/presentation/screens/tab/memo/create/widgets/color_picker_button.dart';
import 'package:with_calendar/presentation/screens/tab/memo/update/update_memo_screen_event.dart';
import 'package:with_calendar/presentation/screens/tab/memo/update/update_memo_screen_state.dart';
import 'package:with_calendar/utils/extensions/string_summarization.dart';
import '../../../../../domain/entities/memo/memo.dart';
import '../../../../design_system/component/app_bar/app_bar.dart';
import '../../../../design_system/component/bottom_sheet/color_picker_bottom_sheet.dart';
import '../../../../design_system/component/text/app_text.dart';
import '../../../../design_system/foundation/app_color.dart';

class UpdateMemoScreen extends BaseScreen with UpdateMemoScreenEvent {
  UpdateMemoScreen({super.key, required this.memo});

  final Memo memo;

  @override
  void onInit(WidgetRef ref) {
    super.onInit(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateMemo(ref, memo);
    });
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 15),
          _buildMemoTextField(ref),
          const SizedBox(height: 16),
          _buildCompletionButton(ref),
        ],
      ),
    );
  }

  ///
  /// 배경색
  ///
  @override
  Color? get backgroundColor => const Color(0xFFF2F2F7);

  ///
  /// 앱바
  ///
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    print('앱바 다시 렌더링');

    return DefaultAppBar(
      title: memo.content.summaryTitle,
      backgroundColor: const Color(0xFFF2F2F7),
      actions: [_buildColorPickerButton(ref), const SizedBox(width: 16)],
    );
  }

  ///
  /// 핀 색상 선택 버튼
  ///
  Widget _buildColorPickerButton(WidgetRef ref) {
    final isPinned = ref.watch(
      UpdateMemoScreenState.memoProvider.select((value) => value.isPinned),
    );

    final pinColor = ref.watch(
      UpdateMemoScreenState.memoProvider.select((value) => value.pinColor),
    );

    return ColorPickerButton(
      isPinned: isPinned,
      onTapped: () {
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
  /// 메모 수정 텍스트 필드
  ///
  Widget _buildMemoTextField(WidgetRef ref) {
    return Expanded(
      child: AppTextField(
        initialValue: memo.content,
        placeholderText: '내용을 입력하세요',
        keyboardType: TextInputType.multiline,
        maxLines: null,
        backgroundColor: Colors.white,
        borderColor: Colors.transparent,
        onTextChanged: (content) {
          updateContent(ref, content);
        },
        onFocusChanged: (isFocused) {
          if (isFocused) {
            updateStarted(ref);
          }
        },
      ),
    );
  }

  ///
  /// 메모 수정 완료 버튼
  ///
  Widget _buildCompletionButton(WidgetRef ref) {
    final isStarted = ref.watch(UpdateMemoScreenState.isStartedProvider);
    final isValidate = ref.watch(UpdateMemoScreenState.isValidProvider);

    if (!isStarted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: AppSize.responsiveBottomInset),
      child: AppButton(
        isEnabled: isValidate,
        text: '수정하기',
        onTapped: () => update(ref),
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
